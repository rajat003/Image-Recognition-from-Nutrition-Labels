
function imgdata = process_match_file(tesseract_output_file, output_folder, imgnamebase)

    % Options:
    DISPLAY_OUTPUT = false;
    DISPLAY_TIMING = false;
    USE_EXTENDED_DICT = false;
    % Use extended dictionary to get more information than just the main
    % labels included in the validation set. Extended dict includes items
    % like Vitamin A, Folic Acid, Insoluble Fiber, etc. See
    % nutrition_dictionary() for more.

    fid = fopen(tesseract_output_file, 'r');
    if (fid == -1)
        error('Error reading file.'); 
    end

    % Don't include any token match with a larger (worse) score than
    % the following threshold:
    score_threshold = 0.65;  
    imgdata.('Image') = imgnamebase; % new structure to hold facts data
    
%   addpath('helper_fns');
    [no_vals, no_pcts, just_numbers, gmg, DV] = get_daily_values();
        % no_vals are lines that are not associated with numbers (ex: % DV)
        % no_pcts line items do not require % DV numbers on the label
        % just_numbers are lines like Calories (no 'g' or '%')
        % gmg tells if grams or milligrams expected
        % DV gives 100% amount in grams or milligrams
    DV_charset = '.0123456789mg%';
    dict = nutrition_dictionary(USE_EXTENDED_DICT);

    % Forced Token Matching and Value Rectification
    resultsfile = [output_folder, 'out_processed.txt'];
    system(['rm -f ', resultsfile]);
    spacer = '..........';
    
    line = get_next_line(fid);
    while ~isempty(line)
        
        tesseract_input = line;

        % Find Dictionary Match
        if DISPLAY_TIMING
            tic;
        end
        [match, score, ind] = get_best_match(line, dict);
        if DISPLAY_TIMING
            disp(['get_best_match took ', num2str(toc), 's']);
        end
        
        % Helpful to see tokens that get refected for being too low of scores
%         if DISPLAY_OUTPUT
%             disp(['Tesseract Input: ', line])
%             disp(['Best Match: ', match])
%             disp(['Score: ', num2str(score)])
%         end

        % Stop Tokens. Stop reading in lines after these is detected.
        if (strcmp(match, '* Percent Daily Values') || strcmp(match, 'Prepared As Directed'))
            if DISPLAY_OUTPUT
                disp(['Read ', match, ' stop token. BREAK.'])
            end
            break;
        end

        if score > score_threshold % does not pass filter.
            line = get_next_line(fid);
            continue;
        end
        confidence = get_confidence(score, score_threshold); % 'LOW', 'MEDIUM', or 'HIGH'   
        remainder = line(ind+1:end); % changed from ind:end
        
        % Remove match from dictionary
        dict(strcmp(dict, match)) = ''; % remove match from dict
        
        % Rectify common pseudonyms
        if strcmp(match, 'Total Carb')
            match = 'Total Carbohydrate';
            dict(strcmp(dict, match)) = '';
        else if strcmp(match, 'Fiber')
                match = 'Dietary Fiber';
                dict(strcmp(dict, match)) = '';
            end
        end
        match_token = regexprep(match,'[^\w]',''); % remove whitespace 

        if DISPLAY_OUTPUT
            disp(['Best Match: ', match])
            disp(['Confidence: ', confidence])
            disp(['Remainder: ', remainder])
        end
        
        % Treat Remainder
        values = {};
        val1 = -1;
        if ~isempty(remainder)

            % name 'line' as a rectified version of the 'remainder'
            line = remainder;
            line(line=='o') = '0';
            line(line=='O') = '0';
            % remove any non-DV_charset letters:
            line = regexprep(line,['[^', DV_charset, ']'],'');
            
            % Scan through for ####{(m)g}####{%}
            try
                units = gmg.(match_token);
                unitslen = length(units);

                % look for g / mg values.
                idx = strfind(line, units);
                if isempty(idx)
                    if strcmp(units, 'g')
                        idx = strfind(line, '9');
                    else % units is 'mg'
                        idx = strfind(line, 'm');
                        unitslen = 1;
                    end
                end
                if ~isempty(idx)
                    % Find 'g' or 'mg' values (val1)
                    val1 = get_clean_value(line, idx(1));
                    values{1} = [num2str(val1), units]; % ex: 45mg
                    line = line(idx(1)+unitslen:end); % next remainder, ex: 15%19%
                    
                    % Now look for DV % values (val2) if we expect them
                    if isempty(strmatch(match_token, no_pcts, 'exact'))
                        try
                            max_dv = DV.(match_token);
                        catch
                            display(['>>> TODO: Add ', match, ' to DV Table!']);
                            break;
                        end

                        expected_val2 = round(100 * val1 / max_dv);

                        idx = strfind(line, '%');
                        if isempty(idx)
                            % Percent not found in line. Set val2 to expected
                            % DV val2 based on above calculation.
                            val2 = expected_val2;
                            values{2} = [num2str(val2), '%'];
                        else
                            % Read % value straight from image.
                            val2 = get_clean_value(line, idx(1)); % clean values.

                            % Now we have two values: grams and percent.
                            % Here we reconcile any differences between
                            % val1/val2 and expected relationship.
                            if expected_val2 ~= val2
                                if DISPLAY_OUTPUT
                                    display('Values in disagreement!!');
                                end
                                if expected_val2 > 50 % flag greater than 50%
                                    % consider the pct as valid (fix val1)
                                    if DISPLAY_OUTPUT
                                        disp(['***Rectifying val1 from ', num2str(val1)])
                                    end
                                    val1 = round(val2 / 100 * max_dv);
                                    values{1} = [num2str(val1), units];
                                else
                                    % consider the grams as valid (fix val2)
                                    if DISPLAY_OUTPUT
                                        disp(['***Rectifying val2 from ', num2str(val2)])
                                    end
                                    val2 = expected_val2;
                                end
                            end
                        end
                        values{2} = [num2str(val2), '%'];
                    end
                end
            catch
                % Line item has no expected 'g' or 'mg' value for this token.
                % ex: Vitamins and Calories and also % Daily Value*
                if ~isempty(strmatch(match_token, just_numbers, 'exact'))
                    % ex: Calories

                    % Just grabs the next token. No validation possible.
                    if ~isempty(remainder)
                        words = textscan(remainder, '%s');
                        words = words{1};
                        for w = 1:length(words)
                            num = words{w}; % num is a str
                            if ~isnan(str2double(num))
                                val1 = str2double(num);
                                values{1} = num2str(get_clean_value(num));
                                break;
                            end
                        end
                    end
                else
                    if isempty(strmatch(match_token, no_vals, 'exact'))
                        % ex: Vitamins (just %ages)
                        idx = strfind(line, '%');
                        if ~isempty(idx)
                            val2 = get_clean_value(line, idx(1));
                            values{2} = [num2str(val2), '%'];
                        end
                    end
                end
            end

        end

        % Display and Output to File if Match with Values (where appropriate)
        if ~isempty(strmatch(match_token, no_vals, 'exact'))
             display_and_output(tesseract_input, match, resultsfile, spacer, confidence);     
        else
            val_str = '';
            for v = 1:length(values)
                val_str = [val_str, values{v}, ' '];
            end
            if ~isempty(val_str)
                % Add labels data to struct for csv.
                if ~isempty(strmatch(match_token, csv_labels(), 'exact'))
                    imgdata.(match_token) = val1;
                end
                display_and_output(tesseract_input, [match, ' ', val_str], resultsfile, spacer, confidence);            
            end
        end

        % Get next line
        if strcmp(forcematch(remainder, dict), levmatch(remainder))
            line = remainder;
        else
            line = get_next_line(fid);
        end
    end 

    fclose(fid);
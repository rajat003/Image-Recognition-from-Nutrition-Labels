
function outdata = naive_match_file(tesseract_output_file, output_folder, imgnamebase)

    % Options:
    USE_EXTENDED_DICT = false;
    
    % Raw Token Matching
    resultsfile = [output_folder, 'out_naive.txt'];
    system(['rm -f ', resultsfile]);
    spacer = '..........';

    fid = fopen(tesseract_output_file, 'r');
    if (fid == -1)
        error('Error reading file.'); 
    end

    % Define a structure to hold results data.
    outdata.('Image') = imgnamebase;
    
    line = get_next_line(fid);
    while ~isempty(line)

        tesseract_input = line;

        % Stop Token. Stop reading in lines after this is detected.
        if ~isempty(strfind(line, 'Vitamin')) || ~isempty(strfind(line, '* Percent Daily Values'))
            break;
        end

        % Find Raw Match
        tokens = nutrition_dictionary(USE_EXTENDED_DICT);
        for n = 1:length(tokens)
            token = tokens{n};
            match_ind = strfind(line, token);
            if isempty(match_ind)
                continue;
            end
            
            % Find numeric value from remainder
            remainder = textscan(line(match_ind+length(token):end), '%s');
            if isempty(remainder) || isempty(remainder{1})
                continue;
            end
            remainder = remainder{1};
            
            value = remainder{1};
            value(isletter(value)) = '';
            % ^^ note that allows for a bit of g/mg/extraneous char ambiguity
            value = str2double(value);
            if isnan(value)
                continue;
            end
            
            match_token = regexprep(token,'[^\w]',''); % remove whitespace
            outdata.(match_token) = value;
            
            display_and_output(tesseract_input, [token, ' ', num2str(value)]);
            break;
        end

        % Get next line
        line = get_next_line(fid);
    end
    fclose(fid);
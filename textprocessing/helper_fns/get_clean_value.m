
% Extract out_val from line(1:exclusive_end) and clean out_val for use as
% Nutrition Facts line remainder.

function out_val = get_clean_value(line, exclusive_end)

    if nargin > 1
        out_val = line(1:exclusive_end-1);
    else
        out_val = line;
    end
    
    % if out_val is blank, a g, or a %, replace with '0'
    if isempty(out_val)
        out_val = '0';
    else
        % Replace common digit/character mixups
        zero_chars = 'g%oO';
        one_chars = 'i';
        
        for z = 1:length(zero_chars)
            out_val(out_val==zero_chars(z)) = '0';
        end
        for o = 1:length(one_chars)
            out_val(out_val==one_chars(o)) = '1';
        end
    end
    out_val(isletter(out_val)) = ''; % remove extraneous letters
            
    % Remove leading zeros from numbers
    out_val = str2double(out_val);
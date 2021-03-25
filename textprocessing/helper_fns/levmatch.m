
% [best_match, min_dist] = levmatch(text) returns the closest match in the
% Nutrition Facts dictionary and the min Levenshtein distance between
% the input TEXT and output BEST_MATCH. Returns original text if no best
% match is found.

function [best_match, min_dist] = levmatch(text)

    % Reference words/phrases expected to occur in tesseract output:
    lines = nutrition_dictionary();
    
    threshold = length(text);
    % ^^ if no match can be found with fewer than "threshold" number of
    % errors, simply return the original text, UNLESS force_match is true.
    
    min_dist = threshold-1;
    best_match = text;
    for n = 1:length(lines)
        
        line = lines{n};
        line(line==' ')=''; % remove whitespace
        
        dist = strdist(text, line);
        if dist < min_dist
            best_match = lines{n};
            min_dist = dist;
        end
        if min_dist == 0
            break;
        end
    end

% [best_match, pct_dist] = forcematch(text, dict) returns the closest match
% in the Nutrition Facts dictionary (optionally specified by 'dict') and
% the % of the Levenshtein distance between the input TEXT and output
% BEST_MATCH, and the length of the input TEXT.
% Input param REMOVE_WHITESPACE is high by default, and removes whitespace
% from the input text (and dictionary matches) to calculate best match.

function [best_match, best_pct_dist] = forcematch(text, dict, remove_whitespace)

    if nargin < 2
        dict = nutrition_dictionary();
    end
    if nargin < 3
        remove_whitespace = 1;
    end

    best_pct_dist = Inf;
    best_match = 'No match.';

    for n = 1:length(dict)
        
        line = dict{n};
        
        if remove_whitespace
            text(text==' ')=''; % remove whitespace
            line(line==' ')=''; % remove whitespace
        end
        
        pct_dist = strdist(text, line) / length(text);
        if pct_dist < best_pct_dist
            best_match = dict{n};
            best_pct_dist = pct_dist;
        end
        if best_pct_dist == 0
            break;
        end
    end
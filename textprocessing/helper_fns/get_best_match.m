    
function [best_match, best_score, best_ind] = get_best_match(line, dict)

    if nargin < 2
        dict = nutrition_dictionary();
    end
    
    best_score = Inf;
    best_match = '';
    best_ind = Inf;
    % ^^ Index at which our phrase ends (and where our ## info begins)
    
    maxlen = 35;
    for ind = min(length(line),maxlen):-1:1
        [match, score] = forcematch(line(1:ind), dict, 0); % don't rm whitespace
        if score < best_score
            best_ind = ind;
            best_score = score;
            best_match = match;
        end
        if (best_score == 0) %< 0.1)
            break;
        end
    end
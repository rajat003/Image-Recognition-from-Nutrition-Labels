
% Takes a numeric score and returns qualitative confidence

function confidence = get_confidence(score, score_threshold)

    if score > 2*score_threshold/3
        confidence = 'LOW';
    else if score > score_threshold/3
            confidence = 'MEDIUM';
        else
            confidence = 'HIGH';
        end
    end
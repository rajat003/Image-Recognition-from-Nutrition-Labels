
function err_rate = compute_error_rate(testdata, excludeErr, excludeNaN)

    % Compute error rate based off of labeled data
    realdata = csvread('real.csv', 1, 0);
    
    % Count NaNs as matches (the absence of false positives)
    if nargin < 3 || ~excludeNaN
        disp('Counting NaNs as 0s')
        realdata(realdata == -1) = 0;
        testdata(testdata == -1) = 0;
    else
        disp('Counting NaNs as -1s')
    end
    
    % Exclude "error" cases from both
    if nargin < 2 || excludeErr
        load('img_desc.mat');
        fail_cols = 1; %[1 3 5 6];
        % ^^ may choose to exclude other images to compare failure rates
        exclusion_mask = img_desc.labels(:,fail_cols);
        exclusion_mask = (sum(exclusion_mask, 2) > 0);
        realdata(exclusion_mask,:) = -2;
    end
    
    % Find image indices of testdata in realdata
    test_idx = ismember(testdata(:,1), realdata(:,1));
    real_idx = ismember(realdata(:,1), testdata(:,1));

    num_err = sum(sum(abs(testdata(test_idx,2:end) - realdata(real_idx,2:end)) > 0.5));
    total = numel(testdata(test_idx,2:end));
    err_rate = num_err / total;
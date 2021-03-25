
function data = run_text_matching(segments_folder, imgname, RUN_TEXT_PROCESSING, issegmented, reverse)

    addpath(segments_folder);

    if nargin < 5
        reverse = 0;
    end
    RUN_TESSERACT = true;
    % ^^ Set to false if you already have out_raw_####.txt files generated
    
    if RUN_TESSERACT
        disp('Running Tesseract');
        tess_tic = tic;
        [folder, file] = run_tesseract(segments_folder, imgname, ...
            'out_raw.txt', issegmented, reverse);
        fprintf('Tesseract elapsed %.1fs\n\n', toc(tess_tic));
    else
        folder = segments_folder;
        file = 'out_raw.txt';
    end
    
    % Run Text Processing
    text_tic = tic;
    if (RUN_TEXT_PROCESSING)
        disp('Matching Tokens by Levenshtein Distance');
        data = process_match_file(file, folder, imgname(1:end-4));
        fprintf('Levenshtein Token Matching elapsed %.1fs\n\n', toc(text_tic));
    else
        disp('Matching Tokens by Naive String Matching');
        data = naive_match_file(file, folder, imgname(1:end-4));
        fprintf('Naive Token Matching elapsed %.1fs\n\n', toc(text_tic));
    end

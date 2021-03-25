
function facts = analyze_text(segments_folder, imgname, RUN_PHOTO_PROCESSING, RUN_TEXT_PROCESSING)

    if nargin < 3
        RUN_PHOTO_PROCESSING = 1;
    end
    if nargin < 4
        RUN_TEXT_PROCESSING = 1;
    end
    if (segments_folder(end) ~= '/')
        segments_folder = [segments_folder, '/'];
    end

    % Call OCR (Tesseract) and Text Matching
    facts = run_text_matching(segments_folder, imgname, ...
        RUN_TEXT_PROCESSING, RUN_PHOTO_PROCESSING);

    % Rotate 180 degrees and run again if no matches found.
    if length(fieldnames(facts)) < 2 % if only 'img_ind' recorded
        display('No matches found. Rotating all images.')
        if (RUN_PHOTO_PROCESSING) % issegmented
            Dt = dir(segments_folder); 
            for n = 1:numel(Dt)
                name = lower(Dt(n).name);
                if numel(name) >= 4 && strcmp(name(end-3:end),'.png')
                    ind = str2double(name(1:end-4));
                    imgname = [segments_folder, name];
                    img = imread(imgname);
                    img = rot90(rot90(img));
                    imwrite(img, imgname);
                end
            end
        else
            full_imgname = [segments_folder, imgname];
            img = imread(full_imgname);
            img = imrotate(img, 180);
            imwrite(img, full_imgname);
        end

        % Run again in reverse order
        facts = run_text_matching(segments_folder, imgname, ...
            RUN_TEXT_PROCESSING, RUN_PHOTO_PROCESSING, 1); 
    end

function write_csv_data(data, csv_filename)

    if length(data) == 1
        data = {data};
    end
    
    % Output data to csv.
    labels = csv_labels();
    numImgs = sum(~cellfun(@isempty, data));
    table = zeros(numImgs, numel(labels));
    for n = 1:numImgs
        img_name = data{n}.('Image');
        img_num = str2double(img_name(5:end));
        table(n, 1) = img_num;
        for m = 1:numel(labels)
            try
                cellval = data{n}.(labels{m});
            catch
                cellval = -1;
            end
            table(n, m+1) = cellval;
        end
    end
    csvwrite(csv_filename, table);
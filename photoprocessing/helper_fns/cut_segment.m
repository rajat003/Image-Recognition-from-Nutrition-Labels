function lines = cut_segment(img)

% Horizontally cuts each text image for further segmentation.
%
% Input:
% IMG: Binary input image

min_height = 10;

iswhite = ~(sum(~img,2) > 0);
d = diff(iswhite);
ind = find(d ~= 0);

if all(~iswhite)
    lines = {trim_img(img)};
    return;
end

h = size(img,1);
n = numel(ind);
lines = cell(1,n+1);

prev_row = 1; %Keep track of current row
count = 0;
for i = 1:n
    row = ind(i) + 1;
    if d(row-1) == 1 && row > prev_row + min_height
        line = img(prev_row:row-1,:);
        trim_img(line);
        count = count + 1;
        lines{count} = line;
    end
    prev_row = row;
end

if prev_row < h - min_height
    line = img(prev_row:h,:);
    if any(~line)
        count = count + 1;
        lines{count + 1} = trim_img(line);
    end
end

lines = lines(~cellfun('isempty',lines));

end
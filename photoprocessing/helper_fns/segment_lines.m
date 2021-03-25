function lines = segment_lines(img,mask,angleThresh)

% Segments out text lines given the original image and a binary mask of the
% nutrition facts label. 
%
% Input:
% IMG: Original grayscale image
% MASK: Binary mask of nutrition facts label lines
% ANGLETHRESH: Angle threshold for region orientation filtering noise
% removal

max_iters = 1000;
lines = cell(1,1000);

props = regionprops(mask,'BoundingBox');
n = numel(props);
[h,w] = size(mask);
ytop = zeros(1,n);
ybottom = zeros(1,n);
xleft = zeros(1,n);
xright = zeros(1,n);
for i = 1:n
    box = props(i).BoundingBox;
    ytop(i) = max(floor(box(2)),1);
    ybottom(i) = min(ceil(box(2)+box(4)),h);
    xleft(i) = max(floor(box(1)),1);
    xright(i) = min(ceil(box(1)+box(3)),w);
end
ytop = sort(ytop);
ybottom = sort(ybottom);

x1 = max(1,min(xleft));
x2 = min(w,max(xright));

n = numel(ytop);
i1 = 1;
i2 = 2;
y2 = 0;
min_height = median(diff(sort([ytop,ybottom])));
count = 0;
for iter = 1:max_iters
    if ~(i1 <= n-1 && i2 <= n)
        break;
    end
    y1 = ybottom(i1);
    while y1 < y2
        i1 = i1 + 1;
        if i1 > n-1
            break;
        end
        y1 = ybottom(i1);
    end
    y2 = ytop(i2);
    while y2-y1 < min_height
        i2 = i2+1;
        if i2 > n
            break
        end
        y2 = ytop(i2);
    end
    if i1 > n-1 || i2 > n
        break;
    end
    
    line = img(y1:y2,x1:x2);
    line = im2bw(line,graythresh(line));
    
    %Filter out noise based on orientation and size
    line1 = filterbyproperty(~line,'Orientation',angleThresh,1);
    line2 = filterbyproperty(~line,'Orientation',-angleThresh,0);
    line3 = or(line1,line2);
    %K-means size threshold
    areas = cell2mat(struct2cell(regionprops(~line,'Area')));
    if numel(areas) >= 3
        [labels,means] = kmeans(areas,3,'emptyaction','singleton');
        c = find(means == min(means));
        areas(labels ~= c) = [];
        tol = max(areas);
        line4 = filterbyproperty(~line,'Area',tol,1);
        line = ~or(line3,line4);
    else
        line = ~line3;
    end
    
    %Close for noise removal
    W = strel('diamond',1);
    line = imclose(line,W);
    
    %Cut regions
    subregions = cut_segment(line);
    for k = 1:numel(subregions)
        count = count + 1;
        lines{count} = subregions{k};
    end
end
nSegments = count;

%Cut again
lines2 = cell(1,1000);
count = 0;
for i = 1:nSegments
    line = lines{i};
    subregions = cut_segment(line);
    for j = 1:numel(subregions)
        count = count + 1;
        lines2{count} = subregions{j};
    end
end

lines = lines2(~cellfun('isempty',lines2));

end
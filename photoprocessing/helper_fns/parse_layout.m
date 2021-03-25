function lines = parse_layout(img,display,shortPause,longPause)

% Localizes the nutrition facts section of an image by identifying the
% parallel lines separating the nutrition facts text. Non-nutrition facts
% parts of the input image are sequentially filtered out, and the correct
% orientation is detected via a Hough transform.
%
% Input:
% IMG: Original binary image
% DISPLAY: Logical 1 to display progress and 0 to suppress (default 0)
% SHORTPAUSE: Short pause time if display is on
% LONGPAUSE: Long pause time if display is on
%
% Output:
% LINES: Cell of segemented nutrition facts text line images

switch nargin
    case 1
        display = 0;
        longPause = 1;
        shortPause = 0.3;
    case 2
        longPause = 1;
        shortPause = 0.3;
    case 3
        shortPause = 0.3;
end

warning('off','all');

%Problem data
orig = img;
img = rgb2gray(img); %Convert color image to grayscale
img = medfilt2(img); %Median filtering
img = adapthisteq(img,'NumTiles',[32 32]); %Adaptive histogram equalization
if display
    figure(1); imshow(img);
    title(['Original Image with Median Filtering '...
        'and Adaptive Histogram Equalization']);
    pause(longPause);
end

eccThresh = 0.98;
angleThresh = 15;

%Locally adaptive thresholding
nX = 16;
nY = 16;
tol = 0.3;
bw = adaptivethreshold(1-img,nX,nY,tol);
if display
    figure(1); imshow(bw,'InitialMagnification',50);
    title('Locally Adaptive Thresholding');
    pause(shortPause);
end

%Filter out small area regions
[A,areas] = filterbyproperty(bw,'Area',-Inf,1,200);
max_area = 10*areas(10);
A = filterbyproperty(A,'Area',max_area,0);
if display
    figure(1); plotcentroids(A,50);
    title('Filter Small Regions');
    pause(longPause);
end
if all(~A)
    lines = {};
    return;
end

%Filter by eccentricity
B = filterbyproperty(A,'eccentricity',eccThresh,1);
if display
    figure(1); plotcentroids(B,50);
    title('Filter by Eccentricity');
    pause(longPause);
end
if all(~B)
    lines = {};
    return;
end

%Filter by orientation
orient = cell2mat(struct2cell(regionprops(B,'Orientation')));

tol = 15;
buckets = zeros(1,181);
angles = -90:90;
for i = 1:180
    angle = angles(i);
    buckets(i) = sum(abs(orient-angle) <= tol) +...
        sum(abs(180-(orient-angle)) <= tol) +...
        sum(abs(180+(orient-angle)) <= tol);
end
[~,ind] = max(buckets);
best_angle = angles(ind);

labeled = bwlabel(B);
B1 = zeros(size(B));
ind = 1:numel(orient);
ind(~(abs(orient-best_angle) < tol | ...
            abs(180-(orient-best_angle)) < tol | ...
            abs(180+(orient-best_angle)) < tol)) = -1;
B1(ismember(labeled,ind)) = 1;
B = logical(B1);
if display
    figure(1); plotcentroids(B);
    title('Orientation Filtered');
    pause(longPause);
end
if all(~B)
    lines = {};
    return;
end

%Hough transform
[H,theta,rho] = hough(B,'Theta',-90:1:89.5);
if display
    imshow(imadjust(mat2gray(H)),'XData',theta,'YData',rho,...
        'InitialMagnification','fit'); %Display the Hough matrix
    hold on;
    title('Hough Transform');
    xlabel('\theta'), ylabel('\rho');
    axis on, axis normal, hold on;
    colormap(hot);
end

%Hough peaks
peaks = houghpeaks(H,20,'Threshold',0);
angles = theta(peaks(:,2)) + 90;
if display
    figure(1);
    plot(theta(peaks(:,2)),rho(peaks(:,1)),'s','color','green');
    hold off;
    pause(longPause);
end

%Filter orientations
tol = 15;
if mod(numel(angles),2) == 0
    angles = [angles(1),angles];
end
angles(abs(angles-median(angles)) > tol) = [];

%Rotate image
angle = 180 + median(angles);
C = imrotate(logical(B),angle);
C = logical(C);
if all(~C)
    lines = {};
    return;
end
rotated = imrotate(img,angle);
if display
    orig_rotated = imrotate(orig,angle);
    figure(1); plotcentroids(C); title('Rotated');
    figure(1); subplot(121);
    imshow(orig_rotated,'InitialMagnification','fit');
    title('Original Image Rotated'); pause(longPause);
end

%Perform Hough transform to clean up
D = imdilate(C,ones(3,1)); %Dilate to boost lines
peaks = sum(D,2);
[labels,centroids] = kmeans(peaks,5,'emptyaction','singleton');
class = find(centroids == min(centroids),1,'first');
D(labels == class,:) = 0;
D = logical(D);
if display
    figure(1); subplot(122); plotcentroids(D);
    title('Clean Up Using Hough Transform'); pause(longPause);
end
if all(~D)
    lines = {};
    return;
end

%Further filtering
D = filterbyproperty(D,'Eccentricity',eccThresh,1);
if display
    figure(1); plotcentroids(D);
    title('Filtering by Eccentricity'); pause(longPause);
end
lengths = cell2mat(struct2cell(regionprops(D,'MajorAxisLength')));
D = filterbyproperty(D,'MajorAxisLength',max(lengths)/10,1);
if display
    figure(1); plotcentroids(D);
    title('Filtering by Major Axis Length'); pause(longPause);
end
D1 = filterbyproperty(D,'Orientation',angleThresh,0);
D = filterbyproperty(D1,'Orientation',-angleThresh,1);
if display
    figure(1); plotcentroids(D);
    title('Filtering by Orientation'); pause(longPause);
end
if all(~D)
    lines = {};
    return;
end

%Filter sides
[h,w] = size(D);
labeled = bwlabel(D);
s = zeros(1,size(D,2));
for i = 1:w;
    s(i) = numel(unique(labeled(:,i)));
end
[labels,centroids] = kmeans(s,2,'emptyaction','singleton');
class = find(centroids == max(centroids),1,'first');
xmin = find(labels == class,1,'first');
xmax = find(labels == class,1,'last');
props = regionprops(D,'BoundingBox');
n = numel(props);
props = cell2mat(struct2cell(props));
bounding_boxes = reshape(props',4,n)';
D1 = [zeros(h,xmin-1),D(:,xmin:xmax),zeros(h,w-xmax)];
ind = zeros(1,n);
for i = 1:n
    midl = bounding_boxes(i,1) + (1/4)*bounding_boxes(i,3);
    midr = bounding_boxes(i,1) + (3/4)*bounding_boxes(i,3);
    if midl >= xmin && midr <= xmax
        ind(i) = i;
    end
end
ind(ind == 0) = [];
D1(ismember(labeled,ind)) = 1;
D = logical(D1);
if display
    figure(1); plotcentroids(D);
    title('Filter Sides'); pause(longPause);
end
if all(~D)
    lines = {};
    return;
end

%Close lines
[~,ulx] = find(D == 1,1,'first');
[~,uly] = find(D' == 1,1,'first');
[~,lrx] = find(D == 1,1,'last');
[~,lry] = find(D' == 1,1,'last');
box = D(uly:lry,ulx:lrx); %Detect overall bounding box
box = imclose(box,ones(1,floor((size(box,2)/2))));

%Replace with closed mask
closed = D;
closed(uly:lry,ulx:lrx) = box;

if display
    displayed = D;
    displayed(uly:lry,ulx:lrx) = imdilate(box,ones(5)); %Make more visible
    margin = 200;
    figure(1); subplot(121);
    imshow(orig_rotated(max(1,uly-margin):min(size(D,1),lry+margin),...
        max(1,ulx-margin):min(size(D,2),lrx+margin),:));
    title('Nutrition Facts Detected');
    figure(1); subplot(122); imshow(displayed);
    title('Lines Detected'); pause(2*longPause);
end

%Segment
lines = segment_lines(rotated,closed,angleThresh);
if display
    for i = 1:numel(lines)
        figure(1); imshow(lines{i},'InitialMagnification','fit');
        pause(shortPause);
    end
end

warning('on','all');
end
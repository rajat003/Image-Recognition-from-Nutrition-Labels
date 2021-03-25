function outputDirectory = analyze_image(filename,inputDirectory,writeToFile,...
    showDisplay,shortPause,longPause)

switch nargin
    case 0
        filename = '';
        inputDirectory = '';
        writeToFile = 1;
        showDisplay = 1;
        shortPause = 0.3;
        longPause = 1;
    case 2
        writeToFile = 1;
        showDisplay = 0;
        shortPause = 0.3;
        longPause = 1;
    case 3
        showDisplay = 0;
        shortPause = 0.3;
        longPause = 1;
    case 4
        shortPause = 0.3;
        longPause = 1;
    case 5
        longPause = 1;
end

if showDisplay
    figure(1); clf;
    set(figure(1),'units','normalized','outerposition',[0 0 1 1]);
end

tic;
img = im2double(imread([inputDirectory,'/',filename]));
filename = filename(1:end-4);
outputDirectory = [inputDirectory,'/output/',filename];

if showDisplay
    figure(1); clf;
    subplot(121); imshow(img,'InitialMagnification',20);
    title('Original Image');
    subplot(122); imshow(zeros(size(img)));
    for k = 1:3
        H = text(900,1200,'Processing Image');
        set(H,'fontsize',24,'color','w');
        pause(0.1);
        imshow(zeros(size(img))); pause(0.1);
    end
    lines = parse_layout(img,1,shortPause,longPause);
else
    lines = parse_layout(img,0,shortPause,longPause);
end

nSegments = numel(lines);
if showDisplay
    fprintf('Lines detected: %d\n',nSegments);
end

%If fewer than 2 lines detected, try again on the inverted color
%image
if nSegments <= 2
    if showDisplay
        disp('Inverting image...');
        subplot(121); imshow(1-img,'InitialMagnification',20);
        title('Original Image');
        subplot(122);
        lines_inv = parse_layout(1-img,1,shortPause,longPause);
    else
        lines_inv = parse_layout(1-img,0,shortPause,longPause);
    end
    nSegments_inv = numel(lines_inv);
    if nSegments_inv <= 2
        lines = {im2bw(img)};
        nSegments = 1;
    elseif nSegments_inv > nSegments
        lines = lines_inv;
        nSegments = nSegments_inv;
    end
    if showDisplay
        fprintf('Lines detected: %d\n',nSegments);
    end
end

if writeToFile
    
    for j = 1:nSegments
        if ~exist(outputDirectory,'dir')
            mkdir(outputDirectory);
        end
        imwrite(lines{j},[outputDirectory, '/',...
            sprintf('%.1d',j),'.png']);
    end
end
toc;
if ~showDisplay
    fprintf('Lines detected: %d\n\n',nSegments);
end
mypath = getenv('PATH');
if isempty(strfind(mypath, ':/opt/local/bin'))
    mypath = [mypath ':/opt/local/bin'];
    setenv('PATH', mypath);
end

images_folder = 'img/';

writeToFile = 1; 
showDisplay = 1; 
shortPause = 0.1;
longPause = 0.1; 

addpath('img');
addpath('photoprocessing');
addpath('photoprocessing/helper_fns');
addpath('textprocessing');
addpath('textprocessing/helper_fns');

D = dir(images_folder);
numImgs = 0;
for i = 1:numel(D)
    name = lower(D(i).name);
    
    % For each input image
    if numel(name) < 4 || ~strcmp(name(end-3:end),'.jpg')
        continue;
    end
    numImgs = numImgs + 1;
    imgname = D(i).name;
    
    disp(['Processing ',imgname,'...']);
    
    segments_folder = analyze_image(imgname,images_folder,writeToFile,showDisplay,shortPause,longPause);
    
    facts = analyze_text(segments_folder, imgname);
end

if numImgs ~= 1
    display([num2str(numImgs), ' Images Processed.'])
else
    display([num2str(numImgs), ' Image Processed.'])
end
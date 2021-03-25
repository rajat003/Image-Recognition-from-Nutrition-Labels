function plotcentroids(img,magnification,showbackground)

% Plots the region centroids overlaid on a binary image.
%
% Input:
% IMG: Original binary image
% MAGNIFICATION: Input for 'InitialMagnification' in imshow.m (default 100)
% SHOWBACKGROUND: 0 to turn off background (default 1)

if nargin <= 2
    showbackground = 1;
end

if nargin == 1
    magnification = 100;
end

s = regionprops(img,'centroid');
centroids = cat(1,s.Centroid);
imshow(zeros(size(img)),'InitialMagnification',magnification);
if showbackground
    imshow(img,'InitialMagnification',magnification);
end
hold on;
if numel(centroids) > 0
    plot(centroids(:,1),centroids(:,2),'b*');
end
hold off;

end
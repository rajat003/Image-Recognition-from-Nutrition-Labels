function [filtered,props,n] = filterbyproperty(img,property,threshold,inequality,N)

% Removes regions of a binary image according to property.
%
% Input:
% IMG: Original binary image
% PROPERTY: Property of regions to consider; must match regionprops.m input
% THRESHOLD: Threshold
% INEQUALITY: Input 0 for <, 1 for > (default 1)
% N: Maximum number of regions to keep; 'all' to consider all regions (default 'all')
%
% Output:
% FILTERED: Filtered image with regions removed.
% PROPS: Vector of sorted property values.
% n: Number of remaining regions

if ~islogical(img)
    error('Input image must be logical');
end

if nargin <= 2
    threshold = -Inf;
    inequality = 1;
end

if nargin <= 3 || ~any(inequality == [0,1])
    inequality = 1;
end

props = regionprops(img,property);
props = cell2mat(struct2cell(props));
img = bwlabel(img);

if nargin == 5 && ~strcmp(N,'all');
    N = max(round(N),1);
else
    N = numel(props);
end

filtered = zeros(size(img));
if inequality
    [props,ind] = sort(props,'descend');
    ind(props <= threshold) = -1;
else
    [props,ind] = sort(props,'ascend');
    ind(props >= threshold) = -1;
end
filtered(ismember(img,ind(1:N))) = 1;
filtered = logical(filtered);
n = sum(ind(1:N) >= 1);

end
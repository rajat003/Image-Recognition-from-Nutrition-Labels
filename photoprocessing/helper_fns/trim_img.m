function img = trim_img(img)

% Crops out black and white padding at the edges of img. Clutter of up to 5
% pixels on the left and right sides are also removed.
%
% Input:
% IMG: Binary input image

margin = 5;
w = size(img,2);

img(:,find(any(img,1),1,'last')+1:end) = [];
img(:,1:find(any(img,1),1,'first')-1) = [];
img(1:find(any(img',1),1,'first')-1,:) = [];
img(find(any(img',1),1,'last')+1:end,:) = [];

img(:,find(any(~img,1),1,'last')+1:end) = [];
img(:,1:find(any(~img,1),1,'first')-1) = [];
img(1:find(any(~img',1),1,'first')-1,:) = [];
img(find(any(~img',1),1,'last')+1:end,:) = [];

%Cut off thin borders left and right
iswhite = ~(sum(~img) > 0);

xl = find(iswhite,1,'first');
xr = find(iswhite,1,'last');
if xl <= margin
    img = img(:,xl+1:end);
end
if xr >= w-margin+1
    img = img(:,1:end-w+xr);
end

img(:,find(any(img,1),1,'last')+1:end) = [];
img(:,1:find(any(img,1),1,'first')-1) = [];
img(1:find(any(img',1),1,'first')-1,:) = [];
img(find(any(img',1),1,'last')+1:end,:) = [];

img(:,find(any(~img,1),1,'last')+1:end) = [];
img(:,1:find(any(~img,1),1,'first')-1) = [];
img(1:find(any(~img',1),1,'first')-1,:) = [];
img(find(any(~img',1),1,'last')+1:end,:) = [];

end
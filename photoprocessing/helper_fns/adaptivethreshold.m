function bw = adaptivethreshold(img,nX,nY,const_thresh)

% Implements adaptive grayscale thresholding based on Otsu's method. Blocks
% of size nY x nX are thresholded independently. If the maximum intensity
% variation within a block is below const_thresh, then all pixels within
% the block are set equal to zero.

bsX = floor(size(img,2)/nX);
bsY = floor(size(img,1)/nY);
for i = 1:nX
    for j = 1:nY
        %Subset out sliding window
        window = img((j-1)*bsY+1:min(end,j*bsY),...
            (i-1)*bsX+1:min(end,i*bsX));
        %Apply adaptive thresholding
        if max(range(window)) < const_thresh
            window = 0;
        else
            thresh = graythresh(window);
            window = im2bw(window,thresh);
        end
        %Replace original area with thresholded window
        img((j-1)*bsY+1:min(end,j*bsY),...
            (i-1)*bsX+1:min(end,i*bsX)) = window;
    end
end

bw = logical(img);

end
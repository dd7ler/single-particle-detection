function cropped = cropcircle(im, centroid, r)
%CROPCIRCLE crop a circular region from an image.
% 	cropped = CROPCIRCLE(im, centroid, r) returns a square image that
% 	circumscribes the circular region of the image IM centered at the [r,c]
% 	coordinates CENTROID with a radius R. The returned image is padded with
% 	the median value within the circular region. 

r = round(r);
centroid = round(centroid);
[rr, cc] = meshgrid(1:size(im,2), 1:size(im,1));
mask = logical(sqrt((rr-centroid(1)).^2+(cc-centroid(2)).^2)<=r);
c = ones(size(mask))*double(median(im(mask)));
c(mask) = im(mask);

sp = round(r/2);
c = padarray(c,[sp sp],median(im(mask)));
centroid = centroid+sp;

r_range = (centroid(2)-r):(centroid(2)+r)
%max(centroid(2)-r, 1):min(centroid(2)+r,size(im,1));
c_range = (centroid(1)-r):(centroid(1)+r)
%max(centroid(1)-r, 1):min(centroid(1)+r,size(im,2));
cropped = c(r_range, c_range);
% figure; imshow(cropped,[]);
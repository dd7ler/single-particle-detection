
function [centroid, r] = detectSpot(im, r_min, r_max)
% Detect a single spot in the image using the Hough transform. 
% centroid, r are the center and outer radius of the detected spot,
% respectively.
% im - image
% r_range - vector containing minimum and maximum radii. 

% -- Parameters --
% Using the Hough transform is much slower with large images.
resize_factor = .1;

% Percent of the perimeter required to be considered a 'hit'. The best
% 'hit' is returned, and there is no major computational punishment for
% keeping it low. 
perimeter_pct = .15; 

% Pad the image to accomodate large circles

% figure; imshow(im,[]);
% -- Image segmentation --
fr = imresize(im,resize_factor);
y = quantile(fr(:),[.85 .15]);
max_thresh = y(1);
min_thresh = y(2);
fr(fr>max_thresh) = max_thresh;
fr(fr<min_thresh) = min_thresh;
% figure; imshow(fr,[]);

fr = 256*(fr - min(fr(:)))/range(fr(:));    % Rescale
bw = edge(fr);                              % Edge detection

% figure; imshow(bw,[]);
bw = bwareaopen(bw,4);
disk = strel('disk',2);
bw = imdilate(bw,disk);                      % close edge
% figure; imshow(bw,[]);

% -- Circle detection --
padsize = round([r_max,r_max]*resize_factor/3);
bw = padarray(bw, padsize);
% figure; imshow(bw);
circles = houghcircles(bw,floor(r_min*resize_factor),floor(r_max*resize_factor),perimeter_pct);
[~,best] = max(circles(:,4));       % only select 1 circle (the best one)
circles = round(circles(best,:)/resize_factor);

centroid = [circles(1) circles(2)]-padsize/resize_factor;
r = circles(3);

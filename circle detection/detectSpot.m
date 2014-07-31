function [centroid, r] = detectSpot(im, r_min, r_max)
% DETECTSPOT Detect a single spot in an image using the Hough transform. 
% 	centroid, r are the center and outer radius of the detected spot,
% 	respectively. r_min and r_max are the minimum and maximum expected spot
% 	radii in pixels.
%
%	DETECTSPOT attempts to improve the spot visibility by rescaling the
%	image and blurring. These settings may not be optimal...
resize_factor = .15;
perimeter_pct = .2; 

im = imresize(im,resize_factor);
y = median(im(:))*[0.95 1.05];
im = imrescale(im, y(1), y(2), 2^8);
im = wiener2(im, [3 3]);
% figure; imshow(im,[])

circles = houghcircles(im,floor(r_min*resize_factor),floor(r_max*resize_factor),perimeter_pct);
[~,best] = max(circles(:,4));       % only select 1 circle (the best one)
circles = round(circles(best,:)/resize_factor);
centroid = [circles(1) circles(2)];
r = circles(3);
function plotCircle(im, centroid, r)
% plot a circle on an image in a MATLAB figure.
% PLOTCIRCLE(im, centroid, r) plots a red circle in im, in red.

figure; 
imshow(im,[]);
hold on;
x = centroid(1) - r;
y = centroid(2) - r;
w = r*2;
rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
plot(centroid(1),centroid(2),'*r');
hold off;
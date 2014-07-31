function plotCircle(im, centroid, r)
% draw a circle
figure; imshow(im,[]);
hold on;
x = centroid(1) - r;
y = centroid(2) - r;
w = r*2;
rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
plot(centroid(1),centroid(2),'*r');
hold off;
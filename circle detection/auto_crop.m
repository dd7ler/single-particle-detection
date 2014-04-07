function output = auto_crop(fr, minmax_radius,savename,ratio,savedirectory)

% the output image is altered, with a fixed lower bound at 
lower_bound = .3;
%... this is so that we can use the same threshold for everything

% convert fr to double type

fr = double((fr - min(fr(:)))/range(fr(:)));
im = fr;

% if nargin <4
%     ratio = .6; % ratio of entire spot size to use for circle (must be <1)
% end
% if nargin <3
%     i = 0;
% end
% if nargin <2
%     minmax_radius = [300 400];
% end

resize_factor = .25; % resize ratio, for hough filter (small is ok)

perimeter_pct = .15;

% flatten the brightest and darkest 10%ile pixels
y = quantile(fr(:),[.85 .15]);
max_thresh = y(1);
min_thresh = y(2);
m = mean(fr(:));
% figure; imshow(fr);
fr(fr>max_thresh) = max_thresh;
fr(fr<min_thresh) = min_thresh;
% figure; imshow(fr,[]);

% apply filter(s) to make the circle more apparent.
% fr = wiener2(fr,[5 5]);
% figure; imshow(fr,[]);

% compress the image so hough transform may be used
fr_small = imresize(fr,.25);
% figure; imshow(fr_small,[]);

% rescale image to a reasonable range
fr_small = fr_small - min(min(fr_small));
fr_small = 256*fr_small/max(max(fr_small));

f = edge(fr_small);
% figure; imshow(f);
disk = strel('disk',2);
f = imdilate(f,disk);
% figure; imshow(f);

% detect the circular edge of the spot using the hough transform

circles = houghcircles(f,floor(minmax_radius(1)*resize_factor),floor(minmax_radius(2)*resize_factor),perimeter_pct);

% draw the detected circle(s) and the circular detection region (80%
% radius ~= 65% area)


[~,best] = max(circles(:,4));       % only select 1 circle (the best one)
circles = round(circles(best,:)/resize_factor);


% for creating debug images

% x = circles(1)-circles(3);
% y = circles(2)-circles(3);
% w = 2*circles(3);
% x2 = round(circles(1)-circles(3)*ratio);
% y2 = round(circles(2)-circles(3)*ratio);
w2 = 2*circles(3)*ratio;
% 
% fig = figure('Visible','off');  % for making output figures
% imshow(fr,[]), hold on;
% rectangle('Position', [x y w w], 'EdgeColor', 'red', 'Curvature', [1 1]);
% rectangle('Position', [x2 y2 w2 w2], 'EdgeColor', 'green', 'Curvature', [1 1]);
% insc_x = floor(circles(1) - circles(3)/sqrt(2)*ratio);
% insc_y = floor(circles(2) - circles(3)/sqrt(2)*ratio);
% insc_w = floor(2*circles(3)/sqrt(2)*ratio);
% rectangle('Position', [insc_x insc_y insc_w insc_w], 'EdgeColor', 'green');
% hold off;
% print(fig, [savedirectory savename ' crop debug'], '-djpeg');
I = repmat(im,[1 1 3]);
red = [1,0,0];
green = [0 1 0];

outer_radius = circles(3);
% outer circle
I = MidpointCircle(I, outer_radius, circles(2), circles(1), red); % each of the colors
%inner circle
inner_radius = outer_radius*ratio;
I = MidpointCircle(I, inner_radius, circles(2), circles(1), green); % each of the colors
imwrite(I, [savedirectory 'cropped ' savename '.png']);

output = im(round(circles(2)-w2/2):round(circles(2)+w2/2),round(circles(1)-w2/2):round(circles(1)+w2/2));
% figure; imshow(output,[]);
mask = zeros(size(output)); % generate a mask of 0's in a circle, 1's outside
radius = round(length(output)/2);
for x = 1:size(output,2)
    for y = 1:size(output,1)
        if sqrt((radius- x).^2 + (radius- y).^2)>= radius
            mask(y,x) = 1;
        end
    end
end
output(logical(mask)) = median(output(~logical(mask))); % set the area outside the spot to a nominal intensity
output(output<lower_bound) = lower_bound;
end

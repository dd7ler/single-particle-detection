function [approxNA, rr] = stackAiryFit(fname, varargin)

optargs = {470, 7.4, 153.5, .75, true}; % default arguements
optargs(1:length(varargin))= varargin(:);
[lambda, camPxPitch, mag, na, hideFig] = optargs{:};

stackInfo = imfinfo(fname);
n = length(stackInfo);

% Get the region
imd = imread(fname, 'Index', round(n/2));
g = figure; 
imshow(imd,[]);
axis on
h = imrect;
roi = wait(h);
close(g)

rr = [];
approxNA = [];
for i = 1:3:n
    im = imread(fname, 'Index', i);
    pIm = im(roi(2):(roi(2) + roi(4)), roi(1):(roi(1) + roi(3)));
    [aNA, ~, ~, r] = airyFit(pIm, lambda, camPxPitch, mag, na, hideFig);
    approxNA = [approxNA aNA];
    rr = [rr sum(r(:).^2)];
end

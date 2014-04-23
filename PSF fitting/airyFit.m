function [approxNA, xOut, x0, resid] = airyFit(im, varargin)
% AIRYFIT Fits a first order bessel function to an image of a single
% particle or point scatterer. xOut is the best-fit [x, y, coef, peak,
% offset] where coef = 2*pi*na/lambda, in the image plane. x0 is the guess
% based on optional input arguements.
% 
% [approxNA, xOut, x0, resid = airyFit(im, lambda, camPxPitch, mag, na,
% hideFig) includes all optional arguments, where lambda is in nanometers,
% camPxPitch is the camera pixel pitch in microns, mag is the camera
% magnification and na is the NA of the objective. If hideFit is set to
% true, no figures will be shown - otherwise, they will. approxNA is the
% best-fit NA of the system, xOut is the best-fit [x, y, coef, peak,
% offset] where coef = 2*pi*na/lambda, in the image plane. x0 is the guess
% based on the optional input arguements. 

optargs = {470, 7.4, 153.5, .75, false}; % default
optargs(1:length(varargin))= varargin(:);
[lambda, camPxPitch, mag, na, hideFig] = optargs{:};
pixScale = camPxPitch/mag*1000; % Pixel size in nanometers

% normalize the input
im = double(im);
im = im - median(im(:));
im = im./max(im(:));

r = 1:size(im,1);
c = 1:size(im,2);

[xdata(:,:,1), xdata(:,:,2)] = meshgrid(r,c);

coef = 2*pi*na/lambda*pixScale;

x0 = [size(im,1)/2, size(im,2)/2, coef, 1,0];
IGuess = airyPattern(x0, xdata);

[xOut, ~, resid] = lsqcurvefit(@airyPattern, x0, xdata, im');
IFit = airyPattern(xOut, xdata);
approxNA = xOut(3)*lambda/pixScale/(2*pi);

if ~hideFig
    figure;
    subplot(1,3,1); surf(im); title('Original')
    subplot(1,3,2); surf(IFit); title('Regression')
    subplot(1,3,3); surf(resid); title('Residual')
end
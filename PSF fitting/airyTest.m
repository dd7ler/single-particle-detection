% Script for testing the airyPattern function
% Derin Sevenler, December 2013

isneg = 'false';
lambda = 470; % Nanometers
camera_pixel_size_microns = 7.4; % Regita = 7.4, Rolera = 12.9, Apogee 7.4
magnification = 50; % singlet equivalent 3.2x (Feb 1)
na = .8;
pixScale = camera_pixel_size_microns/magnification*1000; % Pixel size in nanometers

clear
disp(datestr(now));
close all;
[fname, fpath] = uigetfile('*');

if fname ==0
    disp('No file selected');
    return
end

frame = double(imread([fpath fname]));
im = imcrop(frame,[]);
close

im = im - median(im(:));
if isneg
    im = -im./min(im(:));
else
    im = im./max(im(:));
end

r = 1:size(im,1);
c = 1:size(im,2);

[xdata(:,:,1), xdata(:,:,2)] = meshgrid(r,c);

coef = 2*pi*na/lambda*pixScale; % Look in airyPattern for a detailed description 
x0 = [size(im,1)/2, size(im,2)/2, coef, 1,0]

IGuess = airyPattern(x0, xdata);

[xOut, ~, resid] = lsqcurvefit(@airyPattern, x0, xdata, im');
IFit = airyPattern(xOut, xdata);

xOut
NA_out = xOut(3)*lambda/pixScale/(2*pi)

figure;
subplot(1,4,1); surf(im); title('Original')
subplot(1,4,2); surf(IGuess); title('Guess')
subplot(1,4,3); surf(IFit); title('Regression')
subplot(1,4,4); imagesc(resid); title('Residual');
axis square

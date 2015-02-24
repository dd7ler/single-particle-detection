clear; 
lambda = 533; % Nanometers
camera_pixel_size_microns = 7.4; % Regita = 7.4, Rolera = 12.9, Apogee 7.4
magnification = 50; % singlet equivalent 3.2x (Feb 1)
na = .8;
pixScale = camera_pixel_size_microns/magnification*1000; % Pixel size in nanometers

coef = 2*pi*na/lambda*pixScale;
im = zeros(40,20);
r = 1:size(im,1);
c = 1:size(im,2);

[xdata(:,:,1), xdata(:,:,2)] = meshgrid(r,c);

r = linspace(0,300/pixScale,4);
for n = 1:length(r)
    x0 = [20-r(n), 10, coef, 1, 0];
    x1 = [20+r(n), 10, coef, 1, 0];

    im1 = airyPattern(x0,xdata);
    im2 = airyPattern(x1,xdata);
    subplot(length(r),1,n); imshow(im1+im2,[])
    text(2,5,[num2str(r(n)*pixScale) ' nm'],'BackgroundColor',[.7 .9 .7], 'FontSize',12);
end

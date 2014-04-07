function [ output_args ] = oneSpotRealtime(imDir, fPrefix, varargin)
% ONESPOTREALTIME Track particles in an image sequence. oneSpotRealtime(imDir, fPrefix, varargin)
% Default varargin are the following:
% imageVar = 'frame'
% chipVar = 'Chip\d*'
% tsPattern = 'Frame(\d*).mat$'
% cropR=0
% d_min=1000
% d_max=1800
% im_thresh=0.6
% TemplateSize=9
% SD=1.5
% gaussianTh=0.7
% theta_range=-5:0.2:5
% minSize=0
% maxSize=200
% pixelAreaMicrons=0.0181
% pMaterial='poly'

% default parameters, in case some of them are not entered
optargs = {'frame' 'Chip\d*' 'Frame(\d*).mat$' 0 700 900 0.6 9 1.5 0.7 -2:.4:2 0 200 0.0181 'poly'};
optargs(1:length(varargin)) = varargin(:);
[imageVar, chipVar, tsPattern cropR, d_min, d_max, im_thresh, TemplateSize, SD, gaussianTh, theta_range, minSize, maxSize, pixelAreaMicrons, pMaterial] = optargs{:};

% Generate image names
fList = regexpdir(imDir, fPrefix);

% get all the images. 
mir = 'mirrorDataSet110044';
s = load([pwd filesep mir]);
mir = s.data;
mir = mir(700:1000, 700:1000);

images = zeros([size(mir) length(fList)-1]);
progressbar(1)
for i = 1:length(fList)-1
    s = load(fList{i+1});
    im = s.data;
    im = im(700:1000, 700:1000);
    images(:,:,i) = im./mir;
    progressbar(i/(length(fList)-1));
end

% Align each image to the last, and solve for the displacement and rotation coordinates xyt
progressbar(2);
xyt = [0 0 0];
for i = 1:size(images,3)-1
	[deltax,theta, composite,q] = alignImages(images(:,:,1), images(:,:,i+1), theta_range);
	figure; plot(theta_range, q);
	figure; imshow(composite,[]);
    [deltax, theta]
	xyt = [xyt; deltax, theta];
    save('displacements.mat', 'xyt');
	progressbar(i/size(images,3),1);
end
% Output a series of aligned images
tifName = ['testStack' datestr(now) '.tif'];
for i = 1:size(images,3)
    s = load(fList{i+1});
	im = imrescale(s.frame,2^16);
    im = uint16(im);
    imr = imrotate(im,xyt(i,3),'crop');
	imr(imr == 0) = median(imr(:));
	imrAligned = imtranslate(imr, [0,0]);
	imwrite(imrAligned, tifName,'TIFF', 'writemode', 'append','Compression', 'none');
	progressbar(i/size(images,3));
end

end
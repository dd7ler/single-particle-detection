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
% mir = 'mirrorDataSet110044';
% s = load([pwd filesep mir]);
% mir = s.data;
% mir = mir(700:1000, 700:1000);

% images = zeros([size(mir) length(fList)-1]);
progressbar('Loading Images')
for i = 1:length(fList)-1
    s = load(fList{i+1});
    % im = im(700:1000, 700:1000);
    % images(:,:,i) = im./mir;
    images(:,:,i) = eval(['s.' imageVar]);
    progressbar(i/(length(fList)-1));
end

% Align each image to the last, and solve for the displacement and rotation coordinates xyt
progressbar('Image Set', 'Alignment');
xyt = [0 0 0];
deltax = [];
for i = 1:size(images,3)-1 % Align all images to the first one
	xy = phCorrAlign(images(:,:,1), images(:,:,i+1));
	% [deltax,theta, composite,q] = alignImages(images(:,:,1), images(:,:,i+1), theta_range);
	deltax = [deltax; xy];
	progressbar(i/size(images,3),1);
end
% Find alignments that were less than 2 pixels (anything larger than this works well)
displ = sqrt(deltax(:,1).^2 + deltax(:,2).^2);
% Align these images with the last one;
closeIdx = find(displ < 0.5);
progressbar('Close Images', 'Alignment');
for k = 1:length(closeIdx) 
	xy = phCorrAlign(images(:,:,closeIdx(k)), images(:,:,end));
	deltax(k,:) = deltax(end,:) - xy;
	progressbar(k/length(closeIdx),1);
end
save('displacements.mat', 'deltax');

% Output a series of aligned images
progressbar('Saving Images');
tifName = ['testStack' datestr(now) '.tif'];
for i = 2:size(images,3)
	im = images(:,:,i);
	im = imrescale(im,min(im(:)), max(im(:)),2^16);
    im = uint16(im);
    % imr = imrotate(im,xyt(i,3),'crop');
	% imr(imr == 0) = median(imr(:));
	imrAligned = imtranslate(im, deltax(i-1,:));
	imwrite(imrAligned, tifName,'TIFF', 'writemode', 'append','Compression', 'none');
	progressbar(i/size(images,3));
end

end
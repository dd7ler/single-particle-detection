% This script fits an airy disk PSF equation to point scatterers in an image,
% and thereby measures the point spread function size.
% Derin Sevenler, December 2013


clear; close all;

cropR = 7;
contrast_thresh = 0.5;
edge_thresh = 2;
rMin = 820/2;
rMax = 870/2;

contMin = 1.01;
contMax = 1.2;

lambda = 532; % Nanometers
camera_pixel_size_microns = 7.4; % Regita = 7.4, Rolera = 12.9
magnification = 50;
na = .7;

pixScale = camera_pixel_size_microns/magnification*1000; % Pixel size in nanometers

d = uigetdir(pwd,'Please select the image directory'); % Regexpdir is recursive, so having files in subdirectories is ok.
s = '^psfFrame.*\.mat$'; % anything followed by 'pre' followed by 'green' followed by '.mat', separated by anything
f = 'frame';
usrinput = inputdlg({'Please enter the pre-image file regex:', 'What''s the image variable called?'},'Image File Regex',1,{s, f});
expstr = usrinput{1};
imName = usrinput{2};
fList = regexpdir(d, usrinput{1});

[mname, mdir]= uigetfile(pwd,'Please select the corresponding mirror file');
load([mdir filesep mname]);
mirror = frame;
% This variable has three columns: [r, c, airy disk radius]. It includes particles from all images.
psfScatter = [];

% Airy function for least-squares fit
fudgeFactor = 1;
coef = 2*pi*na/lambda*pixScale/ fudgeFactor;

% Run sift on each frame, and fit an airy pattern to all of the detected particles
opts = optimoptions('lsqcurvefit', 'Display', 'off');
psfList = [];
progressbar(0,0)
for n = 1:length(fList)
	load(fList{n});
	frame = double(frame);
	frame = frame./mirror;
	frame = frame - median(frame(:));

	% Detect circle and crop
	[centroid, r] = detectSpot(frame, rMin, rMax);
	cropped = cropcircle(frame, centroid, r);
	cropOffset = size(cropped)/2 - centroid; % RC Conversion from coordintes in the cropped image to the original.

	KPData = getParticles(cropped, contrast_thresh, edge_thresh);
	xy = KPData.VKPs(1:2,:)';
	contrasts = ComputeContrast(cropped, KPData.Peaks, xy, 9, 12);
	% Filter peaks by contrast
	xy2 = xy(contrasts> 1.02 & KPData.Peaks < 1.35, :);
	rc = xy2 - repmat(cropOffset,size(xy2,1),1);
	figure;
	imshow(frame,[]);
	hold on;
	scatter(rc(:,1), rc(:,2),'o');

	% Perform gaussian fitting on each particle
	for m = 1:size(rc,1)
		cent = round(rc(m,:));
		rSpan = (cent(1)-cropR):(cent(1)+cropR);
		cSpan = (cent(2)-cropR):(cent(2)+cropR);
		if rSpan(1)<1
			rSpan = rSpan - rSpan(1) + 1;
		end
		if cSpan(1)<1
			cSpan = cSpan - cSpan(1) + 1;
		end
		if rSpan(end)> size(frame,1)
			disp('fixed large rSpan');
			rSpan = rSpan - rSpan(end) + size(frame,1);
		end
		if cSpan(end)> size(frame,2)
			cSpan = cSpan - cSpan(end) + size(frame,2);
		end
		im = frame(rSpan, cSpan);
		im = im - median(im(:));
		im = im./max(im(:));
		[xdata(:,:,1), xdata(:,:,2)] = meshgrid(1:size(im,1), 1:size(im,2));
		x0 = [size(im)/2, coef, 1,0];
		xOut = lsqcurvefit(@airyPattern, x0, xdata, im, [], [], opts);
		psfList = [psfList; cent xOut(3)];
		progressbar(m/size(rc,1),[])
	end
	progressbar([], n/length(fList));
end

delta = 50;
[rr, cc] = meshgrid(1:delta:size(frame,1), 1:delta:size(frame,2));
figure;
psfSurf = griddata(psfList(:,1), psfList(:,2), psfList(:, 3), rr, cc);
surf(psfSurf)



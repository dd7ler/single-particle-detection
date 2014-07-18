% SimpleSPD
% Simple particle analysis!
%
% Analyze images hassle free. Everything you need, nothing you don't.
% You can pick particle parameters by looking at a 'prototype' particle.


%% Get image
[filename, pathname, filterindex] = uigetfile({'*'},'Select the image .mat file');
data = load([pathname filesep filename])

imVar = input('What''s the image variable called?\n','s');
im = eval(['data.' imVar]);

%% Get mirror
[filename, pathname, filterindex] = uigetfile({'*'},'Select the mirror .mat file');
mir = load([pathname filesep filename])
imVar = input('What''s the mirror variable called?\n','s');
mirror = eval(['mir.' imVar]);

im = double(im)./double(mirror);

%% Crop Image
figure; imshow(im,[]);
cropType = input('Crop (c) or detect circle (d)? \n','s');
switch lower(cropType)
	case 'c'
        close
		imc = imcrop(im,[]);
	case 'd'
		dia = (input('What''s the diameter, roughly?'));
        close
		r_min = dia/2*0.8;
		r_max = dia/2*1.2;
		[centroid, r] = detectSpot(im, r_min, r_max);
		imc = cropcircle(im, centroid, r);
end

%% SPD

prompt = {'IntensityThresh', 'Gaussian Threshold', 'Contrast Threshold'};
name = 'Particle Detection Parameters!';
numlines = 1;
defaultAns = {'0.3','0.5', '1.0'};

userParams = inputdlg(prompt, name, numlines, defaultAns);
intensityTh = str2double(userParams{1});
gaussianTh = str2double(userParams{2});
contrastTh = str2double(userParams{3});

params = struct('IntensityThresh', intensityTh, 'EdgeTh', 2, 'gaussianTh', gaussianTh, ...
	'template', 5, 'SD', 1.0, 'innerRadius', 2, 'outerRadius', 4, 'contrastTh', contrastTh, 'polarization', false);
[particleXY, contrasts] = particleDetection(imc, params);

imRange = [.98 1.05]*median(imc(:));
imOut = uint8(imrescale(imc,imRange(1), imRange(2), 2^8));
imshow(imOut)
labeledIm = drawCircles(imOut, particleXY{1}, 6, 'red');
datetime

subplot(1,2,1); imshow(imc,imRange);
subplot(1,2,2); imshow(labeledIm);

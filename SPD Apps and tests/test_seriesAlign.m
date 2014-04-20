function test_seriesAlign(varargin)
% TEST_SERIESALIGN Test alignment of a Zoiray image series.
% 
% TEST_SERIESALIGN(imDir, nameRegEx imageVar, mirPath) save a 
% 	multipage TIFF with the the images found in the Zoiray 
% 	images 'imDir' that match the regularExpression 'nameRegEx'.
% 	'imageVar' is a string that matches the variable name 
% 	used for the images saved in the Zoiyray '.mat' files.
% 	You can nor
% Defaults: imDir = pwd; nameRegEx = 'Frame'; imageVar = 'frame'; mirPath = 'none'.

% Default args
imDir = pwd;
nameRegEx = '^.*Frame.*\.mat$';
imageVar = 'frame';
mirPath = 'none';
% Overwrite default args
optargs = {imDir, nameRegEx, imageVar, mirPath};
optargs(1:length(varargin)) = varargin(:);
[imDir, nameRegEx, imageVar, mirPath] = optargs{:};

clc
tic

disp('Loading Images...');
images = loadZoirayImages(imDir, nameRegEx, imageVar);
toc
disp(['found ' num2str(size(images,3)) ' images.']);

% Normalize by mirror if it exists.
if strcmp(mirPath, 'none')
	disp('Not using a mirror...')
else
	disp('Using a mirror...')
	s = load(mirPath);
	mir = eval(['s.' imageVar]);
	mirPat = repmat(mir, [1 1 size(images,3)]);
	images = images./mirPat;
end
% get subregion
images = images(700:1000,700:1000,:);
% save('images.mat','images','-V7.3');
% disp('images saved')
toc


disp('Aligning images...');
% Images are aligned to the firs one
deltaRCT = getImOffsets(images);
save('deltaRCT.mat','deltaRCT');
disp('Alignment saved');
toc

disp('Detecting Particles');
params = struct('IntensityThresh', 0.6, 'EdgeTh', 2, 'gaussianTh', 0.5, ...
	'templateSize', 9, 'SD', 1.5, 'innerRadius', 9, 'outerRadius', 12);
[particleXY, contrasts] = particleDetection(images, params);
save('particleData.mat', 'particleXY', 'contrasts');
disp('Detected particles saved');
toc

disp('Matching & Tracking Particles...');
clusterBandwidth = 4;
particleRC = cellfun(@fliplr, particleXY, 'UniformOutput', false);
deltaRCTneg = num2cell(-1*deltaRCT,2);
imSize = size(images);
imSizeC = cell(imSize(3),1); imSizeC(:) = {imSize(1:2)};
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false);
matches = matchParticles(translatedRC, clusterBandwidth);
particleList = trackParticles(particleRC, matches);
toc

disp('Labeling particles...');
% Label Particles with colors
colors = rand(length(particleList), 3);
colors = num2cell(colors,2);
particleList = [particleList colors];
labelRadius = 4;
labeledIms = labelIms(images, particleList);
outName = 'test';
toc

disp('printing...')
writeAlignedTiff(labeledIms, deltaRCT, outName);
toc

disp('Done!')

end
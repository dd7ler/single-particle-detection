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

% Open Matlabpool if it's not open already
if matlabpool('size') ==0
	matlabpool open
end

imDir = pwd;
nameRegEx = '^.*Frame.*\.mat$';
imageVar = 'frame';
mirPath = 'none';
% Overwrite default args
optargs = {imDir, nameRegEx, imageVar, mirPath};
optargs(1:length(varargin)) = varargin(:);
[imDir, nameRegEx, imageVar, mirPath] = optargs{:};

tic

disp('Loading Images...');
images = loadZoirayImages(imDir, nameRegEx, imageVar);
disp(['Loaded ' num2str(size(images,3)) ' images at ' num2str(round(toc)) ' seconds.']);

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
disp(['Normalization completed at ' num2str(round(toc)) ' seconds.'])
% get subregion
% images = images(700:1000,700:1000,:);
images = imrescale(images, 1, 1.2, 1);
imSize = size(images);
disp(['Cropped region is ' num2str(round(imSize(1)*imSize(2)/10^4)/10^2) ' megapixels.']);
% save('images.mat','images','-V7.3');
% disp('images saved')


disp('Aligning images...');
% Images are aligned to the firs one
deltaRCT = getImOffsets(images);
% save('deltaRCT.mat','deltaRCT');
disp(['Alignment completed at ' num2str(round(toc)) ' seconds.']);


disp('Detecting Particles...');
params = struct('IntensityThresh', 0.6, 'EdgeTh', 2, 'gaussianTh', 0.1, ...
	'templateSize', 9, 'SD', 1.5, 'innerRadius', 9, 'outerRadius', 12);
[particleXY, contrasts] = particleDetection(images, params);
% save('particleData.mat', 'particleXY', 'contrasts');
disp(['Particles Detected at ' num2str(round(toc)) ' seconds.']);


disp('Matching & Tracking Particles...');
clusterBandwidth = 4;
particleRC = cellfun(@fliplr, particleXY, 'UniformOutput', false);
deltaRCTneg = num2cell(-1*deltaRCT,2);
imSizeC = cell(imSize(3),1); imSizeC(:) = {imSize(1:2)};
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false);
matches = matchParticles(translatedRC, clusterBandwidth);
particleList = trackParticles(particleRC, matches);
disp(['Particle tracking completed at ' num2str(round(toc)) ' seconds.']);


disp('Labeling particles...');
colors = rand(length(particleList), 3);
colors = num2cell(colors,2);
particleList = [particleList colors];
labeledIms = labelIms(images, particleList);
outName = 'Individual Particles';
disp(['Labeling completed at ' num2str(round(toc)) ' seconds.']);

disp('printing particles...')
writeAlignedTiff(labeledIms, deltaRCT, outName);
disp(['Printing completed at ' num2str(round(toc)) ' seconds.']);

disp('Determining sites...')
alignedList = trackParticles(translatedRC, matches);
bandWidth = 3;
[imagesHere, sitesXY] = findSites(alignedList, bandWidth);
% 
% disp('Labeling sites...');
% colors = rand(length(sitesXY), 3);
% colors = num2cell(colors,2);
% sitesList = [imagesHere', sitesXY, colors];
% registeredIms = getBWAlignedStack(images, -1*deltaRCT);
% labeledIms = labelIms(registeredIms, sitesList);
% outName = 'Sites';
% disp(['Labeling completed at ' num2str(round(toc)) ' seconds.']);
% 
% disp('printing sites...')
% dummyRCT = zeros(size(deltaRCT));
% writeAlignedTiff(labeledIms, deltaRCT, outName);
% disp(['Printing completed at ' num2str(round(toc)) ' seconds.']);
% 
% disp('Done!')

end
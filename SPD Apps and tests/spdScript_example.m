% This is an example analysis script, with some 
% Copy and paste this script to where your images are, and use it 
% to speed up your analysis. Rather than copying and pasting things 
% from here into the Matlab workspace or running the whole thing every 
% time, you can use "Code Sections" to rapidly iterate over one 
% portion of your analysis! These code sections are just examples of what
% you might want to use.



%% Load images

imDir = pwd;
% This means "Grab any file that contains the phrase 'DataSet' and ends with '.mat'"
nameRegEx = '^.*DataSet.*\.mat$'; 
imageVar = 'frame';

disp('Loading Images...');
images = loadZoirayImages(imDir, nameRegEx, imageVar);
disp(['Loaded ' num2str(size(images,3)) ' images.']);



%% Image Cropping & Normalization

mirPath = 'none';
if strcmp(mirPath, 'none')
	disp('Not using a mirror.')
else
	disp('Using a mirror...')
	s = load(mirPath);
	mir = eval(['s.' imageVar]);
	mirPat = repmat(mir, [1 1 size(images,3)]);
	images = images./mirPat;
end

% CropRegion = '700:1000, 700:1000, :';
% images = images(eval(CropRegion))



%% Detect particles

disp('Detecting Particles...');
params = struct('IntensityThresh', 2, 'EdgeTh', 2, 'gaussianTh', 0.3, ...
	'templateSize', 9, 'SD', 1.5, 'innerRadius', 9, 'outerRadius', 12);
[particleXY, contrasts] = particleDetection(images, params);
% save('particleData.mat', 'particleXY', 'contrasts');
disp(['Particles detection complete!']);



%% Track and Label Particles

disp('Matching & Tracking Particles...');
clusterBandwidth = 4;
particleRC = cellfun(@fliplr, particleXY, 'UniformOutput', false);
deltaRCTneg = num2cell(-1*deltaRCT,2);
imSizeC = cell(imSize(3),1); imSizeC(:) = {imSize(1:2)};
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false);
matches = matchParticles(translatedRC, clusterBandwidth);
particleList = trackParticles(particleRC, matches);
disp(['Particle tracking completed.']);


disp('Labeling particles...');
colors = rand(length(particleList), 3);
colors = num2cell(colors,2);
particleList = [particleList colors];
labeledIms = labelIms(images, particleList);
outName = 'Individual Particles';
disp(['Labeling completed.']);



%% Identify Particle Sites
disp('Determining sites...')
alignedList = trackParticles(translatedRC, matches);
bandWidth = 3;
[imagesHere, sitesXY] = findSites(alignedList, bandWidth);

disp('Labeling sites...');
colors = rand(length(sitesXY), 3);
colors = num2cell(colors,2);
sitesList = [imagesHere', sitesXY, colors];
registeredIms = getBWAlignedStack(images, -1*deltaRCT);
labeledIms = labelIms(registeredIms, sitesList);
outName = 'Sites';
disp(['Labeling completed at ' num2str(round(toc)) ' seconds.']);

disp('printing sites...')
dummyRCT = zeros(size(deltaRCT));
writeAlignedTiff(labeledIms, deltaRCT, outName);
disp(['Printing completed at ' num2str(round(toc)) ' seconds.']);



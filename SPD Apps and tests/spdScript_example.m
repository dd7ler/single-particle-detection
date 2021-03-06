% This is an example analysis script, with some 
% Copy and paste this script to where your images are, and use it 
% to speed up your analysis. Rather than copying and pasting things 
% from here into the Matlab workspace or running the whole thing every 
% time, you can use "Code Sections" to rapidly iterate over one 
% portion of your analysis! These code sections are just examples of what
% you might want to use.

if matlabpool('size') == 0
    matlabpool open
end



%% Load images
imDir = pwd;
% This means "Grab any file that contains the phrase 'DataSet' and ends with '.mat'"
nameRegEx = '^.*1DataSet.*\.mat$'; 
imageVar = 'data';

disp('Loading Images...');
rawIms = loadZoirayImages(imDir, nameRegEx, imageVar);
disp(['Loaded ' num2str(size(rawIms,3)) ' images.']);
save('images.mat','rawIms');



%% Normalization
mirPath = 'none' %'mirrorDataSet110044.mat';

if strcmp(mirPath, 'none')
	disp('Not using a mirror.')
    images = rawIms;
else
	disp('Using a mirror...')
	s = load(mirPath);
	mir = eval(['s.' imageVar]);
	mirPat = repmat(mir, [1 1 size(images,3)]);
	images = rawIms./mirPat;
end

%% Manual Cropping
figure; imshow(images(:,:,round(size(images,3)/2)),[]);
h = imrect;
region = round(wait(h));
images = images(region(1):(region(1)+region(3)), region(2):(region(2)+region(4)), :);
close


%% Circle Detection and cropping

r_min = 150;
r_max = 450;

images = cell(size(rawIms,3),1);
parfor n = 1:size(rawIms,3) % This can be vectorized.
   [centroid, r] = detectSpot(rawIms(:,:,n), r_min, r_max);
   images{n} = cropcircle(rawIms(:,:,n), centroid, r);
end
disp('Finished detecting circles');

%% Image Alignment

disp('Aligning images...');
% Images are aligned to the first one
deltaRCT = getImOffsets(images);
% save('deltaRCT.mat','deltaRCT');
disp(['Alignment completed.']);


imc2 = imcrop(:,:,1:10);
%% Detect particles
params = struct('IntensityThresh', .8, 'EdgeTh', 2, 'gaussianTh', 0.3, ...
	'template', 5, 'SD', 1.0, 'innerRadius', 4, 'outerRadius', 6, 'contrastTh', 1.007); % 'polarization', true);

disp('Detecting Particles...');
if mod(params.template,2) ~=1
    disp('Template parameter must be odd!');
else
    [particleXY, contrasts] = particleDetection(images, params);
    % save('particleData.mat', 'particleXY', 'contrasts');
    disp(['Particle detection complete!']);
end

%% Get particle counts and densities

counts = cellfun(@length, particleXY);
diameters = cellfun(@length, images);
areas = pi*(diameters./2).^2;
densities = counts./areas;


% Compare conditions. Reshape based on the scan order.
spotN = 4;
condN = 8;

condCounts = reshape(counts, spotN, condN);
condDensities = reshape(densities, spotN, condN);

meanDensities = mean(condDensities);
condX = meshgrid(1:condN, 1:spotN);

close all; figure;
plot(condX(:), condDensities(:), '*r');
hold on
plot(meanDensities, '-ob');
axis([0 9 0 .02])


%% Track and Label Particles
imSize = size(imc2);
disp('Matching & Tracking Particles...');
clusterBandwidth = 3;
particleRC = cellfun(@fliplr, particleXY, 'UniformOutput', false);
deltaRCTneg = num2cell(-1*deltaRCT,2);
imSizeC = cell(imSize(3),1); imSizeC(:) = {imSize(1:2)};
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false);
matches = matchParticles(translatedRC, clusterBandwidth);
particleList = trackParticles(particleRC, matches);
disp('Particle tracking completed.');

% Remove one-offs
dwellTs = cellfun(@length,particleList(:,1));
particleList(dwellTs<1,:) = [];

disp('Labeling particles...');
colors = rand(length(particleList), 3);
colors = num2cell(colors,2);
particleList = [particleList colors];
labeledIms = labelIms(imc2, particleList);
outName = 'Individual Particles';
disp('Labeling completed.');

disp('printing particles...')
writeAlignedTiff(labeledIms, deltaRCT, outName);
disp('Printing completed.');

%% Identify Particle Sites
disp('Determining sites...')
alignedList = trackParticles(translatedRC, matches);
bandWidth = 3;
[imagesHere, sitesXY] = findSites(alignedList, bandWidth);

disp('Labeling sites...');
colors = rand(length(sitesXY), 3);
colors = num2cell(colors,2);
sitesList = [imagesHere', sitesXY, colors];
registeredIms = getBWAlignedStack(imc2, -1*deltaRCT);
labeledIms = labelIms(registeredIms, sitesList);
outName = 'Sites';
disp(['Labeling completed at ' num2str(round(toc)) ' seconds.']);

disp('printing sites...')
dummyRCT = zeros(size(deltaRCT));
writeAlignedTiff(labeledIms, deltaRCT, outName);
disp(['Printing completed at ' num2str(round(toc)) ' seconds.']);



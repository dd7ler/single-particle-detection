function [particleXY, contrasts] = particleDetection(images, params)
% SIFTParticles Get particles detected in the image.
% 
% First, Key Points are extracted using Scale-Invariant Feature Transform. 
% 	Those are filtered, such that only key points which are approximately 
% 	gaussian are considered to be particles. 
% 
% [xy, contrasts] = particleDetection(images, params)
% images is a double matrix with size(images, 3) = n, where n is the 
% 	number of images.
% params is a structure with the following fields:
% 	(SIFT) IntensityThresh, EdgeTh
% 	(Gaussian filtering) gaussianTh, templateSize, SD, innerRadius, outerRadius 
% 
% It may be initialized like this (these are typical values):
% defaultParams = struct('IntensityThresh', 0.6, 'EdgeTh', 2, 'gaussianTh', 0.6, 'templateSize', 9, 'SD', 1.5, 'innerRadius', 9, 'outerRadius', 12);

% SIFT key point detection
xyCell = cell(size(images,3),1);
peaks = cell(size(images,3),1);
for n = 1:size(images,3)
	kpdata = getParticles(images(:,:,n), params.IntensityThresh, params.EdgeTh);
	xyCell{n} = kpdata.VKPs(1:2,:)';
	peaks{n} = kpdata.Peaks;
	progressbar(n/size(images,3))
end

% Gaussian filtering
imCell = squeeze(num2cell(images, [1 2]));
templateSizeCell = cell(size(xyCell)); % Initialization
SDCell = templateSizeCell;
gThCell = templateSizeCell;
templateSizeCell(:) = {params.templateSize}; % population
SDCell(:) = {params.SD};
gThCell(:) = {params.gaussianTh};

corrCoefs = cellfun(@gaussianfilter, imCell, xyCell, templateSizeCell, SDCell, 'UniformOutput', false);
indices = cellfun(@(x,y) find(x>y), corrCoefs, gThCell, 'UniformOutput', false);
% apply filters
particleXY = cellfun(@(x,y) x(y,:), xyCell, indices, 'UniformOutput', false);
filteredPeaks = cellfun(@(x,y) x(y,:), peaks, indices, 'UniformOutput', false);

% Compute particle contrasts from local background intensity
irCell=cell(size(xyCell));
irCell(:) = {params.innerRadius};
orCell=cell(size(xyCell));
orCell(:) = {params.outerRadius};
contrasts = cellfun(@ComputeContrast, imCell, filteredPeaks, particleXY, irCell, orCell, 'UniformOutput', false);

end
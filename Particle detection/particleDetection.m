function [particleXY, contrasts] = particleDetection(images, params)
% SIFTParticles Get particles detected in the image.
% 
% First, Key Points are extracted using Scale-Invariant Feature Transform. 
% 	Those are filtered, such that only key points which are approximately 
% 	gaussian are considered to be particles. 
% 
% This script incorporates parallel processing if you have matlab pool open
%   (i.e., run 'matlabpool open' before and 'matlabpool close' after) 
% [xy, contrasts] = particleDetection(images, params)
% images is a double matrix with size(images, 3) = n, where n is the 
% 	number of images.
% params is a structure with the following fields:
% 	(SIFT) IntensityThresh, EdgeTh
% 	(Gaussian filtering) gaussianTh, templateSize, SD, innerRadius, outerRadius 
% 
% It may be initialized like this (these are typical values):
% defaultParams = struct('IntensityThresh', 0.6, 'EdgeTh', 2, 'gaussianTh',
% 0.45, 'template', 5, 'SD', 1, 'innerRadius', 9, 'outerRadius', 12, 'contrastTh', 1.01); 
%  params.template must be odd (it won't error out, but it may give
%  unexpected results).

% SIFT key point detection
particleXY = cell(size(images,3),1);
contrasts = cell(size(images,3),1);
gfilter=fspecial('gaussian',[params.template params.template], 1);
gfilter=gfilter-mean(gfilter(:));
for n = 1:size(images,3)
	kpdata = getParticles(images(:,:,n), params.IntensityThresh, params.EdgeTh);
	xy = kpdata.VKPs(1:2,:)';
	peaks = kpdata.Peaks;
	% corrCoefs = gaussianfilter(images(:,:,n), xy, params.templateSize, params.SD);
	correlations = corrCoefs(images(:,:,n), xy, gfilter);
	indices = correlations>params.gaussianTh;
    coefPeaks = peaks(indices);
    myParticles = xy(indices,:);
	myContrasts = ComputeContrast(images(:,:,n), coefPeaks, myParticles, params.innerRadius, params.outerRadius);
    index2 = myContrasts>params.contrastTh;
    contrasts{n} = myContrasts(index2);
    particleXY{n} = myParticles(index2,:);
%     particleXY{n} = myParticles;
%     contrasts = myContrasts;
end

end
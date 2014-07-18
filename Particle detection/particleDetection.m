function [particleXY, contrasts, correlations] = particleDetection(images, params)
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
% 	(Gaussian filtering) gaussianTh, templateSize, SD, innerRadius,
% 	outerRadius, contrastTh
% params.polarization should be set to 'true' if these images are taken
% with polarization
% 
% It may be initialized like this (these are typical values):
% defaultParams = struct('IntensityThresh', 0.6, 'EdgeTh', 2, 'gaussianTh',
% 0.45, 'template', 5, 'SD', 1, 'innerRadius', 9, 'outerRadius', 12, 'contrastTh', 1.01); 
%  params.template must be odd (it won't error out, but it may give
%  unexpected results).

dMin = 2; % minimum distance to be considered a different particle

% SIFT key point detection
particleXY = cell(size(images,3),1);
contrasts = cell(size(images,3),1);
gfilter=fspecial('gaussian',[params.template params.template], 1);
gfilter=gfilter-mean(gfilter(:));
for n = 1:size(images,3)
	kpdata = getParticles(images(:,:,n), params.IntensityThresh, params.EdgeTh);
	xy = kpdata.VKPs(1:2,:)';
	peaks = kpdata.Peaks;
	correlations = corrCoefs(images(:,:,n), xy, gfilter);
    if params.polarization
        indices = correlations>params.gaussianTh | correlations< -1*params.gaussianTh;
    else
        indices = correlations>params.gaussianTh;
    end
    coefPeaks = peaks(indices);
    myParticles = xy(indices,:);
    correlations = correlations(indices);
    
	myContrasts = ComputeContrast(images(:,:,n), coefPeaks, myParticles, params.innerRadius, params.outerRadius);
    if params.polarization
        index2 = myContrasts>params.contrastTh | myContrasts< 1+((params.contrastTh-1)*-1);
    else
        index2 = myContrasts>params.contrastTh;
    end
    contrasts2 = myContrasts(index2);
    myParticles2 = myParticles(index2,:);
    correlations = correlations(index2);
    
    duplicates = removeDuplicates(myParticles2',dMin);
    myParticles2(duplicates,:) = [];
    contrasts2(duplicates) = [];
    correlations(duplicates) = [];
    
    contrasts{n} = contrasts2;
    particleXY{n} = myParticles2;
end

end
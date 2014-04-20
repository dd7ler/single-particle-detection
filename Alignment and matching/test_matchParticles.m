clc
% You should use with test_particleDetection
imr = images(700:1000,700:1000,1:15);
imCell = squeeze(num2cell(imr/2, [1 2]));

nIms = size(imr, 3);
imSize = [size(imr,1) size(imr,2)];
imSizeC = cell(nIms,1); imSizeC(:) = {imSize};
d = [0 0 0; dd];
deltaRCTneg = num2cell(-1*d,2);
% particleRC already exists

% Get matches
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false);
matches = matchParticles(translatedRC, 4);

% make particle list
particleList = trackParticles(particleRC, matches);

% Label Particles with colors
colors = rand(length(particleList), 3);
colors = num2cell(colors,2);
particleList = [particleList colors];


% show labeled particles in the images
labeledIms = imr;
labelRadius = 4;
labeledIms = labelIms(imr, particleList);
writeAlignedTiff(labeledIms, d, outName);
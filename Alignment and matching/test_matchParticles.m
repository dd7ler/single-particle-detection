clc
nIms = size(imr, 3);
imSize = [size(imr,1) size(imr,2)];
imSizeC = cell(nIms,1); imSizeC(:) = {imSize};
deltaRCTneg = num2cell(-1*dd,2);
% particleRC already exists

% Get matches
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false);
matches = matchParticles(translatedRC, 4);

% make particle list
trackList = trackParticles(translatedRC, matches);

% label particles 
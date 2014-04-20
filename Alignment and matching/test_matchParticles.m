nIms = size(imr, 3);
imSize = [size(imr,1) size(imr,2)];
imSizeC = cell(nIms,1); imSizeC(:) = {imSize};
deltaRCTneg = num2cell(-1*dd,2);
% particleRC already exists

% Get matches
translatedRC = cellfun(@translateCoords, particleRC, deltaRCTneg, imSizeC, 'UniformOutput', false)
matches = matchParticles(translatedRC, 4);

% display matches
matchLengths = cellfun(@length, matches);
randomColors = arrayfun(@rand, matchLengths, 3, 'UniformOutput', false);
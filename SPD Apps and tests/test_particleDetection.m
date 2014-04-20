% test particleDetection
% detect particles in an array and draw circles around them
% You must load an (r,c,n) matrix of images

params = struct('IntensityThresh', 0.6, 'EdgeTh', 2, 'gaussianTh', 0.4, ...
	'templateSize', 9, 'SD', 1.5, 'innerRadius', 9, 'outerRadius', 12);
[particleXY, contrasts] = particleDetection(imr, params);
particleRC = cellfun(@fliplr, particleXY, 'UniformOutput', false);

% rescale to 16-bit

th = [0.85, 1.20];
imr = imrescale(imr, median(imr(:))*th(1), median(imr(:))*th(2), 2^16);

labelRadius = 4;
color = 'red';
nImages = size(imr,3);
imCell = squeeze(num2cell(imr/2, [1 2]));
rC = cell(nImages,1); rC(:) = {labelRadius};
colorC = cell(nImages,1); colorC(:) = {color};
labeledIms = cellfun(@drawCircles, imCell, particleXY, rC, colorC, 'UniformOutput', false);

figure; imshow(labeledIms{1}(:,:,1),[]);
% figure; imshow(labeledIms{1}(:,:,2),[]);
% figure; imshow(labeledIms{1}(:,:,3),[]);
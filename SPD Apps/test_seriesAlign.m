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
imDir = pwd;
nameRegEx = '^.*Frame.*\.mat$';
imageVar = 'frame';
mirPath = 'none';
% Overwrite default args
optargs = {imDir, nameRegEx, imageVar, mirPath};
optargs(1:length(varargin)) = varargin(:);
[imDir, nameRegEx, imageVar, mirPath] = optargs{:};

clc
tic

disp('Loading Images...');
images = loadZoirayImages(imDir, nameRegEx, imageVar);
toc
disp(['found ' num2str(size(images,3)) ' images.']);

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
toc

disp('Aligning images...');
% Images are aligned to the first one
deltaRCT = getImOffsets(images);
toc

disp('Writing multipage TIFF...');
images = imrescale(images, min(images(:)), max(images(:)),2^8);
images= uint8(images);
outName = ['seriesAlign' datestr(now) '.tif'];
writeAlignedTiff(images, deltaRCT, outName);
toc

disp('Done!')

end




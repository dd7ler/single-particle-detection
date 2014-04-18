function images =  loadZoirayImages(imageDir, nameRegEx, imageVar)
% LOADZOIRAYIMAGES retrieve a series of images captured with Zoiray software 
% and saved in .mat files.
% 
% images = loadZoirayImages(imageDir, nameRegEx, imageVar) is a 3D double array 
% 	size (r,c,3), such that image i is retrieved with images(:,:,i).
% 	loadZoirayImages searches recursively in the directory 'imageDir' (string) for '.mat' files that match the file regular expression 'nameRegEx'

fList = regexpdir(imageDir, nameRegEx);


% load the first image, so we can preallocate 'images'
s = load(fList{1});
im1 = eval(['s.' imageVar]);
images = zeros(size(im1,1), size(im1, 2), length(fList));
images(:,:,1) = im1;

for n = 2:length(fList)
	s = load(fList{n});
	images(:,:,n) = eval(['s.' imageVar]);
end

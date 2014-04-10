function deltaRCT = getImOffsets(images)
% getImOffsets get the row, column and rotation offsets of a series of images 
% 	from the first one.
% 	
% deltaxyt = alignSeries(IMAGES) is a nx3 matrix, where n is size(IMAGES,3)-1. 
% 	IMAGES is an array of same-size images, such that image i is retrieved with 
% 	images(:,:,i). 
% 
% If size(images,3) ==1, deltaxyt is an empty matrix. Otherwise,
% 	each row of deltaxyt has the form [deltaR, deltaC, deltaTheta], where each 
% 	displacement is measured in pixels from the first image in the series.
% 
% NOTE - Only row and column offsets are implemented so far - not rotation. 
% 	So, the third column is always 0 - for now...

deltaRCT = zeros(3, size(images,3)-1);
for n = 1:size(images,3)-1
	xy = phCorrAlign(images(:,:,1), images(:,:,n+1));
	deltaRCT(a,:) = [xy 0];
end
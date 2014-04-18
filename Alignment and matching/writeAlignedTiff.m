function writeAlignedTiff(images, deltaRCT, tifName)
% WRITEALIGNEDTIFF write a multipage tiff of 'images'. 
% 
% WRITEALIGNEDTIFF(images, deltaRCT, tifName)
% images should have the data type of the desired image bit depth 
% 	- for example, uint8 or uint16.
% deltaRCT is an n x 3 array, where n is size(images,3) and the 
% 	n-th column has the displacements (r, c, theta) of the (n+1)th 
% 	image. The rotation is done first, then displacement.
% tifName can point to a directory, relative to the current 
% 	working directory or in absolute terms.

% Write first image
imwrite(images(:,:,1), tifName,'TIFF', 'writemode', 'append','Compression', 'none');

% Write the rest of the images
for i = 2:size(images,3)
	im = images(:,:,i);
    imr = imrotate(im,deltaRCT(i-1,3),'crop');
	imr(imr == 0) = median(imr(:));
	imrAligned = imtranslate(im, deltaRCT(i-1,1:2));
	imwrite(imrAligned, tifName,'TIFF', 'writemode', 'append','Compression', 'none');
end
function alignedIms = getBWAlignedStack(images, deltaRCT)
% black and white images

alignedIms = zeros(size(images));
for n = 1:size(images,3)
	im = images(:,:,n);
    imr = imrotate(im,deltaRCT(n,3),'crop');
	imr(imr == 0) = median(imr(:));
	alignedIms(:,:,n) = imtranslate(imr, deltaRCT(n,1:2));
end
alignedIms(alignedIms<0.9*median(alignedIms(:))) = median(alignedIms(:));
size(alignedIms);
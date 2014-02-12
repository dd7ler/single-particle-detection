function [preContrast, postContrast, matches, theta, crop_r] = mpcSIFT(pre, post, im_thresh, crop_r,theta_range,TemplateSize, SD, gaussianTh, writeName, saveDir, r_min, r_max, bright_thresh)
% pcSIFT stands for phase correlation SIFT. Phase correlation is used to
% align a pre and post image, allowing for background particles in both the
% post and pre images to be eliminated from the contrast histogram of
% detected particles.
% It hides information about spot and particle positions and particle 
% matching.

% The pre and post images should be normalized to each other, such that
% they have the same background intensity (reference region)

% It has the following parts:
% 1. Align images using phase correlation, over the range of angles
% specified by theta_range.
% 2. Detect the spot in the composite aligned image, and transform its
% position back to the post iamge
% 3. Crop the (untransformed) pre and post images
% 4. Detect particles in the cropped images using SIFT, and filter using
% gaussian convolution
% 5. Align the detected particles to a single reference frame using the
% transform found in (1)
% 6. Find the nearest neighbor of each post particle in the pre image, and
% find the vector distance between them
% 7. Use a mean-shift clustering algorithm to identify the cluster of post
% particles which all have the same (small) offset between themselves and
% their nearest pre particle neighbor
% 8. Make lists of the contrasts of both the unmatched (the interesting
% ones) and the unmatched (the background) post particles.
% 9. Write image files that show the matched and unmatched particles in the
% pre and post images

% clustering threshold
clusterBandwidth = 4;

% local contrast measurment radii
rInner=9;
rOuter=12;

% 0. Image pre-processing: to avoid bad alignment due to large unique
% features like salt crystals, use attuenuated images for alignment.
median_scale = 2000;
pre =  pre/median(pre(:))*median_scale;
post = post/median(post(:))*median_scale;
preAalignIm = pre;
postAalignIm = post;
preAalignIm(pre>bright_thresh) = median_scale;
postAalignIm(post>bright_thresh) = median_scale;

% Align images, get transform between them
[deltax, theta, composite, q] = alignImages(preAalignIm, postAalignIm, theta_range);
% figure; plot(theta_range,q);
progressbar([],[],1/10);
comp = uint16(imrescale(composite,2^16));

if max(q) < mean(q)+3*std(q) % no good alignment was found
	preContrast = [];
	postContrast = [];
	matches = [];
    imwrite(comp, [saveDir filesep 'composite ' writeName],'TIF', 'writemode', 'append');
    return;
end

% Detect spots in composite image

[centroidpre, spot_r] = detectSpot(composite, r_min, r_max);
if crop_r ==0
    crop_r = spot_r;
end
centroidpost = fliplr(rotateCtrlPt(fliplr(centroidpre)-deltax,-theta,size(composite)));
% Draw composite with crop region circle
% red = uint8([255 0 0]);
% particleInserter = vision.ShapeInserter('Shape','Circles','BorderColor','custom','CustomBorderColor',red);
RGB = repmat(comp,[1,1,3]);
% cmp = step(particleInserter, RGB, uint16(round([centroidpre, crop_r])));
cmp = insertShape(RGB, 'circle', [centroidpre, spot_r], 'color', 'red');
imwrite(cmp, [saveDir filesep 'composite ' writeName],'TIF', 'writemode', 'append');
progressbar([],[],2/10);


% Crop images
pre_cropped = cropcircle(pre, centroidpre, crop_r);
post_cropped = cropcircle(post, centroidpost, crop_r);
progressbar([],[],3/10);


% Perform SIFT to get particles
EdgeTh = 2; % This usually never gets changed.
preKPData = getParticles(pre_cropped, im_thresh, EdgeTh);
postKPData = getParticles(post_cropped, im_thresh, EdgeTh);
prexy =   preKPData.VKPs(1:2,:)';
postxy = postKPData.VKPs(1:2,:)';      % Untransformed particle coordinates
prePeaks = preKPData.Peaks;
postPeaks = postKPData.Peaks;

progressbar([],[],4/10);


% Perform Gaussian filtering on the particles. Applied to both contrasts
% and xy coordinates.
post_gaussCorrCoef = gaussianfilter(post_cropped, postxy, TemplateSize, SD);
postPeaks(post_gaussCorrCoef<gaussianTh) = [];
postxy(post_gaussCorrCoef<gaussianTh,:) = [];
pre_gaussCorrCoef = gaussianfilter(pre_cropped, prexy, TemplateSize, SD);
prePeaks(pre_gaussCorrCoef<gaussianTh,:) = [];
prexy(pre_gaussCorrCoef<gaussianTh,:) = [];
progressbar([],[],5/10);

% Compute particle contrasts
preContrast = ComputeContrast(pre_cropped, prePeaks, prexy, rInner, rOuter);
postContrast = ComputeContrast(post_cropped, postPeaks, postxy, rInner, rOuter);

% Align particle coordinates
postxyalign = zeros(size(postxy));
for i = 1:length(postxy)
    postxyalign(i,:) = rotateCtrlPt(fliplr(postxy(i,:)),theta,size(post_cropped));
end
postxyalign = fliplr(postxyalign);
progressbar([],[],6/10);

% Use nearest neighbor analysis to find all unique pairs. Field points = post, query points = pre
numPost = length(postxy); % Need to pad post points if postxy is shorter than prexy
postxy = [postxy; -1e6+rand((length(prexy)- length(postxy) + 2),2)];
pairs = uniqueNN(postxy, prexy); % column 1 is postxy indices, column 2 is prexy indices. postxy = field points, prexy = query point
pairs(find(pairs(:,1)>numPost),:) = []; % eliminate any pairs to the post pad points, if they exist
vecs = postxy(pairs(:,1),:)- prexy(pairs(:,2),:);

progressbar([],[],7/10);
% Show scatterplot of displacement vectors, and the distinct cluster of matching particles
% figure; plot(vecs(:,1),vecs(:,2),'*k');

% Use mean-shift clustering to find the cluster of matching particles
[clustCent,~,clustMembsCell] = MeanShiftCluster(vecs',clusterBandwidth); % vecs input must be mdim x npoints
[~,matchCluster] = min(clustCent(1,:).^2 + clustCent(2,:).^2); % The match cluster is the cluster closest to (0,0) displacement vector which is the largest also
matches = pairs(clustMembsCell{matchCluster},:);

% Save verification images of matched and unmatched particles
matchedPostxy = postxy(matches(:,1),:);
matchedPrexy = prexy(matches(:,2),:);
tifName = [saveDir filesep 'pre particles ' writeName];
imwriteMatchedParticles(pre_cropped,prexy,'green',matchedPrexy,'red',tifName);
tifName = [saveDir filesep 'post particles ' writeName];
imwriteMatchedParticles(post_cropped,postxy,'blue',matchedPostxy,'red',tifName);
progressbar([],[],10/10);

end
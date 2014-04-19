function [matchedContrastPost, unmatchedContrastPost, unmatchedContrastPre, theta, crop_r] = pcSIFT(pre, post, im_thresh, crop_r,theta_range,TemplateSize, SD, gaussianTh, writeName, saveDir, r_min, r_max, bright_thresh)
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

% 1. Align images, get transform between them
[deltax, theta, composite, q] = alignImages(preAalignIm, postAalignIm, theta_range);
figure; plot(theta_range,q);
progressbar([],[],1/10);
comp = uint16(imrescale(composite,2^16));

if max(q) < mean(q)+3*std(q) % no good alignment was found
    matchedContrastPost = [];
    unmatchedContrastPost = [];
    unmatchedContrastPre = [];
    imwrite(comp, [saveDir filesep 'composite ' writeName],'TIF', 'writemode', 'append');
    return;
end

%2. Detect spots in composite image

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


% 3. crop images
pre_cropped = cropcircle(pre, centroidpre, crop_r);
post_cropped = cropcircle(post, centroidpost, crop_r);
progressbar([],[],3/10);


% 4. Perform SIFT to get particles
EdgeTh = 2; % This usually never gets changed.
preKPData = getParticles(pre_cropped, im_thresh, EdgeTh);
postKPData = getParticles(post_cropped, im_thresh, EdgeTh);
prexy =   preKPData.VKPs(1:2,:)';
postxy = postKPData.VKPs(1:2,:)';      % Untransformed particle coordinates
preContrast = preKPData.Peaks;
postContrast = postKPData.Peaks;
progressbar([],[],4/10);


% 5. Perform Gaussian filtering on the particles. Applied to both contrasts
% and xy coordinates.
post_gaussCorrCoef = gaussianfilter(post_cropped, postxy, TemplateSize, SD);
postContrast(post_gaussCorrCoef<gaussianTh) = [];
postxy(post_gaussCorrCoef<gaussianTh,:) = [];
pre_gaussCorrCoef = gaussianfilter(pre_cropped, prexy, TemplateSize, SD);
preContrast(pre_gaussCorrCoef<gaussianTh,:) = [];
prexy(pre_gaussCorrCoef<gaussianTh,:) = [];
progressbar([],[],5/10);


% 6. Align particle coordinates
postxyalign = zeros(size(postxy));
for i = 1:length(postxy)
    postxyalign(i,:) = rotateCtrlPt(fliplr(postxy(i,:)),theta,size(post_cropped));
end
postxyalign = fliplr(postxyalign);
progressbar([],[],6/10);


% 7. Use nearest neighbor analysis to find all possible matches
nearests = nearNeighbourMatch(postxyalign',prexy');
vecs= zeros(length(nearests),2);
dists = zeros(length(nearests),1);
for i = 1:length(nearests)
    post_pt = postxyalign(i,:);
    pre_pt = prexy(nearests(i),:);
    vecs(i,:) = post_pt - pre_pt;
    dists(i) = norm(vecs(i,:));
end
progressbar([],[],7/10);
% Show scatterplot of displacement vectors, and the distinct cluster of matching particles
% figure; plot(vecs(:,1),vecs(:,2),'*k'); 


% 8. Use mean-shift clustering to find the cluster of matching particles
[clustCent,~,clustMembsCell] = MeanShiftCluster(vecs',clusterBandwidth);
[~,matchCluster] = min(clustCent(1,:).^2 + clustCent(2,:).^2); % Set cluster closest to (0,0) to center
% [~, matchCluster] = max(cellfun('size', clustMembsCell, 1)); % Set the matches to be the center cluster
progressbar([],[],8/10);


% 9. get positions and contrasts of matched and unmatched particles
% -- Indices
postxyIDX = 1:size(postxy,1);
prexyIDX = 1:size(prexy,1);
matchedPostIDX = clustMembsCell{matchCluster};
matchedPreIDX = nearests(matchedPostIDX);
unmatchedPostIDX = setdiff(postxyIDX,matchedPostIDX);
unmatchedPreIDX = setdiff(prexyIDX,matchedPreIDX);
% -- Coordinates of matches
matchedPostxy = postxy(matchedPostIDX,:);
matchedPrexy = prexy(matchedPreIDX,:);
unmatchedPostxy = postxy(unmatchedPostIDX,:);
unmatchedPrexy = prexy(unmatchedPreIDX,:);
% -- Contrasts of matched, unmatched pre, and unmatched post
matchedContrastPre = ComputeContrast(pre_cropped, preContrast(matchedPreIDX), matchedPrexy, rInner, rOuter);
matchedContrastPost = ComputeContrast(post_cropped, postContrast(matchedPostIDX), matchedPostxy, rInner, rOuter);
unmatchedContrastPre = ComputeContrast(pre_cropped, preContrast(unmatchedPreIDX), unmatchedPrexy, rInner, rOuter);
unmatchedContrastPost = ComputeContrast(post_cropped, postContrast(unmatchedPostIDX), unmatchedPostxy, rInner, rOuter);

progressbar([],[],9/10);

% 10. Save verification images of matched and unmatched particles
tifName = [saveDir filesep 'pre particles ' writeName];
imwriteMatchedParticles(pre_cropped,prexy,'green',matchedPrexy,'red',tifName);
tifName = [saveDir filesep 'post particles ' writeName];
imwriteMatchedParticles(post_cropped,postxy,'blue',matchedPostxy,'red',tifName);
progressbar([],[],10/10);

end
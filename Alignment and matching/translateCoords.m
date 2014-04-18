function rcOut = translateCoords(pCoords, deltaRCT, imDim)
% TRANSLATECOORDS Perform rotation and translation to a set of 
% 	particle coordinates.
% 
% rcOut = translateCoords(pCoords, deltaRCT, imDim) is an n x 2 
% 	array of the new translated particle coordinates.
% 
% pCoords is an n x 2 array, where n is the number of particles. 
% 	pCoords(k,:) is the (r,c) coordinates of particle k.
% deltaRCT is the translation vector (deltaR, deltaC, deltaTheta). 
% 	Rotation is performed first, then translation.
% imDim is the image size (necessary for rotation).

% rotate the points
ptsC = num2cell(pCoords, 2);
thC = num2cell(deltaRCT(:,3));
dimC = cell(size(pts,1),1);
dimC(:) = {imdim};
rotatedPts = cellfun(@rotateCtrlPt, pts, dimC, th);

% translate the points
rcOut = rotatedPts + deltaRCT(:,1:2);

end
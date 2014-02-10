
function rc_out = rotateCtrlPt(rc,theta,imDim)
% rc is the untransformed coordinates of the point. delta and theta are the
% desired translation and angle offset (degrees) respectively. imDim is the
% [r,c] size of the image. 
% rc_out is the transformed coordinates of the point.

% 1. Rotate the coordinates about the center of the image
t = theta*pi/180;
A = [cos(t), -sin(t)     % Rotation matrix
    sin(t), cos(t)];
centroid = (imDim+1)/2;
x = rc' - centroid';	% coordinates wrt centroid of image
b = A*x;                % rotated coordinates
rc_out = b' + centroid;
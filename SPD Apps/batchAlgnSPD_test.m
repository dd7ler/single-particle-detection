clc
% regular expression for images with timestamps
postxpr = 'Chip\d+_postFrame\d+.mat';
prexpr = 'Chip\d+_preFrame\d+.mat';

mirPath = '/Users/derin/Documents/MATLAB/Carlos Demo/Ryan Green Mirror.mat';
imDir = '/Users/derin/Documents/MATLAB/Carlos Demo';

imageVar = 'frame';
tsPattern = 'Frame(\d*).mat$'; % the timestamp regular expression
cropR=0;
d_min=700;
d_max=900;
im_thresh=0.6;
TemplateSize=9;
SD=1.5;
gaussianTh=0.7;
theta_range=-5:0.2:5;
minSize=0;
maxSize=200;
pixelAreaMicrons=0.0181;
pMaterial='poly';

exptResults = batchAlgnSPD(imDir, mirPath, prexpr, postxpr, imageVar, tsPattern, cropR, r_min, r_max, im_thresh, TemplateSize,SD, gaussianTh,theta_range, minSize, maxSize, pixelAreaMicrons, pMaterial);

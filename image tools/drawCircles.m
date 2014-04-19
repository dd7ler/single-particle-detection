function labeledIm = drawCircles(I, XY, r, color)
% LABELPARTICLES draw circles in an image
% 
% labeledIm = drawCircles(I, XY, r, color)
% 
% I must be an RGB image matrix: It has type uint8 or uint16, and has dimensions (r,c,3).
% XY are the (x,y) coordinates of the particles (reversed of (r,c) image indexing convention)

rArray = r*ones(size(XY,1),1);
labeledIm= insertShape(I, 'circle', [XY rArray], 'color', color);
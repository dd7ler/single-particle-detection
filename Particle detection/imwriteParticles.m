function imwriteParticles(A, filename, particleXY)
% IMWRITEPARTICLES(A, filename, particleXY)
%
% IMWRITEPARTICLES writes an 8-bit PNG image, with particle locations
% circled in red.

im = uint8(imrescale(A, 0.9*median(A(:)), 1.1*median(A(:)), 2^8));

imC = repmat(im, [1,1,3]);
function I = protoImage(particle, imDim, n, noiseVar)
% I = protoImage(particle, imDim, noiseVar)
% 
% Generate a prototype test image, with (r,c) dimensions 'imDim', 'n' particles that look like 'particle', and some noise.

im = ones(imDim(1), imDim(2));

[pr,pc] = size(particle);

% Add particles to the image
for k = 1:n
	dr = rand*imDim(1); % coordinates of this particle
	dc = rand*imDim(2);

	
end

% Add noise
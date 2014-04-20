function particleList = trackParticles(particleRC, matches)
% TRACKPARTICLES track matched particles.
% 
% particleList = trackParticles(particleRC, matches)
% particleRC is a cell array of [nx2] (r,c) coordinates for 
% 	particles in each image.
% matches is a cell array of [nx2] match arrays.
% 
% particleList is a cell array of all the particles detected in 
% 	all the images. For particle n, particleList(n,1) is an array 
% 	of which images that particle was in (i.e., [1 2 3]). particleList(n,2) is an array of (r,c) particle coordinates in those images.

% First Image
particleList = cell(size(particleRC{1},1),1);
particleList(:) = {1};
firstCoords = particleRC{1};
particleList(:,2) = num2cell(particleRC{1},2); % first image coordinates

for n = 1:length(matches)
	nCoordinates = particleRC{n};

	matchedIdx = matches{n}(:,1); % indices of particles in the previous image

	% append index n to matched particles
	nCell = cell(size(matchedIdx,1));
	cellfun(@(x,y) [x;y], particleList(matchedIdx,1), nCell);
	% append coordinates to matched particles
	
end
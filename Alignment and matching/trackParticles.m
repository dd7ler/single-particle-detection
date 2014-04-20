function trackList = trackParticles(rc, unsrtmatches)
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

trackList = ones(length(rc{1}),1); % initialization with the first image
trackList = num2cell(trackList);
particleNames = 1:length(rc{1});

lut = repmat([1:length(rc{1})]',1,2); % dummy initialization lut

% matches gotta be sorted by first column
oneC = cell(size(unsrtmatches));
oneC(:) = {1};
matches = cellfun(@sortrows, unsrtmatches,oneC,'UniformOutput', false);

for n = 2:length(rc)
	 % crazy indexing magic to update lut
	[C, lutIdx, ~] = intersect(lut(:,1), matches{n-1}(:,1),'stable');
	lut = [matches{n-1}(:,2) lut(lutIdx,2)];

	lastName = length(particleNames);
	unmatchedNames = lastName + (1:(length(rc{n})-length(matches{n-1})));
	allNew = 1:length(rc{n});
	unmatched = setdiff(allNew, lut(:,1)');
	lut = [lut; [unmatched', unmatchedNames']];
	lut = sortrows(lut, 1) % gotta sort it
	trackList = [trackList; cell(length(unmatchedNames),1)];
	for x = 1:length(lut)
		trackList{lut(x,2)} = [trackList{lut(x,2)} n];
	end
	particleNames = 1:max(lut(:,2));
end
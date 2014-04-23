function particleList = trackParticles(rc, matches)
% TRACKPARTICLES track matched particles.
% 
% particleList = trackParticles(rc, matches)
% particleRC is a cell array of [nx2] (r,c) coordinates for 
% 	particles in each image.
% matches is a cell array of [(n-1)x2] match arrays. 
% 
% particleList is a cell array of all the particles detected in 
% 	all the images. For particle n, particleList(n,1) is an array 
% 	of which images that particle was in (i.e., [1 2 3]). particleList(n,2) is an array of (r,c) particle coordinates in those images.

pList = ones(length(rc{1}),1);
particleList = [num2cell(pList) num2cell(rc{1},2)];
particleNames = 1:length(rc{1});

lut = repmat([1:length(rc{1})]',1,2); % dummy initialization lut

% matches gotta be sorted by the first column
oneC = cell(size(matches));
oneC(:) = {1};
matches = cellfun(@sortrows, matches,oneC,'UniformOutput', false);

for n = 2:length(rc)
	 % crazy indexing magic to update lut
	[C, lutIdx, ~] = intersect(lut(:,1), matches{n-1}(:,1),'stable');
	lut = [matches{n-1}(:,2) lut(lutIdx,2)];
	lastName = length(particleNames);
	unmatchedNames = lastName + (1:(length(rc{n})-length(matches{n-1})));
	allNew = 1:length(rc{n});
	unmatched = setdiff(allNew, lut(:,1)');
	lut = [lut; [unmatched', unmatchedNames']];
	lut = sortrows(lut, 1); % gotta sort it
	particleList = [particleList; cell(length(unmatchedNames),2)];
	for x = 1:length(lut)
		particleList(lut(x,2),:) = {[particleList{lut(x,2),1} n], [particleList{lut(x,2),2}; rc{n}(lut(x,1),:)]};
	end
	particleNames = 1:max(lut(:,2));
end
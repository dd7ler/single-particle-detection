function sites = findSites(pList, bandWidth)
% FINDPERSISTERS find persisting sites. 
% sites is a list of all unique locations found in an image. Every particle has a site, and particles can share the same site, but not at the same time.

averageLocs = cellfun(@(x) sum(x,1)/length(x), pList(:,2), 'UniformOutput',false);

particlesHere = {1}; % Initialize first particle index
imagesHere = pList(1,1);
locations = averageLocs{1}; % Initialize first particle coordinates

progressbar(0)
for n = 2:length(pList)
	% Get all the sites which are available in all of my images
	myIms = pList(n,1);
	myImsC = repmat(myIms, size(imagesHere));
	takenSites = cellfun(@ismember, myImsC, imagesHere, 'UniformOutput', false);
	openSites = particlesHere(~cellfun(@nnz, takenSites));
	if isempty(openSites)
		% make a new site
		particlesHere = [particlesHere {n}];
		imagesHere = [imagesHere myIms];
	else

	myPoint = averageLocs{n};
	locations(k,:)
	d = sqrt(sum((locations(k,:)-myPoint).^2)); % distance of closest point
	if d<bandWidth
		% append to this site
		sites(k) = {[sites{k} n]};
		disp(['appended to ' num2str(k) '!']);
	else
		% make a new site
		particlesHere = [particlesHere {n}];
		imagesHere = [imagesHere myIms];
	end
	progressbar(n/length(pList));
end
		
function matches = matchParticles(particles,clusterBandwidth)
% matchParticles match particles in a series of aligned images
% 
% matches = matchParticles(particles, clusterBandwidth)
% 
% 'particles' is a cell array of matrices. The matrix at particles{k} 
% 	has dimensions m x 2, where m is the number of particles in 
% 	image k. Each row corresponds to the (r,c) coordinates
%	of one detected particle.
% 
% clusterBandwidth is the spacing for clustering - default = 4
% 
% 'matches' is a cell array with a length equal to (length(particles)-1). 
%	matches{n} is an a x 2 array, where 'a' matches were found between 
% 	particles{n} and particles{n+1}. Each match is represented by the 
% 	indices of the coordinates in particles{n} (at matchesand particles{n+1}.
% 
% This function uses uniqueNN (unique nearest neighbor) and 
% 	MeanShiftCluster (clustering).

matches = cell(size(particles)-1);
for n = 1:length(particles)-1
	p1 = particles{n};
	p2 = particles{n+1};

	% find nearest neighbors. Query points in image n, field points in image n+1
	p2origL = length(p2);
	p2padded = [p2; -1e4+rand((length(p1)- length(p2) + 2), 2)]; % p2 must have at least 2 more points than p1
	pairs = uniqueNN(p2padded, p1);
	pairs(pairs(:,1)>p2origL,:) = []; % eliminate any pairs made to pad points

	% find neighbors which correspond to matches.
	vecs = p2(pairs(:,1),:)- p1(pairs(:,2),:);
	% plot(vecs(:,1), vecs(:,2), '*b');
	[clustCent,~,clustMembsCell] = MeanShiftCluster(vecs',clusterBandwidth); % vecs input must be mdim x npoints
	[~,matchCluster] = min(clustCent(1,:).^2 + clustCent(2,:).^2); % The match cluster is the cluster closest to (0,0) displacement vector which is the largest also

	m = pairs(clustMembsCell{matchCluster},:);
	matches(n) = {fliplr(m)};
end
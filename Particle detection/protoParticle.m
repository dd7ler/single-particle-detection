% A script for measuring prototypical particle parameters (brightness etc),
% so they can be reliably detected in all images. The idea is to 'teach'
% the computer which features are particles. Yay machine learning!


load smallIm

%% Get prototype particle

close all;
figure; imshow(imc,[])

N = 4;
coords = zeros(N,2);
for k= 1:N
    hold on
    [x,y]=ginput(1);
    plot(x,y,'*r')
    coords(k,:) = [x,y];
end
coords = round(coords);

%% Get Particle Regions
rs = 9; % half-width of region. 6 gets the whole thing, it seems
regions = zeros(rs*2+1,rs*2+1,N);
for k= 1:N
    regX = (coords(k,1)-rs):(coords(k,1)+rs);
    regY = (coords(k,2)-rs):(coords(k,2)+rs);
    regions(:,:,k) = imc(regY, regX);
end

figure;
for k = 1:N
    subplot(4,3,k); imshow(regions(:,:,k),[]);
end

%% Register the particles and average them together


% This needs to be fixed
for k = 1:N
    [approxNA, xOut, x0, resid] = airyFit(regions(:,:,k), 532, 7.4, 153.5, .75, false);
    xOut
end
% Script for measuring PSFs in an image, manually.

%% Get an image
clear
disp(datestr(now));
close all;
[fname, fpath] = uigetfile('*');

if fname ==0
    disp('No file selected');
    return
end

frame = double(imread([fpath fname]));
figure; title('Crop a region, double-click to select...');
im = imcrop(frame,[]);
close

%% select particles
figure; imshow(im,[]); title('Select Particles, press Enter to finish');
[x,y] = getpts; %http://www.mathworks.com/help/images/ref/getpts.html
close;
x = round(x); y = round(y);

%% Meaure gaussian parameters of each of these

rS = 3; % It seems that lsqcurvefit guesses better when rS is small
clear regions
regions = zeros(rS*2+1, rS*2+1, length(x));
for k = 1:length(x)
    rr = (y(k)-rS):(y(k)+rS); rr(rr<1) = 1; rr(rr>size(im,1)) = size(im,1);
    cc = (x(k)-rS):(x(k)+rS); cc(cc<1) = 1; cc(cc>size(im,2)) = size(im,2);
	regions(:,:,k) = im(rr,cc);
end
reg = imrescale(regions, min(regions(:)), max(regions(:)),1);

xdata = zeros(rS*2+1,rS*2+1,2);
[xdata(:,:,1), xdata(:,:,2)] = meshgrid(-1*rS:rS, -1*rS:rS);

gKernel = gaussFn(x0,xdata);

opts = optimset('Display', 'off');
lb = [-1*rS -1*rS 0.3 0 0];
ub = [rS rS 5 1e3 1e3 ];
SD = zeros(size(regions,3),1);
drP = SD;
dcP = SD;
for n = 1:size(regions,3)
    x0 = [0 0 1.1 1 1]; % first guess
	[xOut, ~, resid] = lsqcurvefit(@gaussFn, x0, xdata, regions(:,:,n)', lb, ub, opts);
	drP(n)= xOut(1);
    dcP(n)= xOut(2);
    SD(n)= xOut(3);
    
end
figure;
SD2 =SD(SD<30 & SD>0); 
hist(SD(SD<30 & SD>0),20); title(['region width is ' num2str(rS) ', ' num2str(size(SD2,1)) ' particles fitted']);
disp(['Median standard deviation is ' num2str(median(SD))]);

calcSD = median(SD2);
%% Get their correlation coefficients to our gaussian filter
template = 5;

drcP = [dcP, drP];
xyP = drcP + [x,y];
xyP = round(xyP);
movedRegions = zeros(template*2+1, template*2+1, length(x));
for k = 1:length(x)
    rr = (xyP(k,2)-template):(xyP(k,2)+template); rr(rr<1) = 1; rr(rr>size(im,1)) = size(im,1);
    cc = (xyP(k,1)-template):(xyP(k,1)+template); cc(cc<1) = 1; cc(cc>size(im,2)) = size(im,2);
	movedRegions(:,:,k) = im(rr,cc);
%     figure; imshow(im(rr,cc),[]);
end
gfilter=fspecial('gaussian',[template template], 1);
gfilter=gfilter-mean(gfilter(:));
correlations = corrCoefs(im, xyP', gfilter);
figure; hist(correlations,20); title(['Template size is ' num2str(template*2)]);

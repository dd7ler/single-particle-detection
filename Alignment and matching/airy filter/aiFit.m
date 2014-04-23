function [ correlation ] = aiFit(crop,aiFilter)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%averages only the peak
% backMaskMean=mean(mean(aiFilter.aiMask(~aiFilter.peakMask(:))));
% backCropMean=mean(mean(crop(~aiFilter.peakMask(:))));

%Logical Array of pixels inside first airy peak
peakMask=aiFilter.peakMask;


%averages the whole mask
peakMaskMean=mean(mean(aiFilter.aiMask(peakMask(:))));
peakCropMean=mean(mean(crop(peakMask(:))));

% backMaskMean=max(max(aiFilter.aiMask(peakMask(:))));
% backCropMean=max(max(crop(peakMask(:))));

[aiScaled]=aiFilter.aiMask-peakMaskMean;
[cropScaled]=crop-peakCropMean;

%averages only the peak
% peakMask=max(max(aiScaled(aiFilter.peakMask(:))));
% peakCrop=max(max((cropScaled(aiFilter.peakMask(:)))));

%averages the whole mask
% peakAvg=max(max(aiScaled()));
% peakCrop=max(max((cropScaled(:))));


% powerScale=peakMask/peakCrop;
% [cropScaled]=cropScaled*powerScale;

correlation = sum(sum(aiScaled(peakMask(:)).*cropScaled(peakMask(:))))/sqrt(sum(sum(aiScaled(peakMask(:)).^2))*sum(sum(cropScaled(peakMask(:)).^2)));



ks=aiFilter.kernelSize;
khalf=(ks-1)/2;
kband=linspace(khalf*-1,khalf,ks);

% figure;
% hold on;
% 
% 
% plot(kband,aiScaled(1+khalf,:),'-b',kband,cropScaled(1+khalf,:),'r',kband,cropScaled(:,1+khalf),'g');
% hold off



end


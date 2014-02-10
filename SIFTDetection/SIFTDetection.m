function [KPData]= SIFTDetection(InputIm, IntensityTh, EdgeTh, MatchFlag, ImScale)

%Upsample the image to enlargen the features:
UpInputIm=single(imresize(InputIm,ImScale,'bilinear'));
%Normalize the upsampled image
UpNormInputIm=UpInputIm-min(UpInputIm(:));
UpNormInputIm=255*UpNormInputIm./max(UpNormInputIm(:));

%[BWAnomalyMap]= GetAnomalyMap(UpNormInputIm);
%figure, imagesc(BWAnomalyMap), axis image, colormap gray, title('Anomaly
%map of the chip');

if MatchFlag==1
    [KPData.KPs,KPData.Feats] = vl_sift(UpNormInputIm, 'PeakThresh',IntensityTh,'EdgeThresh',EdgeTh);
else
    [KPData.KPs,~] = vl_sift(UpNormInputIm, 'PeakThresh',IntensityTh,'EdgeThresh',EdgeTh);
end

[KPData.VKPs]= ComputeVisualKeyPoints(KPData.KPs,ImScale, size(InputIm));


%figure, imagesc(UpNormInputIm),axis image, colormap gray, title(['SIFT detector with peak threshold= ', num2str(peakthresh)...
%    , ' and curvature threshold= ', num2str(edgethresh)]),hold on
%h=vl_plotframe(KeyPoints);

% %Range filtering
% [AnY, AnX] =find(BWAnomalyMap==1);
% LinearAnIndices= sub2ind(size(UpNormInputIm),AnY, AnX);
% LinearKeyLocs= sub2ind(size(UpNormInputIm), KeyPoints(2,:)',KeyPoints(1,:)');
% InAnomaly=repmat(LinearAnIndices(:)',length(LinearKeyLocs),1)-repmat(LinearKeyLocs(:),1,length(LinearAnIndices));
% [InAnomaly,dummy]=find(InAnomaly==0);
% KeyPoints(:,InAnomaly)=[];
% 
% figure, imagesc(UpNormInputIm),axis image, colormap gray, title('SIFT detector after range fltering'), hold on
% h=vl_plotframe(KeyPoints);
% 
% %Map the key points to the original image:
% KeyPoints=round(KeyPoints./ImScale);
% 
% %Gaussian Thresholding
% KernelSigma=2;
% [GaussianCorrCoefs]=GaussianTemplateMatch(InputIm, KeyPoints, [10 10], KernelSigma);
% GaussianTh=0.7;
% SimilartoGaussian=GaussianCorrCoefs > GaussianTh;
% KeyPoints=KeyPoints(:,SimilartoGaussian);
% figure, imagesc(InputIm),axis image, colormap gray, title(['Gaussian-fit based elimination with NCC threshold= ',...
%     num2str(GaussianTh)]), hold on
% h=vl_plotframe(KeyPoints);
% 
% 
% 
% %figure, hist(IFiltKeyPoints(3,:),15), title('Distribution of size of detected particles');
% 
% %Elimination by manual selection:
% % BigSpots= find(IFiltKeyPoints(3,:) >8);
% % SmallSpots= find(IFiltKeyPoints(3,:)<0);
% 
% %Size base elimination using median absolute deviation:
% SizeMAD=mad(KeyPoints(3,:),1);
% SizeMedian=median(KeyPoints(3,:));
% FactorSize=3;
% BigSizeTh = SizeMedian + FactorSize*SizeMAD;
% %SmallSizeTh = SizeMedian - FactorSize*SizeMAD;
% 
% BigSpots= find(KeyPoints(3,:) > BigSizeTh);
% %SmallSpots= find(KeyPoints(3,:)< SmallSizeTh);
% 
% SizeFiltKeyPoints=KeyPoints;
% SizeFiltKeyPoints(:,BigSpots)=[];
% 
% %figure, imagesc(UpNormInputIm),axis image, colormap gray, title('Filtering using size'), hold on
% %h=vl_plotframe(SizeFiltKeyPoints);
% 
% %         PixelLocations=round(SizeFiltKeyPoints(1:2,:)).';
% %         PixelLocations=sub2ind(size(UpNormInputIm),PixelLocations(:,2),PixelLocations(:,1));
% %         PixelIntensities=UpNormInputIm(PixelLocations);
% %          figure, hist(PixelIntensities,15), title('Distribution of peak intensity of detected particles');
% 
% %Elimination by manual selection:
% % LowIntensity=find(PixelIntensities < 40);
% % HighIntensity=find(PixelIntensities > 60);
% 
% %         %Intensity based elimination using median absolute deviation:
% %         PixelIntensitiesMAD=mad(PixelIntensities,1);
% %         PixelIntensitiesMedian=median(PixelIntensities);
% %         FactorIntensityHigh=2;
% %         %FactorIntensityLow=1;
% %         HightIntensityTh = PixelIntensitiesMedian + FactorIntensityHigh*PixelIntensitiesMAD;
% %         %LowIntensityTh = PixelIntensitiesMedian -FactorIntensityLow*PixelIntensitiesMAD;
% %
% %         %LowIntensity=find(PixelIntensities < LowIntensityTh );
% %         HighIntensity=find(PixelIntensities > HightIntensityTh);
% %
% %         %Remove the intensity outliers from the dataset:
% %         SizeIFiltKeyPoints=SizeFiltKeyPoints;
% %         SizeIFiltKeyPoints(:,HighIntensity)=[];
% %
% %         figure, imagesc(UpNormInputIm),axis image, colormap gray, title('Filtering using intensity and size'), hold on
% %         h=vl_plotframe(SizeIFiltKeyPoints);
% 
% FolderCounts{folderindex}{dataindex,2}=length(SizeFiltKeyPoints);

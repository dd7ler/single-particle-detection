function [GaussianCorrCoefs]=GaussianTemplateMatch(Image, KeyPoints, KernelSize, Sigma)

if nargin <4
    Sigma=1;
end

if nargin <3
    KernelSize=[11 11];
end

if nargin <2
    error('Function:Input:Issue','Keypoints vector is missing!');
end


NumKeyPoints=size(KeyPoints,2);
GaussianCorrCoefs=zeros(NumKeyPoints,1);
halfkernelsize=(KernelSize(1)-1)/2;

GaussianPatch=fspecial('gaussian',[KernelSize KernelSize], Sigma);

for keypoint=1:NumKeyPoints
    TempXLoc =round(KeyPoints(1,keypoint));
    TempYLoc =round(KeyPoints(2,keypoint));
    GaussianPatch=GaussianPatch-mean(GaussianPatch(:));
    
    XLocStart=TempXLoc-halfkernelsize;
    XLocEnd=TempXLoc+halfkernelsize;
    YLocStart=TempYLoc-halfkernelsize;
    YLocEnd=TempYLoc+halfkernelsize;
    %Check for boundaries:
    if XLocStart > 0 && YLocStart >0
        if XLocEnd <size(Image,2) && YLocEnd <size(Image,1)
            TempImagePatch=Image(YLocStart:YLocEnd,XLocStart:XLocEnd);
            TempImagePatch=TempImagePatch-mean(TempImagePatch(:));
            GaussianCorrCoefs(keypoint)=sum(sum(GaussianPatch.*TempImagePatch))/sqrt(sum(sum(GaussianPatch.^2))*sum(sum(TempImagePatch.^2)));
            
        else
            GaussianCorrCoefs(keypoint)=0;
            continue;
        end
    else
        GaussianCorrCoefs(keypoint)=0;
        continue;
    end
end
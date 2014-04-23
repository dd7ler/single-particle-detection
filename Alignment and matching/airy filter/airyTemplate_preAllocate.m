function [correlations]=airyTemplate_preAllocate(Image, KeyPoints, KernelSize, NA, backradius,pixel_image,Contrasts,showcrop_flag)
% 




% if nargin <4
%     Sigma=1;
% end

if nargin <3
    KernelSize=[11 11];
end

if nargin <2
    error('Function:Input:Issue','Keypoints vector is missing!');
end


NumKeyPoints=size(KeyPoints,2);
correlations=zeros(NumKeyPoints,1);
halfkernelsize=(KernelSize(1)-1)/2;



% tic;
patch_array=cell(11,11);

for m=1:11;
    for n=1:11;
        patch_array{n,m}=(filtergen_AIRY_v2(KernelSize(1),[(n-6)/10 (m-6)/10],NA,backradius,pixel_image));
    end
end
% disp(['Patch Allocation time: ' num2str(toc)]);


% tic;
for keypoint=1:NumKeyPoints
    RawXLoc=KeyPoints(1,keypoint);
    TempXLoc =round(KeyPoints(1,keypoint));
    dx=RawXLoc-TempXLoc;
    RawYLoc=KeyPoints(2,keypoint);
    TempYLoc =round(KeyPoints(2,keypoint));
    dy = RawYLoc-TempYLoc;
    
    
%    GaussianPatch=GaussianPatch-mean(GaussianPatch(:));
    
    
    XLocStart=TempXLoc-halfkernelsize;
    XLocEnd=TempXLoc+halfkernelsize;
    YLocStart=TempYLoc-halfkernelsize;
    YLocEnd=TempYLoc+halfkernelsize;
    %Check for boundaries:
    if XLocStart > 0 && YLocStart >0
        if XLocEnd <size(Image,2) && YLocEnd <size(Image,1)
%             scaling is done in aiFit
%             airyPatch = (filtergen_AIRY_v2(KernelSize(1),[dx dy],NA,backradius,pixel_image));
            X_ind=round(dx*10)+6;
            Y_ind=round(dy*10)+6;
            
            
            TempImagePatch=Image(YLocStart:YLocEnd,XLocStart:XLocEnd);
            correlations(keypoint)=aiFit(TempImagePatch,patch_array{X_ind,Y_ind});
            
%             showcrop_flag=0;
            if showcrop_flag
                if (correlations(keypoint)>.8)&&((Contrasts(keypoint)>1.05)&&(Contrasts(keypoint)<1.1))
                    
                    [maxIm,~]=max(TempImagePatch(:));
                    [minIm,~]=min(TempImagePatch(:));
                    tempRange=maxIm-minIm;
                    
                    
                    templateScale=airyPatch.aiMask;
                    [minTemplate,~]=min(templateScale(:));
                    templateScale=templateScale-minTemplate;
                    templateScale=templateScale*tempRange;
                    
                    
                    templateScale=templateScale+minIm;
                    
                    
                    
                    tempf=figure;
                    subplot(221);
                    surf(TempImagePatch);
                    title(['Particle - Contrast: ' num2str(Contrasts(keypoint))]);
                    view(2);
                    
                    subplot(223);
                    surf(TempImagePatch);
                    title(['Particle - Contrast: ' num2str(Contrasts(keypoint))]);
                    view(0,0);
                    
                    subplot(222);
                    surf(templateScale);
                    title(['Template: - Correlation: ' num2str(correlations(keypoint))]);
                    view(2);
                    
                    subplot(224);
                    surf(templateScale);
                    title(['Template: - Correlation: ' num2str(correlations(keypoint))]);
                    view(0,0);
                    
                    close(tempf);
                    
                end
            end
                        
            
%        
        else
            correlations(keypoint)=0;
            continue;
        end
    else
        correlations(keypoint)=0;
        continue;
    end
end
% disp(['PSF preallocated time for ' num2str(NumKeyPoints) ': ' num2str(toc)]);
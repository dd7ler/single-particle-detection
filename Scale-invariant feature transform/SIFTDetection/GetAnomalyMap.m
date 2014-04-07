function [BWAnomalyMap]= GetAnomalyMap(Image,Th)

if nargin <2
    Th=2;
end

Image=Image-min(Image(:));
Image=255*Image./max(Image(:));

dilateI = imdilate(Image,ones(5,5));
erodeI = imerode(Image,ones(5,5));
ContrastMap = dilateI./erodeI;

BWContrastMap=ContrastMap> Th;

BWAnomalyMap=imclose(BWContrastMap,ones(5,5));
BWAnomalyMap=imfill(BWAnomalyMap,'holes');

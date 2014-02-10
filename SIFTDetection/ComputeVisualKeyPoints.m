function [VisualKeyPoints]= ComputeVisualKeyPoints(KeyPoints, ImScale, ImSize)

%Key points with same location must be eliminated.

% KeyPointsLocs=KeyPoints(1:2,:);
% NumPoints=size(KeyPointsLocs,2);
% KeyPointsLocsRep = KeyPointsLocs(:).';
% KeyPointsLocsRep = repmat(KeyPointsLocsRep,NumPoints,1);
% DiffLocations = abs(repmat(KeyPointsLocs.',1,NumPoints)-KeyPointsLocsRep);
% 
% DiffLocations1 = DiffLocations(:,1:2:end);
% DiffLocations2 = DiffLocations(:,2:2:end);
% DiffLocationsTotal = DiffLocations1+DiffLocations2;
% DiffLocationsZero = DiffLocationsTotal==0;
% 
% ExtraPoints=[];
% for keyindex=1:NumPoints
%     Templocation=DiffLocationsZero(:,keyindex);
%     if sum(Templocation)>1
%         tempsame=find(Templocation==1);
%         ExtraPoints= [ExtraPoints;tempsame(2:end)];
%     else
%         continue
%     end
% end
% 
% VisualKeyPoints=KeyPoints; 
% VisualKeyPoints(:,ExtraPoints)=[];
% VisualKeyPoints=VisualKeyPoints./ImScale;

KeyPointsLocs=KeyPoints(1:2,:);
[VisualKeyPoints, IndicesFrom ] = unique(KeyPointsLocs', 'rows');
VisualKeyPoints = [VisualKeyPoints'./ImScale; KeyPoints(3,IndicesFrom)./ImScale; KeyPoints(4,IndicesFrom)];

%Some keypoints might be located outside the image, these points must be
%pulled to the closest image pixel location:

LargerRow = VisualKeyPoints(2,:) > ImSize(1);
VisualKeyPoints(2,LargerRow) = ImSize(1);
SmallerRow = VisualKeyPoints(2,:) < 1;
VisualKeyPoints(2,SmallerRow) = 1;

LargerColumn = VisualKeyPoints(1,:) > ImSize(2);
VisualKeyPoints(1,LargerColumn) = ImSize(2);
SmallerColumn = VisualKeyPoints(1,:) < 1;
VisualKeyPoints(1,SmallerColumn) = 1;

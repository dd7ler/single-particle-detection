function [VisualMatches] = ComputeVisualMatches(Matches, KPs1, KPs2)

KPs1Locs=KPs1(1:2, Matches(1,:));
KPs2Locs=KPs2(1:2, Matches(2,:));

AllLocs=[KPs1Locs; KPs2Locs];
ExtraMatches=[];

for i=1:size(AllLocs,2)
    TempCol=AllLocs(:,i);
    TempCol=repmat(TempCol,1,size(AllLocs,2));
    TempColReps= find(sum(abs(AllLocs-TempCol)).'==0);
    ExtraMatches=[ExtraMatches; TempColReps(2:end)];
end

VisualMatches=Matches;
VisualMatches(:, ExtraMatches)=[];
 
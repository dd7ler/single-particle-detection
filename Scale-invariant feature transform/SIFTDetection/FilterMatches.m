function RefinedVisualMatches = FilterMatches(VisualMatches,KPs1, KPs2)

X1= KPs1(1,VisualMatches(1,:));
Y1 =KPs1(2,VisualMatches(1,:));


X2= KPs2(1,VisualMatches(2,:));
Y2= KPs2(2,VisualMatches(2,:));

TransX=abs(X1-X2);
TransY=abs(Y1-Y2);

MedX = median(TransX);
EpsX =1;
MedY = median(TransY);
EpsY =1;

RefinedX = TransX > MedX-EpsX & TransX < MedX + EpsX;
RefinedY = TransY > MedY-EpsY & TransY < MedY + EpsY;

RefinedMatches=RefinedX & RefinedY;

RefinedVisualMatches=VisualMatches(:, RefinedMatches);
%figure, plot(TransX, TransY, 'x');
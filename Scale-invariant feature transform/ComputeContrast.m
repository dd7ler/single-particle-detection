function ParticleContrasts= ComputeContrast(frame, PeakValues, peakLocations, innerRadius, outerRadius)

medianVals = zeros(size(PeakValues));
padF = padarray(frame,[outerRadius, outerRadius]);

for i = 1:size(peakLocations,1)
	yx = round(peakLocations(1,:) + outerRadius);
	y = yx(1);
	x = yx(2);
	region = frame((y - outerRadius):(y+outerRadius), (x - outerRadius):(x+outerRadius));
    [rr,cc] = meshgrid((y-outerRadius):(y+outerRadius),(x-outerRadius):(x+outerRadius));
    mask = ~(sqrt((rr-y).^2+(cc-x).^2)>=outerRadius | sqrt((rr-y).^2+(cc-x).^2)<=innerRadius ...
        | rr<1 | rr>size(frame,1) | cc<1 | cc>size(frame,2));
    overlap = region.*mask;
    medianVals(i)= median(overlap(overlap~=0));
end
ParticleContrasts = PeakValues./medianVals;
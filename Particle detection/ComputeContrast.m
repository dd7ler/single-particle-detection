function ParticleContrasts= ComputeContrast(frame, PeakValues, peakLocations, innerRadius, outerRadius)
% PARTICLECONTRASTS determine particle local contrasts
% 
% ParticleContrasts= ComputeContrast(frame, PeakValues, peakLocations, innerRadius, outerRadius)

medianVals = zeros(size(PeakValues));
padF = padarray(frame,[outerRadius, outerRadius]);

for i = 1:size(peakLocations,1)
	rc = round(peakLocations(1,:));
	r0 = rc(1) - outerRadius; if r0 < 1, r0 = 1; end;
	r1 = rc(1) + outerRadius; if r1 > size(frame,1), r1 = size(frame,1); end;
	c0 = rc(2) - outerRadius; if c0 < 1, c0 = 1; end;
	c1 = rc(2) + outerRadius; if c1 > size(frame,2), c1 = size(frame,2); end;
	region = frame(r0:r1, c0:c1);
    [rr,cc] = meshgrid(r0:r1, c0:c1);
    mask = ~(sqrt((rr-r).^2+(cc-c).^2)>=outerRadius | sqrt((rr-r).^2+(cc-c).^2)<=innerRadius);
    overlap = region.*mask;
    medianVals(i)= median(overlap(overlap~=0));
end

ParticleContrasts = PeakValues./medianVals;
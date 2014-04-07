% Simple image alignment using phase correlation
% Translation only, does not account for rotation.
% Sauce: http://www.mathworks.com/matlabcentral/newsreader/view_thread/22794

function [delta,q] = phCorrAlign(I1, I2)
% delta is the [row, column] displacement of I2 relative to I1.

block_outer = 300;

% Take FFT of each image
F1 = fft2(I1);
F2 = fft2(I2);

% Create phase difference matrix
pdm = exp(1i*(angle(F1)-angle(F2)));
% Solve for phase correlation function
pcf = real(ifft2(pdm));
pcf = fftshift(pcf);
center = floor(size(pcf)/2)+1;

pcf(center(1), center(2)) = 0;
v = pcf((center(1)-1):(center(1)+1), (center(2)-1):(center(2)+1));

pcf(center(1), center(2)) = sum(v(:))./8;

[r,c] = meshgrid(1:size(pcf,1), 1:size(pcf,2));
mask = sqrt((r-size(pcf,1)/2).^2 + (c-size(pcf,2)/2).^2) > block_outer;
pcf(mask) = 0;

figure; imagesc(pcf);
colorbar;
[q, idx] = max(pcf(:));
[r, c] = ind2sub(size(pcf),idx);
v = [r c];
delta = v - center;

roi = pcf(r-5:r+5, c-5:c+5);
P = peakfit2d(roi);

v = P - (floor(size(roi)/2) + 1) + [r c];
delta = v - center;
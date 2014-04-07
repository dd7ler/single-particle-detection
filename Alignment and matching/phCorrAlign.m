% Simple image alignment using phase correlation
% Translation only, does not account for rotation.
% Sauce: http://www.mathworks.com/matlabcentral/newsreader/view_thread/22794

function [delta,q] = phCorrAlign(I1, I2)
% delta is the [row, column] displacement of I2 relative to I1.

block_r=0;
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
% figure; imagesc(pcf);
% colorbar;
% rr = (center(1)-block_r):(center(1)+block_r);
% cc = (center(2)-block_r):(center(2)+block_r);

pcf(center(1), center(2)) = 0;
[r,c] = meshgrid(1:size(pcf,1), 1:size(pcf,2));
mask = sqrt((r-size(pcf,1)/2).^2 + (c-size(pcf,2)/2).^2) > block_outer;
pcf(mask) = 0;

% figure; imagesc(pcf);
% colorbar;
[q, idx] = max(pcf(:));
[r, c] = ind2sub(size(pcf),idx);
v = [r c];
delta = v - center;

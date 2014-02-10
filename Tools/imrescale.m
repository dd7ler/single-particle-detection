function I2 = imrescale(I, maxVal)
% rescales an image to the max specified, wihtout altering data. I2 type is
% double.
I2 = maxVal*(I - min(I(:)))./range(I(:));
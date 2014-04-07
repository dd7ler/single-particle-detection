function I2 = imrescale(I, minVal, maxVal,bitSize)
% rescales an image to fill the range 'bitsize'. 
% Image elements below minVal or above maxVal are set to 0 and bitSize, respectively.
I(I<minVal) = minVal;
I(I>maxVal) = maxVal;
I2 = bitSize * (I - minVal)/(maxVal-minVal);

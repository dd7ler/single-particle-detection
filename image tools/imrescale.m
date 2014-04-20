function I2 = imrescale(I, minVal, maxVal,bitSize)
% rescales an image to fill the range 'bitsize'. 
% Image elements between minVal and maxVal are rescaled to between 0 and bitSize.
I(I<minVal) = minVal;
I(I>maxVal) = maxVal;
I2 = bitSize * (I - minVal)/(maxVal-minVal);

function [ aiFilter] = filtergen_AIRY_v2(kernelSize,offset,NA,backRadius,pixel_dim_image)
%generates a 2D Airy Disk Mask of given inputs over [kernelSize kernelSize]
%   kernelSize must be [odd odd]
%   mask_airy is NaN at (y,x)=1 at generation, function must manually set
%   center of continuous function =1.
%
%The 1D Airy Funtion is given by
%
%   I = Io*(2*J1(k)/k)^2
%   Io = peak intensity
%   J1 = Bessel Function 1
%   k = (pi*q)/(wavelength*fnumberw)
%   q = distance = x*pixesize; x = pixel distance
%   fnumberw = n*m/((2*NA)(m-1))
%   m = magnification 
%   n = media refractive index (air = 1, water = 1.33);
%   
%   
%
%   radial distance of 1st dark ring (zero)
%   q1 = 1.22*wavelength / (2 * NA)  %encircles 86% of total power
%   q2 = 2.23*wavelength / (2 * NA)  
%
% second peak p2=1.66*wavelength / (2 * NA) %encircles 90% power

if nargin<5
  
    backRadius=3.3;
end

n=1;
% pixelsize=7500; %1d pixel dimension in nm
% pixel_dim_image = pixelsize/mag; %in nm
wavelength = .518;


xoff = offset(1);
yoff = offset(2);
maxRadius = (kernelSize(1)-1)/2; 

fnumberw = n/(2*NA);
%fnumberw=NA;

%Create 2D array of radial distance from center




%Generate 1D Airy Function for X
x_pix=linspace(maxRadius*(-1),maxRadius,kernelSize);
x_true=x_pix-xoff;
x_trueArray=repmat(x_true,kernelSize,1);





%Generate 1D Airy Function for Y
y_pix=linspace(maxRadius*(-1),maxRadius,kernelSize);
y_true=y_pix-yoff;
y_trueArray=repmat(y_true.',1,kernelSize);


%Create 2D Mask of distances from the center
[r_trueArray]=((x_trueArray.^2)+(y_trueArray.^2)).^(.5);

%The theoretical definition of the k array may be reversed, seems to imply
%an NA that is too low
[k_trueArray]=(r_trueArray*pi*pixel_dim_image)/(wavelength*fnumberw);

mask2d=airy_continuous(abs(k_trueArray));




aiFilter.aiMask=mask2d;
aiFilter.r_trueArray=r_trueArray;
aiFilter.rzero1=1.22*wavelength*fnumberw/pixel_dim_image;
aiFilter.rzero2=2.23*wavelength * fnumberw/pixel_dim_image;
aiFilter.k_trueArray=k_trueArray;





aiFilter.fnum=fnumberw;

%edit the definition of the masks to not go below input radius
% [peakMask]=(r_trueArray<aiFilter.rzero1) & (r_trueArray<backRadius);
[peakMask]=(r_trueArray<backRadius);
[backMask]=r_trueArray>backRadius;
aiFilter.peakMask=peakMask;
aiFilter.backMask=backMask;
aiFilter.kernelSize=kernelSize;
aiFilter.powerMask_r1=r_trueArray<aiFilter.rzero1;
aiFilter.powerSum_r1=sum(aiFilter.aiMask(aiFilter.powerMask_r1));

%ringmask of near neighbors for contrast calculation, currently unused
[ringMask]=((r_trueArray>aiFilter.rzero1)|(r_trueArray>backRadius)) & ((r_trueArray<aiFilter.rzero2)|(r_trueArray<backRadius));
aiFilter.ringMask=ringMask;

end


%helper fucntion.  Evaluate Raw Airy function at vector k
function [values] = airy_continuous(kDistAbs)
%evaluate airy function at absolute distance from origin;

%removed square based on conversation with ronen
[values]=(2*besselj(1,kDistAbs)./kDistAbs);

%if Airy Desk is centered, set value at origin = 1;
[NaNcheck] = kDistAbs==0;
values(NaNcheck(:))=1;
end


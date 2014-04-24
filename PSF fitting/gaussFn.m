function I = gaussFn(x0, rc)
	% Generalized 2D gaussian equation.
	% See http://en.wikipedia.org/wiki/Airy_disk#Approximation_using_a_Gaussian_profile
	% Derin Sevenler, December 2013

	% With IRIS, the PSF resembles J(x)/x moreso than (J(x)/x)^2, according to Ronen, but I don't know for sure why...
	
	% rc contains the coordinates of points to fit.

	% x0(1), x0(2) correspond to (x,y) translation of the gaussian function. Here q is the radial distance from the center
	q = sqrt((rc(:,:,1)-x0(1)).^2 + (rc(:,:,2)- x0(2)).^2);

	% x0(3) is sigma, the gaussian RMS width
	I = exp(-(q.^2)./(2*x0(3)^2));
	% x0(4) is an intensity scaling coefficient. x0(5) is a background coefficient.
	I = x0(4)*I + x0(5);
end
function I = airyPattern(x0, rc)
	% Generalized airy pattern equation.
	% See en.wikipedia.org/wiki/Airy_disk#Mathematical_details, or my lab notebook page 34
	% Derin Sevenler, December 2013

	% With IRIS, the PSF resembles J(x)/x moreso than (J(x)/x)^2, according to Ronen, but I don't know for sure why...
	
	% rc contains the coordinates of points to fit.

	% x0(1), x0(2) correspond to (x,y) translation of the airy pattern. Here q is the radial distance from the center
	q = sqrt((rc(:,:,1)-x0(1)).^2 + (rc(:,:,2)- x0(2)).^2);

	% x0(3) is the spatial scaling coefficient: x= k*a*sin(theta) = (2*pi*na/lambda) * q
	x = x0(3) *q;

	I = (2*besselj(1,x)./x);
	I(isnan(I)) = 1;

	% x0(4) is an intensity scaling coefficient. x0(5) is a background coefficient.
	I = x0(4)*I + x0(5);
end
function gb=gabor_fn(sigma,theta,lambda,psi,gamma)
%Acquired from http://en.wikipedia.org/wiki/Gabor_filter

% %Gabor In image processing, a Gabor filter, named after Dennis Gabor, is a 
% linear filter used for edge detection. Frequency and orientation 
% representations of Gabor filters are similar to those of the human visual 
% system, and they have been found to be particularly appropriate for texture 
% representation and discrimination. In the spatial domain, a 2D Gabor filter 
% is a Gaussian kernel function modulated by a sinusoidal plane wave.

sigma_x = sigma;
sigma_y = sigma/gamma;
 
% Bounding box
nstds = 3;
xmax = max(abs(nstds*sigma_x*cos(theta)),abs(nstds*sigma_y*sin(theta)));
xmax = ceil(max(1,xmax));
ymax = max(abs(nstds*sigma_x*sin(theta)),abs(nstds*sigma_y*cos(theta)));
ymax = ceil(max(1,ymax));
xmin = -xmax; ymin = -ymax;
[x,y] = meshgrid(xmin:xmax,ymin:ymax);
 
% Rotation 
x_theta=x*cos(theta)+y*sin(theta);
y_theta=-x*sin(theta)+y*cos(theta);
 
gb= exp(-.5*(x_theta.^2/sigma_x^2+y_theta.^2/sigma_y^2)).*cos(2*pi/lambda*x_theta+psi);
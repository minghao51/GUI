templateT = rgb2gray(double(imread('templateTest.png')));
templateT = (double(imread('templateTest.png')));

templateT = templateT(:,:,1);



%  BWoutline = bwperim(BWfinal);
% Segout = I;
% Segout(BWoutline) = 255;
% figure, imshow(Segout), title('outlined original image');
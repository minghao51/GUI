function imageout = threshold2(imagein,thresv,cropcor1,...
    strelv,bwarea1,bwarea2,plotp,holec,erodec,thresc, thresc2)

% a variation of threshold1, as the image could be considered as already
% cropped and thresholded. 

%cropping and thresholding the image


if thresc==1
    imagein = imcrop(imagein,cropcor1);
    range=(imagein > thresv & imagein <= thresc2);
    imagein(range)=0;
    imagein(~range)=1;
elseif thresc==2 % only usable for GUI atm, for cropped and thresholded img 
    
elseif thresc==0
    imagein = imcrop(imagein >thresv , cropcor1);
end


% imagein = imcrop(imagein , cropcor);
if plotp == 1
    figure, imshow(imagein,[])
end

se = strel('disk',strelv);
% filling up holes and removing small pixels connected smaller than 20
if holec == 1
    imagein = imfill(imagein,'holes');
end
if erodec == 1
    imagein = imerode(imagein, se);
end

imagein = bwareaopen(imagein, bwarea1);
imagein = imclose(imagein,se);


if plotp == 1
    figure, imshow(imagein,[])
end

% level = graythresh(I)
% I = im2bw(I,level);
% imshow(I,[])

hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(imagein), hy, 'replicate');
Ix = imfilter(double(imagein), hx, 'replicate');
imageout = sqrt(Ix.^2 + Iy.^2);

if plotp == 1
    figure, imshow(imageout,[]), title('Gradient magnitude (gradmag)')
end



% imageout = bwareaopen((imageout), bwarea2);

imageout = watershed(imageout);
if plotp == 1
    figure, imshow(imageout,[]), title('Watershed transform of gradient magnitude (Lrgb)')
end

% error('test')


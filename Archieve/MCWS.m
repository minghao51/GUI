rgb = imread('pears.png');
I = rgb2gray(rgb);
imshow(I)

text(732,501,'Image courtesy of Corel(R)',...
     'FontSize',7,'HorizontalAlignment','right')
 
 hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
% figure, imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

L = watershed(gradmag);
Lrgb = label2rgb(L);
% figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)')

%Step 3: Mark the Foreground Objects
se = strel('disk', 20);
Io = imopen(I, se);
% figure, imshow(Io), title('Opening (Io)')
% 
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
% figure, imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);
% figure, imshow(Ioc), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
% figure, imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

fgm = imregionalmax(Iobrcbr);
% figure, imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')
 
 I2 = I;
I2(fgm) = 255;
% figure, imshow(I2), title('Regional maxima superimposed on original image (I2)')
% 
se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
figure, imshow(I3)
 title('Modified regional maxima superimposed on original image (fgm4)')

%Step 4: Compute Background Markers
bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
% figure, imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure, imshow(bgm), title('Watershed ridge lines (bgm)')

%Step 5: Compute the Watershed Transform of the Segmentation Function.
gradmag2 = imimposemin(gradmag, bgm | fgm4);


figure, imshow(gradmag2), title('gradmag2')
L = watershed(gradmag2);

figure, imshow(L), title('L')
%Step 6: Visualize the Result
I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure, imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure, imshow(Lrgb)
% title('Colored watershed label matrix (Lrgb)')
function imageout = MCWS3(imagein,MBGM)

% Marker-Controlled Watershed Segmentation method, 
% following this http://www.mathworks.com.au/products/image/examples.html?file=/products/demos/shipping/images/ipexwatershed.html
% with altering in ones size and threshold etc 

% Require Manualbgm.png in the corresponding dir to function
% path is require to point the function to search at the correct dir for
% the Manualbgm.png, ie the manually created background marker

I = imagein;

maxI = max(I(:));
% I=I/maxI*255;

%Gradient
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
% figure, imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

L = watershed(gradmag);
Lrgb = label2rgb(L);
% figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)')


%Mark the Foreground Objects
se = strel('disk', 3);
Io = imopen(I, se);
% 
% figure,
% subplot(2,2,1);
% imshow(Io,[]), title('Opening (Io)')

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
% 
% subplot(2,2,2);
% imshow(Iobr,[]), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);
% 
% subplot(2,2,3);
% imshow(Ioc,[]), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
% 
% subplot(2,2,4);
%  imshow(Iobrcbr,[]), title('Opening-closing by reconstruction (Iobrcbr)')


%Removing the background at all
% %% my own input to extract/kill the background
% % grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
BackG = im2bw(I, graythresh(I));
Iobrcbr(BackG==0) = 0;
figure,imshow(Iobrcbr,[])

% Step 3: Mark the Foreground Objects
%possible for imextendedmax here

fgm = imregionalmax(Iobrcbr,4);
% figure, imshow(fgm,[]), title('Regional maxima of opening-closing by reconstruction (fgm)')
 
 I2 = I;
I2(fgm) = maxI;
% figure, imshow(I2,[]), title('Regional maxima superimposed on original image (I2)')

se2 = strel(ones(3,3));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 5);

I3 = I;
I3(fgm4) = maxI;
% figure, imshow(I3,[])
% title('Modified regional maxima superimposed on original image (fgm4)')

% Step 4: Compute Background Markers
%Manual marker for this region
% 
% cd(path);
% MBGM=imread('Manualbgm.png');
% MBGM=rgb2gray(double(MBGM>0));

%I think my data isn't consistent here
gradmag2 = imimposemin(gradmag, MBGM | fgm4);
% figure,imshow(gradmag2,[])
L = watershed(gradmag2,8);
% figure,imshow(L,[])


imageout = L;

%Visualize the Result

% I4 = I;
% % I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
% I4(L==0 | MBGM | fgm4) = maxI;
% % I4( bgm | fgm4) = maxI;
% figure, imshow(I4,[])
% title('Markers and object boundaries superimposed on original image (I4)')
% 


Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure, imshow(Lrgb,[])
title('Colored watershed label matrix (Lrgb)')



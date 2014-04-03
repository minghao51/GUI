function imageout = MCWS1(imagein)

% Marker-Controlled Watershed Segmentation method, 
% following this http://www.mathworks.com.au/products/image/examples.html?file=/products/demos/shipping/images/ipexwatershed.html
[fName,pName] = uigetfile('*', 'Load data');
% pName = C:\Users\Minghao\Desktop\research project\Lung Datasets\test4-cropT cop pat\;
handles.dicomlist = dir(fullfile(pName, '*'));
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = [];

handles.data{1} = imread(fullfile(pName,handles.dicomlist(1).name));


% I have to be 0 to 255 for easy manipulation...sigh

%Prefilter
% I = double(handles.data{1});
I = handles.data{1};
% I = medfilt2(I);
I = Gaussian_fn(I, 3,2);
figure,imshow(I,[])

maxI = max(I(:));
% I=I/maxI*255;




%Gradient
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
figure, imshow(gradmag,[]), title('Gradient magnitude (gradmag)')

L = watershed(gradmag);
Lrgb = label2rgb(L);
% figure, imshow(Lrgb), title('Watershed transform of gradient magnitude (Lrgb)')




%Mark the Foreground Objects
se = strel('disk', 3);
Io = imopen(I, se);
figure,
subplot(2,2,1);
imshow(Io,[]), title('Opening (Io)')

Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);

subplot(2,2,2);
imshow(Iobr,[]), title('Opening-by-reconstruction (Iobr)')

Ioc = imclose(Io, se);

subplot(2,2,3);
imshow(Ioc,[]), title('Opening-closing (Ioc)')

Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

subplot(2,2,4);
imshow(Iobrcbr,[]), title('Opening-closing by reconstruction (Iobrcbr)')


%Removing the background at all
% %% my own input to extract/kill the background
% % grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
BackG = im2bw(I, graythresh(I));
Iobrcbr(BackG==0) = 0;
% figure,imshow(Iobrcbr,[])
% I= bwareaopen(I,5);

% Step 3: Mark the Foreground Objects

fgm = imregionalmax(Iobrcbr,4);
figure, imshow(fgm,[]), title('Regional maxima of opening-closing by reconstruction (fgm)')
 
 I2 = I;
I2(fgm) = maxI;
figure, imshow(I2,[]), title('Regional maxima superimposed on original image (I2)')

se2 = strel(ones(3,3));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

fgm4 = bwareaopen(fgm3, 5);

I3 = I;
I3(fgm4) = maxI;
figure, imshow(I3,[])
title('Modified regional maxima superimposed on original image (fgm4)')

% Step 4: Compute Background Markers

% % % bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
% % % figure,imshow(bw,'InitialMagnification','fit')
% % % 
% % % imgDist=-bwdist(~bw,'cityblock');
% % % % figure,imshow(imgDist,[],'InitialMagnification','fit')
% % % 
% % % % imgDist=imimposemin(imgDist,fgm4);
% % % % figure,imshow(imgDist,[],'InitialMagnification','fit')
% % % imgDist(~bw)=-inf;   
% % % % imgDist(~bw)=-inf;  
% % % % imgDist=imgDist<100;   
% % % % figure,imshow(imgDist,[],'InitialMagnification','fit')
% % % imgLabel=watershed(imgDist);    
% % % imgLabel=imgLabel>0;
% % % figure,imshow(imgLabel==0,'InitialMagnification','fit')


bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
% bgmspecial = otsu(Iobrcbr,3);
% bw = bgmspecial
figure, imshow(bw,[]), title('Thresholded opening-closing by reconstruction (bw)')


%
bw = imerode(bw, se2);

D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure, imshow(bgm,[]), title('Watershed ridge lines (bgm)')
% bgm=~imgLabel;


%I think my data isn't consistent here
gradmag2 = imimposemin(gradmag, bgm | fgm4);
figure,imshow(gradmag2,[])
L = watershed(gradmag2,4);
figure,imshow(L,[])
%Visualize the Result

I4 = I;
% I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
I4(L==0 | bgm | fgm4) = maxI;
% I4( bgm | fgm4) = maxI;
figure, imshow(I4,[])
title('Markers and object boundaries superimposed on original image (I4)')

Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure, imshow(Lrgb,[])
title('Colored watershed label matrix (Lrgb)')
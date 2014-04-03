%Testing WSMC without threshold and markers controls, this failed
%misarablely

% function imageout = MCWS(imagein

% Marker-Controlled Watershed Segmentation method, 
% following this http://www.mathworks.com.au/products/image/examples.html?file=/products/demos/shipping/images/ipexwatershed.html
[fName,pName] = uigetfile('*', 'Load data');
% pName = C:\Users\Minghao\Desktop\research project\Lung Datasets\test4-cropT cop pat\;
handles.dicomlist = dir(fullfile(pName, '*'));
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = [];

handles.data{1} = imread(fullfile(pName,handles.dicomlist(1).name));


%Prefilter
% I = double(handles.data{1});
I = handles.data{1};
I = medfilt2(I);
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

imageout = watershed(gradmag);
figure, imshow(imageout,[]), title('Gradient magnitude (gradmag)')


% test 14
% Processing to identify the ROI to test template or coordinates

%Loading the imag as per usual
[fName,pName] = uigetfile('*', 'Load data');
handles.dicomlist = dir(fullfile(pName, '*'));
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = [];

handles.data{1} = dicomread(fullfile(pName,handles.dicomlist(1).name));
%As I will be reading only from the very 1st frame here




imshow(handles.data{1},[])
handles.data{1}=imcrop;
close 1
imshow(handles.data{1},[])


I=handles.data{1};
I=otsu(I,3);
imshow(I,[])

subplot(1,2,2);


strelv = 1;
se = strel('disk',strelv);
% I = imtophat(I, ones(15, 15))
% %  imagein = imerode(I, se);
% %   imagein = imdilate(imagein, se);
% I = imclearborder(I)



figure, imshow(I,[])
[x,y,vals] = impixel;   
grain = false(size(I));
grain(I==vals(1)) = 1;
grain = imerode(grain, se);
grain = bwareaopen(grain, 5);
grain = imdilate(grain, se);


figure, imshow(grain,[])

Wgrain=bwconncomp(grain);

% figure, imshow(bw,[])
  
%   L = bwlabel(grain)
%   I = bwareaopen(I, 5);
% % I2 = imtophat(I, ones(15, 15));
% % bw = im2bw(I2, graythresh(I2));
% bw2 = bwareaopen(I, 5);
% % bw3 = imclearborder(bw2);
% imshow(bw2,[])
figure, imshow(I,[])
[x,y,vals] = impixel;   
% 
% % img = bwmorph(handles.data{1},'open');
% img = bwareaopen(handles.data{1},30);
% subplot(1,2,2)
% imshow(img,[])
% xlabel('After Morphology')
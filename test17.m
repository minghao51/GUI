%test17
% http://www-rohan.sdsu.edu/doc/matlab/toolbox/images/morph19.html
[fName,pName] = uigetfile('*', 'Load data');
% pName = C:\Users\Minghao\Desktop\research project\Lung Datasets\test4-cropT cop pat\;
handles.dicomlist = dir(fullfile(pName, '*'));
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = [];

handles.data{1} = imread(fullfile(pName,handles.dicomlist(1).name));

afm = handles.data{1} ;

se = strel('disk', 2);


Itop = imtophat(afm, se);
Ibot = imbothat(afm, se);
figure, imshow(Itop, []), title('top-hat image');

figure, imshow(Ibot, []), title('bottom-hat image');

Ienhance = imsubtract(imadd(Itop, afm), Ibot);
figure, imshow(Ienhance), title('original + top-hat - bottom-hat');

Iec = imcomplement(Ienhance);
figure, imshow(Iec), title('complement of enhanced image');

Iemin = imextendedmin(Iec, 22);
Iimpose = imimposemin(Iec, Iemin);
figure, imshow(Iemin), title('extended minima image');

figure, imshow(Iimpose), title('imposed minima image');

wat = watershed(Iimpose);

rgb = label2rgb(wat);
figure, imshow(rgb);
title('watershed segmented image');
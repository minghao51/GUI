% test case for programs in GUI
% loading all files as usual, but stop before segmenting
clear all
close all

[fName,pName] = uigetfile('*', 'Load data');
handles.pName = pName; % to pass this directory for other function
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
handles.dicomlist = dir(fullfile(pName, '*'));  %Generating a list of filename for reading in that directory, based on the 1st letter on the name
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = []; % this yank out those files that isn't start with the same 1st letter as selected file
% handles.dicominfo = dicominfo(fullfile(pName,handles.dicomlist(1).name));   %reading dicominfo from the very 1st file
% It seems I would have to read the acquisition time seperately, 1st file

for cnt = 1 : numel(handles.dicomlist)
     dataM{cnt} = imread(fullfile(pName,handles.dicomlist(cnt).name)); % directory reading of dicom files
     dataM{cnt} = double(dataM{cnt}(:,:,1)>0);
      RegionProperties=regionprops(dataM{cnt},'Area','Centroid','Extrema');
            Atumour(cnt)=RegionProperties(1).Area;
            CtumourX(cnt)= RegionProperties(1).Centroid(1);
            CtumourY(cnt)= RegionProperties(1).Centroid(2);
%             Etumour(cnt,i)=RegionProperties(1).Extrema(2);
end



x = 1:numel(Atumour);
plot(x, Atumour, '-r', x, CtumourX, '-g', x, CtumourY, '-b')
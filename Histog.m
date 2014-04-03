% test 20
% test case for programs in GUI
% loading all files as usual, but stop before segmenting
clear all
close all

handles.cropcor1 = [103.51,101.51,43.98,38.98];
handles.cropcor2 = [172.51,161.51,47.98,71.98];

[fName,pName] = uigetfile('*', 'Load data');
handles.pName = pName; % to pass this directory for other function
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
handles.dicomlist = dir(fullfile(pName, '*'));  %Generating a list of filename for reading in that directory, based on the 1st letter on the name
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = []; % this yank out those files that isn't start with the same 1st letter as selected file
% handles.dicominfo = dicominfo(fullfile(pName,handles.dicomlist(1).name));   %reading dicominfo from the very 1st file
% It seems I would have to read the acquisition time seperately, 1st file
% isn't enough
for cnt = 1 : numel(handles.dicomlist)
     handles.data{cnt} = dicomread(fullfile(pName,handles.dicomlist(cnt).name)); % directory reading of dicom files
     handles.info{cnt}  = dicominfo(fullfile(pName,handles.dicomlist(cnt).name)) ;
end

% Read for coordinate data and threshold data
handles.predataName = 'predata.txt';
if exist(fullfile(pName, handles.predataName), 'file')
    % File exists.  Do stuff....
%     % Display that notice the user there is pre-existing crop region
%     txtInfo = sprintf('There is pre-existing crop region \n cropping and thresholding will generate new predata.txt');
%     set(handles.txtbox, 'string', txtInfo);
    
    % Read the File, and output it into matrix
    M = dlmread(fullfile(pName, handles.predataName));
    
    % Updating crop coordinates and method's option
    handles.cropcor1 = M(1,:);
    handles.cropcor2 = M(2,:);
%     handles.MethodV = M(3,1);
else
    % File does not exist.
    % Display that notice the user there is not pre-existing crop region
    txtInfo = sprintf('There is no pre-existing crop region \n will generate predata.txt after cropping and thresholding \n handles.cropcor1');
    set(handles.txtbox, 'string', txtInfo);
    
end
% 
% 
% handles.I1{1} = imcrop(handles.data{1},handles.cropcor1);
% handles.I2{1} = imcrop(handles.data{1},handles.cropcor2);


for cnt = 1 : numel(handles.dicomlist)
    oriI1{cnt} = imcrop(handles.data{cnt},handles.cropcor1);
    oriI2{cnt} = imcrop(handles.data{cnt},handles.cropcor2);
end


for cnt = 1 : numel(handles.dicomlist)
%     handles.data{cnt} = otsu(handles.data{cnt},3);
    handles.I1{cnt} = imcrop(handles.data{cnt},handles.cropcor1);
    handles.I2{cnt} = imcrop(handles.data{cnt},handles.cropcor2);
    %     handles.I1{cnt}=MCWS1(handles.I1{cnt});
    %     handles.I2{cnt}=MCWS1(handles.I2{cnt});
end

figure,imshow(handles.I1{1},[])


% Somehow, it normalise the picture to 10000k value, probably due to me
% included some areas I am not supposed to
% for cnt = 1 : numel(handles.dicomlist)
%     handles.I1{cnt} = histeq(handles.I1{cnt});
%     handles.I2{cnt} = histeq(handles.I2{cnt});
% end

figure,imshow(oriI1{1},[])
figure,imshow(handles.I1{1},[])

figure,imhist(double(handles.I1{1}),48);
%     prompt = {'Enter range fromo ROI'};
    %     reg_maxdist = double(inputdlg(prompt));
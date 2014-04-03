% test 7
% test case if file exist in path directory, if it does, read from
% the file, otherwise, create a file
clear all
close all

handles.cropcor1 = [126.5 98.5 45 38];
handles.cropcor2 = [37.5 179.5 42 48];



[fName,pName] = uigetfile('*', 'Load data');
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
dicomlist = dir(fullfile(pName,'0*'));
dicominfo1 = dicominfo(fullfile(pName,dicomlist(1).name)) ;
for cnt = 1 : numel(dicomlist)
    %             data{cnt} = dicomread(fullfile(pName,'Images',dicomlist(cnt).name));
    data{cnt} = dicomread(fullfile(pName,dicomlist(cnt).name));
end


%read for coordinate data and threshold data
fullFileName = 'data.txt';
if exist(fullfile(pName, fullFileName), 'file')
    %     exist(pName\'cordata.txt', 'file')
    % File exists.  Do stuff....
    % Display that notice the user there is pre-existing crop region
        
    % Read the File, and output it into matrix
    M = dlmread(fullfile(pName, fullFileName));
    
    handles.cropcor1 = M(1,:);
    handles.cropcor2 = M(2,:);
else
    % File does not exist.
    warningMessage = sprintf('Warning: file does not exist:\n%s', fullFileName);
    uiwait(msgbox(warningMessage));
    
    % Display that notice the user there is not pre-existing crop region
    % handles.preData=0;
    % handles.cropcor1 = [126.5 98.5 45 38];
    % handles.cropcor2 = [37.5 179.5 42 48];
    %
    % fid = fopen(fullfile(pName, fullFileName), 'wt'); % Open for writing
    % for i=1:3
    %
    % %    fprintf(fid, '%d \n', mat2str(handles.cropcor1));
    % %    fprintf(fid, '%d \n', handles.cropcor2);
    % end
    % fclose(fid);
end


% hence after crop and threshold, write it to the file, though this would
% require sharing of pName, fullFileName as handles
dlmwrite(fullfile(pName, fullFileName), [handles.cropcor1; handles.cropcor2; handles.MethodV, handles.t1, handles.t2, handles.t3 ; handles.temp1; ])

% Exporting for the centroid of tumour and diaphragm data
% note, this will overwrite the previous data, if there is any
fullFileName = 'test.txt';
dlmwrite(fullfile(pName, fullFileName), [ temp1 ; temp2 ; y_d])


%         temp1(cnt) = [A1{cnt,1}(1)];        %parameters of tumour-x
%         temp2(cnt) = [A1{cnt,1}(2)];        %parameters of tumour-y
%         y_d(cnt);
% test 20
% test case for programs in GUI: loading all files as usual, but stop
% before segmenting, would be changes to test all different segmentation
% methods
clear all
close all

handles.cropcor1 = [51.51,94.51,75.98,51.98];
handles.cropcor2 = [23.51,201.51,84.98,52.98];

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
    handles.MethodV = M(3,1);
else
    % File does not exist.
    % Display that notice the user there is not pre-existing crop region
    txtInfo = sprintf('There is no pre-existing crop region \n will generate predata.txt after cropping and thresholding \n handles.cropcor1');
    set(handles.txtbox, 'string', txtInfo);
    
end


handles.I1{1} = imcrop(handles.data{1},handles.cropcor1);
handles.I2{1} = imcrop(handles.data{1},handles.cropcor2);


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

% MCWS - Marker Controlled Water Segmentation method.
% Hence, anything other than 0 to use manual generated foreground/background region

% this generate a input dialog with two options to offer control of bgm
% and fgm.
prompt = {'Enter bgm Value','Enter fgm Value:'};
dlg_title = 'Input';
num_lines = 1;
def = {'0','0'};
ans = inputdlg(prompt,dlg_title,num_lines,def);
bgmV = str2double(cell2mat(ans(1)));
fgmV = str2double(cell2mat(ans(2)));

if bgmV ~= 0
    MBGM=imread([handles.ImageFolder '\Manualbgm.png']);
    MBGM=rgb2gray(double(MBGM>0));
else
    MBGM = 0;
end

if fgmV ~= 0
    MFGM=imread([handles.ImageFolder '\Manualfgm.png']);
    MFGM=rgb2gray(double(MFGM>0));
else
    MFGM = 0;
end

%Segmentation
% Using Marker controlled watershed segmentation on I1, otsu for
% diaphragm I2.
for cnt = 1 : numel(handles.dicomlist)
    handles.dataT{cnt} = handles.data{cnt};
    handles.I1{cnt} = MCWS1(handles.I1{cnt}, bgmV, MBGM, fgmV, MFGM);
    handles.I2{cnt} = otsu(handles.I2{cnt}, handles.OtsuBinV) * handles.OtsuBinV;
end

% 
% N_ROI = 1;
% plotp = 2;
% se = strel('disk',2);
% bwarea1= 30;
% 
% 
% 
% for cnt = 1 : numel(handles.dicomlist)
%     imageout_t{cnt} = handles.I1{cnt};
%     imageout_d{cnt} = handles.I2{cnt};
%     if cnt == 1
%         figure, imshow(imageout_t{cnt},[])
%         % [x_t,y_t,vals_t] = impixel;
%         % note I am using the old x,y,vals as variable for coordinates of tumour
%         [x_t,y_t,vals_t] = impixel;
%         close 1 %     %Closing the figure for selection
%         figure, imshow(imageout_d{cnt},[])
%         [x_d,y_d,vals_d] = impixel;
%         close 1 %     %Closing the figure for selection
%         %loop to show ROI only and calculate their area
%         %generating a blank image size of L
%         grain = false(size(imageout_t{cnt}));
%                 
%         for i = 1:N_ROI
%             A1{cnt,i}=[x_t(i),y_t(i),vals_t(i,:)];
%             % Some Image processing operation to fill, remove noise, and
%             % artifacts of thresholding
%             grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
%             % A few if case here to enable the control of checkbox in GUI
% 
% %                 grain = imerode(grain, se);
% %            
% %                 grain = bwareaopen(grain, bwarea1);
% %            
% %                 grain = imdilate(grain, se);
% %           
% %             grain = imfill(grain,'holes');
%    
%             dataMap{cnt} = grain;     % passing it to save cropped image with tumour only
%             handles.dataMap{cnt} = grain;
%        
%             % test for the case if there is more than one non connected threshold region
%             % If there is, this would label them differently according to
%             % the connetivity, and then the impixel would be able to
%             % identify the one selected and isolate it
%             grain=bwlabel(grain);
% %             if max(grain(:))>1 ;
% %                 vals=impixel(grain,x_t,y_t)
% %                 dataMap{cnt} = double(grain== vals(1));
% %                 handles.dataMap{cnt} = dataMap{cnt} ;
% %             end
%         
%             data=regionprops(dataMap{cnt},'Area','Centroid','Extrema');
%             Atumour(cnt,i)=data(1).Area;
%             CtumourX(cnt,i)= data(1).Centroid(1);
%             CtumourY(cnt,i)= data(1).Centroid(2);
%             Etumour(cnt,i)=data(1).Extrema(2);
%             
%                  % Plotting the Grain( ImageSegmentation-selected) ROI with centroid marked on
%             % figure for Tumour
%             if plotp == 2
%                 figure, imshow(grain), title(' Centroid Locations')
%                 hold on
%                 for l = 1 : N_ROI
%                     plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
%                 end
%                 hold off
%             end
%             
%             %             % In case that the centroid doens't clip to the Region of
%             %             % Interest, Here the CtumourX, CtumourY, Ediaphragm of all is
%             %             % set to the 1st coordinates, this only works if the ROI
%             %             % doesn't move much from its initial coordiantes
%             %             for cnt = 1: numel(handles.dicomlist)
%             %                 CtumourX(cnt,i)= data(vals(i,1)).Centroid(1);
%             %                 CtumourY(cnt,i)= data(vals(i,1)).Centroid(2);
%             %                 Ediaphragm(cnt,i)=data(vals(i,1)).Extrema(2);
%             %             end
%         end
%         
% %         
% %         % Plotting the Grain( ImageSegmentation-selected) ROI with centroid marked on
% %         % figure for Tumour
% %         if plotp == 2
% %             figure, imshow(grain), title(' Centroid Locations')
% %             hold on
% %             for l = 1 : N_ROI
% %                 plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
% %             end
% %             hold off
% %         end
%         
%         % Plotting the Grain( ImageSegmentation-selected) ROI with centroid marked on
%         % figure for Diaphragm
%         if plotp == 2
%             figure,imshow(imageout_d{cnt},[])
%         end
%         % Removing noise
%         imageout_d{cnt}=bwareaopen(imageout_d{cnt},100);
%         % Finding Boundaries
%         [B,L,N] = bwboundaries(imageout_d{cnt});
%         coln=find(B{1,1}(:,2)==x_d);
%         y_d(cnt) = B{1,1}(coln(1),1);
%         ymax  = size(imageout_d{cnt});
%         hold on
%         line([x_d,x_d],[0,ymax(1)],'Color','r','LineWidth',2)
%         plot(x_d,y_d(cnt),'bo');
%         hold off
%         
%         
%     else
%         %Process for designation of ROI on 2nd run
%         % first, establish the location of previous section, and search
%         for i = 1:N_ROI
%             try
%                 [x_t,y_t,vals_t]= impixel(imageout_t{cnt},...
%                     CtumourX(cnt-1,i),(CtumourY(cnt-1,i)));
%             catch exception
%                 % If it fails to acquire the previous CtumourX, CtumourY, it
%                 % will try to acquire from the previous previous one.
%                 fprintf(1, 'Overide at at %d Tumour \n',cnt);
%                 [x_t,y_t,vals_t]= impixel(imageout_t{cnt},...
%                     CtumourX(cnt-2,i),(CtumourY(cnt-2,i)));
%             end
%             A1{cnt,i} = [x_t,y_t,vals_t];
%         end
%         %generating a blank image size of L ( with all 0)
%             grain = false(size(imageout_t{cnt}));
%             
%             %loop to show ROI only and calculate their area
%             for i = 1:N_ROI
%                 %set the ROI interest to be 1
%                 grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
%               
% %                     grain = imerode(grain, se);
% %           
% %                     grain = bwareaopen(grain, bwarea1);
% %                
% %                     grain = imdilate(grain, se);
% %                
% %                     grain = imfill(grain,'holes');
%  
%                 dataMap{cnt} = grain;     % passing it to save cropped image with tumour only
%                 handles.dataMap{cnt} = grain;
%                 % test for the case if there is more than one non connected threshold region
%                 % If there is, this would label them differently according to
%                 % the connetivity, and then the impixel would be able to
%                 % identify the one selected and isolate it
%                 grain=bwlabel(grain);
%                 if max(grain(:))>1 ;
%                     vals_t=impixel(grain,x_t,y_t)
%                     dataMap{cnt} = double(grain== vals_t(1));
%                     handles.dataMap{cnt} = dataMap{cnt} ;
%                 end
%                 try              %# Attempt to perform some computation
%                     data=regionprops(grain,'Area','Centroid','Extrema');
%                     Atumour(cnt,i)=data(1).Area;
%                     CtumourX(cnt,i)= data(1).Centroid(1);
%                     CtumourY(cnt,i)= data(1).Centroid(2);
%                     Etumour(cnt,i)=data(1).Extrema(2);
%                 catch exception  %# Catch the exception
%                     warning('myfun:warncode','Warning message!')
%                     fprintf(1, 'Exception at %d Tumour \n',cnt);
%                     continue       %# Pass control to the next loop iteration
%                 end
%             end
%             
%             % Plotting the Grain( ImageSegmentation-selected) ROI with centroid marked on
%             % figure for Tumour
%             if plotp == 2
%                 figure, imshow(grain), title(' Centroid Locations');
%                 hold on
%                 for l = 1 : N_ROI
%                     plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
%                 end
%                 hold off
%             end
%             
%             % Plotting the Grain( ImageSegmentation-selected) ROI with centroid marked on
%             % figure for Diaphragm
%             if plotp == 2
%                 figure,imshow(imageout_d{cnt},[])
%             end
%             
%             try              %# Attempt to perform some computation
%                 imageout_d{cnt}=bwareaopen(imageout_d{cnt},100);
%                 [B,L,N] = bwboundaries(imageout_d{cnt});
%                 coln=find(B{1,1}(:,2)==x_d);
%                 y_d(cnt) = B{1,1}(coln(1),1);
%                 y_max  = size(imageout_d{cnt});
%                 if plotp == 2
%                     hold on
%                     line([x_d,x_d],[0,ymax(1)],'Color','r','LineWidth',2)
%                     plot(x_d,y_d(cnt),'bo');
%                     hold off
%                 end
%             catch exception  %# Catch the exception
%                 warning('myfun:warncode','Warning message!')
%                 fprintf(1, 'Exception at %d frame for Diaphragm\n',cnt);
%                 continue       %# Pass control to the next loop iteration
%             end
%         end
%     end
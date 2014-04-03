 % test 4 
% test case for programs in GUI
clear all
 close all
 
handles.cropcor1 = [51.51,94.51,75.98,51.98];
handles.cropcor2 = [23.51,201.51,84.98,52.98];


[fName,pName] = uigetfile('*', 'Load data');
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
dicomlist = dir(fullfile(pName,'*'));
dicomlist(~strncmp({dicomlist.name}, fName(1), 1)) = []; % this yank out those files that isn't start with the same 1st letter 
dicominfo1 = dicominfo(fullfile(pName,dicomlist(1).name)) ;
for cnt = 1 : numel(dicomlist)
    %             data{cnt} = dicomread(fullfile(pName,'Images',dicomlist(cnt).name));
   data{cnt} = dicomread(fullfile(pName,dicomlist(cnt).name));
   info{cnt}  = dicominfo(fullfile(pName,dicomlist(cnt).name)) ;
   % Relevent dicominfo reading
   % info.AcquisitionTime
   % info.pixelspacing - The first value is the row spacing in mm, that is the
   %spacing between the centers of adjacent rows, or vertical spacing. The second 
   %value is the column spacing in mm, that is the spacing between the centers of 
   %adjacent columns, or horizontal spacing.
end

for cnt = 1 : numel(dicomlist)
    oriI1{cnt} = imcrop(data{cnt},handles.cropcor1);
    oriI2{cnt} = imcrop(data{cnt},handles.cropcor2);
end

for cnt = 1 : numel(dicomlist)
    %     data{cnt} = otsu(data{cnt},3);
    I1{cnt} = imcrop(data{cnt},handles.cropcor1);
    I2{cnt} = imcrop(data{cnt},handles.cropcor2);
    I1{cnt} = otsu(I1{cnt},2);
    I2{cnt} = otsu(I2{cnt},2);
end   




N_ROI = 1;
plotp = 0;
se = strel('disk',1);
bwarea1= 50;

for cnt = 1 : numel(dicomlist)
    imageout_t{cnt} = I1{cnt}*2;
    imageout_d{cnt} = I2{cnt}*2; % times 2 because of the orignal half int
    if cnt == 1
        figure, imshow(imageout_t{cnt},[])
        % [x_t,y_t,vals_t] = impixel;
        % note I am using the old x,y,vals as variable for coordinates of tumour
        [x,y,vals] = impixel;
        figure, imshow(imageout_d{cnt},[])
        [x_d,y_d,vals_d] = impixel;
        
        %loop to show ROI only and calculate their area
        %generating a blank image size of L
        grain = false(size(imageout_t{cnt}));
        
        for i = 1:N_ROI
            A1{cnt,i}=[x(i),y(i),vals(i,:)];
            grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
            grain = imerode(grain, se);
            grain = bwareaopen(grain, bwarea1);
            grain = imdilate(grain, se);
            grain = imfill(grain,'holes');
            dataMap{cnt} = grain; % passing it to save cropped image with tumour only
            data=regionprops(grain,'Area','Centroid','Extrema');
            Atumour(cnt,i)=data(vals(i,1)).Area;
            CtumourX(cnt,i)= data(vals(i,1)).Centroid(1);
            CtumourY(cnt,i)= data(vals(i,1)).Centroid(2);
            Ediaphragm(cnt,i)=data(vals(i,1)).Extrema(2);
        end
        
%         
%         s=regionprops(grain,'Area','Centroid','Extrema');
        % finding the highest pixel value for diaphragm
        %recording the corresponding pixel
        %plotting to show the centroid area on the figure
        if plotp == 2
            figure, imshow(grain)
        end
        
        hold on
        for l = 1 : N_ROI
            plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
        end
        
        hold off
        
        if plotp == 2
            figure,imshow(imageout_d{cnt},[])
        end
%         imageout_d1=(imageout_d>1);
        imageout_d{cnt}=bwareaopen(imageout_d{cnt},100);
        [B,L,N] = bwboundaries(imageout_d{cnt});
        coln=find(B{1,1}(:,2)==x_d);
        y_d(cnt) = B{1,1}(coln(1),1);
        ymax  = size(imageout_d{cnt});
        hold on
        line([x_d,x_d],[0,ymax(1)],'Color','r','LineWidth',2)
        plot(x_d,y_d(cnt),'bo');
        hold off
        
        
    else
        %Process for designation of ROI on 2nd run
        % first, establish the location of previous section, and search
        for i = 1:N_ROI
            try
                [x,y,vals]= impixel(imageout_t{cnt},...
                    CtumourX(cnt-1,i),(CtumourY(cnt-1,i)));
            catch exception
                % If it fails to acquire the previous CtumourX, CtumourY, it
                % will try to acquire from the previous previous one.
                fprintf(1, 'Overide at at %d Tumour \n',cnt);
                [x,y,vals]= impixel(imageout_t{cnt},...
                    CtumourX(cnt-2,i),(CtumourY(cnt-2,i)));
                
            end
            A1{cnt,i} = [x,y,vals];
        end
        
        
        %generating a blank image size of L ( with all 0)
        grain = false(size(imageout_t{cnt}));
        
        %loop to show ROI only and calculate their area
        for i = 1:N_ROI
            %set the ROI interest to be 1
            grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
            grain = imerode(grain, se);
            grain = bwareaopen(grain, bwarea1);
            grain = imdilate(grain, se);
            grain = imfill(grain,'holes');
            dataMap{cnt} = grain;     % passing it to save cropped image with tumour only
            try              %# Attempt to perform some computation
                data=regionprops(grain,'Area','Centroid','Extrema');
                Atumour(cnt,i)=data(A1{cnt,i}(3)).Area;
                CtumourX(cnt,i)= data(A1{cnt,i}(3)).Centroid(1);
                CtumourY(cnt,i)= data(A1{cnt,i}(3)).Centroid(2);
                Ediaphragm(cnt,i)=data(A1{cnt,i}(3)).Extrema(2);
            catch exception  %# Catch the exception
                warning('myfun:warncode','Warning message!')
                fprintf(1, 'Exception at %d Tumour \n',cnt);
                continue       %# Pass control to the next loop iteration
            end
        end
        
        
%         try              %# Attempt to perform some computation
%             %# The operation you are trying to perform goes here
%         catch exception  %# Catch the exception
%             continue       %# Pass control to the next loop iteration
%         end
        
        s=regionprops(grain,'Area','Centroid','Extrema');
        % finding the highest pixel value for diaphragm
        %recording the corresponding pixel
        %plotting to show the centroid area on the figure
        if plotp == 2
            figure, imshow(grain)
        end
        title(' Centroid Locations');
        hold on
        for l = 1 : N_ROI
            plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
        end
        hold off
        
        if plotp == 2
            figure,imshow(imageout_d{cnt},[])
        end
        try              %# Attempt to perform some computation
            imageout_d{cnt}=bwareaopen(imageout_d{cnt},100);
            [B,L,N] = bwboundaries(imageout_d{cnt});
            coln=find(B{1,1}(:,2)==x_d);
            y_d(cnt) = B{1,1}(coln(1),1);
            y_max  = size(imageout_d{cnt});
            hold on
            line([x_d,x_d],[0,ymax(1)],'Color','r','LineWidth',2)
            plot(x_d,y_d(cnt),'bo');
            hold off
        catch exception  %# Catch the exception
            warning('myfun:warncode','Warning message!')
            fprintf(1, 'Exception at %d Diaphragm\n',cnt);
            continue       %# Pass control to the next loop iteration
        end
    end
end
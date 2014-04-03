% test 4 
% test case for programs in GUI
% Using only otsu method, follow by extraction of features
clear all
 close all
 
handles.cropcor1 = [126.5 98.5 45 38];
handles.cropcor2 = [37.5 179.5 42 48];


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

for i = 1: numel(dicomlist)
    temp1(i) = [A1{i,1}(1)];
    temp2(i) = [A1{i,1}(2)];
    y_d(i);
end
% hold off

% Check for massive change of disconnection between point based on the
% change of tumour/diaphragm location from one frame to another, and print
% out an error msg. It will then kill the respective data and coordinates
% Note : the yanking out info part doesn't seems correct at times
% Note : It doesn't kill DataGrain atm.
pixelmargin = 5;
for i = 2: numel(dicomlist)
    if abs(temp1(i-1) - temp1(i)) > pixelmargin
        fprintf(1, 'Exception at %d CtumourX\n',i-1);
        temp1(i-1) = NaN;
        temp1(i) = NaN;
        Atumour(i-1,1) = NaN;
        Atumour(i,1) = NaN;
    end
    if abs(temp2(i-1) - temp2(i)) > pixelmargin
        fprintf(1, 'Exception at %d CtumourY\n',i-1);
        temp2(i-1) = NaN;
    end
    if y_d(i-1)-y_d(i)  > pixelmargin;
        fprintf(1, 'Exception at %d DiaphragmY\n',i-1);
        y_d(i) = NaN;
    end
end


figure
hold on
title(' pixel location of Ctumour and diaphragm');
grid on
set(gca,'GridLineStyle','-');
grid minor;
x = 1:numel(dicomlist);
% x = x*dicominfo1.RepetitionTime;
plot(x,temp1,'-r',x,temp2,'-b',x,y_d,'-g')
hleg1 = legend('Ctumour-x','Ctumour-y','Diaphragm-y');
hold off


% info.pixelspacing

% voxelspacing.x = first element of PixelSpacing (0028,0030), i.e. before "\"
% voxelspacing.y = second element of PixelSpacing (0028,0030), i.e. after "\"
% voxelspacing.z = SliceSpacing (0018,0088) or 0 if 2D and/or not specified 
% delta = (pointA - pointB) * voxelspacing
% distance = sqrt(delta.x^2 + delta.y^2 + delta.z^2);


% info.AcquisitionTime
for cnt = 1 : numel(dicomlist)
    InitialTime =  info{1}.AcquisitionTime;
    x_axis{cnt} = str2num(info{cnt}.AcquisitionTime ) - str2num(info{1}.AcquisitionTime);
           %  x1{cnt} = x1{cnt}
end
 x_axis  =cell2mat (x_axis);
 
%info.pixelspacing
TumourXcentroid = temp1*info{1}.PixelSpacing(1);
TumourXcentroid = TumourXcentroid - nanmean(temp1)*info{1}.PixelSpacing(1); %Mean ignoring NaN values
TumourYcentroid = temp2*info{1}.PixelSpacing(2);
TumourYcentroid = TumourYcentroid - nanmean(temp2)*info{1}.PixelSpacing(1);
DiaphragmYbound = y_d*info{1}.PixelSpacing(2);
DiaphragmYbound = DiaphragmYbound - nanmean(y_d)*info{1}.PixelSpacing(1);


figure
hold on
title(' pixel location of Ctumour and diaphragm');
grid on
set(gca,'GridLineStyle','-');
grid minor;
plot(x_axis,TumourXcentroid,'-r' ...
    ,x_axis,TumourYcentroid,'-b'...
    ,x_axis,DiaphragmYbound,'-g')
xlabel('Time (s)')
ylabel('Diaplcement(mm)')
hleg1 = legend('Ctumour-x SA/RL','Ctumour-y CC','Diaphragm-y CC');
hold off

figure
hold on
title (' Volume of tumour')
grid on
plot(x_axis, Atumour)
xlabel('Time (s)')
ylabel('Volume(1.5625mm^2)')
hold off

% Combining all tumour only image to form a probability map
% datagrain{cnt} = grain;  
ProbabilityMap = 0;
for cnt = 1: numel(dicomlist)
    ProbabilityMap = ProbabilityMap + dataMap{cnt};
end
% Normalising
ProbabilityMap = ProbabilityMap/numel(dicomlist);
figure, contour(ProbabilityMap,'ShowText','on')


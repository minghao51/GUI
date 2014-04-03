function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 04-Mar-2014 15:40:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
clc;
clear global;
% global handles
cd(fileparts(which(mfilename)));
handles.ImageFolder = cd;
set(handles.txtFolder, 'string', handles.ImageFolder);


%some default value - case specific

handles.cropcor1 = [126.5 98.5 45 38];
handles.cropcor2 = [37.5 179.5 42 48];

set(handles.Tcor, 'string', mat2str(handles.cropcor1));
set(handles.Dcor, 'string', mat2str(handles.cropcor2));

%Initial parameters for options and methods in the GUI
%This roughly corresponds with the order of options in the GUI from top to
%bottom, Play, Crop, Threshold.
%PostResults as dataV to allow slider to
%update the centroid location.
handles.PlayV = 1;
handles.CropV = 1;
handles.MethodV =1;
handles.dataV =0;
handles.ThresholdV = 0;
    
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;


    
% Update handles structure
guidata(hObject, handles);


% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadbutton.
%# load data
function loadbutton_Callback(hObject, eventdata, handles)
% hObject    handle to Tcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tcor as text
%        str2double(get(hObject,'String')) returns contents of Tcor as a double


txtInfo = sprintf('MAGIC - MATLAB Analysis text .\n\n Bytext.\nttext text.');
	set(handles.txtbox, 'string', txtInfo);

[fName,pName] = uigetfile('*', 'Load data');
handles.pName = pName; % to pass this directory for other function
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
handles.dicomlist = dir(fullfile(pName, '*'));  %Generating a list of filename for reading in that directory, based on the 1st letter on the name
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = []; % this yank out those files that isn't start with the same 1st letter as selected file
% handles.dicomlist.name = sort_nat({handles.dicomlist.name});    %Because the files have unreasonable names tha require special treatment
[handles.fname inx]= sort_nat({handles.dicomlist.name});
handles.dicomlist = handles.dicomlist(inx);
% handles.dicominfo = dicominfo(fullfile(pName,handles.dicomlist(1).name));   %reading dicominfo from the very 1st file
% It seems I would have to read the acquisition time seperately, 1st file
% isn't enough
for cnt = 1 : numel(handles.dicomlist)
     handles.data{cnt} = dicomread(fullfile(pName,handles.dicomlist(cnt).name)); % directory reading of dicom files
     handles.info{cnt}  = dicominfo(fullfile(pName,handles.dicomlist(cnt).name)) ;
end

handles.ImageFolder = pName;                                   %passing the directory path to textbox/display
set(handles.txtFolder, 'string', handles.ImageFolder);

% Read for coordinate data and threshold data
handles.predataName = 'predata.txt';
if exist(fullfile(pName, handles.predataName), 'file')
    % File exists.  Do stuff....
    % Display that notice the user there is pre-existing crop region
    txtInfo = sprintf('There is pre-existing crop region \n cropping and thresholding will generate new predata.txt');
	set(handles.txtbox, 'string', txtInfo);
        
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

axes(handles.axes1);
imshow(handles.data{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
hold on
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');        %plotting the default crop position as rect box
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off

handles.I1{1} = imcrop(handles.data{1},handles.cropcor1);
imshow(handles.I1{1},[], 'Parent', handles.axes4) %displaying cropped portion of tumour
handles.I2{1} = imcrop(handles.data{1},handles.cropcor2);
imshow(handles.I2{1},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram

% Initialing slider value
set(handles.slider1, ...
    'value',1, ...
    'max',numel(handles.dicomlist), ...
    'min',1, ...
    'sliderstep',[1 1]/numel(handles.dicomlist));

% Refreshing the data states to intial data plots
handles.dataV =0;






% Updating handles
guidata(hObject, handles);

% assignin(data, 'var', data)             % Passsing the image data to
% workspace, doesnt seems to be working as i expect using guidata instead
% to store and retrieve




function Tcor_Callback(hObject, eventdata, handles)
% hObject    handle to loadbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
varName = get(hObject,'String');    %# Get the string value from the uicontrol
                                      %#   object with handle hEditText
try                                   %# Make an attempt to...
  handles.cropcor1=str2mat(varName) %#   get the value from the base workspace
catch exception                       %# Catch the exception if the above fails
  error(['Variable ''' varName ...    %# Throw an error
         ''' doesn''t exist in workspace.']);
end
I1 = imcrop(data{1},handles.cropcor1);
imshow(I,[], 'Parent', handles.axes4)


% to update the changes
guidata(hObject, handles);
% 




% --- Executes during object creation, after setting all properties.
function Tcor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Tcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Dcor_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of Dcor as text
%        str2double(get(hObject,'String')) returns contents of Dcor as a double


% % assignin('base', 'imfile', hObject);
% varName = get(hObject,'String');    %# Get the string value from the uicontrol
%                                       %#   object with handle hEditText
% try                                   %# Make an attempt to...
%   handles.cropcor2=str2mat(varName) %#   get the value from the base workspace
% catch exception                       %# Catch the exception if the above fails
%   error(['Variable ''' varName ...    %# Throw an error
%          ''' doesn''t exist in workspace.']);
% end
% 
% I2 = imcrop(data{1},handles.cropcor2);
% imshow(I,[], 'Parent', handles.axes5)
% % to update the changes
% guidata(hObject, handles);
% hObject    handle to Dcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
function Dcor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Dcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.PlayV == 1;
    B = cat(3, handles.data{:});
    implay(B,6)
    
    
elseif  handles.PlayV == 2;
      
    B = cat(3, handles.I1{:});
    implay(B,6)
    A = cat(3, handles.I2{:});
    implay(A,6)
end



% --- Executes on button press in Crop.
function Crop_Callback(hObject, eventdata, handles)
% hObject    handle to Crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.CropV == 1;
    % Cropping the image for tumour and diaphragm
    figure,imshow(handles.data{1},[])
    [handles.I1{1}, cropcor1]= imcrop;
    
    imshow(handles.data{1},[])
    [handles.I2{1}, cropcor2]= imcrop;
    
    imshow(handles.I1{1},[], 'Parent', handles.axes4) %displaying cropped portion of tumour
    imshow(handles.I2{1},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram
    
    % Updates Cropping Cordinates
    handles.cropcor1=cropcor1;
    handles.cropcor2=cropcor2;
    
    % Closing the figure
    close 1 
         
elseif handles.CropV == 2;
    % Cropping tumour portion of image only
    figure,imshow(handles.data{1},[])
    [handles.I1{1}, cropcor1]= imcrop;
    
    imshow(handles.I1{1},[], 'Parent', handles.axes4) %displaying cropped portion of tumour
    
    % Updates Cropping Cordinates
    handles.cropcor1=cropcor1;
    
    % Closing the figure
    close 1 
    
elseif handles.CropV == 3;
    % Cropping tumour portion of image only
    figure,imshow(handles.data{1},[])
    [handles.I2{1}, cropcor2]= imcrop;
    
    imshow(handles.I2{1},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram
    
    % Updates Cropping Cordinates
    handles.cropcor2=cropcor2;
    
    % Closing the figure
    close 1 
end



% Updating the editable cordinates text box
set(handles.Tcor, 'string', mat2str(handles.cropcor1));
set(handles.Dcor, 'string', mat2str(handles.cropcor2));

% Updating the Rectangle box on the Main Axes
axes(handles.axes1);
imshow(handles.data{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
hold on
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off

% Update handles structure
guidata(hObject, handles);
drawnow




% --- Executes on button press in Threshold.
function Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to ImageProc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

for cnt = 1 : numel(handles.dicomlist)
    handles.oriI1{cnt} = imcrop(handles.data{cnt},handles.cropcor1);
    handles.oriI2{cnt} = imcrop(handles.data{cnt},handles.cropcor2);
end

if handles.MethodV == 1;
    %Using threshold and crop to processs all the images
    for cnt = 1 : numel(handles.dicomlist)
        handles.dataT{cnt} = otsu(handles.data{cnt},3);
        handles.I1{cnt} = imcrop(handles.dataT{cnt},handles.cropcor1)*2;
        handles.I2{cnt} = imcrop(handles.dataT{cnt},handles.cropcor2)*2;  % times 2 because of the orignal half int
    end   
    

    
        % hence after crop and threshold, write it to the file, though this would
        % require sharing of pName, fullFileName as handles
        MethodV(1:4)= handles.MethodV; % for the vector to be consistent with the crop coordinates
        dlmwrite(fullfile(handles.pName, handles.predataName), [handles.cropcor1; handles.cropcor2; MethodV ])
    
elseif handles.MethodV == 2;
    
    handles.dataT = handles.data;
    
    for cnt = 1 : numel(handles.dicomlist)
        handles.I1{cnt} = imcrop(handles.dataT{cnt},handles.cropcor1)*2;
        handles.I2{cnt} = imcrop(handles.dataT{cnt},handles.cropcor2)*2;  % times 2 because of the orignal half int
        handles.I1{cnt} = otsu(handles.I1{cnt},2);
        handles.I2{cnt} = otsu(handles.I2{cnt},2);
    end
    
    
elseif handles.MethodV == 3;
    % Show promtp up cropped figures windows, asking for selection of background/tumour/tissue to custom threshold the responding image click on the 
    % Considering build a custom function for it, might shift everything
    % here out later
    
    % Select region of interest to extract the val of pixel of relevent
    % region, then proceed to record the variable and close it
    
    handles.dataT = handles.data;
    
    % Tumour
    figure, imshow(handles.I1{1},[]),title('Select background')
    [Tumour_x_background,Tumour_y_background,Tumour_vals_background] = impixel;
    close 1
    figure, imshow(handles.I1{1},[]),title('Select tumour')
    [Tumour_x_tumour,Tumour_y_tumour,Tumour_vals_tumour] = impixel;
    close 1
    figure, imshow(handles.I1{1},[]),title('Select tissue')
    [Tumour_x_tissue,Tumour_y_tissue,Tumour_vals_tissue] = impixel;
    close 1
        
    % Tumour  and diapgragm Range
    % turning those pixel in range into relevent values, to make sure they
    % have the correct order in their ranking
    if Tumour_vals_tumour < Tumour_vals_tissue
        t1 = Tumour_vals_background(1) ;
        t2 = Tumour_vals_tumour(1) ;
        t3 = Tumour_vals_tissue(1) ;
        handles.t1 = Tumour_vals_background(1) ;
        handles.t2 = Tumour_vals_tumour(1) ;
        handles.t3 = Tumour_vals_tissue(1) ;
    else
        t1 = Tumour_vals_background(1) ;
        t2 = Tumour_vals_tissue(1) ;
        t3 = Tumour_vals_tumour(1) ;
        handles.t1 = Tumour_vals_background{1} ;
        handles.t2 = Tumour_vals_tissue{1};
        handles.t3 = Tumour_vals_tumour{1} ;
    end
    
    %Treating the image with the acquired range
        for cnt = 1 : numel(handles.dicomlist)
            range_b = (handles.dataT{cnt} <= (t1 + t2)/2);
            handles.dataT{cnt}(range_b) =  0;
            range_t1 = (handles.dataT{cnt} > (t1 + t2)/2 & handles.data{cnt} <= (t2 + t3)/2);
            handles.dataT{cnt}(range_t1) =  1;
            range_t2 = (handles.dataT{cnt} > (t3 + t2)/2 );
            handles.dataT{cnt}(range_t2) =  2;
            handles.I1{cnt} = imcrop(handles.dataT{cnt},handles.cropcor1);
            handles.I2{cnt} = imcrop(handles.dataT{cnt},handles.cropcor2);
        end   
        
        
        % hence after crop and threshold, write it to the file, though this would
        % require sharing of pName, fullFileName as handles
        MethodV(1:4)= handles.MethodV; % for the vector to be consistent with the crop coordinates
        dlmwrite(fullfile(handles.pName, handles.predataName), [handles.cropcor1; handles.cropcor2; MethodV; handles.t1, handles.t2, handles.t3, 0])
        

end


    
% Updating all the relevent axes
axes(handles.axes1);
imshow(handles.dataT{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
hold on
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off
imshow(handles.I1{1},[], 'Parent', handles.axes4) %displaying cropped portion of tumour
imshow(handles.I2{1},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram

handles.ThresholdV = 1;
 



% Update handles structure
guidata(hObject, handles);


% ImageProc button has been removed
% % --- Executes on button press in ImageProc.
% function ImageProc_Callback(hObject, eventdata, handles)
% % hObject    handle to Threshold (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
%   % image processing parameters
%     thresv = 50;
%     strelv = 1;
%     bwarea1 = 20;
%     bwarea2 = 20;
%     
%     % loop to refine the img
% for cnt = 1 : numel(dicomlist)
% I2a{cnt} = threshold2(I2{cnt},thresv,handles.cropcor1,...
%     strelv,bwarea1,bwarea2,0,0,0,0,200);
% I1a{cnt} = threshold2(I1{cnt},thresv,handles.cropcor2,...
%     strelv,bwarea1,bwarea2,0,0,0,0,200);
% end

% --- Executes on button press in PostResults.
function PostResults_Callback(hObject, eventdata, handles)
% hObject    handle to PostResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


N_ROI = 1;
plotp = 0;
se = strel('disk',2);
bwarea1= 30;

for cnt = 1 : numel(handles.dicomlist)
    imageout_t{cnt} = handles.I1{cnt};
    imageout_d{cnt} = handles.I2{cnt};
    if cnt == 1
        figure, imshow(imageout_t{cnt},[])
        % [x_t,y_t,vals_t] = impixel;
        % note I am using the old x,y,vals as variable for coordinates of tumour
        [x,y,vals] = impixel;     
        close 1 %     %Closing the figure for selection
        figure, imshow(imageout_d{cnt},[])
        [x_d,y_d,vals_d] = impixel;
        close 1 %     %Closing the figure for selection
        
        %loop to show ROI only and calculate their area
        %generating a blank image size of L
        grain = false(size(imageout_t{cnt}));
        
        for i = 1:N_ROI
            A1{cnt,i}=[x(i),y(i),vals(i,:)];
            % Some Image processing operation to fill, remove noise, and
            % artifacts of thresholding
            grain(imageout_t{cnt}==A1{cnt,i}(3)) = 1;
            grain = imerode(grain, se);
            grain = bwareaopen(grain, bwarea1);
            grain = imdilate(grain, se);
            grain = imfill(grain,'holes');
            dataMap{cnt} = grain;     % passing it to save cropped image with tumour only
            
            % Plotting the Grain( Threshold-selected) ROI with centroid marked on
            % figure for Tumour
            if plotp == 2
                figure, imshow(grain), title(' Centroid Locations')
                hold on
                for l = 1 : N_ROI
                    plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
                end
                hold off
            end
        
        
            data=regionprops(grain,'Area','Centroid','Extrema');
            Atumour(cnt,i)=data(vals(i,1)).Area;
            CtumourX(cnt,i)= data(vals(i,1)).Centroid(1);
            CtumourY(cnt,i)= data(vals(i,1)).Centroid(2);
            Ediaphragm(cnt,i)=data(vals(i,1)).Extrema(2);
            
            %             % In case that the centroid doens't clip to the Region of
            %             % Interest, Here the CtumourX, CtumourY, Ediaphragm of all is
            %             % set to the 1st coordinates, this only works if the ROI
            %             % doesn't move much from its initial coordiantes
            %             for cnt = 1: numel(handles.dicomlist)
            %                 CtumourX(cnt,i)= data(vals(i,1)).Centroid(1);
            %                 CtumourY(cnt,i)= data(vals(i,1)).Centroid(2);
            %                 Ediaphragm(cnt,i)=data(vals(i,1)).Extrema(2);
            %             end
        end
        
%         
%         % Plotting the Grain( Threshold-selected) ROI with centroid marked on
%         % figure for Tumour
%         if plotp == 2
%             figure, imshow(grain), title(' Centroid Locations')
%             hold on
%             for l = 1 : N_ROI
%                 plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
%             end
%             hold off
%         end
        
        % Plotting the Grain( Threshold-selected) ROI with centroid marked on
        % figure for Diaphragm
        if plotp == 2
            figure,imshow(imageout_d{cnt},[])
        end
        % Removing noise
        imageout_d{cnt}=bwareaopen(imageout_d{cnt},100);
        % Finding Boundaries
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
                handles.dataMap{cnt} = grain;
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
            
            % Plotting the Grain( Threshold-selected) ROI with centroid marked on
            % figure for Tumour
            if plotp == 2
                figure, imshow(grain), title(' Centroid Locations');
                hold on
                for l = 1 : N_ROI
                    plot(data(l).Centroid(1), data(l).Centroid(2),'bo');
                end
                hold off
            end
            
            % Plotting the Grain( Threshold-selected) ROI with centroid marked on
            % figure for Diaphragm
            if plotp == 2
                figure,imshow(imageout_d{cnt},[])
            end
            
            try              %# Attempt to perform some computation
                imageout_d{cnt}=bwareaopen(imageout_d{cnt},100);
                [B,L,N] = bwboundaries(imageout_d{cnt});
                coln=find(B{1,1}(:,2)==x_d);
                y_d(cnt) = B{1,1}(coln(1),1);
                y_max  = size(imageout_d{cnt});
                if plotp == 2
                    hold on
                    line([x_d,x_d],[0,ymax(1)],'Color','r','LineWidth',2)
                    plot(x_d,y_d(cnt),'bo');
                    hold off
                end
            catch exception  %# Catch the exception
                warning('myfun:warncode','Warning message!')
                fprintf(1, 'Exception at %d frame for Diaphragm\n',cnt);
                continue       %# Pass control to the next loop iteration
            end
        end
    end
    
    
    
    for cnt = 1: numel(handles.dicomlist)
        TumourXcor(cnt) = [A1{cnt,1}(1)];        %parameters of tumour-x
        TumourYcor(cnt) = [A1{cnt,1}(2)];        %parameters of tumour-y
        y_d(cnt);                           %parameters of diaphragm
        Atumour(cnt,1);                        %volume of diaphragm
        handles.temp1(cnt) = [A1{cnt,1}(1)];        %temp changes- parameters of tumour-x
        handles.temp2(cnt) = [A1{cnt,1}(2)];        %temp changes- parameters of tumour-y
        handles.y_d(cnt)=y_d(cnt);           %temp changes-
        handles.x_d = x_d;
    end
    
    
    % Check for massive change of disconnection between point based on the
    % change of tumour/diaphragm location from one frame to another, and print
    % out an error msg.
    Tumourpixelmargin = 5;
    Diahphragmpixelmargin = 10;
    for i = 2: numel(handles.dicomlist)
        if abs(TumourXcor(i-1) - TumourXcor(i)) > Tumourpixelmargin
            fprintf(1, 'Exception at %d CtumourX\n',i-1);
            TumourXcor(i-1) = NaN;
            temp1(i-1) = NaN;
            temp1(i) = NaN;
            Atumour(i-1,1) = NaN;
            Atumour(i,1) = NaN;
        end
        if abs(TumourYcor(i-1) - TumourYcor(i)) > Tumourpixelmargin
            fprintf(1, 'Exception at %d CtumourY\n',i-1);
            TumourYcor(i-1) = NaN;
        end
        if y_d(i-1)-y_d(i)  > Diahphragmpixelmargin;
            fprintf(1, 'Exception at %d DiaphragmY\n',i-1);
             y_d(i) = NaN;
        end
    end
    
    
    % % Closing the marked figure
    % Close 1
    % Close 2
    
    % Plotting the new figure for the changes of cordinates in Tumour and
    % Diaphragm
    % figure
    axes(handles.axes3);
    hold on
    title(' pixel location of Ctumour and diaphragm');
    grid on
    set(gca,'GridLineStyle','-');
    grid minor;
    x = 1:numel(handles.dicomlist);
    plot(x,TumourXcor,'-r',x,TumourYcor,'-b',x,y_d,'-g','Parent', handles.axes3)
    hleg1 = legend('Ctumour-x SA/RL','Ctumour-y CC','Diaphragm-y CC');
    hold off
    
    
    % info.pixelspacing
    
    % voxelspacing.x = first element of PixelSpacing (0028,0030), i.e. before "\"
    % voxelspacing.y = second element of PixelSpacing (0028,0030), i.e. after "\"
    % voxelspacing.z = SliceSpacing (0018,0088) or 0 if 2D and/or not specified
    % delta = (pointA - pointB) * voxelspacing
    % distance = sqrt(delta.x^2 + delta.y^2 + delta.z^2);
    
    
    % info.AcquisitionTime
    for cnt = 1 : numel(handles.dicomlist)
        InitialTime =  handles.info{1}.AcquisitionTime;
        x_axis{cnt} = str2num(handles.info{cnt}.AcquisitionTime ) - str2num(handles.info{1}.AcquisitionTime);
        %  x1{cnt} = x1{cnt}
    end
    x_axis  = cell2mat (x_axis);
    
    %info.pixelspacing
    TumourXcentroid = TumourXcor*handles.info{1}.PixelSpacing(1);
    TumourXcentroid = TumourXcentroid - nanmean(TumourXcor)*handles.info{1}.PixelSpacing(1); %Mean ignoring NaN values
    TumourYcentroid = TumourYcor*handles.info{1}.PixelSpacing(2);
    TumourYcentroid = TumourYcentroid - nanmean(TumourYcor)*handles.info{1}.PixelSpacing(1);
    DiaphragmYbound = y_d*handles.info{1}.PixelSpacing(2);
    DiaphragmYbound = DiaphragmYbound - nanmean(y_d)*handles.info{1}.PixelSpacing(1);
    
    
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
    for cnt = 1: numel(handles.dicomlist)
        ProbabilityMap = ProbabilityMap + dataMap{cnt};
    end
    % Normalising
    ProbabilityMap = ProbabilityMap/numel(handles.dicomlist);
    figure, contourf(ProbabilityMap,'ShowText','on')


    % Replotting the main figure, for the location of centroid for tumour and
    % diaphragm, as well as the designated line to find the diaphragm location
    axes(handles.axes1);
    imshow(handles.dataT{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
    
    hold on
    %Drawing the cropped region as rect box
    rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
    rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
    
    %Marking the line of interest
    % line([x_d + handles.cropcor2(1),x_d + handles.cropcor2(1)],[0,ymax(1)],'Color','r','LineWidth',2)
    y_max  = size(handles.data{1});
    line([x_d + handles.cropcor2(1),x_d + handles.cropcor2(1)],[0,y_max(1)],'Color','r','LineWidth',2)
    
    for cnt = 1: numel(handles.dicomlist)
        plot(TumourXcor(cnt) + handles.cropcor1(1), TumourYcor(cnt)+ handles.cropcor1(2) ,'bo'); % plotting the tumour
        plot(x_d + handles.cropcor2(1), y_d(cnt)+ handles.cropcor2(2) ,'bo'); % plotting the diaphragm
    end
    hold off
  
% Will do it later perhaps minghao
% % Exporting for the centroid of tumour and diaphragm data
% % note, this will overwrite the previous data, if there is any
% fullFileName = 'data.txt';
% dlmwrite(fullfile(handles.pName, fullFileName), [ temp1 ; temp2 ; y_d; x_d ])


% Marking the plot to includes updated centroid plots
handles.dataV = 1 ;

% Updating handles
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function txtFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global data
val = get(hObject,'value');
cnt = round(val);
% dat=GetFrameData(currentFrame);
%fprintf(1, 'Just ...  %d\n ',val);
if handles.ThresholdV == 0

    imshow(handles.data{cnt},[], 'Parent', handles.axes1)    % use of round here is not optimal..!!
    axes(handles.axes1);
elseif handles.ThresholdV == 1
    
    axes(handles.axes4);
%     imshow(handles.I1{cnt},[], 'Parent', handles.axes4) %displaying cropped portion of tumour
    imshow(handles.oriI1{cnt},[], 'Parent', handles.axes4)
    % Make a truecolor all-green image.
    green = cat(3, zeros(size(handles.oriI1{1})), ones(size(handles.oriI1{1})), zeros(size(handles.oriI1{1})));
    hold on
    h = imshow(green, 'Parent', handles.axes4);
       % Use our influence map as the
    % AlphaData for the solid green image.
    set(h, 'AlphaData', handles.dataMap{cnt}*0.3)
    hold off
 
    
    
    imshow(handles.I2{cnt},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram
    axes(handles.axes1);
    imshow(handles.dataT{cnt},[], 'Parent', handles.axes1)
end

hold on

if handles.dataV == 1
    
%     imshow(handles.dataT{cnt},[], 'Parent', handles.axes1)
%      imshow(handles.dataT{round(val)},[], 'Parent', handles.axes1)
    % Marking the line of interest
    y_max  = size(handles.data{1});
    line([handles.x_d + handles.cropcor2(1),handles.x_d + handles.cropcor2(1)],[0,y_max(1)],'Color','r','LineWidth',2)
    % Plotting the Centroid of tumour and diaphragm
    plot(handles.temp1(round(val)) + handles.cropcor1(1), handles.temp2(round(val))+ handles.cropcor1(2) ,'bo'); % plotting the tumour
    plot(handles.x_d + handles.cropcor2(1), handles.y_d(round(val))+ handles.cropcor2(2) ,'bo'); % plotting the diaphragm
end

rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off



% Giving it a handle variable
handles.var = round(val);

% Updating the editable cordinates text box
set(handles.frame, 'string', round(val));

% Updating the handles
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.

function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in PlayMenu.
function PlayMenu_Callback(hObject, eventdata, handles)
% hObject    handle to PlayMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns PlayMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from PlayMenu

val = get(hObject, 'Value');
handles.PlayV = val;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function PlayMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PlayMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CropV.
function CropV_Callback(hObject, eventdata, handles)
% hObject    handle to CropV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CropV contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CropV

val = get(hObject, 'Value');
handles.CropV = val;
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function CropV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CropV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MethodV.
function MethodV_Callback(hObject, eventdata, handles)
% hObject    handle to MethodV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns MethodV contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MethodV
val = get(hObject, 'Value');
handles.MethodV = val;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MethodV_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MethodV (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function frame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

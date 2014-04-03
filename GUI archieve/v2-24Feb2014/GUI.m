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

% Last Modified by GUIDE v2.5 23-Feb-2014 15:59:10

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
handles.PlayV = 1;
handles.CropV = 1;
handles.MethodV =1;
    
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


% --- Executes on button press in pushbutton1.
%# load data
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to Tcor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Tcor as text
%        str2double(get(hObject,'String')) returns contents of Tcor as a double


[fName,pName] = uigetfile('*', 'Load data');
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
handles.dicomlist = dir(fullfile(pName,'0*'));
for cnt = 1 : numel(handles.dicomlist)
    %             data{cnt} = dicomread(fullfile(pName,'Images',dicomlist(cnt).name));
    handles.data{cnt} = dicomread(fullfile(pName,handles.dicomlist(cnt).name));
    
end

handles.ImageFolder = pName;                                   %passing the directory path to textbox/display
set(handles.txtFolder, 'string', handles.ImageFolder);


axes(handles.axes1);
imshow(handles.data{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
hold on
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off

handles.I1{1} = imcrop(handles.data{1},handles.cropcor1);
imshow(handles.I1{1},[], 'Parent', handles.axes4) %displaying cropped portion of tumour
handles.I2{1} = imcrop(handles.data{1},handles.cropcor2);
imshow(handles.I2{1},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram

%initialing slider value

set(handles.slider1, ...
    'value',1, ...
    'max',numel(handles.dicomlist), ...
    'min',1, ...
    'sliderstep',[1 1]/numel(handles.dicomlist));

guidata(hObject, handles);

% assignin(data, 'var', data)             % Passsing the image data to workspace, doesnt seems to be working as i expect

%         data = dicomread(pName,fName);
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Tcor_Callback(hObject, eventdata, handles)
% assignin('base', 'imfile', hObject);
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
% for cnt = 1 : numel(dicomlist)
%     %             data{cnt} = dicomread(fullfile(pName,'Images',dicomlist(cnt).name));
%         imshow(data{cnt},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
% end

if handles.PlayV == 1;
    B = cat(3, handles.data{:});
    implay(B,6)
    
    
elseif  handles.PlayV == 2;
      
    B = cat(3, handles.I1{:});
    implay(B,6)
    A = cat(3, handles.I2{:});
    implay(A,6)
end

% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Crop.
function Crop_Callback(hObject, eventdata, handles)
% for cnt = 1 : numel(dicomlist)
%     %             data{cnt} = dicomread(fullfile(pName,'Images',dicomlist(cnt).name));
%     I1{cnt} = imcrop(data{cnt},handles.cropcor1);
%     I2{cnt} = imcrop(data{cnt},handles.cropcor2);
% end

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




% --- Executes on button press in Otsu.
function Otsu_Callback(hObject, eventdata, handles)
%  if handles.Method == 1;
% yet to be implemented

%Using otsu and crop to processs all the images
for cnt = 1 : numel(handles.dicomlist)
    handles.data{cnt} = otsu(handles.data{cnt},3);
    handles.I1{cnt} = imcrop(handles.data{cnt},handles.cropcor1);
    handles.I2{cnt} = imcrop(handles.data{cnt},handles.cropcor2);
end

axes(handles.axes1);
imshow(handles.data{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory
hold on
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off


imshow(handles.I1{1},[], 'Parent', handles.axes4) %displaying cropped portion of tumour

imshow(handles.I2{1},[], 'Parent', handles.axes5) %displaying cropped portion of diaphram


% Update handles structure
guidata(hObject, handles);

% hObject    handle to Otsu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in ImageProc.
function ImageProc_Callback(hObject, eventdata, handles)
%not fully working atm
global I1 I2
global dicomlist
  % image processing parameters
    thresv = 50;
    strelv = 1;
    bwarea1 = 20;
    bwarea2 = 20;
    
    % loop to refine the img
for cnt = 1 : numel(dicomlist)
I2a{cnt} = threshold2(I2{cnt},thresv,handles.cropcor1,...
    strelv,bwarea1,bwarea2,0,0,0,0,200);
I1a{cnt} = threshold2(I1{cnt},thresv,handles.cropcor2,...
    strelv,bwarea1,bwarea2,0,0,0,0,200);
end
% hObject    handle to ImageProc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PostResults.
function PostResults_Callback(hObject, eventdata, handles)
% hObject    handle to PostResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


N_ROI = 1;
plotp = 0;
se = strel('disk',1);
bwarea1= 50;

for cnt = 1 : numel(handles.dicomlist)
    imageout_t{cnt} = handles.I1{cnt}*2;
    imageout_d{cnt} = handles.I2{cnt}*2; % times 2 because of the orignal half int
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
            data=regionprops(grain,'Area','Centroid','Extrema');
            Atumour(cnt,i)=data(vals(i,1)).Area;
            CtumourX(cnt,i)= data(vals(i,1)).Centroid(1);
            CtumourY(cnt,i)= data(vals(i,1)).Centroid(2);
            Ediaphragm(cnt,i)=data(vals(i,1)).Extrema(2);
        end
        
        
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
            plot(s(l).Centroid(1), s(l).Centroid(2),'bo');
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
            [x,y,vals]= impixel(imageout_t{cnt},...
                CtumourX(cnt-1,i),(CtumourY(cnt-1,i)));
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
            
            title(' Centroid Locations');
            hold on
            for l = 1 : N_ROI
                plot(s(l).Centroid(1), s(l).Centroid(2),'bo');
            end
            hold off
        end
        
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
            fprintf(1, 'Exception at %d Diaphragm\n',cnt);
            continue       %# Pass control to the next loop iteration
        end
    end
end

for cnt = 1: numel(handles.dicomlist)
    temp1(cnt) = [A1{cnt,1}(1)];        %parameters of tumour
    temp2(cnt) = [A1{cnt,1}(2)];        %parameters of diaphragm
    y_d(cnt);
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
plot(x,temp1,'-r',x,temp2,'-b',x,y_d,'-g','Parent', handles.axes3)
hleg1 = legend('Ctumour-x','Ctumour-y','Diaphragm-y');
hold off

% Replotting the main figure, for the location of centroid for tumour and
% diaphragm, as well as the designated line to find the diaphragm location
axes(handles.axes1);
imshow(handles.data{1},[], 'Parent', handles.axes1)  % displaying the 1st img in the directory

hold on
%Drawing the cropped region as rect box
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');

%Marking the line of interest
% line([x_d + handles.cropcor2(1),x_d + handles.cropcor2(1)],[0,ymax(1)],'Color','r','LineWidth',2)
y_max  = size(handles.data{1});
line([x_d + handles.cropcor2(1),x_d + handles.cropcor2(1)],[0,y_max(1)],'Color','r','LineWidth',2)

for cnt = 1: numel(handles.dicomlist)
    plot(temp1(cnt) + handles.cropcor1(1), temp2(cnt)+ handles.cropcor1(2) ,'bo'); % plotting the tumour 
    plot(x_d + handles.cropcor2(1), y_d(cnt)+ handles.cropcor2(2) ,'bo'); % plotting the diaphragm 
end
hold off


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
% dat=GetFrameData(currentFrame);
%fprintf(1, 'Just ...  %d\n ',val);
imshow(handles.data{round(val)},[], 'Parent', handles.axes1)    % use of round here is not optimal..!!

hold on
rectangle('Position',handles.cropcor1 , 'LineWidth',2, 'EdgeColor','y');
rectangle('Position',handles.cropcor2 , 'LineWidth',2, 'EdgeColor','y');
hold off


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

% Function to move a mask over an image and return the new mask vertices
% coordinates.
% By Mark Hayworth, Ph.D.  The Procter and Gamble Company, Cincinnati Ohio
function varargout = MoveMask(varargin)
% MOVEMASK M-file for MoveMask.fig
%      MOVEMASK, by itself, creates a new MOVEMASK or raises the existing
%      singleton*.
%
%      H = MOVEMASK returns the handle to a new MOVEMASK or the handle to
%      the existing singleton*.
%
%      MOVEMASK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MOVEMASK.M with the given input arguments.
%
%      MOVEMASK('Property','Value',...) creates a new MOVEMASK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MoveMask_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MoveMask_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MoveMask

% Last Modified by GUIDE v2.5 10-May-2009 19:54:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MoveMask_OpeningFcn, ...
                   'gui_OutputFcn',  @MoveMask_OutputFcn, ...
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

%--------------------------------------------------------------------
% --- Executes just before MoveMask is made visible.
function MoveMask_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MoveMask (see VARARGIN)

	% Choose default command line output for MoveMask
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	% This sets up the initial plot - only do when we are invisible
	% so window can get raised using MoveMask.
	if strcmp(get(hObject,'Visible'),'off')
		plot(rand(5));
	end

	global imgOriginal;
	global maskVerticesXCoords;
	global maskVerticesYCoords;
	
	% Retrieve the arguments.
	imgOriginal = varargin{1};	% The image array.
	maskVerticesXCoords = varargin{2};	% The x coordinates of the mask vertices.
	maskVerticesYCoords = varargin{3};	% The y coordinates of the mask vertices.
	
	% Show the image.
	axes(handles.axes1);
	imshow(imgOriginal, []);
	
	% Show the mask.
	TranslateMask(handles);
	
	% UIWAIT makes MoveMask wait for user response (see UIRESUME)
	uiwait(handles.figMoveMask);
	return;	% MoveMask_OpeningFcn()


%--------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = MoveMask_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
	global maskVerticesXCoords;
	global maskVerticesYCoords;
	varargout{1} = maskVerticesXCoords;
	varargout{2} = maskVerticesYCoords;
	clear global maskVerticesXCoords;
	clear global maskVerticesYCoords;
	return;	% MoveMask_OutputFcn

%--------------------------------------------------------------------
% --- Executes on button press in btnOK.
% MoveMask exits and control returns to the calling program.
function btnOK_Callback(hObject, eventdata, handles)
% hObject    handle to btnOK (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	global maskVerticesXCoords;
	global maskVerticesYCoords;
	% Put the temp variables into our master global variable.
	[newX, newY] = CalculateNewCoordinates(handles);
	maskVerticesXCoords = newX;
	maskVerticesYCoords = newY;
	uiresume(handles.figMoveMask);
	delete(handles.figMoveMask);
	return;  % to calling program.


%--------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.*');
if ~isequal(file, 0)
	% Display the image.
	imgOriginal = DisplayImage(handles, ImageName);
end
%=====================================================================
% Reads FullImageFileName from disk into the Viewer axes.
function imageArray = DisplayImage(handles, FullImageFileName)
	% Find out extension.
	[folder, basefilename, extension] = fileparts(FullImageFileName);
	extension = lower(extension);
	set(handles.txtImageName, 'string', [basefilename extension]);

	% Read in image differently depending on extension.
	% Read in image from disk into an array.
	imageArray = imread(FullImageFileName);

    % Display image array in a window on the user interface.
    axes(handles.axes1);
    imshow(imageArray, []);
	
	return% DisplayImage
	
%--------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figMoveMask)

%--------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figMoveMask,'Name') '?'],...
                     ['Close ' get(handles.figMoveMask,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figMoveMask)


%--------------------------------------------------------------------
% --- Executes on slider movement.
function sldVert_Callback(hObject, eventdata, handles)
% hObject    handle to sldVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
	TranslateMask(handles);


%--------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function sldVert_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldVert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%--------------------------------------------------------------------
% --- Executes on slider movement.
function sldHoriz_Callback(hObject, eventdata, handles)
% hObject    handle to sldHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
	TranslateMask(handles);


%--------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function sldHoriz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldHoriz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%--------------------------------------------------------------------
% Translates the mask according to the delta values in the scroll bars.
% Replots the mask on the image and updates the global variables
% holding the coordinates of the vertices.
function TranslateMask(handles)
	[newX, newY] = CalculateNewCoordinates(handles);
	% Delete old plot.
	h = findobj(gca,'Type','line');
	if ~isempty(h)
		delete (h);
	end
	% Plot new (and possibly clipped) coordinates.
	hold on;
	plot(newX, newY);
	return;  % from TranslateMask()
	
	%--------------------------------------------------------------------
function [newX, newY] = CalculateNewCoordinates(handles)
	global imgOriginal;
	global maskVerticesXCoords; % These don't change until we return to calling program.
	global maskVerticesYCoords;
	sliderXValue = get(handles.sldHoriz,'Value');
	sliderYValue = get(handles.sldVert,'Value');
	imageSize = size(imgOriginal);
	deltaX = sliderXValue * imageSize(1);
	deltaY = sliderYValue * imageSize(2);
	% Get new, translated coordinates.
	newX = maskVerticesXCoords + deltaX;
	newY = maskVerticesYCoords - deltaY;
	% Clip to edges of picture.
	coordinatesToClip = newX < 1;
	newX(coordinatesToClip) = 1;
	coordinatesToClip = newX > imageSize(1);
	newX(coordinatesToClip) = imageSize(1);
	coordinatesToClip = newY < 1;
	newY(coordinatesToClip) = 1;
	coordinatesToClip = newY > imageSize(2);
	newY(coordinatesToClip) = imageSize(2);
	return; % from CalculateNewCoordinates()

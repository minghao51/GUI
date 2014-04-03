function varargout = magic_gui(varargin)
% Tutorial m-file to demonstrate the operation of various controls 
% such as listbox, radio button, checkbox, push button, static text, and axes.
% Requires the Image Processing Toolbox.
%
% Written by Mark Hayworth, Ph.D.
% Advanced Imaging Section
% email: hayworth dot ms at pg dot com
% The Procter & Gamble Company, Cincinnati, Ohio, USA.
% December 2008 - May 2009.  Updated Feb. 2013.
%
% magic_gui M-file for magic_gui.fig
%      magic_gui by itself, creates a new magic_gui or raises the existing
%      singleton*.
%
%      H = magic_gui returns the handle to a new magic_gui or the handle to
%      the existing singleton*.
%
%      magic_gui('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in magic_gui.M with the given input arguments.
%
%      magic_gui('Property','Value',...) creates a new magic_gui or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before magic_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to magic_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help magic_gui

% Last Modified by GUIDE v2.5 23-Feb-2014 15:52:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @magic_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @magic_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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

% --- Executes just before magic_gui is made visible.
function magic_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to magic_gui (see VARARGIN)

% Choose default command line output for magic_gui
handles.output = hObject;

%=====================================================================
% --- My Startup Code --------------------------------------------------
    % Clear old stuff from console.
	clc;
	fprintf(1, 'Just entered magic_gui_OpeningFcn...\n');
	
	% Change the current folder to the folder of this m-file.
	% (The line of code below is from Brett Shoelson of The Mathworks.)
	cd(fileparts(which(mfilename)));

	% MATLAB QUIRK: Need to clear out any global variables you use anywhere
	% otherwise it will remember their prior values from a prior running of the macro.
    clear global;

	handles.macroFolder = cd;
    handles.maskFolder = [handles.macroFolder '/Masks'];
	set(handles.figMainWindow, 'Visible', 'off');

	% Load up the initial values from the mat file.
	strIniFile = fullfile(handles.macroFolder, 'Magic_GUI.mat');
	if exist(strIniFile, 'file')
		% Pull out values and stuff them in structure initialValues.
		initialValues = load(strIniFile);
		% Assign the image folder from the lastUsedImageFolder field of the
		% structure.
	    handles.ImageFolder = initialValues.lastUsedImageFolder;
	end
	% If the image folder does not exist, but the imdemos folder exists, then point them to that.
	if exist(handles.ImageFolder, 'dir') == 0
		% Folder stored in the mat file does not exist.  Try the imdemos folder instead.
		imdemosFolder = fullfile(matlabroot, '\toolbox\images\imdemos');
		if exist(imdemosFolder, 'dir') == 0
			% imdemos folder exists.  Use it.
			handles.ImageFolder = imdemosFolder;
		else
			% imdemos folder does not exist.  Use current folder.
			handles.ImageFolder = cd;
		end
	end
	% handles.ImageFolder will be a valid, existing folder by the time you get here.
	if exist(strIniFile, 'file')
		% If the mat file is not there, save current folder out in our mat file.
		% Save the image folder in our ini file.
		lastUsedImageFolder = handles.ImageFolder;
		save(strIniFile, 'lastUsedImageFolder');
	end
    set(handles.txtFolder, 'string', handles.ImageFolder);
	
    %uiwait(msgbox(handles.ImageFolder));
    % Load list of images in the image folder.
    handles = LoadImageList(handles);
	% Select none of the items in the listbox.
	set(handles.lstImageList, 'value', []);
	% Update the number of images in the Analyze button caption.
	UpdateAnalyzeButtonCaption(hObject, eventdata, handles)
    
    % Load list of mask images in the app/masks folder.
    handles=LoadMaskList(handles);
	
	% Load a splash image.
    %axes(handles.axesImage);
	fullSplashImageName = fullfile(handles.macroFolder, '/Splash Images/Magic Hat.png');
	
	if exist(fullSplashImageName, 'file')
		% Display splash image.
		imgOriginal = imread(fullSplashImageName);
	else
		% Display something
		imgOriginal = peaks(300);
	end
    % Display image array in a window on the user interface.
	% Display in axes, storing handle of image for later quirk workaround.
	hold off;	% IMPORTANT NOTE: hold needs to be off in order for the "fit" feature to work correctly.
    axesChildHandle = imshow(imgOriginal, 'InitialMagnification', 'fit', 'parent', handles.axesImage);
	imageFolder = handles.ImageFolder;
	h = axesChildHandle;
	setappdata(h, 'imageFolder', imageFolder);

	txtInfo = sprintf('MAGIC - MATLAB Analysis with test\n\ntest \ntest \n\ntest.');
	set(handles.txtInfo, 'string', txtInfo);
	
	% !!!! QUIRK workaround.!!!!
	% Make it so that if they click in the image axes, it will execute a
	% button down callback called "axesImage_ButtonDownFcn".
	% Now it won't  -- unless you do this quirk workaround.
	% Double click on the dialog box's (main figure's) background to bring up the property inspector.
	% Change both the WindowButtonDownFcn and ButtonDownFcn properties so that they are blank.
	% Also set the main figure's HitTest to off.  Then, make sure you already have the handle to the
	% image living in the axes by getting it from an imshow.  Then do this:
	set(axesChildHandle, 'ButtonDownFcn', @axesImage_ButtonDownFcn);
	% Put everything you want to do when they click the image into the function axesImage_ButtonDownFcn()
	% !!!! End QUIRK workaround.!!!!

	fprintf(1, 'Done with magic_gui_OpeningFcn.\n');

	% Update handles structure
    guidata(hObject, handles);

% --- End of My Startup Code --------------------------------------------------
%=====================================================================


%=====================================================================
% --- Outputs from this function are returned to the command line.
function varargout = magic_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	fprintf(1, 'Just entered magic_gui_OutputFcn...\n');
	% Get default command line output from handles structure
	varargout{1} = handles.output;
	% Call special function that The Mathworks provides on their website to maximize the window and leave it in focus.
	% 	minfig(F,1) % minimizes the figure window for the figure with handle F
	% 	minfig(F,0) % restores figure F if F is minimized
	% 	maxfig(F,1) % maximizes the figure window for the figure with handle F
	% 	maxfig(F,0) % restores figure F if F is maximized s = figstate(F) % returns the state of figure { Maximized | Minimized | Normal }
	% Note: This works only if the window is already displayed.  If not, it will throw a java exception.
	% The best place to put this is in the yourApp_OutputFcn(), 
	% which actually gets called as the last thing before your app is made available to the user.
	checkForMaxfig = whos('maxfig');
	if isempty(checkForMaxfig)
		% maxfig is not installed on this computer.
		% Enlarge figure to full screen.
		set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
	else
		maxfig(handles.figMainWindow, 1) % Maximizes the figure window for the figure with handle in the first argument.
	end
	fprintf(1, 'Done with magic_gui_OutputFcn.\n');

%=====================================================================
% --- Executes on clicking in lstImageList listbox.
% Display image from disk and plots histogram
function lstImageList_Callback(hObject, eventdata, handles)
% hObject    handle to lstImageList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = get(hObject,'String') returns lstImageList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstImageList
    global baseImageFileName;
	clear global imgOriginal;
	global imgOriginal;	% Declare global so that other functions can see it, if they also declare it global.
	
	% Change mouse pointer (cursor) to an hourglass.  
	% QUIRK: use 'watch' and you'll actually get an hourglass not a watch.
	set(gcf,'Pointer','watch');
	drawnow;	% Cursor won't change right away unless you do this.

	% Update the number of images in the Analyze button caption.
	UpdateAnalyzeButtonCaption(hObject, eventdata, handles)

	% Get image name
    selectedListboxItem = get(handles.lstImageList, 'value');
	if isempty(selectedListboxItem)
		% Bail out if nothing was selected.
		% Change mouse pointer (cursor) to an arrow.
		set(gcf,'Pointer','arrow');
		drawnow;	% Cursor won't change right away unless you do this.
		return;
	end
    % If more than one is selected, bail out.
    if length(selectedListboxItem) > 1 
        % Disable Draw new mask - not clear if there is an image being
        % displayed.
        set(handles.btnDrawNewMask, 'enable', 'off');
        baseImageFileName = '';
		% Change mouse pointer (cursor) to an arrow.
		set(gcf,'Pointer','arrow')
		drawnow;	% Cursor won't change right away unless you do this.
        return;
    end
    % If only one is selected, display it.
	set(handles.axesPlot, 'visible', 'off');	% Hide plot of results since there are no results yet.
    set(handles.btnDrawNewMask, 'enable', 'on');    % Enable Draw Mask Button.
    ListOfImageNames = get(handles.lstImageList, 'string');
    baseImageFileName = strcat(cell2mat(ListOfImageNames(selectedListboxItem)));
    fullImageFileName = [handles.ImageFolder '/' baseImageFileName];	% Prepend folder.
	
	[folder, baseFileName, extension] = fileparts(fullImageFileName);
	switch lower(extension)
	case {'.mov', '.wmv', '.asf'}
		msgboxw('Mov and wmv format video files are not supported by MATLAB.');
		% Change mouse pointer (cursor) to an arrow.
		set(gcf,'Pointer','arrow');
		drawnow;	% Cursor won't change right away unless you do this.
		return;
	case '.avi'
		% The only video format supported natively by MATLAB is avi.
		% A more complicated video player plug in is on MATLAB File Central
		% that will support more types of video.  It has a bunch of DLL's and
		% other files that you have to install.
		
		% Read the file into a MATLAB movie structure.
		myVideo = aviread(fullImageFileName);
		myVideoParameters = aviinfo(fullImageFileName);
		numberOfFrames = myVideoParameters.NumFrames;
		
		% Extract a frame.
		frameToView = uint8(floor(numberOfFrames/2));	% Take the middle frame.
		imgFirstFrame = myVideo(frameToView).cdata;	% The index is the frame number.
		cla(handles.axesPlot, 'reset');
		imshow(imgFirstFrame, 'Parent', handles.axesPlot); % Display the first frame.
		
		% Play the movie in the axes.  It doesn't stretch to fit the axes.
		% The macro will wait until it finishes before continuing.
		axes(handles.axesImage);
		hold off;
		cla(handles.axesImage, 'reset'); % Let image resize, for example demo video rhinos.avi won't fill the image buffer if we don't do this.
		movie(handles.axesImage, myVideo);
		cla(handles.axesPlot, 'reset'); % Clear the mini-image from the plot axes.
		
	    guidata(hObject, handles);
		% Change mouse pointer (cursor) to an arrow.
		set(gcf,'Pointer','arrow');
		drawnow;	% Cursor won't change right away unless you do this.
		return;
	otherwise
		% Display the image.
		imgOriginal = DisplayImage(handles, fullImageFileName);
	end
	
	% If imgOriginal is empty (couldn't be read), just exit.
	if isempty(imgOriginal) 
		% Change mouse pointer (cursor) to an arrow.
		set(gcf,'Pointer','arrow');
		drawnow;	% Cursor won't change right away unless you do this.
		return;
	end
	
	% Read in mask file, or if they haven't chosen one, just have mask be 
	% entire shape of imgOriginal.
	GetImageMask(handles);
	% These declarations need to be after GetImageMask because GetImageMask clears them
	% out and the association with this function is then lost.
	global imgMask;
	global maskVerticesXCoordinates;
	global maskVerticesYCoordinates;

	% Mask off the original with pre-selected mask, if they chose one.
	% Then display masked image and return it in array maskedImage and
	% return mask in logical array binaryMask
	imageSize = size(imgOriginal);
	% Convert this outline into an image.
	imgMask = poly2mask(maskVerticesXCoordinates, maskVerticesYCoordinates, imageSize(1), imageSize(2));
	[maskedImage logBinaryMask] = MaskAndDisplayImage(handles, imgOriginal, false);
	
	% Analyze this image.
	if get(handles.chkAutoAnalyze,'Value') 
		AnalyzeSingleImage(handles, maskedImage, logBinaryMask);
    end

    %fprintf('lstImageList_Callback.5\n');
    
    %axes(handles.axesImage);	% Switch current figure back to image box.
    
    %fprintf('lstImageList_Callback.6\n');
    
	% Change mouse pointer (cursor) to an arrow.
	set(gcf,'Pointer','arrow');
	drawnow;	% Cursor won't change right away unless you do this.
    guidata(hObject, handles);
    return % from lstImageList_Callback()

%=====================================================================
% Reads FullImageFileName from disk into the axesImage axes.
function imageArray = DisplayImage(handles, FullImageFileName)
	% Read in image.
	try
		[imageArray colorMap] = imread(FullImageFileName);
		% colorMap will have something for an indexed image (gray scale image with a stored colormap).
		% colorMap will be empty for a true color RGB image or a monochrome gray scale image.
	catch ME
		errorMessage = sprintf('Error opening image file with imread():\n%s', FullImageFileName);
		set(handles.txtInfo, 'String', errorMessage);
		msgboxw(errorMessage);
		imageArray = [];
		return;	% Skip the rest of this function
	end
	
	try
		% Display image array in a window on the user interface.
		%axes(handles.axesImage);
		hold off;	% IMPORTANT NOTE: hold needs to be off in order for the "fit" feature to work correctly.
		
		% Here we actually display the image in the "axesImage" axes.
		axesChildHandle = imshow(imageArray, 'InitialMagnification', 'fit', 'parent', handles.axesImage);

		% Display a title above the image.
		[folder, basefilename, extension] = fileparts(FullImageFileName);
		extension = lower(extension);
		% Convert any underlines in the name into spaces because otherwise the character after the underline would be a subscript.
		caption = strrep([basefilename extension], '_', ' ');
		% Display the title.
		title(handles.axesImage, caption, 'FontSize', 14);

		% Make it so that if they click on the image, the callback function is executed.
		% See note on QUIRK in startup code section.
		set(axesChildHandle, 'ButtonDownFcn', @axesImage_ButtonDownFcn);
		imageFolder = folder;
		setappdata(axesChildHandle, 'imageFolder', imageFolder);

		[rows columns numberOfColorChannels] = size(imageArray);
		% Get the file date
		fileInfo = dir(FullImageFileName);
		txtInfo = sprintf('%s\n\n%d lines (rows) vertically\n%d columns across\n%d color channels\n', ...
			[basefilename extension], rows, columns, numberOfColorChannels);
		% Tell user the type of image it is.
		if numberOfColorChannels == 3
			colorbar 'off';  % get rid of colorbar.
			txtInfo = sprintf('%s\nThis is a true color, RGB image.', txtInfo);
		elseif numberOfColorChannels == 1 && isempty(colorMap)
			colorbar 'off';  % get rid of colorbar.
			txtInfo = sprintf('%s\nThis is a gray scale image, with no stored color map.', txtInfo);
		elseif numberOfColorChannels == 1 && ~isempty(colorMap)
			txtInfo = sprintf('%s\nThis is an indexed image.  It has one "value" channel with a stored color map that is used to pseudocolor it.', txtInfo);
			colormap(colorMap);
			whos colorMap;
			%fprintf('About to apply the colormap...\n');
			% Thanks to Jeff Mather at the Mathworks to helping to get this working for an indexed image.
			colorbar('peer', handles.axesImage);
			%fprintf('Done applying the colormap.\n');
		end
		% Show the file time and date.
		txtInfo = sprintf('%s\n\n%s', txtInfo, fileInfo.date);
		set(handles.txtInfo, 'String', txtInfo);

		% Plot the histogram if requested.
		plotHistogram = get(handles.chkPlotHistograms, 'Value');
		if plotHistogram
			fprintf('About to plot histogram...\n');
			PlotImageHistogram(handles, imageArray);
			fprintf('Done plotting histogram.\n');
		end
	catch ME
		errorMessage = sprintf('Error in function DisplayImage.\nError Message:\n%s', ME.message);
		WarnUser(errorMessage);
	end
	return; % from DisplayImage


%=====================================================================
function DisplayResults(handles, resultsArray)
	% Display the results
	% MATLAB BUG: \t doesn't work (R2006a)
	% Workaround: convert to "courier New to get fixed space font and use
	% spaces or field widths to align the numbers.
	global CDFPercentiles;
	strHeader = sprintf('Measurement\n____________________________________________________');
	strTotalArea =    sprintf('Total area    %7d', resultsArray(1)) ;
	strMinValue =      sprintf('Minimum Value  %7.2f', resultsArray(2));
	strMaxValue =      sprintf('Minimum Value  %7.2f', resultsArray(3));
	strMeanValue =     sprintf('Mean Value     %7.2f', resultsArray(4));
	strStdDev =       sprintf('Std. Dev.     %7.2f', resultsArray(5));
	strPercentiles =  sprintf('25th percentile at %5.2f\n75th percentile at %5.2f\n50th percentile (median) at %5.2f', CDFPercentiles(25), CDFPercentiles(75), CDFPercentiles(50));
	strResults =      sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s', strHeader, strTotalArea, strMinValue, strMaxValue, strMeanValue, strStdDev, strPercentiles);
	set(handles.txtInfo, 'String', strResults);

	return;	% DisplayResults
	
%=====================================================================
% Update Analyze button and tooltip string depending on how many files in the listbox were selected.
function UpdateAnalyzeButtonCaption(hObject, eventdata, handles)
    Selected = get(handles.lstImageList, 'value');
	if length(Selected) > 1 
        buttonCaption = {'Step 6:  Analyze '};   % MATLAB quirk - needs to be cell array to keep trailing spaces.
        buttonCaption = strcat(buttonCaption, num2str(length(Selected)));
        buttonCaption = strcat(buttonCaption, ' images');
        set(handles.btnAnalyze, 'string', buttonCaption);
		set(handles.btnAnalyze, 'Tooltipstring', 'Display and analyze the selected image(s)');
	elseif length(Selected) == 1 
        set(handles.btnAnalyze, 'string', 'Step 6:  Analyze 1 image');
		set(handles.btnAnalyze, 'Tooltipstring', 'Display and analyze the selected image');		
	else
        set(handles.btnAnalyze, 'string', 'Step 6:  Analyze no images');
		set(handles.btnAnalyze, 'Tooltipstring', 'Please select image(s) first');
	end
	return;
		
%=====================================================================
% --- Executes during object creation, after setting all properties.
function lstImageList_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to lstImageList (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called

    % Hint: listbox controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    return

%=====================================================================
% --- Executes on clicking btnSelectFolder button.
% Asks user to select a directory and then loads up the listbox (via a call
% to LoadImageList)
function btnSelectFolder_Callback(hObject, eventdata, handles)
    % hObject    handle to btnSelectFolder (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %msgbox(handles.ImageFolder);
    returnValue = uigetdir(handles.ImageFolder,'Select folder');
	% returnValue will be 0 (a double) if they click cancel.
	% returnValue will be the path (a string) if they clicked OK.
	if returnValue ~= 0
		% Assign the value if they didn't click cancel.
		handles.ImageFolder = returnValue;
		handles = LoadImageList(handles);
		set(handles.txtFolder, 'string' ,handles.ImageFolder);
		guidata(hObject, handles);
		% Save the image folder in our ini file.
		lastUsedImageFolder = handles.ImageFolder;
		save('Magic_GUI.mat', 'lastUsedImageFolder');
	end
    return
    
%=====================================================================
% --- Load up the listbox with tif files in folder handles.handles.ImageFolder
function handles=LoadImageList(handles)        
	ListOfImageNames = {};
	folder = handles.ImageFolder;
	if ~isempty(handles.ImageFolder) 
		if exist(folder,'dir') == false
			warningMessage = sprintf('Note: the folder used when this program was last run:\n%s\ndoes not exist on this computer.\nPlease run Step 1 to select an image folder.', handles.ImageFolder);
			msgboxw(warningMessage);
			return;
		end
	else
		msgboxw('No folder specified as input for function LoadImageList.');
		return;
	end
	% If it gets to here, the folder is good.
	ImageFiles = dir([handles.ImageFolder '/*.*']);
	for Index = 1:length(ImageFiles)
		baseFileName = ImageFiles(Index).name;
		[folder, name, extension] = fileparts(baseFileName);
		extension = upper(extension);
		switch lower(extension)
		case {'.png', '.bmp', '.jpg', '.tif', '.avi'}
			% Allow only PNG, TIF, JPG, or BMP images
			ListOfImageNames = [ListOfImageNames baseFileName];
		otherwise
		end
	end
	set(handles.lstImageList,'string',ListOfImageNames);
    return

%=====================================================================
% --- Load up the listbox with tif files in folder handles.handles.ImageFolder
function handles=LoadMaskList(handles)        
    ListOfMaskFilenames = {'Do not use a mask'};
    dirListing = dir([handles.maskFolder '/*.mat']);
    for Index = 1:length(dirListing)
        baseFileName = dirListing(Index).name;
        ListOfMaskFilenames = [ListOfMaskFilenames baseFileName];
    end
    set(handles.lstMasks, 'string', ListOfMaskFilenames);
    return


%=====================================================================
% --- Executes on clicking btnAnalyze button.
% Goes down through the list, displaying then analyzing each highlighted image file.
% Main processing is done by the function AnalyzeSingleImage()
function btnAnalyze_Callback(hObject, eventdata, handles)
    % hObject    handle to btnAnalyze (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
	
	% Change mouse pointer (cursor) to an hourglass.  
	% QUIRK: use 'watch' and you'll actually get an hourglass not a watch.
	set(gcf,'Pointer','watch');
	drawnow;	% Cursor won't change right away unless you do this.

	% Get a list of those indexes that are selected, so we know which images to process.
    Selected = get(handles.lstImageList, 'value');
    numberOfSelectedFiles = length(Selected);

	% Then get list of all of the filenames in the list,
	% regardless of whether they are selected or not.
    ListOfImageNames = get(handles.lstImageList, 'string');
	
    % Make an array for the results.  
	% We will send these to Excel if requested.
%     resultsArray = zeros(numberOfSelectedFiles, 6);
	
	for j = 1 : numberOfSelectedFiles    % Loop though all selected indexes.
        index = Selected(j);    % Get the next selected index.
        % Get the filename for this selected index.
        baseImageFileName = strcat(cell2mat(ListOfImageNames(index)));
		imageFullFileName = fullfile(handles.ImageFolder, baseImageFileName);
		
		% Display the image.
		imgOriginal = DisplayImage(handles, imageFullFileName);
		% If imgOriginal is empty (couldn't be read), skip to next file.
		if isempty(imgOriginal) 
			continue;
		end
	
		% If you don't want to use masking, then uncomment the next two lines.
% 		maskedImage = imgOriginal;
% 		logBinaryMask = [];
        % Mask off the original with pre-selected mask, if they chose one.
		% Then display masked image and return it in array maskedImage and
		% return mask in logical array binaryMask.
		% If you don't want to use masking, then delete the next line.
		[maskedImage logBinaryMask] = MaskAndDisplayImage(handles, imgOriginal, true);
		
		% Analyze this image.
        resultsArray = AnalyzeSingleImage(handles, maskedImage, logBinaryMask);
		
		if get(handles.chkSendToExcel, 'value') 
			% Send the results to Excel.  One workbook will be created for each image.
			% Note: You could have one workbook and one worksheet for each image, (just keep the
			% same excelFullFileName but change workSheetName), but Excel 2003 limits you
			% to 32 worksheets or less per workbook, so be aware of that.
			blankString = ' ';  % Need so that both rows of columnNames cell array have the same number of elements (or else you'll get an error).
			columnNames = {baseImageFileName, blankString, blankString, blankString,...
				blankString, blankString, blankString; ...
				'Blob #', 'Area', 'Mean Intensity', 'Perimeter', ...
				'CentroidX', 'CentroidY', 'ECD'};
			[folder, baseFileNameNoExtension, extension] = fileparts(baseImageFileName);
			excelBaseFileName = sprintf('Results for %s.xls', baseFileNameNoExtension);
			excelFullFileName = fullfile(handles.ImageFolder, excelBaseFileName);
			workSheetName = 'Results';
			% Write the filename into row 1, and the column headings into row 2.
			xlswrite(excelFullFileName, columnNames, workSheetName, 'B1');
			% Write numerical results starting on row 3.
			xlswrite(excelFullFileName, resultsArray, workSheetName, 'B3');
			msgboxw({'Done with analysis.  Results are in Excel file:'; excelFullFileName});
		end
		
		% Prompt to allow user to inspect the image.
        if j < numberOfSelectedFiles && get(handles.chkPauseAfterImage, 'value') 
            userPrompt = sprintf('Check out results, then\nclick Continue to process the next image.');
			reply = questdlg(userPrompt, ...
				'Continue?', 'Continue', 'Quit loop', 'Continue');
			% reply = '' for Upper right X, otherwise it's the exact wording.
			if strcmpi(reply, 'Quit loop')
				set(handles.txtInfo, 'string', 'Batch processing terminated.');
				break;
			end
        end
	end	
		    
	set(gcf,'Pointer','arrow');
	drawnow;	% Cursor won't change right away unless you do this.

	guidata(hObject, handles);
    return

%=====================================================================
% Mask image according to maskVerticesXCoordinates and maskVerticesYCoordinates.
% Important: imgOriginal can't be empty since MATLAB won't allow you to pass
% empty arrays as arguments.
% Inputs:
%	imgOriginal is either a 2D monochrome image or a 3D color image.
%	showImage = logical true if you want to display it.  showImage = false to not display.
% Outputs:
%	logBinaryMask is a 2D logical (binary) image of just the mask.
%	maskedImage is which has been set to zero outside of the mask.
function [maskedImage logBinaryMask] = MaskAndDisplayImage(handles, imgOriginal, showImage)
	% Declare our global variables so that this function can now see and access them.
	global maskVerticesXCoordinates;
	global maskVerticesYCoordinates;
	% Mask off the original with pre-selected mask, if they chose one.
	
	% Set up default return values.
	maskedImage = [];
	logBinaryMask = [];
	lowValue = 0;
	highValue = 255;
	
	% Gate check for valid values.
	if isempty(imgOriginal)
		% No image - nothing to do!
		return;
	end
	if isempty(maskVerticesXCoordinates) || isempty(maskVerticesYCoordinates)
		% No mask coordinates - nothing to mask.  Just display if requested, then exit.
		if showImage
			% Display masked image array in a window on the user interface.
			%axes(handles.axesImage);
			hold(handles.axesImage, 'off');	% Need to do this so the image will get updated and the image buffer won't be sized according to the last image that was in there.
			imshow(maskedImage, [lowValue highValue], 'parent', handles.axesImage);
		end
		return;
	end
	
	% If we get here, we have an image array passed in, and a valid mask.
	imageSize = size(imgOriginal);
	% Convert this outline into a binary image.
	imgMask = poly2mask(maskVerticesXCoordinates, maskVerticesYCoordinates, imageSize(1), imageSize(2));
	maskSize = size(imgMask);

	% Now, mask off image
	% First mask sure mask is the same size as the image.
	% Make sure the dimensions are the same.
	% Make sure masked image is the same size as the original.
	% You have to create it first with some definite size before you
	% can multiply it by a mask image.
	maskedImage = imgOriginal;
	if maskSize(1) ~= imageSize(1) || maskSize(1) ~= imageSize(1)
		% Dimensions of image and mask don't match.
		% Mask is the entire image - in essence, no mask.
% 		errorMessage = {'Cannot show mask over the color image because', 'the mask image dimensions do not match the image dimensions.', ['    Mask image dimensions: ' num2str(maskSize(1)) ' by ' num2str(maskSize(2))], ['    Color image dimensions: ' num2str(imageSize(1)) ' by ' num2str(imageSize(2))]};
% 		msgboxw(errorMessage);
		logBinaryMask  = ones(size(imgOriginal)) == 1;	% logical image.
	else
		% Image and mask image dimension match.
		if length(imageSize) >= 3
			numberOfColors = imageSize(3);
		else
			numberOfColors = 1;
		end
		if numberOfColors >= 2
			highRValue = max(imgOriginal(:,:,1));
			highGValue = max(imgOriginal(:,:,2));
			highBValue = max(imgOriginal(:,:,3));
			highValue = max([highRValue highGValue highBValue]);	% Max over all pixels in all color bands.
			for intColorBand = 1:numberOfColors
				maskedImage(:,:,intColorBand) = double(imgOriginal(:,:,intColorBand)) .* double(imgMask(:,:));
			end
		else
			% It's monochrome.
			lowValue = min(imgOriginal(:));
			highValue = max(imgOriginal(:));
			maskedImage = double(imgOriginal) .* double(imgMask);
		end
		logBinaryMask = imgMask > 0;	% logical image.
	end

	if showImage
		% Display masked image array in a window on the user interface.
		%axes(handles.axesImage);
		hold(handles.axesImage, 'off');	% Need to do this so the image will get updated and the image buffer won't be sized according to the last image that was in there.
		imshow(maskedImage, [lowValue highValue], 'parent', handles.axesImage);
	end
	return;
		
%=====================================================================
% --- Executes on button press in btnSelectAllOrNone.
function btnSelectAllOrNone_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectAllOrNone (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Find out button caption and take appropriate action.
    ButtonCaption = get(handles.btnSelectAllOrNone, 'string');
	if strcmp(ButtonCaption, 'Step 2:  Select All') == 1
        % Select all items in the listbox.
        % Need to find out how many items are in the listbox (both selected and
        % unselected).  It's quirky and inefficient but it's the only way I
        % know how to do it. 
        % First get the whole damn listbox text into a cell array.
        caListboxString = get(handles.lstImageList, 'string');
        NumberOfItems = length(caListboxString);    % Get length of that cell array.
        AllIndices=1:NumberOfItems; % Make a vector of all indices.
        % Select all indices.
        set(handles.lstImageList, 'value', AllIndices);
        % Finally, change caption to say "Select None"
        set(handles.btnSelectAllOrNone, 'string', 'Step 2:  Select None');
        % It scrolls to the bottom of the list.  Use the following line
        % if you want the first item at the top of the list.
        set(handles.lstImageList, 'ListboxTop', 1);
    else
        % Select none of the items in the listbox.
        set(handles.lstImageList, 'value', []);
        % Change caption to say Select All
        set(handles.btnSelectAllOrNone, 'string', 'Step 2:  Select All');
	end
	% Update the number of images in the Analyze button caption.
	UpdateAnalyzeButtonCaption(hObject, eventdata, handles)
	guidata(hObject, handles);


%=====================================================================
% --- Executes on button press in chkSendToExcel.
function chkSendToExcel_Callback(hObject, eventdata, handles)
% hObject    handle to chkSendToExcel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkSendToExcel
	checkboxState = get(hObject,'Value');
	message = sprintf('Now the results will be saved to an Excel workbook in folder\n%s', handles.ImageFolder);
	if checkboxState
		set(handles.txtInfo, 'string', message);
	else
		set(handles.txtInfo, 'string', 'Now the results will not be saved to an Excel workbook.');
	end


%=====================================================================
% --- Executes on button press in chkPauseAfterImage.
function chkPauseAfterImage_Callback(hObject, eventdata, handles)
% hObject    handle to chkPauseAfterImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkPauseAfterImage
	checkboxState = get(hObject,'Value');
	if checkboxState
		set(handles.txtInfo, 'string', 'Now you will be able to inspect the results before it processes the next image.');
	else
		set(handles.txtInfo, 'string', 'Now the image(s) will be analyzed without pausing for you will be able to inspect the results in between images.');
	end


%=====================================================================
function GetImageMask(handles)
	% Make sure it's cleared out (work around of MATLAB feature).
	% MATLAB QUIRK.  MATLAB can remember maskVerticesXCoordinates and maskVerticesYCoordinates
	% prior runs of this macro even when you haven't clicked on the mask.
	% This is because if you don't erase it from the "global" workspace before you exit this m-file
	% then it will remain in the global workspace.
	% It will even remember it in the ImageList_Callback function even
	% though imgMask has never even been mentioned prior to it getting
	% there.  Clearing it here seems to fix everything.
	clear global maskVerticesXCoordinates;
	clear global maskVerticesYCoordinates;
	% Now redeclare them.  They should be empty at this point.
	% Declare both the logical mask image and the coordinates that created it.
	global maskVerticesXCoordinates;
	global maskVerticesYCoordinates;

	% Declare imgOriginal.  It might be filled with values here.
	global imgOriginal;	% Declare global so that other functions can see it, if they also declare it global.
	
    %fprintf('GetImageMask.4\n');

    % Clear any exiting polygon overlay that may be plotted on top of the image.
	%axes(handles.axesImage);
    %drawnow
	
    %fprintf('GetImageMask.4a\n');
	ClearLinesFromAxes(handles.axesImage);
	
	% Get the index of the entry they've selected.
    SelectedMask = get(handles.lstMasks, 'value');
	if ~isempty(imgOriginal)
		% An image is available.
		imageSize = size(imgOriginal);
		% Get mask coordinates: either derive them from the original image size,
		% or read them in from a disk file.
		if SelectedMask == 1 
			% They have selected the top entry: "Do not use a mask"
			% If they've selected an image, make the mask an array of all ones
			% the same size as the image.
			maskVerticesXCoordinates(1) = 0;
			maskVerticesXCoordinates(2) = 0;
			maskVerticesXCoordinates(3) = imageSize(2);
			maskVerticesXCoordinates(4) = imageSize(2);
			maskVerticesYCoordinates(1) = 0;
			maskVerticesYCoordinates(2) = imageSize(1);
			maskVerticesYCoordinates(3) = imageSize(1);
			maskVerticesYCoordinates(4) = 0;			
		else
			% They've selected a mask file.
			% Get the complete list of all mask file names listed,
			% whether selected or not.
			ListOfImageNames = get(handles.lstMasks, 'string');
			% Get the mask file name
			maskName = strcat(cell2mat(ListOfImageNames(SelectedMask)));

			% Get the full name of the mask coordinates file.
			[folder, baseFileName, ext] = fileparts(maskName);
			coordinatesFileName = fullfile(handles.maskFolder, [baseFileName '.mat']);
			load(coordinatesFileName, 'maskVerticesXCoordinates', 'maskVerticesYCoordinates');
			
			% Clip to mask coordinates to image boundaries.  Mask can't go outside the image.
			maskVerticesXCoordinates(maskVerticesXCoordinates > imageSize(2)) = imageSize(2);
			maskVerticesYCoordinates(maskVerticesYCoordinates > imageSize(1)) = imageSize(1);

			% Plot the mask as an outline over the image.
			hold on;
			plot(maskVerticesXCoordinates, maskVerticesYCoordinates, 'linewidth', 2);
		end
		        
	else
		% They've not clicked on an image yet.  
		% Just read in the mask coordinates and return.
		if SelectedMask == 1 
			% They have selected the top entry: "Do not use a mask"
			% If they've selected an image, make the mask an array of all ones
			% the same size as the image.
			return;
		else
			% They've selected a mask file but no image file.
			% Get the complete list of all mask file names listed,
			% whether selected or not.
			ListOfImageNames = get(handles.lstMasks, 'string');
			% Get the mask file name
			maskName = strcat(cell2mat(ListOfImageNames(SelectedMask)));

			% Get the full name of the mask coordinates file.
			[folder, baseFileName, ext] = fileparts(maskName);
			coordinatesFileName = fullfile(handles.maskFolder, [baseFileName '.mat']);
			load(coordinatesFileName, 'maskVerticesXCoordinates', 'maskVerticesYCoordinates');
			% Nothing more we can do since we don't have an image,
			% so just exit.
			return;
		end
	end
	return;
	
	
%=====================================================================
% Erases all lines from the image axes.  The current axes should be set first using the axes()
% command before this function is called, as it works from the current axes, gca.
function ClearLinesFromAxes(h)

    %fprintf('ClearLinesFromAxes.1\n');
	axesHandlesToChildObjects = findobj(h, 'Type', 'line');
    %fprintf('ClearLinesFromAxes.2\n');
	if ~isempty(axesHandlesToChildObjects)
		delete(axesHandlesToChildObjects);
	end
	return; % from ClearLinesFromAxes

	
%=====================================================================
% --- Executes on selection change in lstMasks.
% Displays mask on top of the displayed image, if imgOriginal is not empty.
% Auto-analyzes if that checkbox is checked.
function lstMasks_Callback(hObject, eventdata, handles)
% hObject    handle to lstMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lstMasks contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstMasks
    
	% Read the image mask file and put the result into a logical mask image called imgMask.
	GetImageMask(handles);

	% These declarations need to be after GetImageMask because GetImageMask clears them
	% out and the association with this function is then lost.
	global imgOriginal;	% Every function that declares this variable global will be able to use and modity it.

	if ~isempty(imgOriginal)
		% Mask off the original with pre-selected mask, if they chose one.
		% Then display masked image and return it in array maskedImage and
		% return mask in logical array binaryMask
		[maskedImage logBinaryMask] = MaskAndDisplayImage(handles, imgOriginal, false);

		if get(handles.chkAutoAnalyze, 'Value') 
			% Analyze this image.
			AnalyzeSingleImage(handles, maskedImage, logBinaryMask);
		else
			set(handles.txtInfo, 'String', ' ');
		end
	end

    %axes(handles.axesImage);	% Switch current figure back to image box.
    guidata(hObject, handles);
    return


%=====================================================================
% --- Executes during object creation, after setting all properties.
function lstMasks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%=====================================================================
% --- Executes on button press in btnDrawNewMask.
% Allows user to draw a polygon over image and then save the coordinates in a binary data file.
% (We could just as well use a mat format file.)
function btnDrawNewMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnDrawNewMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

	% Declare our global variables in case they want to save them to a mat file.
	global maskVerticesXCoordinates;
	global maskVerticesYCoordinates;
	
    % Prompt user to draw a region on the image.
    uiwait(msgbox({'Draw a polygon over the image.' 'Right click the last vertex point to finish drawing.'}));
	
	% Erase all previous lines.
	ClearLinesFromAxes(handles.axesImage);
	
	% Get binary image that is a mask representing the region they drew.
    % binaryMask is an image of Logical data type.
    [binaryMask xCoords yCoords] = roipolyold;   % drop the binaryMask= and ; to see the binary image mask
%     imshow(binaryMask);

	% Plot the mask as an outline over the image.
	hold on;
	plot(xCoords, yCoords, 'linewidth', 2);

    reply = questdlg({'Do you want to save the mask', 'to disk as a template?'},'Save mask?', 'Yes','No', 'Yes');
    % Note: reply = '' for Upper right X, 'Yes' for Yes, 'No' for No.
    if strcmp(reply, 'Yes')
		defaultFileName = fullfile(handles.maskFolder, 'Polygon.mat');
		[fileName, folder, FilterIndex] = uiputfile(defaultFileName, 'Save mask file name');
		if FilterIndex == 0
			% If the user clicks the Cancel button, closes the dialog window, 
			% or if the file does not exist, FilterIndex is set to 0. 
			% Bail out in that case.
		    guidata(hObject, handles);
			return;
		end
		
		maskVerticesXCoordinates = xCoords;
		maskVerticesYCoordinates = yCoords;

		[folder, baseFileName, ext] = fileparts(fileName);
        % Save the mask as a PNG-format image for later recall if desired.
%         maskImageFileName = fullfile(handles.maskFolder, [baseFileName '.png']);
%         imwrite(binaryMask, maskImageFileName, 'png');
		
		% Write the coordinates out to a mat-format file.		
        coordinatesFileName = fullfile(handles.maskFolder, [baseFileName '.mat']);
		save(coordinatesFileName, 'maskVerticesXCoordinates', 'maskVerticesYCoordinates');

		% Refresh the listbox of mask filenames.
        % Load list of mask images in the app/masks folder.
        handles=LoadMaskList(handles);
    		
		% Now let's make sure that the one we just saved is the selected one.
		% First get the complete list of all mask file names listed, whether selected or not.
		ListOfImageNames = get(handles.lstMasks, 'string');
		numberOfMasks = length(ListOfImageNames);
		for maskNumber = 2:numberOfMasks
			% Get the mask file name
			maskName = strcat(cell2mat(ListOfImageNames(maskNumber)));
			if strcmpi(maskName, [baseFileName '.mat'])
				set(handles.lstMasks, 'value', maskNumber);	% Select first entry
				break;	% Skip the rest of the loop since we found it.
			end
		end
	end

    guidata(hObject, handles);
	return;


%=====================================================================
% --- Executes during object creation, after setting all properties.
% EVEN THOUGH THIS FUNCTION IS EMPTY, DON'T DELETE IT OR ERRORS WILL OCCUR
function axesPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesPlot


%=====================================================================
% --- Executes during object creation, after setting all properties.
% EVEN THOUGH THIS FUNCTION IS EMPTY, DON'T DELETE IT OR ERRORS WILL OCCUR
function axesImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axesImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axesImage


%=====================================================================
% --- Executes during object creation, after setting all properties.
% EVEN THOUGH THIS FUNCTION IS EMPTY, DON'T DELETE IT OR ERRORS WILL OCCUR
function figMainWindow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figMainWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%=====================================================================
% --- Executes on mouse press over axes background.
function axesImage_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axesImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% IMNPORTANT NOTE: handles is not available for some strange reason
% when we get here as a result of clicking on the image.
% That's why we use "global" and not handles or getappdata (which also requires handles).
	fprintf(1, 'Just entered axesImage_ButtonDownFcn...\n');
    global baseImageFileName;
	if length(baseImageFileName) < 4 
		return;
	end
	% Retrieve the image folder, which was stored with the image object
	% when it was displayed with DisplayImage().
	imageFolder = getappdata(hObject, 'imageFolder');
	fullFileName = [imageFolder '/' baseImageFileName];
	if exist(fullFileName, 'file')
		hEnlargedImage = figure(1);		% Bring up a new window.
		hImage = imshow(fullFileName);
		% Make the figure fill up most of the screen.
		w = 0.96;
		h = 0.85;
		pos = [(1-w)/2, (1-h)/2, w, h]; % [left, bottom, width, height]
		% Apply to the GUI.
		set(hEnlargedImage, 'Units', 'Normalized');
		set(hEnlargedImage, 'Position', pos);
% 		disp(get(hImage,'Type'));
% 		disp(get(hEnlargedImage,'Type'));
% 		maximize(hEnlargedImage);
	else
		errorMessage = sprintf('The file does not exist:\n%s', fullFileName);
		WarnUser(errorMessage);
	end
	fprintf(1, 'Leaving axesImage_ButtonDownFcn.\n');
	return; % from axesImage_ButtonDownFcn

%=====================================================================
% --- Executes on button press in btnDeleteMask.
function btnDeleteMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnDeleteMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	% Get the index of the entry they've selected.
    Selected = get(handles.lstMasks, 'value');
	if Selected == 1 
		% They have selected the top entry: "Do not use a mask"
		% If so, just return.
		msgboxw('You must select a mask file first.');
		return;
	end
	
	% Get the complete list of all mask image names listed,
	% whether selected or not.
    ListOfImageNames = get(handles.lstMasks, 'string');
    % Get the mask image name
    baseFileName = strcat(cell2mat(ListOfImageNames(Selected)));
    reply = questdlg({'Do you want to send this mask to the recycle bin?', handles.maskFolder, baseFileName},'Delete mask?', 'Yes','No', 'Yes');
    % reply = '' for Upper right X, 'Yes' for Yes, 'No' for No.
	if strcmp(reply, 'Yes')
		% Erase any existing, displayed mask.
		ClearLinesFromAxes(handles.axesImage);

        maskFullFileName = fullfile(handles.maskFolder, baseFileName);
		recycle('on')
		delete(maskFullFileName)
		% Refresh the listbox of mask filenames.
        % Load list of mask images in the app/masks folder.
		% QUIRK: need to set the selected index to something less than the
		% index at the end of the list otherwise you get an error.
		set(handles.lstMasks, 'value', 1);	% Select first entry
        handles=LoadMaskList(handles);
	end
    guidata(hObject, handles);
	return;

%=====================================================================
% --- Executes on button press in btnExit.
function btnExit_Callback(hObject, eventdata, handles)
% hObject    handle to btnExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	try
		fprintf(1, 'Just entered btnExit_Callback...\n');
		% Get rid of variables from the global workspace so that they aren't
		% hanging around the next time we try to run this m-file.
		clear global;
		% Cause it to shutdown.
		delete(handles.figMainWindow);
		fprintf(1, 'Leaving btnExit_Callback.\n');
	catch ME
		errorMessage = sprintf('Error in function btnExit_Callback.\nError Message:\n%s', ME.message);
		WarnUser(errorMessage);
	end


% --- Executes on button press in chkAutoAnalyze.
function chkAutoAnalyze_Callback(hObject, eventdata, handles)
% hObject    handle to chkAutoAnalyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of chkAutoAnalyze
	checkboxState = get(hObject,'Value');
	if checkboxState
		set(handles.txtInfo, 'string', 'Now the image will be analyzed as soon as it is selected.');
	else
		set(handles.txtInfo, 'string', 'Now the image(s) will be analyzed only when the Analyze button is clicked.');
	end

	
% --- Executes on button press in btnMoveMask.
% Demonstrates how to call a modal dialog box and pass arguments to it and receive output variables
% back from it.
function btnMoveMask_Callback(hObject, eventdata, handles)
% hObject    handle to btnMoveMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    Selected = get(handles.lstMasks, 'value');
	if Selected == 1 
		% They have selected the top entry: "Do not use a mask"
		% If so, just return.
		msgboxw('You must select a mask file first.');
		return;
	end
	global imgOriginal;
	global maskVerticesXCoordinates;
	global maskVerticesYCoordinates;
	[newMaskVerticesXCoordinates newMaskVerticesYCoordinates] = MoveMask(imgOriginal, maskVerticesXCoordinates, maskVerticesYCoordinates);
	maskVerticesXCoordinates = newMaskVerticesXCoordinates;
	maskVerticesYCoordinates = newMaskVerticesYCoordinates;
	% Delete old plot.
	%axes(handles.axesImage);
	h = findobj(handles.axesImage,'Type','line');
	if ~isempty(h)
		delete (h);
	end
	% Plot the new mask over the image.
	plot(maskVerticesXCoordinates, maskVerticesYCoordinates, 'linewidth', 2);
	return;

%=====================================================================
% Process image
% You can replace this contents of this function with whatever you want.
% Just delete it all and put your own code in here.
% For this simple tutorial, I simply thresholded the image (green band if it's a color image)
% according to MATLAB'S autothresholding method and got a distribution of blob sizes and plotted
% them.
function [resultsArray] = AnalyzeSingleImage(handles, maskedImage, binaryMask)
	try
	% Get the text in the edit text box.  (We don't do anything with it though - it's just for demo.)
	editTextContents = get(handles.edtEditText, 'String');
	editTextContents = editTextContents{:}; % Convert from cell array to string.
	fprintf(1, '%s\n', editTextContents);
	set(handles.txtInfo, 'String', editTextContents);
	
	resultsArray = zeros(1, 7);	% Initialize to make sure that something will always be returned.
	if length(size(maskedImage)) == 3
		% It's a color image.  Take the green band.
		originalImage = maskedImage(:, :, 2);
	else
		% It's a monochrome image.
		originalImage = maskedImage;
	end
    % Extract out all the pixels within the masked area so we can threshold the area within the mask.
	% The result will be a column vector, but we can still use it in graythresh().
	if isempty(binaryMask)
		% They want to use masking.
		pixelsInsideMask = uint8(maskedImage(binaryMask));   % Gives a column vector.
	else
		% They commented out the masking code.
		pixelsInsideMask = uint8(maskedImage(:));   % Gives a column vector.
	end
	thresholdLevel = graythresh(pixelsInsideMask) * 255;		% Find threshold according to Otsu's method.
	binaryImage = (originalImage >= thresholdLevel);       % Threshold to binary (a logical image)
	labeledImage = bwlabel(binaryImage, 8);     % Label each blob so can do calc on it
	% Show colored blobs just for fun.
	coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle'); % pseudo random color labels
	imshow(coloredLabels);
	drawnow; % Force an immediate update of the GUI.
	% Make the measurements
	blobMeasurements = regionprops(labeledImage, 'Area', 'Perimeter', 'PixelIdxList', 'Centroid');   % Get the blob properties of 'Area' and 'Perimeter'
	numberOfBlobs = size(blobMeasurements, 1);

	% bwboundaries returns a cell array, where each cell
	% contains the row/column coordinates for an object in the image.
	% Plot the borders of all the coins on the original
	% grayscale image using the coordinates returned by bwboundaries.
	hold on;
	boundaries = bwboundaries(binaryImage);	
	for k = 1 : numberOfBlobs
		thisBoundary = boundaries{k};
		plot(thisBoundary(:,2), thisBoundary(:,1), 'g', 'LineWidth', 2);
	end
	hold off;

	if numberOfBlobs > 1
		resultsArray = zeros(numberOfBlobs, 7);	% Pre-allocate space.
	end
	for blobNumber = 1 : numberOfBlobs           % Loop through all blobs.
		% Find the mean of each blob.  (R2008a has a better way where you can pass the original image
		% directly into regionprops.  The way below works for all versions including earlier versions.)
		thisBlobsPixels = blobMeasurements(blobNumber).PixelIdxList;  % Get list of pixels in current blob.
		meanGL = mean(originalImage(thisBlobsPixels));             % Find mean intensity (in original image!)
		blobArea = blobMeasurements(blobNumber).Area;		% Get area.
		blobPerimeter = blobMeasurements(blobNumber).Perimeter;		% Get perimeter.
		blobCentroid = blobMeasurements(blobNumber).Centroid;		% Get centroid.
		% Calculate the equivalent circular diameter - the diameter the blob would have it if were perfectly circular with the same area.
		blobECD = sqrt(4.0 * blobArea / pi);	
		resultsArray(blobNumber, 1) = blobNumber;
		resultsArray(blobNumber, 2) = blobArea;
		resultsArray(blobNumber, 3) = meanGL;
		resultsArray(blobNumber, 4) = blobPerimeter;
		resultsArray(blobNumber, 5) = blobCentroid(1);	% X coordinate.
		resultsArray(blobNumber, 6) = blobCentroid(2);	% Y coordinate.
		resultsArray(blobNumber, 7) = blobECD; % Equivalent Circular Diameter
	end
	% Set up the column headers.
	set(handles.uitable1, 'ColumnName', {'Blob #', 'Blob Area', 'Mean GL', 'Perimeter', 'Centroid X', 'Centroid Y', 'ECD'});
	% Stick the data ( a 2D numerical array) into the table.
	set(handles.uitable1, 'data', resultsArray);
	drawnow; % Force an immediate update of the GUI.

	% Read the radio button and sort according to what's selected.
	if get(handles.radOption1, 'value')
		indexToSortBy = -2;
		set(handles.pnlResults, 'title', 'Results sorted by area');
	elseif get(handles.radOption2, 'value')
		indexToSortBy = -3;
		set(handles.pnlResults, 'title', 'Results sorted by intensity');
	else
		indexToSortBy = -7;
		set(handles.pnlResults, 'title', 'Results sorted by ECD');
	end
	% Sort the array from largest blobArea to smallest blobArea (index #2).
	sortedResults = sortrows(resultsArray, indexToSortBy);
	% Put back the blob number in there (it got messed up during sorting).
	sortedResults(:, 1) = 1:numberOfBlobs;
	fprintf(1,'Blob #,    Area,     Mean GL,  Perimeter,  CentroidX,  CentroidY,   ECD\n');
	txtInfo = sprintf('Blob #      Area   Mean GL    Perimeter  CentroidX  CentroidY   ECD\n');
	for blobNumber = 1 : numberOfBlobs           % Loop through all blobs.
		% Print the values out to the command window.
		fprintf(1,'#%d %5.1f %11.1f %8.1f %8.1f %8.1f %8.1f\n', blobNumber, sortedResults(blobNumber, 2), sortedResults(blobNumber, 3), sortedResults(blobNumber, 4), sortedResults(blobNumber, 5), sortedResults(blobNumber, 6), sortedResults(blobNumber, 7));
		txtInfo = sprintf('%s#%d    %5.1f %11.1f %8.1f %8.1f %8.1f %8.1f\n', txtInfo, blobNumber, sortedResults(blobNumber, 2), sortedResults(blobNumber, 3), sortedResults(blobNumber, 4), sortedResults(blobNumber, 5), sortedResults(blobNumber, 6), sortedResults(blobNumber, 7));
	end
	set(handles.txtInfo, 'string', txtInfo);
	
    % Get a histogram of the blob ECD's within the masked area, and plot it.
	listOfECDs = sortedResults(:, 7);
	[PixelCounts, GLs] = PlotHistogram(handles, listOfECDs);

	catch ME
		% Some error happened if you get here.
		strErrorMessage = sprintf('Error in function mnuToolsSaveScreenshot_Callback\n\nError message: %s', ME.message);
		WarnUser(strErrorMessage);
	end
	return;  % AnalyzeSingleImage
	
%=====================================================================
% Takes histogram of 1-D array blobSizeArray, and plots it.
function [blobCounts, areaValues] = PlotHistogram(handles, blobSizeArray)
	% Get a histogram of the blobSizeArray and display it in the histogram viewport.
	numberOfBins = min([100 length(blobSizeArray)]);
	[blobCounts, areaValues] = hist(blobSizeArray, numberOfBins);
	% Plot the number of blobs with a certain area versus that area.
	axes(handles.axesPlot);
	bar(areaValues, blobCounts);
	title('Histogram of Blob Sizes');
	return;


%=====================================================================
function CenterFigure(handles)
	% The figure Position property
	% does not include the window borders, so this example uses a width of 5 pixels
	% on the sides and bottom and 30 pixels on the top.
	borderWidth = 5;
	titleBarWidth = 30;
	% Ensure root units are pixels and get the size of the screen:
	set(0, 'Units', 'pixels');
	set(handles.figMainWindow, 'Units', 'pixels');
	% Get the screen size in pixels.
	screenSize = get(0,'ScreenSize');
	% Get the size of the window.
	initialFigurePosition = get(handles.figMainWindow, 'Position');
	% Create an array that will center it.
	centeredX = (screenSize(3) - initialFigurePosition(3)) / 2;
	centeredY = (screenSize(4) - initialFigurePosition(4)) / 2;
	centeredPosition  = [centeredX,... 
		centeredY,...
		initialFigurePosition(3),...
		initialFigurePosition(4)];
	set(handles.figMainWindow, 'Position', centeredPosition);
	return; % from CenterFigure()


% --- Executes when selected object is changed in grpRadButtonGroup.
function grpRadButtonGroup_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in grpRadButtonGroup 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
	switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
		case 'radOption1'
			% Code for when radiobutton1 is selected.
			txtInfo = sprintf('Option 1 is selected and the others are deselected.\n\nResults will be sorted in order of decreasing area.');
			set(handles.pnlResults, 'title', 'Results sorted by area');
		case 'radOption2'
			% Code for when radiobutton2 is selected.
			txtInfo = sprintf('Option 2 is selected and the others are deselected.\n\nResults will be sorted in order of decreasing intensity.');
			set(handles.pnlResults, 'title', 'Results sorted by intensity');
		case 'radOption3'
			% Code for when togglebutton1 is selected.
			txtInfo = sprintf('Option 3 is selected and the others are deselected.\n\nResults will be sorted in order of decreasing ECD.');
			set(handles.pnlResults, 'title', 'Results sorted by ECD');
% 		case 'togglebutton2'
			% Code for when togglebutton2 is selected.
		% Continue with more cases as necessary.
		otherwise
			% Code for when there is no match.
	end
	set(handles.txtInfo, 'String', txtInfo);
	return; % from grpRadButtonGroup_SelectionChangeFcn


%=============================================================================================
% --- Executes on slider movement.
function sldHorizontalScrollbar_Callback(hObject, eventdata, handles)
% hObject    handle to sldHorizontalScrollbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
	scrollbarValue = get(hObject,'Value');
	caption = sprintf('H value = %.2f', scrollbarValue);
	set(handles.txtHScrollbar, 'string', caption);


%=============================================================================================
% --- Executes during object creation, after setting all properties.
function sldHorizontalScrollbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldHorizontalScrollbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%=============================================================================================
% --- Executes on slider movement.
function sldVerticalScrollbar_Callback(hObject, eventdata, handles)
% hObject    handle to sldVerticalScrollbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
	scrollbarValue = get(hObject,'Value');
	caption = sprintf('V value = %.2f', scrollbarValue);
	set(handles.txtVScrollbar, 'string', caption);

%=============================================================================================
% --- Executes during object creation, after setting all properties.
function sldVerticalScrollbar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sldVerticalScrollbar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%=============================================================================================
% --- Executes on mouse motion over figure - except title and menu.
function figMainWindow_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figMainWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



%=============================================================================================
function edtEditText_Callback(hObject, eventdata, handles)
% hObject    handle to edtEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edtEditText as text
%        str2double(get(hObject,'String')) returns contents of edtEditText as a double


%=============================================================================================
% --- Executes during object creation, after setting all properties.
function edtEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%=============================================================================================
function mnuToolsSaveScreenshot_Callback(hObject, eventdata, handles)
% hObject    handle to mnuToolsSaveScreenshot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% IMPORTANT NOTE: YOU MUST HAVE DOWNLOADED import_fig()
% FROM THE FILE EXCHANGE FOR THIS FUNCTION TO WORK.
	try
		% Save the figure
		% Have user browse for a file, from a specified "starting folder."
		% For convenience in browsing, set a starting folder from which to browse.
		startingFolder = 'C:\Program Files\MATLAB';
		if ~exist(startingFolder, 'dir')
			% If that folder doesn't exist, just start in the current folder.
			startingFolder = pwd;
		end
		% Get the name of the color image file that the user wants to save this figure into.
		defaultFileName = fullfile(startingFolder, 'MAGIC_Screenshot.png');
		[baseFileName, folder] = uiputfile(defaultFileName, 'Specify a file for your screenshot');
		if baseFileName == 0
			% User clicked the Cancel button.
			return;
		end
		screenshotFileName = fullfile(folder, baseFileName);
		% Display a message on the UI.
		txtInfo = sprintf('Please wait...\nSaving screenshot as\n%s', screenshotFileName);
		set(handles.txtInfo, 'String', txtInfo);
		% CALL export_fig, WHICH YOU MUST HAVE DOWNLOADED.
		export_fig(screenshotFileName);
		message = sprintf('Screenshot saved as:\n%s', screenshotFileName);
		set(handles.txtInfo, 'String', message);
		msgboxw(message);
	catch ME
		% Some error happened if you get here.
		strErrorMessage = sprintf('Error in function mnuToolsSaveScreenshot_Callback\n\nError message: %s', ME.message);
		WarnUser(strErrorMessage);
		WarnUser('Are you sure you downloaded export_fig, and it is on the search path?');
	end
	return; % from mnuToolsSaveScreenshot_Callback


%=============================================================================================
function mnuToolsMontage_Callback(hObject, eventdata, handles)
% hObject    handle to mnuToolsMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	try
		% Change mouse pointer (cursor) to an hourglass.  
		% QUIRK: use 'watch' and you'll actually get an hourglass not a watch.
		set(gcf,'Pointer','watch');
		% Get a list of all the filenames.
		ListOfImageNames = get(handles.lstImageList, 'string');
		% Get a list of what files they selected.
		selectedItems = get(handles.lstImageList, 'value');
		% If none are selected, use them all.
		numberOfSelectedImages = length(selectedItems);
		if numberOfSelectedImages <= 1
			numberOfSelectedImages = length(ListOfImageNames);
			selectedItems = 1 : numberOfSelectedImages;
		end
		caption = sprintf('Please wait...Constructing montage of %d images...', numberOfSelectedImages);
		title(caption, 'FontSize', 14);
		set(handles.txtInfo, 'string', caption);
		drawnow;	% Cursor won't change right away unless you do this.
		% Get a list of the selected files only.
		% Warning: This will not include folders so we will have to prepend the folder.
		ListOfImageNames = ListOfImageNames(selectedItems);
		for k = 1 : numberOfSelectedImages    % Loop though all selected indexes.
			% Get the filename for this selected index.
			baseImageFileName = cell2mat(ListOfImageNames(k));
			imageFullFileName = fullfile(handles.ImageFolder, baseImageFileName);
			ListOfImageNames{k} = imageFullFileName;
		end
		% Figure out how many rows and there should be.
		% There is twice as much space horizontally as vertically so solve the equation 2*rows^2 = numberOfImages.
		rows = ceil(sqrt(numberOfSelectedImages/2));
		columns = 2 * rows;
		axes(handles.axesImage);
		cla(handles.axesImage, 'reset');
		handleToImage = handles.axesImage;
		hMontage = montage(ListOfImageNames, 'size', [rows columns]);
		caption = sprintf('Displaying a montage of %d images.', numberOfSelectedImages);
		title(caption, 'FontSize', 20);
		set(handles.txtInfo, 'string', caption);
	catch ME
		errorMessage = sprintf('Error in function mnuToolsMontage_Callback.\nError Message:\n%s', ME.message);
		set(handles.txtInfo, 'string', errorMessage);
		LoadSplashImage(handles, handles.axesImage);
		WarnUser(errorMessage);
	end
	% Change mouse pointer (cursor) to an arrow.
	set(gcf,'Pointer','arrow');
	drawnow;	% Cursor won't change right away unless you do this.

	return; % from mnuToolsMontage_Callback


%=====================================================================
% Plots the histogram of grayImage in axes axesImage
% If grayImage is a double, it must be normalized between 0 and 1.
function [minGL maxGL ] = PlotImageHistogram(handles, imageArray)
	try
		numberOfDimensions = ndims(imageArray);
		if numberOfDimensions == 1 || numberOfDimensions == 2
			% Grayscale 2D or 1D image.
			PlotGrayscaleHistogram(handles, imageArray)
		elseif numberOfDimensions == 3
			% True color RGB image.
			PlotRGBHistograms(handles, imageArray);
		else
			warningMessage = sprintf('Histograms are only supported for grayscale (2D) or color (3D) images');
			WarnUser(warningMessage);
		end
	catch ME
		errorMessage = sprintf('Error in function PlotImageHistogram.\nError Message:\n%s', ME.message);
		WarnUser(errorMessage);
	end
	return; % PlotImageHistogram

%=====================================================================
% Plots the histogram of grayImage in axes axesImage
% If grayImage is a double, it must be normalized between 0 and 1.
function [minGL maxGL] = PlotGrayscaleHistogram(handles, grayImage)
	try
		% Plot the histogram in the histogram viewport.
		% Make the plot visible.
		SetImageVisibility(handles, handles.axesPlot, 1);
		axes(handles.axesPlot);  % makes existing axes handles.axesPlot the current axes.
		
		% Get the histogram
		[pixelCounts, grayLevels] = imhist(grayImage);
		
		% Plot it.
		bar(pixelCounts);
		title('Histogram of Gray Image', 'FontSize', 12);
		grid on;
		
		% Get the min and max GL for fun.
		minGL = min(grayImage(:));
		maxGL = max(grayImage(:));
		
		% Set up the x axis of the histogram to go from 0 to the max value allowed for this type of integer (uint8 or uint16).
		theClass = class(grayImage);
		% Only set xlim for integers.  For example the demo image blobs.png is logical not integer even though it's grayscale.
		if strfind(theClass, 'int')
			xlim([0 intmax(theClass)]);
		end
	catch ME
		errorMessage = sprintf('Error in function PlotGrayscaleHistogram.\nError Message:\n%s', ME.message);
		WarnUser(errorMessage);
	end
	return; % PlotGrayscaleHistogram

%=====================================================================
% Plots the histogram of imgColorImageArray in axes axesImage
% If imgArray is a double, it must be normalized between 0 and 1.
function [minGL maxGL gl1Percentile gl99Percentile] = PlotRGBHistograms(handles, imgColorImageArray)
	try
		% Get a histogram of the entire image.  But imhist only allows 2D images, not color ones.
		% First get individual channels from the original image.
		redBand = imgColorImageArray(:,:,1);
		greenBand = imgColorImageArray(:,:,2);
		blueBand = imgColorImageArray(:,:,3);

		% Use 256 bins.
		[redCounts, redGLs] = imhist(redBand, 256);    % make sure you label the axes after imhist because imhist will destroy them.
		[greenCounts, greenGLs] = imhist(greenBand, 256);    % make sure you label the axes after imhist because imhist will destroy them.
		[blueCounts, blueGLs] = imhist(blueBand, 256);    % make sure you label the axes after imhist because imhist will destroy them.

		% GLs goes from 0 (at element 1) to 255 (at element 256) but only some
		% these bins have data in them.  The upper ones may be 0.  Find the last
		% non-zero bin so we can plot just up to there to get better horizontal resolution.
		maxBinUsedR = find(redCounts, 1, 'last' );
		maxBinUsedG = find(greenCounts, 1, 'last' );
		maxBinUsedB = find(blueCounts, 1, 'last' );
		% If the entire image is zero, have the max bin be 0.
		if isempty(maxBinUsedR); maxBinUsedR = 1; end;
		if isempty(maxBinUsedG); maxBinUsedG = 1; end;
		if isempty(maxBinUsedB); maxBinUsedB = 1; end;
		% Take the largest one overall for plotting them all.
		maxBinUsed = max([maxBinUsedR maxBinUsedG maxBinUsedB]);

		% Get subportion of array that has non-zero data.
		redCounts = redCounts(1:maxBinUsed);
		greenCounts = greenCounts(1:maxBinUsed);
		blueCounts = blueCounts(1:maxBinUsed);
		GLs = redGLs(1:maxBinUsed);

		% Because of the mask, the first bin will have a ton of zeros in it and count(1) will be sky
		% high.  Zero out this bin so we aren't getting the histogram of the mask.
		redCounts(1) = 0;
		greenCounts(1) = 0;
		blueCounts(1) = 0;

		% Assign the max and min for the 3 color bands.
		minGL(1) = GLs(maxBinUsedR);
		maxGL(2) = GLs(maxBinUsedG);
		maxGL(3) = GLs(maxBinUsedB);

		% Calculate the 1% and 99% value of the CDF for the 3 color bands.
		gl1Percentile = ones(3, 1);	    % Preallocate one element for each color.
		gl99Percentile = ones(3, 1);		% Preallocate one element for each color.
		for color = 1:3
			switch color
				case 1
					counts = redCounts;
				case 2
					counts = greenCounts;
				case 3
					counts = blueCounts;
			end
			summed = sum(counts);
			cdf = 0;
			for bin = 1 : maxBinUsed
				cdf = cdf + counts(bin);
				if cdf < 0.01 * summed
					gl1Percentile(color) = GLs(bin);
				end
				if cdf > 0.99 * summed
					break;
				end
			end
			gl99Percentile(color) = GLs(bin);
		end

		% Plot the histogram in the histogram viewport.
		% Make the plot visible.
		SetImageVisibility(handles, handles.axesPlot, 1);
		axes(handles.axesPlot);  % makes existing axes handles.axesPlot the current axes.
		% Plot the histogram as a line curve.
		plot(GLs, blueCounts, 'b', 'LineWidth', 3);
		hold on;
		plot(GLs, greenCounts, 'g', 'LineWidth', 3);
		plot(GLs, redCounts, 'r', 'LineWidth', 3);
		grid on;
		title('Red, Green, and Blue Histograms');
		maxCountInHistogram = max([redCounts(:); greenCounts(:); blueCounts(:)]);
		set(handles.axesPlot,'YLim',[0 maxCountInHistogram]);
		
		% Plot the sum of all of them
% 		sumCounts = redCounts + greenCounts + blueCounts;
% 		plot(GLs, sumCounts, 'k', 'LineWidth', 1);  % Plot sum in black color.
% 		set(handles.axesPlot,'YLim',[0 max(sumCounts)]);
		
		set(handles.axesPlot,'XTick',      [0 20 40 60 80 100 120 140 160 180 200 220 240 255]);
		set(handles.axesPlot,'XTickLabel', {0 20 40 60 80 100 120 140 160 180 200 220 240 255});
		set(get(handles.axesPlot,'XLabel'),'string','Gray Level');
		ylabel('# of Pixels');
		xlim([0 255]);
		hold off;

		axes(handles.axesImage);	% Switch current figure back to image box.
	catch ME
		errorMessage = sprintf('Error in function PlotRGBHistograms.\nError Message:\n%s', ME.message);
		WarnUser(errorMessage);
	end
	return; % PlotRGBHistograms


%=============================================================================================
function mnuTools_Callback(hObject, eventdata, handles)
% hObject    handle to mnuTools (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%=============================================================================================
% Pops up a message box and waits for the user to click OK.
function msgboxw(in_strMessage)
    uiwait(msgbox(in_strMessage));
    return;

%==========================================================================================================================
% Warn user via the command window and a popup message.
function WarnUser(warningMessage)
	fprintf(1, '%s\n', warningMessage);
	uiwait(warndlg(warningMessage));
	return; % from WarnUser()


% --- Executes on button press in chkPlotHistograms.
function chkPlotHistograms_Callback(hObject, eventdata, handles)
% hObject    handle to chkPlotHistograms (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkPlotHistograms


% --- Executes during object creation, after setting all properties.
function txtFolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txtFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function grpRadButtonGroup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to grpRadButtonGroup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

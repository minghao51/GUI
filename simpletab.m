function tabbedGUI()
    %# create tabbed GUI
    hFig = figure('Menubar','none');
    s = warning('off', 'MATLAB:uitabgroup:OldVersion');
    hTabGroup = uitabgroup('Parent',hFig);
    warning(s);
    hTabs(1) = uitab('Parent',hTabGroup, 'Title','Data');
    hTabs(2) = uitab('Parent',hTabGroup, 'Title','Params');
    hTabs(3) = uitab('Parent',hTabGroup, 'Title','Plot');
    set(hTabGroup, 'SelectedTab',hTabs(1));

    %# populate tabs with UI components
    uicontrol(hTabs(1),'Style','pushbutton', 'String','Load data', ...
         'Callback',@loadButtonCallback);
%     uicontrol(hTabs(1),'Style','pushbutton', 'String','Save data', ...
%          'Callback',@loadButtonCallback1);
    uicontrol('Style','popupmenu', 'String','r|g|b', ...
        'Parent',hTabs(2), 'Callback',@popupCallback);
    hAx = axes('Parent',hTabs(3));
    hLine = plot(NaN, NaN, 'Parent',hAx, 'Color','r');

    %# button callback
    function loadButtonCallback1(src,evt)
        %# load data
        [fName,pName] = uigetfile('*.mat', 'Load data');
        if pName == 0, return; end
        data = load(fullfile(pName,fName), '-mat', 'X');

        %# plot
        set(hLine, 'XData',data.X(:,1), 'YData',data.X(:,2));

        %# swithc to plot tab
        set(hTabGroup, 'SelectedTab',hTabs(3));
        drawnow
    end

        
    %# button callback
    function loadButtonCallback(src,evt)
        %# load data
        [fName,pName] = uigetfile('*.mat', 'Load data');
        if pName == 0, return; end
        data = load(fullfile(pName,fName), '-mat', 'X');

        %# plot
        set(hLine, 'XData',data.X(:,1), 'YData',data.X(:,2));

        %# swithc to plot tab
        set(hTabGroup, 'SelectedTab',hTabs(3));
        drawnow
    end

    %# drop-down menu callback
    function popupCallback(src,evt)
        %# update plot color
        val = get(src,'Value');
        clr = {'r' 'g' 'b'};
        set(hLine, 'Color',clr{val})

        %# swithc to plot tab
        set(hTabGroup, 'SelectedTab',hTabs(3));
        drawnow
    end
end
% End initialization code - DO NOT EDIT



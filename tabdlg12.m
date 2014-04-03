tabStrings = {'Random', 'Sine Wave'};
[dialogFig, sheetPos, sheetPanels, buttonPanel] = tabdlg('create', tabStrings);

% put something on the sheets
a1 = axes('Parent',sheetPanels(1));
plot(rand(5),'Parent',a1);
ht = get(a1,'Title');
set(ht,'String','Random')

a2 = axes('Parent',sheetPanels(2));
t = 0:.01:2*pi;
plot(t, sin(t),'Parent',a2);
ht = get(a2,'Title');
set(ht,'String','Sine wave')

% put some buttons on the button panel
buttonStrings = {'OK','Apply','Cancel','sigh'};
buttonCallbacks ={'close(gcbf)','close(gcbf)','close(gcbf)','close(gcbf)'};
offsets = [5 5];
pos = get(0,'defaultUicontrolPosition');
numControls = length(buttonStrings);
containerPos = getpixelposition(buttonPanel);
leftOffset = containerPos(3)/2 - ...
    ((numControls-1) * offsets(1) + numControls *pos(3))/2;
for i = 1:numControls
    uicontrol(buttonPanel, ...
        'Style','pushbutton', ...
        'String', buttonStrings{i}, ...
        'Position', ...
        [offsets(1) * i + leftOffset + pos(3) * (i-1) ...
        offsets(2)/2 pos(3:4)], ...
        'Callback', buttonCallbacks{i});
end
set(dialogFig, 'Visible', 'on');
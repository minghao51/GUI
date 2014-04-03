% test 13
%testing maximun colleration of the object

[fName,pName] = uigetfile('*', 'Load data');
handles.pName = pName; % to pass this directory for other function
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
handles.dicomlist = dir(fullfile(pName, '*'));  %Generating a list of filename for reading in that directory, based on the 1st letter on the name
handles.dicomlist(~strncmp({handles.dicomlist.name}, fName(1), 1)) = []; % this yank out those files that isn't start with the same 1st letter as selected file
% handles.dicomlist.name = sort_nat({handles.dicomlist.name});    %Because the files have unreasonable names tha require special treatment
[handles.fname inx]= sort_nat({handles.dicomlist.name});
handles.dicomlist = handles.dicomlist(inx);


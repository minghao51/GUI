%Test case to get the universal loader working
[fName,pName] = uigetfile('*', 'Load data');
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));

% handles.dicomlist = dir(fullfile(pName, '   fprintf(A)  '  ));
dicomlist = dir(fullfile(pName, '*'));
% dicomlist = dicomlist(cellfun(@(N) ~ismember(N(end-4),'xy'), struct2cell(dicomlist)));
% initial
% start

dicomlist(~strncmp({dicomlist.name}, fName(1), 1)) = []
% 
% dicomlist1=dicomlist(~(strcmp('.',dicomlist.name)|strcmp('..',dicomlist.name)));
% 
% 
% folders = dir(pName);
% folders(~strncmp({folders.name}, fName(1), 1)) = []

% To remove '.' and  '..'
%folders(strncmp({folders.name}, '.', 1)) = []; % new, no exceptions  

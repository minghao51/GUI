%%Sorting

% list = dir(fullfile(cd, '*.mat'));



name = {dicomlist.name};
str  = sprintf('%s#', name{:});
num  = sscanf(str, '571_%d#');
[dummy, index] = sort(num);
name = name(index);

%%
file_date=[files.datenum]

%%

sort_nat({dicomlist.name})
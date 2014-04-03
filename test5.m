
%Test case to get the historgram normalisation, postponsed for now


[fName,pName] = uigetfile('*', 'Load data');
if pName == 0, return; end
%         dicomlist = dir(fullfile(pName,'Images','*.dcm'));
dicomlist = dir(fullfile(pName,'0*'));
dicominfo1 = dicominfo(fullfile(pName,dicomlist(1).name)) ;
for cnt = 1 : numel(dicomlist)
    %             data{cnt} = dicomread(fullfile(pName,'Images',dicomlist(cnt).name));
    data{cnt} = dicomread(fullfile(pName,dicomlist(cnt).name));
end



% 
% figure,imhist(data{1})
% 
% %% Normalize the Image:
% myImg= data{1};
% myRange = getrangefromclass(myImg);
% newMax = myRange(2)
% newMin = myRange(1)
% 
% myImgNorm = (myImg - min(myImg(:)))*(newMax - newMin)/(max(myImg(:)) - min(myImg(:))) + newMin;
% figure,imshow(myImgNorm)
% figure,imhist(myImgNorm)
% 

figure, imshow(data{1},[])
% t1 = 0;
% t2 = 300;
% t3= 1000;

data1{1} = otsu(data{1},3);

    % Bin those relevent pixel range into background
    range=(data{1} <= (t1 + t2)/2);
    data{1}(range)=0;
    % Bin tumour
    range=(data{1} > (t1 + t2)/2 & data{1} <= (t2 + t3)/2);
   data{1}(range)=1;
    % Bin tissue
    range=(data{1} > (t3 + t2)/2 );
    data{1}(range)=2;

    
figure,imshow(data{1},[])


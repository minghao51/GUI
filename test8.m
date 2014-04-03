BW1 = double(dataMap{1});
BW2=double(I1{1});
alpha = repmat(0.35 * BW1 ,[1 1 3]);
labels = double(label2rgb(bwlabel( BW1)));
im3 = repmat(BW2,[1 1 3]); %# Assuming image is grayscale
overlay = ( (1-alpha) .* im3 ) + ( alpha .* labels );
imshow(overlay , 'FaceAlpha', 0.3); %# Or imwrite, etc.
%  dataMap{1}

%%
imshow(I1{1});colormap(gray)
hold on
imshow(dataMap{1});colormap(hot)
set(dataMap{1},'AlphaData',0.5)
hold off

%%
%  imshow(oriI1{1}, 'InitialMag', 'fit')
imshow(oriI1{1},[])
 % Make a truecolor all-green image.
 green = cat(3, zeros(size(oriI1{1})), ones(size(oriI1{1})), zeros(size(oriI1{1})));
 hold on 
 h = imshow(green); 
 hold off
  % Use our influence map as the 
 % AlphaData for the solid green image.
 set(h, 'AlphaData', dataMap{1}*0.3)
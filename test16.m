%test 16
% http://stackoverflow.com/questions/7423596/over-segmentation-in-the-marker-controlled-watershed-in-matlabt

bw = im2bw(Iobrcbr, graythresh(Iobrcbr));
figure,imshow(bw,'InitialMagnification','fit')

imgDist=-bwdist(~bw,'cityblock');
figure,imshow(imgDist,[],'InitialMagnification','fit')

% imgDist=imimposemin(imgDist,fgm4);
% figure,imshow(imgDist,[],'InitialMagnification','fit')

imgDist(~bw)=-inf;    
figure,imshow(imgDist,[],'InitialMagnification','fit')
imgLabel=watershed(imgDist);    

figure,imshow(imgLabel==0,'InitialMagnification','fit')
function R=MaxCorrelation1(ImageIn, template);
% Attempt to template matching/max correlation with template on the matrix
% Require template.png in the corresponding path dir
% http://stackoverflow.com/questions/8286646/matlab-template-matching-using-vectorization
%% The size of the corr2 must be the same
%Record the size of ImageIn
[hI,wI] = size(ImageIn);
% 
% cd(path)
% Template = imread('template.png');
[hT,wT] = size(template);


%% Start searching around specific point
% % would have to define a point on the ImageIn to initiate searching anyhow,
% % as centroid is not determine yet
% figure, imshow(ImageIn,[]),title('Select initial searching point')
% [Tumour_x_initial,Tumour_y_initial,Tumour_vals_initial] = impixel;


%%
% searching through all possible points
h = hI-hT+1;
w = wI-wT+1;
R = zeros(h,w);
for i = 1:h % probably need a better variable or size as limit
    for k = 1:w
        R(i,j)=corr2(ImageIn(i:i+hT-1,j:j+wT-1),Template);
        %         %Exit loop for the pixels if R value is satisfying
        %         if R>0.8
        %             continue
        %         end
    end
    %     if R>0.8
    %         continue
    %     end
end


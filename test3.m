% test3

prompt = {'Enter image name:', 'Enter colormap name:'};
title = 'Image display - assignin example';
lines = 1;
def = {'my_image', 'hsv'};
answer = inputdlg(prompt, title, lines, def);
assignin('base', 'imfile', answer{1});
assignin('base', 'cmap', answer{2});
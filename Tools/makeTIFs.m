% Script for saving TIFs of images that are saved in Zoiray-style .mat
% files. Run this while in the directory of the .mat files.
clc
s = '^.*(pre|post).*\.mat$'; % anything followed by 'pre' followed by 'green' followed by '.mat', separated by anything
f = 'frame';
usrinput = inputdlg({'Please enter the pre-image file regex:', 'What''s the image variable called?'},'Image File Regex',1,{s, f});
expstr = usrinput{1};
imName = usrinput{2};

d = uigetdir(pwd,'Please select the containing folder');
fnames = regexpdir(d,expstr);

for i = 1:length(fnames)
    load(fnames{i});
    [pathstr, name, ext] = fileparts(fnames{i});
    frame = uint16(eval(imName));
    imwrite(frame, [pathstr filesep name '.tif'],'TIFF');
    progressbar(i/length(fnames));
end
progressbar(1);
disp('Images created.');
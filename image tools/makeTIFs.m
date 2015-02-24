% Script for saving TIFs of images that are saved in Zoiray-style .mat
% files. Run this while in the directory of the .mat files.
s = '^.*(pre|post|DataSet).*\.mat$'; % anything followed by 'pre' or 'post' followed by '.mat', separated by anything
f = 'data';
usrinput = inputdlg({'Please enter the image filename regex:', 'What''s the image variable called?'},'Image File Regex',1,{s, f});
expstr = usrinput{1};
imName = usrinput{2};

d = uigetdir(pwd,'Please select the containing folder');
fnames = regexpdir(d,expstr);

% capture1 = load(fnames{1});
for i = 1:length(fnames)
    load(fnames{i});
    [pathstr, name, ext] = fileparts(fnames{i});
    frame = eval(imName);
%     norm = frame./eval(['capture1.' imName]);
    frame = squeeze(frame(1,:,:));
    frame = uint8(imrescale(frame,0,max(frame(:)),2^8));
%     frame(frame == max(frame(:)))=1;
    imwrite(frame, [pathstr filesep name(1:end-6) '.tif'],'TIFF', 'WriteMode', 'append');
    progressbar(i/length(fnames));
end
progressbar(1);
disp('finished making TIFs.');
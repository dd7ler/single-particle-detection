% Main Driver for batch SIFT using image registration.
% 9/5/2013, Derin Sevenler

clc
clear
close all

% get the regular expression
s = '^.*pre.+\.mat$'; % anything followed by 'pre' followed by '.mat', separated by anything
usrinput = inputdlg({'Please enter the pre-image file regex:'},'Image File Regex',1,{s});
expstr = usrinput{1};
% Get the directory
d = uigetdir(pwd,'Please select the containing folder');
% Get the mirror
[mname, mdir]= uigetfile(pwd,'Please select the corresponding mirror file');
load([mdir filesep mname]);
mirror = frame;

% get the pre file list
flist = regexpdir(d,expstr);

% Parameters for alignment and detection
crop_r = 330;
im_thresh = 0.6;
camera_offset = 0;  % Dark noise from the camera 
hist_thresh= 1.5;   % Contrast attenuation
median_scale = 2000;
theta_range = (-6:.1:6) - 90;

th = hist_thresh*median_scale; % Threshold for contrast attenuation

tic
progressbar('Image Set','Image Alignment','Particle Detection');
for i = 1:length(flist)
    % load the images
    preDir = flist{i};
    postDir = strrep(preDir,'pre','post');
    load(preDir);
    preIm = frame;
    load(postDir);
    postIm = frame;
%     figure; imshow(preIm,[]);
%     figure; imshow(postIm,[]);
    % get the directory info, for the output and also the verification
    % images
    [prePath, ~, ~] = fileparts(preDir);
    [postPath, postName, ~] = fileparts(postDir);
    writename = [postPath filesep postName(5:end) ' results.xlsx'];

    % Normalize with the mirror, and rescale the images to the same range
    postIm = double(postIm)*median(mirror(:))./(double(mirror));
    preIm  = double(preIm)*median(mirror(:))./(double(mirror));
    
%     figure; imshow(preIm,[]);
%     figure; imshow(postIm,[]);

    % Threshold bright parts of the image
    preIm =  preIm/median(preIm(:))*median_scale;
    postIm = postIm/median(postIm(:))*median_scale;
    preIm(preIm>th) = th;
    postIm(postIm>th) = th;
%     figure; imshow(preIm,[]);
%     figure; imshow(postIm,[]);
    
    % Measure particle counts and contrast
    [matchedContrastPost, unmatchedContrastPost, preContrast, theta] = pcSIFT(preIm, postIm, im_thresh, crop_r,theta_range,postName(5:end),postPath);
    if isempty(matchedContrastPost)
        % write that this image failed.
        xlswrite(writename,{'The alignment failed for this image'});
        disp(['Alignment failed for spot: ' postName(5:end)]);
        
    else
        % Convert contrasts to actual contrast measurements
        matchedContrastPost = matchedContrastPost/median_scale;
        unmatchedContrastPost = unmatchedContrastPost/median_scale;
        preContrast = preContrast/median_scale;

         % write to xls sheet
        xlswrite(writename,{'Contrast', 'Counts', 'Contrast (matches)', 'Matches', 'Contrast (pre)', 'Counts (pre)'});
        xlswrite(writename, unmatchedContrastPost, ['A2:A' num2str(length(unmatchedContrastPost)+1)]);
        xlswrite(writename, length(unmatchedContrastPost), 'B2:B2');
        xlswrite(writename, matchedContrastPost, ['C2:C' num2str(length(matchedContrastPost)+1)]);
        xlswrite(writename, length(matchedContrastPost), 'D2:D2');
        xlswrite(writename, preContrast, ['E2:E' num2str(length(preContrast)+1)]);
        xlswrite(writename, length(preContrast), 'F2:F2');
    end
    
    progressbar(i/length(flist),0,0);
end
progressbar(1)
disp(['Complete! Batch processing took ' num2str(round(toc/60)) ' minutes at ' num2str(round(toc/length(flist))) ' seconds per image']);
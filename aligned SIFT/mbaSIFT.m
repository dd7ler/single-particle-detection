% 
% Automated Single Particle Detection with Image Registration
% Derin Sevenler
% Updated by author 9/27/2013 10:42:52 AM

clear; clc; close all;
% 1. Input: images and parameters
d = uigetdir(pwd,'Please select the data directory'); % Regexpdir is recursive, so it will find files in subdirectories.

postxpr = 'chip\d+_postDataSet\d+.mat';
prexpr = 'chip\d+_preDataSet\d+.mat';
usrinput = inputdlg({'Please enter the PRE file regex:','and POST file regex:'},'Regex',1,{prexpr,postxpr});
preFList = regexpdir(d, usrinput{1});
postFList = regexpdir(d, usrinput{2});

if length(preFList)~=length(postFList)
    err = MException('ResultChk:BadInput', ...
        'Different number of Pre and Post image files');
    throw(err);
end

[mname, mdir]= uigetfile(d,'Please select the corresponding mirror file');
mir = load([mdir filesep mname]);
mirror = mir.data_mir;

% Set crop, SIFT,  gaussian filter and particle sizing parameters
median_scale = 2000;
bright_thresh = 1.3*median_scale;


defaults = {'0','700','900','0.6','9','1.5','0.7','-5:.2:5', '0', '200','.0181','poly'};
usrinput = inputdlg({'Crop diameter (enter 0 for auto-scaled cropping)', 'Circle detection D_min', 'Circle detection D_max', ...
    'SIFT intensity threshold','Gaussian template size', 'Standard deviation', 'Threshold','Alignment angle range', ...
    'Size filter D_min, nm', 'Size filter D_max, nm', 'Area, micron^2', ...
    'Particle index material - Enter ''poly'' or ''gold'''}, 'Parameters',1, defaults);
crop_r = str2double(usrinput{1})/2;
r_min = str2double(usrinput{2})/2;
r_max = str2double(usrinput{3})/2;
im_thresh = str2double(usrinput{4});
TemplateSize = str2double(usrinput{5});
SD = str2double(usrinput{6});
gaussianTh = str2double(usrinput{7});
theta_range = str2num(usrinput{8});
minSize = str2num(usrinput{9});
maxSize = str2num(usrinput{10});
pixelAreaMicrons = str2double(usrinput{11});
pMaterial=usrinput{12};

% 2. Align the file lists using the timestamps and chip numbers
tokk = cell(size(preFList));
tokk(:) = {'tokens'};

chipNP = 'chip(\d*)'; % the chip name regular expression
ChipNamesPatt = cell(size(preFList));
ChipNamesPatt(:) = {chipNP};

preChipNames = cellfun(@regexpi,preFList,ChipNamesPatt,tokk);
preChipNames = [preChipNames{:}];
postChipNames = cellfun(@regexpi,postFList,ChipNamesPatt,tokk);
postChipNames = [postChipNames{:}];
if ~isempty(setdiff(unique(preChipNames), unique(postChipNames)))
    err = MException('ResultChk:BadInput', ...
        'Pre and post chip numbers don''t match.');
    throw(err);
end

tsPattern = 'DataSet(\d*).mat$'; % the timestamp regular expression
tsPatt = cell(size(preFList));
tsPatt(:) = {tsPattern};
preTS= cellfun(@regexpi,preFList,tsPatt,tokk);
preTS = [preTS{:}];
preTS = cellfun(@str2num, preTS);
postTS = cellfun(@regexpi,postFList,tsPatt,tokk);
postTS = [postTS{:}];
postTS = cellfun(@str2num, postTS);

% Build a list of matching pre and post images.
matchedSpotFList = cell(length(postFList), 2);
chips = unique(preChipNames);
sCounter = 1;
for i = 1:length(chips)
    % indicies of the spots from this chip
    preIdx = strfind(preChipNames, chips{i});
    preIdx = find(not(cellfun(@isempty, preIdx)));
    postIdx = strfind(postChipNames, chips{i});
    postIdx = find(not(cellfun(@isempty, postIdx)));
    % indicies of spots, sorted by timestamps
    [~,preSortedIdx] = sort(preTS(preIdx));
    [~,postSortedIdx] = sort(preTS(postIdx));

    matchedSpotFList(sCounter:sCounter+length(preIdx)-1,:) = {preFList{preIdx(preSortedIdx)}; postFList{postIdx(postSortedIdx)}}';
    sCounter = sCounter + length(preSortedIdx);
end
[pathstr,name,ext] = fileparts(d);
dateTag = datestr(now);
dateTag = strrep(dateTag,':','.');
writename = [name ' results ' dateTag '.mat'];
save
% 3. Perform aligned SIFT on the paired images

progressbar('Image Set','Image Alignment','Particle Detection');

verifImName = [name ' ' dateTag '.tif'];

tic
for i = 1:length(postFList)
    % load the images
    preIm = load(matchedSpotFList{i,1});
    preIm = preIm.data;
    postIm = load(matchedSpotFList{i,2});
    postIm = postIm.data;

    % Normalize with the mirror, and rescale the images to the same range
    postIm = double(postIm)*median(mirror(:))./(double(mirror));
    preIm  = double(preIm)*median(mirror(:))./(double(mirror));

    % Measure particle counts and contrast
    [preC, postC, matchI, thetaI, cropRI] = mpcSIFT(preIm, postIm, ...
        im_thresh, crop_r,theta_range, TemplateSize,SD,gaussianTh, verifImName,d, r_min, r_max, bright_thresh);

    expt.chipNumber
    expt.preTS{i}=
    expt.postTS{i}=
    expt.
    expt.preContrasts{i}= preC;
    expt.postContrasts{i}= postC;
    expt.matches{i}= matchI;
    expt.theta{i}= thetaI;
    expt.cropR(i)= cropRI;
    save(writename, '-struct', 'expt'); % Save every loop, so if it crashes you don't lose everything
    end
    
    progressbar(i/length(postFList),0,0);
end
progressbar(1)
disp(['Complete! Batch processing took ' num2str(round(toc/60)) ' minutes at ' num2str(round(toc/length(postFList))) ' seconds per image']);
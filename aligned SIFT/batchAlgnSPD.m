function expt = batchAlgnSPD(imDir, mirPath, prexpr, postxpr, varargin)
% Call this function to perform aligned SIFT on a batch of images that all have the same numbering convention. The images are sorted by timestamp or whatever number. Mir is the directory for the mirror file. You may use something along the lines of the following to get it

% Default inputs are in this order:
% imageVar = 'frame'
% chipVar = 'Chip\d*'
% tsPattern = 'Frame(\d*).mat$'
% cropR=0
% d_min=1000
% d_max=1800
% im_thresh=0.6
% TemplateSize=9
% SD=1.5
% gaussianTh=0.7
% theta_range=-5:0.2:5
% minSize=0
% maxSize=200
% pixelAreaMicrons=0.0181
% pMaterial='poly'

% default parameters, in case some of them are not entered
optargs = {'frame' 'Chip\d*' 'Frame(\d*).mat$' 0 700 900 0.6 9 1.5 0.7 -5:0.2:5 0 200 0.0181 'poly'};
optargs(1:length(varargin)) = varargin(:);
[imageVar, chipVar, tsPattern cropR, d_min, d_max, im_thresh, TemplateSize, SD, gaussianTh, theta_range, minSize, maxSize, pixelAreaMicrons, pMaterial] = optargs{:};

% hard-coded parameters
median_scale = 2000;
bright_thresh = 1.3*median_scale;

% Load image names
preFList = regexpdir(imDir, prexpr);
postFList = regexpdir(imDir, postxpr);
if isempty(preFList) || isempty(postFList)
    err = MException('ResultChk:BadInput', ...
        'No Pre or Post images found');
    throw(err);
elseif length(preFList)~=length(postFList)
    err = MException('ResultChk:BadInput', ...
        'Different number of Pre and Post image files');
    throw(err);
end

% Load mirror
mir = load(mirPath);
mirror = mir.frame;

% 2. Align the file lists using the timestamps and chip numbers
tokk = cell(size(preFList));
tokk(:) = {'tokens'};

ChipNamesPatt = cell(size(preFList));
ChipNamesPatt(:) = {chipVar};

[~,preFNames] = cellfun(@fileparts, preFList, 'Uniformoutput', 0);
[~,postFNames] = cellfun(@fileparts, postFList, 'Uniformoutput', 0);
preChipNames = cellfun(@regexpi,preFNames,ChipNamesPatt,tokk);
preChipNames = [preChipNames{:}]';
postChipNames = cellfun(@regexpi,postFNames,ChipNamesPatt,tokk);
postChipNames = [postChipNames{:}]';
if ~isempty(setdiff(unique(preChipNames), unique(postChipNames)))
    err = MException('ResultChk:BadInput', ...
        'Pre and post chip numbers don''t match.');
    throw(err);
end

tsPatt = cell(size(preFNames));
tsPatt(:) = {tsPattern};

preTS= cellfun(@regexpi,preFNames,tsPatt,tokk);
preTS = [preTS{:}];
postTS = cellfun(@regexpi,postFNames,tsPatt,tokk);
postTS = [postTS{:}];
expt.preTS = cellfun(@str2num, preTS);
expt.postTS = cellfun(@str2num, postTS);

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

[~,matchedNames] = cellfun(@fileparts, matchedSpotFList(:,1), 'Uniformoutput', 0);
chipNameColumn = cellfun(@regexpi, matchedNames, ChipNamesPatt,tokk);
chipNameColumn = [chipNameColumn{:}]';

spotNameColumn = cell(size(chipNameColumn));
for i = 1:length(chipNameColumn)
    t = cell(i,1);
    t(:) = chipNameColumn(i);
    temp = cellfun(@strcmp,chipNameColumn(1:i),t);
    spotNameColumn{i} = num2str(sum(temp));
end
expt.spotNumber = spotNameColumn;
expt.chipName = chipNameColumn;

[pathstr,name] = fileparts(imDir);
dateTag = datestr(now);
dateTag = strrep(dateTag,':','.');
writename = [name ' results ' dateTag '.mat'];

% 3. Perform aligned SIFT on the paired images
progressbar('Image Set','Image Alignment','Particle Detection');
verifImName = [name ' ' dateTag '.tif'];
tic
for i = 1:length(postFList)
    % load the images
    preIm = load(matchedSpotFList{i,1});
    preIm = eval(['preIm.' imageVar]);
    postIm = load(matchedSpotFList{i,2});
    postIm = eval(['postIm.' imageVar]);

    % Normalize with the mirror, and rescale the images to the same range
    postIm = double(postIm)*median(mirror(:))./(double(mirror));
    preIm  = double(preIm)*median(mirror(:))./(double(mirror));r

    % Measure particle counts and contrast
    [preC, postC, matchI, thetaI, cropRI] = mpcSIFT(preIm, postIm, ...
        im_thresh, cropR, theta_range, TemplateSize,SD,gaussianTh, verifImName,imDir, d_min/2, d_max/2, bright_thresh);

    expt.preContrasts{i}= preC;
    expt.postContrasts{i}= postC;
    expt.matches{i}= matchI;
    expt.theta{i}= thetaI;
    expt.cropR(i)= cropRI;
    save(writename, '-struct', 'expt'); % Save every loop, so if it crashes you don't lose everything
    
    progressbar(i/length(postFList),0,0);
end
progressbar(1)
disp(['Complete! Batch processing took ' num2str(round(toc/60)) ' minutes at ' num2str(round(toc/length(postFList))) ' seconds per image']);

end
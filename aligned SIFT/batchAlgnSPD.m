function exptResults = batchAlgnSPD(imDir, postxpr, prexpr, mir, varargin)
% Call this function to perform aligned SIFT on a batch of images that all have the same numbering convention. The images are sorted by timestamp or whatever number. Mir is the directory for the mirror file. You may use something along the lines of the following to get it

% [mname, mdir]= uigetfile(d,'Please select the corresponding mirror file');
% mir = load([mdir mname]);

% Default inputs are in this order:
% imageVar = 'frame'
% cropR=0
% r_min=700
% r_max=900
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
optargs = {'frame' 0 700 900 0.6 9 1.5 0.7 -5:0.2:5 0 200 0.0181 'poly'}
optargs{1:numvarargs} = varargin{:};


% Load image names
preFList = regexpdir(d, prexpr);
postFList = regexpdir(d, postxpr);

if isempty(preFList)
    err = MException('ResultChk:BadInput', ...
        'Different number of Pre and Post image files');
    throw(err);
elseif isempty(postFList)
    err = MException('ResultChk:BadInput', ...
        'Different number of Pre and Post image files');
    throw(err);
elseif length(preFList)~=length(postFList)
    err = MException('ResultChk:BadInput', ...
        'Different number of Pre and Post image files');
    throw(err);
end

% TODO: load mirror


% TODO: for loop:

% TODO: load pre and post image, normalize them with the mirror and by each other, and with respect to all the others 

% TODO: perform alignedSIFT. It makes all the required the verification images for alignment and detection

% Write the desired variables to the exptResults struct. 
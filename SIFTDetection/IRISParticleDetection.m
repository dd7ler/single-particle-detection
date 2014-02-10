function varargout = IRISParticleDetection(varargin)
% IRISPARTICLEDETECTION M-file for IRISParticleDetection.fig
%      IRISPARTICLEDETECTION, by itself, creates a new IRISPARTICLEDETECTION or raises the existing
%      singleton*.
%
%      H = IRISPARTICLEDETECTION returns the handle to a new IRISPARTICLEDETECTION or the handle to
%      the existing singleton*.
%
%      IRISPARTICLEDETECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IRISPARTICLEDETECTION.M with the given input arguments.
%
%      IRISPARTICLEDETECTION('Property','Value',...) creates a new IRISPARTICLEDETECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before IRISParticleDetection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to IRISParticleDetection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help IRISParticleDetection

% Last Modified by GUIDE v2.5 14-Aug-2012 16:15:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @IRISParticleDetection_OpeningFcn, ...
    'gui_OutputFcn',  @IRISParticleDetection_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before IRISParticleDetection is made visible.
function IRISParticleDetection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to IRISParticleDetection (see VARARGIN)

%Add vlfeat-0.9.14 and all subfolder to path | AR edit 7/11/2012
%addpath(genpath([pwd '\vlfeat-0.9.14']));

% Choose default command line output for IRISParticleDetection
handles.output = hObject;
handles.rect=[0 0 0 0];

%Set default values for intenisty and edge thresholds:
DefaultIntensityTh='';
handles.IntensityTh =num2str(DefaultIntensityTh);
set(handles.ETIntensityTh,'String',num2str(DefaultIntensityTh));
DefaultEdgeTh=2;
handles.EdgeTh = num2str(DefaultEdgeTh);
set(handles.ETEdgeTh,'String',num2str(DefaultEdgeTh));

%Set default view property:
%The default is the circle view:
set(handles.RBDebugView, 'Value', 0);
set(handles.RBPointView, 'Value', 0);
set(handles.RBCircleView, 'Value', 1);

%Compute Matching property:
set(handles.CBComputeMatching, 'Value', 1);
%Visualize Matchings property:
set(handles.PBVisualizeMatchings, 'Value', 0);

%Initialize AfterSpotImage and PreSpotImage:
handles.PreSpotImage=[];
handles.PreSpotImageDir=[];
handles.AfterSpotImage=[];
axis(handles.PreSpotAxes, 'off');
axis(handles.AfterSpotAxes, 'off');

%Histogram Axes
FunImage = imread('MatlabLogo.png');
axes(handles.HistogramAxes), imagesc(FunImage), axis image, axis off;

%Set default annuli values:
DefaultInnerRadius=9;
DefaultOuterRadius=12;
set(handles.ETInnerRadius,'String',num2str(DefaultInnerRadius));
set(handles.ETOuterRadius,'String',num2str(DefaultOuterRadius));

%Gaussian Filtering Threshold
DefaultGaussianTh=0.6;
set(handles.ETGaussianTh,'String',num2str(DefaultGaussianTh));

%Set default histogram drawing:
set(handles.RBHistSize, 'Value',1);

%Set image scale
handles.ImScale=4;

%Set bin number:
DefaultBinNumber=10;
set(handles.ETBinNumber,'String',num2str(DefaultBinNumber));

%Set Gaussian template matching defaults:
GaussianSD=1.5;
GaussianTemplateSize=9;
set(handles.ETSD,'String',num2str(GaussianSD));
set(handles.ETTemplateSize,'String',num2str(GaussianTemplateSize));
handles.GaussianFiltering=0;

%Histogram Size Filtering
%Sliders should be on after size distribution is evaluated.
set(handles.SRSmallOutlier,'Enable','off');
set(handles.SRLargeOutlier,'Enable','off');

%Histogram Mode Operation Flag:
handles.HistogramModeOperation = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes IRISParticleDetection wait for user response (see UIRESUME)
% uiwait(handles.IRISParticleDetection);


% --- Outputs from this function are returned to the command line.
function varargout = IRISParticleDetection_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function [curve_g, curve_r, diameter_interpolated]=ShowContrastCurve(handles)

green = handles.data(:,1);
red = handles.data(:,2);
dstep = 0.1;
diameter = handles.data(:,3)*2;
diameter_interpolated = handles.data(1,3)*2-10:dstep:120;
%diameter_interpolated = handles.data(1,3)*2-10:dstep:handles.data(end,3)*2;
ppg = interp1(diameter,green,'cubic','pp');
% ppg = csape(diameter,green);
curve_g = ppval(ppg,diameter_interpolated);
% ppr = csape(diameter,red);
ppg = interp1(diameter,red,'cubic','pp');
curve_r = ppval(ppg,diameter_interpolated);
axes(handles.HistogramAxes);
plot(diameter_interpolated,curve_g,'g','LineWidth',2);
hold on
plot(diameter_interpolated,curve_r,'r', 'LineWidth',2),
xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 10);
ylabel('Contrast','FontName','Arial', 'FontSize', 10), title('Contrast vs Diameter','FontName','Arial', 'FontSize', 10),
set(gca,'FontName','Arial','FontSize',10);


% --- Executes on button press in PBLoadPreSpotImage.
function PBLoadPreSpotImage_Callback(hObject, eventdata, handles)
% hObject    handle to PBLoadPreSpotImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[SPDData]=CropChipImage(handles.rect); 
handles.PreSpotImageDir=SPDData.ImageDir;
handles.rect=SPDData.rect;
handles.PreSpotImageRect = handles.rect;
axes(handles.PreSpotAxes);
handles.PreSpotImage=SPDData.croppedimage;

TempMedian=median(handles.PreSpotImage(:));
TempStd=std(handles.PreSpotImage(:));
handles.PreSpotImageClim=[TempMedian-2*TempStd,TempMedian+2*TempStd];

set(hObject, 'Visible', 'Off');
set(handles.CBPreSpotImage, 'Visible', 'Off');
UpdateImageAxes(hObject, handles)
guidata(hObject, handles);


% --- Executes on key press with focus on PBLoadPreSpotImage and none of its controls.
function PBLoadPreSpotImage_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to PBLoadPreSpotImage (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PBLoadAfterSpotImage.
function PBLoadAfterSpotImage_Callback(hObject, eventdata, handles)
% hObject    handle to PBLoadAfterSpotImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.PreSpotImageDir)
    [SPDData]=CropChipImage(handles.rect);
else
    [SPDData]=CropChipImage(handles.rect,handles.PreSpotImageDir);
end

handles.rect=SPDData.rect;
handles.AfterSpotImageRect = handles.rect;

handles.PreSpotImageDir=[];
axes(handles.AfterSpotAxes);
handles.AfterSpotImage=SPDData.croppedimage;

TempMedian=median(handles.AfterSpotImage(:));
TempStd=std(handles.AfterSpotImage(:));
handles.AfterSpotImageClim=[TempMedian-2*TempStd,TempMedian+2*TempStd];

set(hObject, 'Visible', 'Off');
UpdateImageAxes(hObject, handles)
guidata(hObject, handles);


function ETIntensityTh_Callback(hObject, eventdata, handles)
% hObject    handle to ETIntensityTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETIntensityTh as text
%        str2double(get(hObject,'String')) returns contents of ETIntensityTh as a double
handles.IntensityTh=(get(hObject,'String'));
guidata(hObject, handles);
% --- Executes during object creation, after setting all properties.
function ETIntensityTh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETIntensityTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ETEdgeTh_Callback(hObject, eventdata, handles)
% hObject    handle to ETEdgeTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETEdgeTh as text
%        str2double(get(hObject,'String')) returns contents of ETEdgeTh as a double
handles.EdgeTh= (get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ETEdgeTh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETEdgeTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CBPreSpotImage.
function CBPreSpotImage_Callback(hObject, eventdata, handles)
% hObject    handle to CBPreSpotImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CBPreSpotImage

if get(hObject,'Value')==1
    %change the color of the background:
    set(hObject,'BackgroundColor','default');
    set(handles.PBLoadPreSpotImage,'Visible','Off');
    set(handles.CBComputeMatching, 'Value', 0);
    set(handles.CBComputeMatching, 'Enable', 'off');
    set(handles.PBVisualizeMatchings, 'Enable','off');
    set(handles.PBSaveBackgroundData, 'Enable','off');
    handles.PreSpotImage=[];
else
    set(hObject,'BackgroundColor','white');
    set(handles.PBLoadPreSpotImage,'Visible','On');
    set(handles.CBComputeMatching, 'Enable', 'on');
    set(handles.CBComputeMatching, 'Value', 1);
    set(handles.PBVisualizeMatchings, 'Enable','on');
    set(handles.PBSaveBackgroundData, 'Enable','on');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PreSpotAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PreSpotAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate PreSpotAxes


% --- Executes on button press in PBRunDetection.
function PBRunDetection_Callback(hObject, eventdata, handles)
% hObject    handle to PBRunDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.IntensityTh) && isempty(handles.EdgeTh)
    msgbox('Please enter intensity and edge thresholds !');
    return;
elseif isempty(handles.EdgeTh)
    msgbox('Please enter an edge threshold !');
    return;
elseif isempty(handles.IntensityTh)
    msgbox('Please enter an intensity threshold !');
    return;
end

IntensityTh=str2num(handles.IntensityTh);
EdgeTh=str2num(handles.EdgeTh);
MatchFlag= get(handles.CBComputeMatching, 'Value');

if isempty(handles.PreSpotImage)
    %Pre-spotting image is not available.
    set(handles.PBShowAnomalyMap, 'Enable','on');
    set(handles.PBAnomalyFiltering, 'Enable','on');
    MatchFlag=0;

    %handles=NormalizeImages(handles);
    [handles.KPDataAfterSpot]= SIFTDetection(handles.AfterSpotImage, IntensityTh, EdgeTh, MatchFlag, handles.ImScale);
    handles.KPDataAfterSpot.Peaks=handles.AfterSpotImage(sub2ind(size(handles.AfterSpotImage), round(handles.KPDataAfterSpot.VKPs(2,:).'), round(handles.KPDataAfterSpot.VKPs(1,:).')));
    
else
    
    %handles=NormalizeImages(handles);
    handles.KPDataPreSpot =  SIFTDetection(handles.PreSpotImage, IntensityTh, EdgeTh, MatchFlag, handles.ImScale);
    handles.KPDataAfterSpot = SIFTDetection(handles.AfterSpotImage, IntensityTh, EdgeTh, MatchFlag, handles.ImScale);

    if MatchFlag==1
        %Compute the matching between descriptors:
        [Matches, Scores]=vl_ubcmatch(handles.KPDataPreSpot.Feats,handles.KPDataAfterSpot.Feats);
        %Since there might be multiple copies of a keypoint at different
        %orientations , there might be multiple matchings between two
        %keypoints and extra matchings have to be eliminated:
        [handles.VisualMatches] = ComputeVisualMatches(Matches, handles.KPDataPreSpot.KPs, handles.KPDataAfterSpot.KPs);
        
        %The features we use do not incorporate any spatial information
        %about keypoints. In our set up, we assume that if there is a
        %translation or rotation, these are global, i.e. same for all the
        %image.
        
        %REMARK:
        %If the number of matches is small, we cannot fit
        %an affine model between the background and the spotted image. In
        %such cases, RANSAC should not be called.
        
        handles.RANSACFlag=0;
        if size(handles.VisualMatches,2) > 7
            handles.RANSACFlag=1;
            [F, inliers,handles.RANSACFlag] = ransacfitfundmatrix7(handles.KPDataPreSpot.KPs(1:2,handles.VisualMatches(1,:)),handles.KPDataAfterSpot.KPs(1:2,handles.VisualMatches(2,:)), 0.001);
            if handles.RANSACFlag==0
                set(handles.PBShowAnomalyMap, 'Enable','on');
                set(handles.PBShowChipImage,'Enable','on');
                set(handles.PBAnomalyFiltering, 'Enable','on');
                handles.VisualMatches=FilterMatches(handles.VisualMatches,handles.KPDataPreSpot.KPs,handles.KPDataAfterSpot.KPs);
            else
                handles.VisualMatches=handles.VisualMatches(:,inliers);
            end
            
        elseif  size(handles.VisualMatches,2) > 0
            set(handles.PBShowAnomalyMap, 'Enable','on');
            set(handles.PBShowChipImage,'Enable','on');
            set(handles.PBAnomalyFiltering, 'Enable','on');
            handles.VisualMatches=FilterMatches(handles.VisualMatches,handles.KPDataPreSpot.KPs,handles.KPDataAfterSpot.KPs);
        end
        %After the matchings are found, they need to be eliminated from the
        %chips:
        [handles.KPDataPreSpot.VKPs, handles.KPDataAfterSpot.VKPs]= ComputeRemainingParticles(hObject, handles);
        
    end
    handles.KPDataPreSpot.Peaks=handles.PreSpotImage(sub2ind(size(handles.PreSpotImage), round(handles.KPDataPreSpot.VKPs(2,:).'), round(handles.KPDataPreSpot.VKPs(1,:).')));
    handles.KPDataAfterSpot.Peaks=handles.AfterSpotImage(sub2ind(size(handles.AfterSpotImage), round(handles.KPDataAfterSpot.VKPs(2,:).'), round(handles.KPDataAfterSpot.VKPs(1,:).')));
end
PublishResults(hObject,handles);
UpdateImageAxes(hObject, handles);
guidata(hObject, handles);


function handles =NormalizeImages(handles)

if ~isempty(handles.PreSpotImage)
    
    MinIms=min([min(handles.PreSpotImage(:)), min(handles.AfterSpotImage(:))]);
    handles.NormalizedPreSpotImage=handles.PreSpotImage-MinIms;
    handles.NormalizedAfterSpotImage=handles.AfterSpotImage-MinIms;
    
    MaxIms=max([max(handles.NormalizedPreSpotImage(:)), max(handles.NormalizedAfterSpotImage(:))]);
    
    handles.NormalizedPreSpotImage=255*handles.NormalizedPreSpotImage./MaxIms;
    handles.NormalizedAfterSpotImage=255*handles.NormalizedAfterSpotImage./MaxIms;

else
    
    handles.NormalizedAfterSpotImage=handles.AfterSpotImage-min(handles.AfterSpotImage(:));
    handles.NormalizedAfterSpotImage=255*handles.NormalizedAfterSpotImage/max(handles.NormalizedAfterSpotImage(:));
    
end


function UpdateImageAxes(hObject, handles)

if ~isempty(handles.PreSpotImage)
    cla(handles.PreSpotAxes);
    axes(handles.PreSpotAxes), imagesc(handles.PreSpotImage,handles.PreSpotImageClim), axis image, colormap gray, hold on;
    if isfield(handles,'KPDataPreSpot')
        %PreSpot keypoints are available
        if get(handles.RBCircleView, 'Value')==1
            for circleindex=1:size(handles.KPDataPreSpot.VKPs,2)
                circle([handles.KPDataPreSpot.VKPs(1,circleindex),handles.KPDataPreSpot.VKPs(2,circleindex)], 6, 100, '-g');
            end
        elseif get(handles.RBPointView, 'Value')==1
            plot(handles.KPDataPreSpot.VKPs(1,:),handles.KPDataPreSpot.VKPs(2,:), '.g');
        elseif get(handles.RBDebugView, 'Value')==1
            VKPsPreSpotHandle=vl_plotframe(handles.KPDataPreSpot.VKPs);
        end
        hold off;
    else
        hold off;
    end
end

if ~isempty(handles.AfterSpotImage)
    cla(handles.AfterSpotAxes);
    axes(handles.AfterSpotAxes), imagesc(handles.AfterSpotImage,handles.AfterSpotImageClim), axis image, colormap gray, hold on;
    if isfield(handles,'KPDataAfterSpot')
        %AfterSpot keypoints are available
        if get(handles.RBCircleView, 'Value')==1
            for circleindex=1:size(handles.KPDataAfterSpot.VKPs,2)
                circle([handles.KPDataAfterSpot.VKPs(1,circleindex),handles.KPDataAfterSpot.VKPs(2,circleindex)], 6, 100, '-g');
            end
        elseif get(handles.RBPointView, 'Value')==1
            plot(handles.KPDataAfterSpot.VKPs(1,:),handles.KPDataAfterSpot.VKPs(2,:), '.g');
        elseif get(handles.RBDebugView, 'Value')==1
            VKPsPreSpotHandle=vl_plotframe(handles.KPDataAfterSpot.VKPs);
        end
        hold off;
    else
        hold off;
    end
end
guidata(hObject, handles);


function H=circle(center,radius,NOP,style)
%---------------------------------------------------------------------------------------------
% H=CIRCLE(CENTER,RADIUS,NOP,STYLE)
% This routine draws a circle with center defined as
% a vector CENTER, radius as a scaler RADIS. NOP is
% the number of points on the circle. As to STYLE,
% use it the same way as you use the rountine PLOT.
% Since the handle of the object is returned, you
% use routine SET to get the best result.
%
%   Usage Examples,
%
%   circle([1,3],3,1000,':');
%   circle([2,4],2,1000,'--');
%
%   Zhenhai Wang <zhenhai@ieee.org>
%   Version 1.00
%   December, 2002
%---------------------------------------------------------------------------------------------

if (nargin <3),
    error('Please see help for INPUT DATA.');
elseif (nargin==3)
    style='b-';
end;
THETA=linspace(0,2*pi,NOP);
RHO=ones(1,NOP)*radius;
[X,Y] = pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);
H=plot(X,Y,style);

function UpdateStats(Data, hObject, handles)
MeanData = mean(Data);
SDData = std(Data);
set(handles.ETStatMean,'String', num2str(MeanData));
set(handles.ETStatSD,'String', num2str(SDData));
set(handles.ETTotal, 'String', num2str(length(Data)));

guidata(hObject, handles);

function PublishResults(hObject, handles)

if isempty(handles.PreSpotImage)
    ReportText1=sprintf('%s\n','Background image is not available.');
    ReportText2=sprintf('%s\n',['Number of particles detected in the spotted image = ', num2str(size(handles.KPDataAfterSpot.VKPs,2)),'.']);
    ReportText=[ReportText1, ReportText2];
    set(handles.ETDetectionSummary, 'String', '');
    set(handles.ETDetectionSummary, 'String', ReportText);
    
else
    ReportText1 = sprintf('%s\n',['Number of particles detected in the background image = ', num2str(size(handles.KPDataPreSpot.VKPs,2)),'.']);
    ReportText2 = sprintf('%s\n',['Number of particles detected in the spotted image = ', num2str(size(handles.KPDataAfterSpot.VKPs,2)),'.']);
    
    if handles.RANSACFlag==1
        ReportText3= sprintf('%s\n','RANSAC was used to fit an affine model.');
        ReportText4= sprintf('%s\n', ['Number of matched particles between backgorund and the spotted image = ', num2str(size( handles.VisualMatches,2)), '.']);
    else
        ReportText3= sprintf('%s\n','Translation estimation is used.');
        ReportText4= sprintf('%s\n', ['Number of matched particles between backgorund and the spotted image = ', num2str(size(handles.VisualMatches,2)), '.']);
    end
    ReportText=[ReportText1, ReportText2, ReportText3, ReportText4 ];
    set(handles.ETDetectionSummary, 'String', '');
    set(handles.ETDetectionSummary, 'String', ReportText);
end



guidata(hObject, handles);

% --- Executes on button press in RBDebugView.
function RBDebugView_Callback(hObject, eventdata, handles)
% hObject    handle to RBDebugView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RBDebugView

% if get(handles.RBDebugView, 'Value')==1
%     set(handles.RBPointView, 'Value', 0);
%     if isfield(handles, 'KPDataPreSpot')
%         cla(handles.PreSpotAxes);
%         axes(handles.PreSpotAxes), hold on, imagesc(handles.PreSpotImage), axis image, colormap gray;
%         VKPsPreSpotHandle=vl_plotframe(handles.KPDataPreSpot.VKPs);
%         hold off;
%
%         cla(handles.AfterSpotAxes);
%         axes(handles.AfterSpotAxes), hold on, imagesc(handles.AfterSpotImage), axis image, colormap gray;
%         VKPsAfterSpotHandle=vl_plotframe(handles.KPDataAfterSpot.VKPs);
%         hold off;
%
%     elseif isfield(handles, 'KPDataAfterSpot')
%         cla(handles.AfterSpotAxes);
%         axes(handles.AfterSpotAxes), hold on, imagesc(handles.AfterSpotImage), axis image, colormap gray;
%         VKPsAfterSpotHandle=vl_plotframe(handles.KPDataAfterSpot.VKPs);
%         hold off;
%     end
% end
%
UpdateImageAxes(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in RBPointView.
function RBPointView_Callback(hObject, eventdata, handles)
% hObject    handle to RBPointView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RBPointView
% if get(handles.RBPointView, 'Value')==1
%     set(handles.RBDebugView, 'Value', 0);
%     if isfield(handles, 'KPDataPreSpot')
%         cla(handles.PreSpotAxes);
%         axes(handles.PreSpotAxes), hold on, imagesc(handles.PreSpotImage), axis image, colormap gray;
%         plot(handles.KPDataPreSpot.VKPs(1,:),handles.KPDataPreSpot.VKPs(2,:), '.g');
%         hold off;
%
%         cla(handles.AfterSpotAxes);
%         axes(handles.AfterSpotAxes), hold on, imagesc(handles.AfterSpotImage), axis image, colormap gray;
%         plot(handles.KPDataAfterSpot.VKPs(1,:), handles.KPDataAfterSpot.VKPs(2,:), '.g');
%         hold off;
%
%     elseif isfield(handles, 'KPDataAfterSpot')
%         cla(handles.AfterSpotAxes);
%
%         axes(handles.AfterSpotAxes), hold on, imagesc(handles.AfterSpotImage), axis image, colormap gray;
%         plot(handles.KPDataAfterSpot.VKPs(1,:), handles.KPDataAfterSpot.VKPs(2,:), '.g');
%         hold off;
%
%     end
%
% end
UpdateImageAxes(hObject, handles)
guidata(hObject, handles);


% --- Executes on button press in CBComputeMatching.
function CBComputeMatching_Callback(hObject, eventdata, handles)
% hObject    handle to CBComputeMatching (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CBComputeMatching
if get(hObject,'Value')==1
    set(handles.PBVisualizeMatchings, 'Enable','on');
else
    set(handles.PBVisualizeMatchings, 'Enable','off');
    
end
guidata(hObject, handles);


% --- Executes on button press in PBVisualizeMatchings.
function PBVisualizeMatchings_Callback(hObject, eventdata, handles)
% hObject    handle to PBVisualizeMatchings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ImScale=handles.ImScale;
if isfield(handles,'VisualMatches')
    WhiteSpace=15;
    ChipsAppended=AppendIms(handles.PreSpotImage,handles.AfterSpotImage, WhiteSpace);
    figure, imagesc(ChipsAppended),axis image, colormap gray;
    hold on
    X1= handles.KPDataPreSpot.KPs(1,handles.VisualMatches(1,:))/ImScale;
    X2= handles.KPDataAfterSpot.KPs(1,handles.VisualMatches(2,:))/ImScale + size(handles.PreSpotImage,2)+WhiteSpace;
    Y1 =handles.KPDataPreSpot.KPs(2,handles.VisualMatches(1,:))/ImScale;
    Y2= handles.KPDataAfterSpot.KPs(2,handles.VisualMatches(2,:))/ImScale;
    line([X1; X2], [Y1; Y2], 'Color', 'c');
    plot(X1, Y1,'g.', X2, Y2, 'g.');
    hold off;
end
guidata(hObject, handles);


function [VKPsPre VKPsAfter]= ComputeRemainingParticles(hObject, handles)

MatchedIndicesAfterSpot=[];
MatchedIndicesPreSpot=[];

for index=1:size(handles.VisualMatches,2)
    
    TempIndexPre=handles.VisualMatches(1,index);
    TempCoordPre=handles.KPDataPreSpot.KPs(1:2,TempIndexPre);
    ZeroIndicesPre= find(sum(abs(handles.KPDataPreSpot.KPs(1:2,:)-repmat(TempCoordPre,1,size(handles.KPDataPreSpot.KPs,2))))==0);
    MatchedIndicesPreSpot=[MatchedIndicesPreSpot; ZeroIndicesPre.'];
    
    
    TempIndexAfter=handles.VisualMatches(2,index);
    TempCoordAfter=handles.KPDataAfterSpot.KPs(1:2,TempIndexAfter);
    ZeroIndicesAfter= find(sum(abs(handles.KPDataAfterSpot.KPs(1:2,:)-repmat(TempCoordAfter,1,size(handles.KPDataAfterSpot.KPs,2))))==0);
    MatchedIndicesAfterSpot=[MatchedIndicesAfterSpot; ZeroIndicesAfter.'];
end

AuxKPsPre=handles.KPDataPreSpot.KPs;
AuxKPsPre(:,MatchedIndicesPreSpot)=[];
VKPsPre= ComputeVisualKeyPoints(AuxKPsPre, handles.ImScale, size(handles.PreSpotImage));


AuxKPsAfter=handles.KPDataAfterSpot.KPs;
AuxKPsAfter(:,MatchedIndicesAfterSpot)=[];
VKPsAfter= ComputeVisualKeyPoints(AuxKPsAfter, handles.ImScale, size(handles.AfterSpotImage));


function OuterMedian=MedianOuterAnnuli(handles, InputIm, LocationVec)
%function find_imedian find the median of background the bead in the
%intensity image

xi=round(LocationVec(1));
yi=round(LocationVec(2));

radius1 = str2double(get(handles.ETInnerRadius,'String'));
radius2 = str2double(get(handles.ETOuterRadius,'String'));
median_array=[];
i_=0;
for i1=-radius2:radius2;
    if yi+i1<1
        continue
    elseif yi+i1> size(InputIm,1)
        continue
    else
        for i2=-radius2:radius2
            if xi+i2<1
                continue
            elseif xi+i2>size(InputIm,2)
                continue
            else
                r_temp=i1^2+i2^2;
                if r_temp<radius2^2 && r_temp>radius1^2
                    i_=i_+1;
                    median_array(i_)=InputIm(yi+i1,xi+i2);
                end
            end
        end
    end
end
OuterMedian = median(median_array);


function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETInnerRadius_Callback(hObject, eventdata, handles)
% hObject    handle to ETInnerRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETInnerRadius as text
%        str2double(get(hObject,'String')) returns contents of ETInnerRadius as a double


% --- Executes during object creation, after setting all properties.
function ETInnerRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETInnerRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETOuterRadius_Callback(hObject, eventdata, handles)
% hObject    handle to ETOuterRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETOuterRadius as text
%        str2double(get(hObject,'String')) returns contents of ETOuterRadius as a double


% --- Executes during object creation, after setting all properties.
function ETOuterRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETOuterRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PBComputeHistogram.
function PBComputeHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to PBComputeHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if isfield(handles,'HistogramData')
    if strcmp(handles.HistogramMode, 'Contrasts')
        warndlg('Contrast data cannot be filtered!','Warning!','modal');
        return;
    elseif strcmp(handles.HistogramMode, 'Size')
         set(handles.SRSmallOutlier, 'Value', str2double(get(handles.ETSmallOutlier, 'String')));
         set(handles.SRLargeOutlier, 'Value', str2double(get(handles.ETLargeOutlier, 'String')));
         HistogramFiltering(hObject,handles);
    else
        return;
    end
else
    
    if get(handles.RBHistPreSpot, 'Value')==0 && get(handles.RBHistAfterSpot, 'Value')==0
        errordlg('Please select an image to analyze !','Missing Input!','modal');
        return;
    end
    
    if get(handles.RBHistAfterSpot, 'Value')==1
        if ~isfield(handles,'KPDataAfterSpot')
            msgbox('Particle data do not exist !');
            return;
        else
            handles.KPDataAfterSpot.Contrasts = ComputeContrast(handles, handles.AfterSpotImage, handles.KPDataAfterSpot.Peaks, handles.KPDataAfterSpot.VKPs(1:2,:));
        end
        
        if get(handles.RBHistSize,'Value')==1
            
            if get(handles.RBGold,'Value')==0 && get(handles.RBPoly100,'Value')==0 && get(handles.RBPoly90,'Value')==0
                msgbox('Please select a particle type !');
                return;
            elseif get(handles.RBGold,'Value')==1
                %Load the gold contrast curves:
                load GoldContrastCurves.mat;
                handles.data = data;
                clear data;
                [handles.CurveGreen, handles.CurveRed, handles.Diameters]= ShowContrastCurve(handles);
                
            elseif get(handles.RBPoly100,'Value')==1
                %Load the polystyrene contrast curves:
                load Poly100ContrastCurves.mat;
                handles.data = data;
                clear data;
                [handles.CurveGreen, handles.CurveRed, handles.Diameters]= ShowContrastCurve(handles);
                
            elseif get(handles.RBPoly90,'Value')==1
                %Load the polystyrene contrast curves:
                load Poly90ContrastCurves.mat;
                handles.data = data;
                clear data;
                [handles.CurveGreen, handles.CurveRed, handles.Diameters]= ShowContrastCurve(handles);
            end
            
            %Plot the size histogram:
            if get(handles.CBCurveRed, 'Value')==0 && get(handles.CBCurveGreen, 'Value')==0
                msgbox('Please select a light color !');
                return;
            elseif get(handles.CBCurveRed, 'Value')==1
                %Red light is used:
                CurveData=handles.CurveRed;
            elseif get(handles.CBCurveGreen, 'Value')==1
                %Green light is used:
                CurveData=handles.CurveGreen;
            end
            %To plot the size histogram, we should first find the closest size
            %match from the light curve:
            
            [Dummy,DiameterIndices] = min(abs(repmat(CurveData(:),1,length(handles.KPDataAfterSpot.Contrasts))-repmat(handles.KPDataAfterSpot.Contrasts(:).',length(CurveData),1)));
            handles.KPDataAfterSpot.Diameters = handles.Diameters(DiameterIndices);
            
            if ~isempty(get(handles.ETSmallOutlier, 'String')) &&  ~isempty(get(handles.ETLargeOutlier, 'String'))
                %The values in ETSmallOutlier and ETLargeOutlier might be
                %updated manually, so the slider values must be updated because
                %the HistogramFiltering function uses the slider values to
                %filter the histogram.
                set(handles.SRSmallOutlier, 'Value', str2double(get(handles.ETSmallOutlier, 'String')));
                set(handles.SRLargeOutlier, 'Value', str2double(get(handles.ETLargeOutlier, 'String')));
                
                [handles.KPDataAfterSpot.Diameters,  handles.KPDataAfterSpot.Contrasts ]= HistogramFiltering(hObject,handles);
            else
                cla(handles.HistogramAxes);
                axes(handles.HistogramAxes);
                hist( handles.KPDataAfterSpot.Diameters, str2double(get(handles.ETBinNumber, 'String'))), xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 9);
                ylabel('Frequency','FontName', 'Arial', 'FontSize', 9),
                title('Size Histogram','FontName', 'Arial', 'FontSize', 9);
                h = findobj(gca,'Type','patch');
                set(h,'FaceColor','r','EdgeColor','w');
                
                set(handles.SRSmallOutlier,'Enable','on');
                set(handles.SRSmallOutlier, 'Min', min(handles.KPDataAfterSpot.Diameters), 'Max',max(handles.KPDataAfterSpot.Diameters),'Value',min(handles.KPDataAfterSpot.Diameters), 'SliderStep',[0.01 0.05]);
                
                set(handles.SRLargeOutlier,'Enable','on');
                set(handles.SRLargeOutlier, 'Min', min(handles.KPDataAfterSpot.Diameters), 'Max',max(handles.KPDataAfterSpot.Diameters), 'Value',max(handles.KPDataAfterSpot.Diameters),'SliderStep',[0.01 0.05]);
                
                set(handles.ETSmallOutlier,'String', num2str(min(handles.KPDataAfterSpot.Diameters)));
                set(handles.ETLargeOutlier,'String', num2str(max(handles.KPDataAfterSpot.Diameters)));
            end
            UpdateStats(handles.KPDataAfterSpot.Diameters ,hObject, handles);
            
            %Plot the constrast histogram:
        elseif get(handles.RBHistContrast,'Value')==1
            %Check if remaining peaks contrast data is available:
            cla(handles.HistogramAxes);
            axes(handles.HistogramAxes);
            hist(handles.KPDataAfterSpot.Contrasts,str2double(get(handles.ETBinNumber, 'String'))), xlabel('Contrast Value','FontName', 'Arial', 'FontSize', 9);
            ylabel('Frequency','FontName', 'Arial', 'FontSize', 9),
            title('Contrast Histogram','FontName', 'Arial', 'FontSize', 9);
            h = findobj(gca,'Type','patch');
            set(h,'FaceColor','r','EdgeColor','w');
            
            set(handles.SRSmallOutlier,'Enable','off');
            set(handles.SRLargeOutlier,'Enable','off');
            UpdateStats(handles.KPDataAfterSpot.Contrasts, hObject, handles);
        end
        
    elseif get(handles.RBHistPreSpot, 'Value')==1
        if ~isfield(handles,'KPDataPreSpot')
            msgbox('Background data do not exist !');
            return;
        else
            handles.KPDataPreSpot.Contrasts = ComputeContrast(handles, handles.PreSpotImage, handles.KPDataPreSpot.Peaks, handles.KPDataPreSpot.VKPs(1:2,:));
        end
        
        if get(handles.RBHistSize,'Value')==1
            
            if get(handles.RBGold,'Value')==0 && get(handles.RBPoly100,'Value')==0
                msgbox('Please select a particle type !');
                return;
            elseif get(handles.RBGold,'Value')==1
                %Load the gold contrast curves:
                load GoldContrastCurves.mat;
                handles.data = data;
                clear data;
                [handles.CurveGreen, handles.CurveRed, handles.Diameters]= ShowContrastCurve(handles);
                
            elseif get(handles.RBPoly100,'Value')==1
                %Load the polystyrene contrast curves:
                load Poly100ContrastCurves.mat;
                handles.data = data;
                clear data;
                [handles.CurveGreen, handles.CurveRed, handles.Diameters]= ShowContrastCurve(handles);
            end
            
            %Plot the size histogram:
            if get(handles.CBCurveRed, 'Value')==0 && get(handles.CBCurveGreen, 'Value')==0
                msgbox('Please select a light color !');
                return;
            elseif get(handles.CBCurveRed, 'Value')==1
                %Red light is used:
                CurveData=handles.CurveRed;
            elseif get(handles.CBCurveGreen, 'Value')==1
                %Green light is used:
                CurveData=handles.CurveGreen;
            end
            %To plot the size histogram, we should first find the closest size
            %match from the light curve:
            
            [Dummy,DiameterIndices]=min(abs(repmat(CurveData(:),1,length(handles.KPDataPreSpot.Contrasts))-repmat(handles.KPDataPreSpot.Contrasts(:).',length(CurveData),1)));
            handles.KPDataPreSpot.Diameters =handles.Diameters(DiameterIndices);
            
            if ~isempty(get(handles.ETSmallOutlier, 'String')) &&  ~isempty(get(handles.ETLargeOutlier, 'String'))
                %The values in ETSmallOutlier and ETLargeOutlier might be
                %updated manually, so the slider values must be updated because
                %the HistogramFiltering function uses the slider values to
                %filter the histogram.
                set(handles.SRSmallOutlier, 'Value', str2double(get(handles.ETSmallOutlier, 'String')));
                set(handles.SRLargeOutlier, 'Value', str2double(get(handles.ETLargeOutlier, 'String')));
                
                [handles.KPDataPreSpot.Diameters,  handles.KPDataPreSpot.Contrasts ]= HistogramFiltering(hObject,handles);
                
            else
                cla(handles.HistogramAxes);
                axes(handles.HistogramAxes);
                hist( handles.KPDataPreSpot.Diameters,str2double(get(handles.ETBinNumber, 'String'))), xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 9);
                ylabel('Frequency','FontName', 'Arial', 'FontSize', 9),
                title('Size Histogram','FontName', 'Arial', 'FontSize', 9);
                h = findobj(gca,'Type','patch');
                set(h,'FaceColor','r','EdgeColor','w');
                
                set(handles.SRSmallOutlier,'Enable','on');
                set(handles.SRSmallOutlier, 'Min', min(handles.KPDataPreSpot.Diameters), 'Max',max(handles.KPDataPreSpot.Diameters),'Value',min(handles.KPDataPreSpot.Diameters), 'SliderStep',[0.01 0.05]);
                
                set(handles.SRLargeOutlier,'Enable','on');
                set(handles.SRLargeOutlier, 'Min', min(handles.KPDataPreSpot.Diameters), 'Max',max(handles.KPDataPreSpot.Diameters), 'Value',max(handles.KPDataPreSpot.Diameters),'SliderStep',[0.01 0.05]);
                
                set(handles.ETSmallOutlier,'String', num2str(min(handles.KPDataPreSpot.Diameters)));
                set(handles.ETLargeOutlier,'String', num2str(max(handles.KPDataPreSpot.Diameters)));
            end
            UpdateStats(handles.KPDataPreSpot.Diameters, hObject, handles);
            %Plot the constrast histogram:
        elseif get(handles.RBHistContrast,'Value')==1
            cla(handles.HistogramAxes);
            axes(handles.HistogramAxes);
            hist(handles.KPDataPreSpot.Contrasts, str2double(get(handles.ETBinNumber, 'String'))), xlabel('Contrast Value','FontName', 'Arial', 'FontSize', 9);
            ylabel('Frequency','FontName', 'Arial', 'FontSize', 9),
            title('Contrast Histogram','FontName', 'Arial', 'FontSize', 9);
            h = findobj(gca,'Type','patch');
            set(h,'FaceColor','r','EdgeColor','w');
            
            set(handles.SRSmallOutlier,'Enable','off');
            set(handles.SRLargeOutlier,'Enable','off');
            UpdateStats(handles.KPDataPreSpot.Contrasts, hObject, handles);
        end
    end
end

guidata(hObject, handles);

function ParticleContrasts= ComputeContrast(handles, InputIm, PeakValues, PeakLocations)

MedianValues=zeros(size(PeakValues));
for peakindex=1:length(PeakValues)
    LocationVec=PeakLocations(:,peakindex);
    MedianValues(peakindex)=MedianOuterAnnuli(handles, InputIm, LocationVec);
end

ParticleContrasts = PeakValues./MedianValues;


% --- Executes on button press in PBSaveParticleData.
function PBSaveParticleData_Callback(hObject, eventdata, handles)
% hObject    handle to PBSaveParticleData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'KPDataAfterSpot')   
    if ~isfield(handles.KPDataAfterSpot, 'Contrasts')
        errordlg('No contrast data generated yet!','Save file error!','modal');
        return;
    else
        ParticleData.Contrasts = handles.KPDataAfterSpot.Contrasts(:);
    end
    if ~isfield(handles.KPDataAfterSpot, 'Diameters')
        errordlg('No sizing result generated yet!','Save file error!','modal');
        return;
    else
        ParticleData.Size = handles.KPDataAfterSpot.Diameters(:);
    end  
else
    errordlg('Particle data does not exist!','Save file error!','modal');
    return;
end

if handles.HistogramModeOperation == 0
    DetectionParamaters.IntensityTh = handles.IntensityTh;
    DetectionParamaters.EdgeTh = handles.EdgeTh;
    DetectionParamaters.Rect = handles.AfterSpotImageRect;
    
    if handles.GaussianFiltering == 1
        DetectionParamaters.GaussianSize = str2double(get(handles.ETTemplateSize, 'String'));
        DetectionParamaters.GaussianSD = str2double(get(handles.ETSD, 'String'));
        DetectionParamaters.GaussianTh = str2double(get(handles.ETGaussianTh, 'String'));
    end
end

[filename,pathname] = uiputfile('*.mat','Save Particle Data');
if isequal(filename,0) || isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
end
ParticleData.Software = 'v1';
save(fpath,'ParticleData', 'DetectionParamaters');

guidata(hObject, handles);

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in CBCurveRed.
function CBCurveRed_Callback(hObject, eventdata, handles)
% hObject    handle to CBCurveRed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject, 'Value')==1
    set(handles.CBCurveGreen,'Value',0);
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of CBCurveRed


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in CBCurveGreen.
function CBCurveGreen_Callback(hObject, eventdata, handles)
% hObject    handle to CBCurveGreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of CBCurveGreen
if get(hObject, 'Value')==1
    set(handles.CBCurveRed,'Value',0);
end
guidata(hObject, handles);

% --- Executes when IRISParticleDetection is resized.
function IRISParticleDetection_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to IRISParticleDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in RBHistSize.
function RBHistSize_Callback(hObject, eventdata, handles)
% hObject    handle to RBHistSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RBHistSize


% --- Executes on button press in RBHistContrast.
function RBHistContrast_Callback(hObject, eventdata, handles)
% hObject    handle to RBHistContrast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RBHistContrast


% --- Executes on button press in PBSaveHistogram.
function PBSaveHistogram_Callback(hObject, eventdata, handles)
% hObject    handle to PBSaveHistogram (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile('*.fig','Save as');
if isequal(filename,0) || isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname, filename);
end

% axes(handles.ROI)
% saveas(gca,fpath)
fig = figure('visible','on');
% colormap gray
newax = copyobj(handles.HistogramAxes, fig);
set(newax, 'units', 'normalized', 'position', [0.13 0.11 0.775 0.815]);
set(fig,'Name','Saved Image')
set(fig,'NumberTitle','off')

hgsave(fig,fpath)
close(fig) % clean up by closing it
guidata(hObject, handles);



function ETDetectionSummary_Callback(hObject, eventdata, handles)
% hObject    handle to ETDetectionSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETDetectionSummary as text
%        str2double(get(hObject,'String')) returns contents of ETDetectionSummary as a double


% --- Executes during object creation, after setting all properties.
function ETDetectionSummary_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETDetectionSummary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PBShowAnomalyMap.
function PBShowAnomalyMap_Callback(hObject, eventdata, handles)
% hObject    handle to PBShowAnomalyMap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.CBPreSpotImage,'Value')==1
    if ~isempty(handles.AfterSpotImage)
        handles.AfterAnomalyMap=GetAnomalyMap(handles.AfterSpotImage);
        cla(handles.AfterSpotAxes);
        axes(handles.AfterSpotAxes),  imagesc(handles.AfterAnomalyMap), colormap gray, axis image;
    else
        return;
    end
else
    if ~isempty(handles.AfterSpotImage)
        handles.AfterAnomalyMap=GetAnomalyMap(handles.AfterSpotImage);
        cla(handles.AfterSpotAxes);
        axes(handles.AfterSpotAxes),  imagesc(handles.AfterAnomalyMap), colormap gray, axis image;
    end
    
    if ~isempty(handles.PreSpotImage)
        handles.PreAnomalyMap=GetAnomalyMap(handles.PreSpotImage);
        cla(handles.PreSpotAxes);
        axes(handles.PreSpotAxes),  imagesc(handles.PreAnomalyMap), colormap gray, axis image;
    end
end
guidata(hObject, handles);



% --- Executes on button press in PBAnomalyFiltering.
function PBAnomalyFiltering_Callback(hObject, eventdata, handles)
% hObject    handle to PBAnomalyFiltering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.PreSpotImage)
    if ~isempty(handles.AfterSpotImage)
        if isfield(handles, 'KPDataAfterSpot')==1
            handles.AfterAnomalyMap=GetAnomalyMap(handles.AfterSpotImage);
            
            [AnY, AnX] =find(handles.AfterAnomalyMap==1);
            LinearAnIndices= sub2ind(size(handles.AfterSpotImage),AnY, AnX);
            
            LinearKeyLocs= sub2ind(size(handles.AfterSpotImage), round(handles.KPDataAfterSpot.VKPs(2,:)'),round(handles.KPDataAfterSpot.VKPs(1,:)'));
            InAnomaly=repmat(LinearAnIndices(:)',length(LinearKeyLocs),1)-repmat(LinearKeyLocs(:),1,length(LinearAnIndices));
            [InAnomaly,dummy]=find(InAnomaly==0);
            handles.KPDataAfterSpot.VKPs(:,InAnomaly)=[];
            handles.KPDataAfterSpot.Peaks(InAnomaly)=[];
            UpdateImageAxes(hObject, handles);
        else
            errordlg('Particle data does not exist !','Missing Data', 'modal');
            return;
        end
    else
        errordlg('Particle data does not exist !','Missing Data', 'modal');
        return;
    end
    PublishResults(hObject, handles);
else
    if isfield(handles, 'KPDataPreSpot') && isfield(handles, 'KPDataAfterSpot')
        handles.PreAnomalyMap=GetAnomalyMap(handles.PreSpotImage);
        [AnY, AnX] =find(handles.PreAnomalyMap==1);
        LinearAnIndices= sub2ind(size(handles.PreSpotImage),AnY, AnX);
        LinearKeyLocs= sub2ind(size(handles.PreSpotImage), round(handles.KPDataPreSpot.VKPs(2,:)'),round(handles.KPDataPreSpot.VKPs(1,:)'));
        InAnomaly=repmat(LinearAnIndices(:)',length(LinearKeyLocs),1)-repmat(LinearKeyLocs(:),1,length(LinearAnIndices));
        [InAnomaly,dummy]=find(InAnomaly==0);
        handles.KPDataPreSpot.VKPs(:,InAnomaly)=[];
        handles.KPDataPreSpot.Peaks(InAnomaly)=[];
        
        handles.AfterAnomalyMap=GetAnomalyMap(handles.AfterSpotImage);
        
        [AnY, AnX] =find(handles.AfterAnomalyMap==1);
        LinearAnIndices= sub2ind(size(handles.AfterSpotImage),AnY, AnX);
        
        LinearKeyLocs= sub2ind(size(handles.AfterSpotImage), round(handles.KPDataAfterSpot.VKPs(2,:)'),round(handles.KPDataAfterSpot.VKPs(1,:)'));
        InAnomaly=repmat(LinearAnIndices(:)',length(LinearKeyLocs),1)-repmat(LinearKeyLocs(:),1,length(LinearAnIndices));
        [InAnomaly,dummy]=find(InAnomaly==0);
        handles.KPDataAfterSpot.VKPs(:,InAnomaly)=[];
        handles.KPDataAfterSpot.Peaks(InAnomaly)=[];
        UpdateImageAxes(hObject, handles);
        PublishResults(hObject, handles);
    else
        errordlg('Particle data does not exist !','Missing Data', 'modal');
        return;
    end
end


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function uipanel12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when selected object is changed in uipanel12.
function uipanel12_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel12
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in PBShowChipImage.
function PBShowChipImage_Callback(hObject, eventdata, handles)
% hObject    handle to PBShowChipImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if get(handles.CBPreSpotImage,'Value')==1
%     if ~isempty(handles.AfterSpotImage)
%         if isfield(handles,'KPDataAfterSpot')
%             cla(handles.AfterSpotAxes);
%             axes(handles.AfterSpotAxes),imagesc(handles.AfterSpotImage), axis image, colormap gray, hold on;
%             if get(handles.RBDebugView,'Value')==1
%                 VKPsAfterSpotHandle=vl_plotframe(handles.KPDataAfterSpot.VKPs);
%             else
%                 plot(handles.KPDataAfterSpot.VKPs(1,:),handles.KPDataAfterSpot.VKPs(2,:), '.g');
%             end
%         else
%             cla(handles.AfterSpotAxes);
%             axes(handles.AfterSpotAxes),imagesc(handles.AfterSpotImage), axis image, colormap gray;
%         end
%     else
%         return;
%     end
% else
%     if ~isempty(handles.PreSpotImage)
%         if isfield(handles,'KPDataPreSpot')
%             cla(handles.PreSpotAxes);
%             axes(handles.PreSpotAxes),imagesc(handles.PreSpotImage), axis image, colormap gray, hold on;
%             if get(handles.RBDebugView,'Value')==1
%                 VKPsPreSpotHandle=vl_plotframe(handles.KPDataPreSpot.VKPs);
%             else
%                 plot(handles.KPDataPreSpot.VKPs(1,:),handles.KPDataPreSpot.VKPs(2,:), '.g');
%             end
%         else
%             cla(handles.PreSpotAxes);
%             axes(handles.PreSpotAxes),imagesc(handles.PreSpotImage), axis image, colormap gray;
%         end
%     end
%
%     if ~isempty(handles.AfterSpotImage)
%         if isfield(handles,'KPDataAfterSpot')
%             cla(handles.AfterSpotAxes);
%             axes(handles.AfterSpotAxes),imagesc(handles.AfterSpotImage), axis image, colormap gray, hold on;
%             if get(handles.RBDebugView,'Value')==1
%                 VKPsAfterSpotHandle=vl_plotframe(handles.KPDataAfterSpot.VKPs);
%             else
%                 plot(handles.KPDataAfterSpot.VKPs(1,:),handles.KPDataAfterSpot.VKPs(2,:), '.g');
%             end
%         else
%             cla(handles.AfterSpotAxes);
%             axes(handles.AfterSpotAxes),imagesc(handles.AfterSpotImage), axis image, colormap gray;
%         end
%     end
%
% end
UpdateImageAxes(hObject, handles);
guidata(hObject, handles);


% --- Executes on button press in PBSaveBackgroundData.
function PBSaveBackgroundData_Callback(hObject, eventdata, handles)
% hObject    handle to PBSaveBackgroundData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles, 'KPDataPreSpot')
    
    if ~isfield(handles.KPDataPreSpot, 'Contrasts')
        errordlg('Histogram is not computed!','Save file error!','modal');
        return;
    else
        BackgroundData.Contrasts = handles.KPDataPreSpot.Contrasts(:);
    end
    if ~isfield(handles.KPDataPreSpot, 'Diameters')
        errordlg('No sizing result generated yet!','Save file error!','modal');
        return;
    else
        BackgroundData.Size = handles.KPDataPreSpot.Diameters(:);
    end
else
    errordlg('Background data does not exist!','Save file error!','modal');
    return;
end

if handles.HistogramModeOperation == 0
    DetectionParamaters.IntensityTh = handles.IntensityTh;
    DetectionParamaters.EdgeTh = handles.EdgeTh;
    DetectionParamaters.Rect = handles.PreSpotImageRect;
    
    if handles.GaussianFiltering == 1
        DetectionParamaters.GaussianSize = str2double(get(handles.ETTemplateSize, 'String'));
        DetectionParamaters.GaussianSD = str2double(get(handles.ETSD, 'String'));
        DetectionParamaters.GaussianTh = str2double(get(handles.ETGaussianTh, 'String'));
    end
end

[filename,pathname] = uiputfile('*.mat','Save Background Data');
if isequal(filename,0) || isequal(pathname,0)
    return;
else
    fpath=fullfile(pathname,filename);
end
BackgroundData.Software = 'v1';
save(fpath,'BackgroundData', 'DetectionParamaters');


guidata(hObject, handles);


% --- Executes on button press in PBVisualizeMatchings.
function pushbutton17_Callback(hObject, eventdata, handles)
% hObject    handle to PBVisualizeMatchings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ETTemplateSize_Callback(hObject, eventdata, handles)
% hObject    handle to ETTemplateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETTemplateSize as text
%        str2double(get(hObject,'String')) returns contents of ETTemplateSize as a double


% --- Executes during object creation, after setting all properties.
function ETTemplateSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETTemplateSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETSD_Callback(hObject, eventdata, handles)
% hObject    handle to ETSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETSD as text
%        str2double(get(hObject,'String')) returns contents of ETSD as a double


% --- Executes during object creation, after setting all properties.
function ETSD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PBGaussianFiltering.
function PBGaussianFiltering_Callback(hObject, eventdata, handles)
% hObject    handle to PBGaussianFiltering (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles, 'KPDataPreSpot') && ~isfield(handles, 'KPDataAfterSpot')
    errordlg('Particle data does not exist !', 'Missing Data', 'modal');
    return;
end

handles.GaussianFiltering=1;
TemplateSize =str2double(get(handles.ETTemplateSize, 'String'));
SD=str2double(get(handles.ETSD, 'String'));
GaussianTh=str2double(get(handles.ETGaussianTh, 'String'));
if isfield(handles, 'KPDataPreSpot')
    
    [GaussianCorrCoefsPreSpot]=GaussianTemplateMatch(handles.PreSpotImage, handles.KPDataPreSpot.VKPs, TemplateSize, SD);
    SimilartoGaussianPre=GaussianCorrCoefsPreSpot > GaussianTh;
    handles.KPDataPreSpot.VKPs= handles.KPDataPreSpot.VKPs(:,SimilartoGaussianPre);
    handles.KPDataPreSpot.Peaks=handles.PreSpotImage(sub2ind(size(handles.PreSpotImage), round(handles.KPDataPreSpot.VKPs(2,:).'), round(handles.KPDataPreSpot.VKPs(1,:).')));
    
    [GaussianCorrCoefsAfterSpot]=GaussianTemplateMatch(handles.AfterSpotImage, handles.KPDataAfterSpot.VKPs, TemplateSize, SD);
    SimilartoGaussianAfter=GaussianCorrCoefsAfterSpot > GaussianTh;
    handles.KPDataAfterSpot.VKPs= handles.KPDataAfterSpot.VKPs(:,SimilartoGaussianAfter);
    handles.KPDataAfterSpot.Peaks=handles.AfterSpotImage(sub2ind(size(handles.AfterSpotImage), round(handles.KPDataAfterSpot.VKPs(2,:).'), round(handles.KPDataAfterSpot.VKPs(1,:).')));
else
    [GaussianCorrCoefsAfterSpot]=GaussianTemplateMatch(handles.AfterSpotImage, handles.KPDataAfterSpot.VKPs, TemplateSize, SD);
    SimilartoGaussianAfter=GaussianCorrCoefsAfterSpot > GaussianTh;
    handles.KPDataAfterSpot.VKPs= handles.KPDataAfterSpot.VKPs(:,SimilartoGaussianAfter);
    handles.KPDataAfterSpot.Peaks=handles.AfterSpotImage(sub2ind(size(handles.AfterSpotImage), round(handles.KPDataAfterSpot.VKPs(2,:).'), round(handles.KPDataAfterSpot.VKPs(1,:).')));
    
end

PublishResults(hObject, handles);
UpdateImageAxes(hObject, handles);

guidata(hObject, handles);

% --- Executes on button press in RBCircleView.
function RBCircleView_Callback(hObject, eventdata, handles)
% hObject    handle to RBCircleView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of RBCircleView



function ETGaussianTh_Callback(hObject, eventdata, handles)
% hObject    handle to ETGaussianTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETGaussianTh as text
%        str2double(get(hObject,'String')) returns contents of ETGaussianTh as a double


% --- Executes during object creation, after setting all properties.
function ETGaussianTh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETGaussianTh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function PBLoadPreSpotImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBLoadPreSpotImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function SRSmallOutlier_Callback(hObject, eventdata, handles)
% hObject    handle to SRSmallOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.ETSmallOutlier,'String',num2str(get(hObject,'Value')));

if get(hObject,'Value') > get(handles.SRLargeOutlier,'Value')
    warndlg('Upper value should be larger than lower value!','!! Warning !!','modal');
    return
end

if isfield(handles, 'HistogramModeData')
    
    HistogramFiltering(hObject,handles);
    UpdateStats(handles.HistorgamModeData, hObject, handles);
else
    
    if get(handles.RBHistPreSpot, 'Value')==1
        [handles.KPDataPreSpot.Diameters,  handles.KPDataPreSpot.Contrasts ]= HistogramFiltering(hObject,handles);
        UpdateStats(handles.KPDataPreSpot.Diameters, hObject, handles);
    elseif get(handles.RBHistAfterSpot, 'Value')==1
        [handles.KPDataAfterSpot.Diameters,  handles.KPDataAfterSpot.Contrasts ]= HistogramFiltering(hObject,handles);
        UpdateStats(handles.KPDataAfterSpot.Diameters, hObject, handles);
    end
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SRSmallOutlier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SRSmallOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SRLargeOutlier_Callback(hObject, eventdata, handles)
% hObject    handle to SRLargeOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

set(handles.ETLargeOutlier,'String',num2str(get(hObject,'Value')));

if get(hObject,'Value') < get(handles.SRSmallOutlier,'Value')
    warndlg('Upper value should be larger than lower value!','!! Warning !!','modal')
    return
end

if isfield(handles, 'HistogramModeData')
    
    HistogramFiltering(hObject,handles);
    UpdateStats(handles.HistorgamModeData, hObject, handles);
else
    
    if get(handles.RBHistPreSpot, 'Value')==1
        [handles.KPDataPreSpot.Diameters,  handles.KPDataPreSpot.Contrasts ]= HistogramFiltering(hObject,handles);
        UpdateStats(handles.KPDataPreSpot.Diameters, hObject, handles);
    elseif get(handles.RBHistAfterSpot, 'Value')==1
        [handles.KPDataAfterSpot.Diameters,  handles.KPDataAfterSpot.Contrasts ]= HistogramFiltering(hObject,handles);
        UpdateStats(handles.KPDataAfterSpot.Diameters, hObject, handles);
    end
end

guidata(hObject, handles);

function [Diameters, Contrasts] = HistogramFiltering(hObject,handles)

SmallTh=get(handles.SRSmallOutlier, 'Value');
LargeTh=get(handles.SRLargeOutlier, 'Value');

if isfield(handles, 'HistogramData')
    Diameters = handles.HistogramData.Size;
    
    [ParticlesLargeEnough]=(Diameters >= SmallTh);
    [ParticlesSmallEnough]=(Diameters <= LargeTh);
    
    ParticlesFiltered= ParticlesLargeEnough & ParticlesSmallEnough;
    
    Diameters = handles.HistogramData.Size(ParticlesFiltered(:));
    Contrasts = handles.HistogramData.Contrasts(ParticlesFiltered(:));
    
    cla(handles.HistogramAxes);
    axes(handles.HistogramAxes);
    hist(Diameters, str2double(get(handles.ETBinNumber,'String'))), xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 10);
    ylabel('Frequency','FontName', 'Arial', 'FontSize', 10),
    title('Size Histogram','FontName', 'Arial', 'FontSize', 10);
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w');

else
    
    if get(handles.RBHistAfterSpot,'Value') == 1
        Diameters = handles.KPDataAfterSpot.Diameters;
        
        [ParticlesLargeEnough]=(Diameters >= SmallTh);
        [ParticlesSmallEnough]=(Diameters <= LargeTh);
        
        ParticlesFiltered= ParticlesLargeEnough & ParticlesSmallEnough;
        
        Diameters = handles.KPDataAfterSpot.Diameters(ParticlesFiltered(:));
        Contrasts = handles.KPDataAfterSpot.Contrasts(ParticlesFiltered(:));
        
        cla(handles.HistogramAxes);
        axes(handles.HistogramAxes);
        hist(Diameters, str2double(get(handles.ETBinNumber,'String'))), xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 10);
        ylabel('Frequency','FontName', 'Arial', 'FontSize', 10),
        title('Size Histogram','FontName', 'Arial', 'FontSize', 10);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','w');
        
    elseif get(handles.RBHistPreSpot,'Value') == 1
        Diameters = handles.KPDataPreSpot.Diameters;
        [ParticlesLargeEnough]=(Diameters >= SmallTh);
        [ParticlesSmallEnough]=(Diameters <= LargeTh);
        
        ParticlesFiltered= ParticlesLargeEnough & ParticlesSmallEnough;
        
        Diameters = handles.KPDataPreSpot.Diameters(ParticlesFiltered(:));
        Contrasts = handles.KPDataPreSpot.Contrasts(ParticlesFiltered(:));
        
        cla(handles.HistogramAxes);
        axes(handles.HistogramAxes);
        hist(Diameters), xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 10);
        ylabel('Frequency','FontName', 'Arial', 'FontSize', 10),
        title('Size Histogram','FontName', 'Arial', 'FontSize', 10);
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor','r','EdgeColor','w');
        
    end
end


guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SRLargeOutlier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SRLargeOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function ETLargeOutlier_Callback(hObject, eventdata, handles)
% hObject    handle to ETLargeOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETLargeOutlier as text
%        str2double(get(hObject,'String')) returns contents of ETLargeOutlier as a double


% --- Executes during object creation, after setting all properties.
function ETLargeOutlier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETLargeOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETSmallOutlier_Callback(hObject, eventdata, handles)
% hObject    handle to ETSmallOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETSmallOutlier as text
%        str2double(get(hObject,'String')) returns contents of ETSmallOutlier as a double


% --- Executes during object creation, after setting all properties.
function ETSmallOutlier_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETSmallOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over SRLargeOutlier.
function SRLargeOutlier_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to SRLargeOutlier (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton22.
function pushbutton22_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ETBinNumber_Callback(hObject, eventdata, handles)
% hObject    handle to ETBinNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETBinNumber as text
%        str2double(get(hObject,'String')) returns contents of ETBinNumber as a double


% --- Executes during object creation, after setting all properties.
function ETBinNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETBinNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PBReset.
function PBReset_Callback(hObject, eventdata, handles)
% hObject    handle to PBReset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close all;
IRISParticleDetection;



function ETStatMean_Callback(hObject, eventdata, handles)
% hObject    handle to ETStatMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETStatMean as text
%        str2double(get(hObject,'String')) returns contents of ETStatMean as a double


% --- Executes during object creation, after setting all properties.
function ETStatMean_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETStatMean (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETStatSD_Callback(hObject, eventdata, handles)
% hObject    handle to ETStatSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETStatSD as text
%        str2double(get(hObject,'String')) returns contents of ETStatSD as a double


% --- Executes during object creation, after setting all properties.
function ETStatSD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETStatSD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ETTotal_Callback(hObject, eventdata, handles)
% hObject    handle to ETTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ETTotal as text
%        str2double(get(hObject,'String')) returns contents of ETTotal as a double


% --- Executes during object creation, after setting all properties.
function ETTotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ETTotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in RBHistPreSpot.
function RBHistPreSpot_Callback(hObject, eventdata, handles)
% hObject    handle to RBHistPreSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isempty(get(handles.ETSmallOutlier, 'String')) && ~isempty(get(handles.ETLargeOutlier, 'String'))
   set(handles.ETSmallOutlier, 'String', '');
   set(handles.ETLargeOutlier, 'String', '');
else
    return;
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of RBHistPreSpot


% --- Executes on button press in RBHistAfterSpot.
function RBHistAfterSpot_Callback(hObject, eventdata, handles)
% hObject    handle to RBHistAfterSpot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(get(handles.ETSmallOutlier, 'String')) && ~isempty(get(handles.ETLargeOutlier, 'String'))
   set(handles.ETSmallOutlier, 'String', '');
   set(handles.ETLargeOutlier, 'String', '');
else
    return;
end
guidata(hObject, handles);
% Hint: get(hObject,'Value') returns toggle state of RBHistAfterSpot

function PBLoadHistogram_Callback(hObject, eventdata, handles)
[filename pathname]=uigetfile('*.mat','Select Histogram Data');
if isequal(filename,0) || isequal(pathname,0)
    return;
end

fpath=[pathname filename];
HistogramData = load(fpath);
if isstruct(HistogramData)
     VariableName = fieldnames(HistogramData);
     HistogramData = getfield(HistogramData, VariableName{1});
     
    if isfield(HistogramData, 'Size') && isfield(HistogramData, 'Contrasts')
        %Set the Histogram Mode Operation Flag:
        handles.HistogramModeOperation = 1;
        handles.HistogramData = HistogramData;
        if ~isempty(get(handles.ETSmallOutlier, 'String')) && ~isempty(get(handles.ETLargeOutlier, 'String'))
            set(handles.ETSmallOutlier, 'String', '');
            set(handles.ETLargeOutlier, 'String', '');
        end
        choice = questdlg('Which information do you want to load?', ...
            'Select Info Type', ...
            'Size','Contrasts', 'Cancel', 'Size');
        % Handle response
        switch choice
            case 'Size'
                handles.HistogramMode = 'Size';
                cla(handles.HistogramAxes);
                axes(handles.HistogramAxes);
                hist(handles.HistogramData.Size, str2double(get(handles.ETBinNumber, 'String'))), xlabel('Diameter (nm)','FontName', 'Arial', 'FontSize', 9);
                ylabel('Frequency','FontName', 'Arial', 'FontSize', 9),
                title('Size Histogram','FontName', 'Arial', 'FontSize', 9);
                h = findobj(gca,'Type','patch');
                set(h,'FaceColor','r','EdgeColor','w');
                
                set(handles.SRSmallOutlier,'Enable','on');
                set(handles.SRSmallOutlier, 'Min', min(handles.HistogramData.Size), 'Max',max(handles.HistogramData.Size),'Value',min(handles.HistogramData.Size), 'SliderStep',[0.01 0.05]);
                
                set(handles.SRLargeOutlier,'Enable','on');
                set(handles.SRLargeOutlier, 'Min', min(handles.HistogramData.Size), 'Max',max(handles.HistogramData.Size), 'Value',max(handles.HistogramData.Size),'SliderStep',[0.01 0.05]);
                
                set(handles.ETSmallOutlier,'String', num2str(min(handles.HistogramData.Size)));
                set(handles.ETLargeOutlier,'String', num2str(max(handles.HistogramData.Size)));

                UpdateStats(handles.HistogramData.Size, hObject, handles);
                
            case 'Contrasts'
                handles.HistogramMode = 'Contrasts';
                cla(handles.HistogramAxes);
                axes(handles.HistogramAxes);
                hist(handles.HistogramData.Contrasts,str2double(get(handles.ETBinNumber, 'String'))), xlabel('Contrast Value','FontName', 'Arial', 'FontSize', 9);
                ylabel('Frequency','FontName', 'Arial', 'FontSize', 9),
                title('Contrast Histogram','FontName', 'Arial', 'FontSize', 9);
                h = findobj(gca,'Type','patch');
                set(h,'FaceColor','r','EdgeColor','w');
                
                set(handles.SRSmallOutlier,'Enable','off');
                set(handles.SRLargeOutlier,'Enable','off');
                
                set(handles.ETSmallOutlier,'String', '');
                set(handles.ETLargeOutlier,'String', '');
                
                UpdateStats(handles.HistogramData.Contrasts, hObject, handles);

            case 'Cancel'
                return;
        end       
    else
        warndlg('Histogram data is not properly formatted!','!! Warning !!','modal');
        return;
    end
else
    warndlg('Histogram data is not properly formatted!','!! Warning !!','modal');
    return;
end

guidata(hObject, handles);

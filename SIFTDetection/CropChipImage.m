function varargout = CropChipImage(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @CropChipImage_OpeningFcn, ...
    'gui_OutputFcn',  @CropChipImage_OutputFcn, ...
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

function CropChipImage_OpeningFcn(hObject, eventdata, handles, varargin)

clc;
cla;
reset(gca);

handles.ContrastLowLim = 0.25;
handles.ContrastHighLim = 1.3;
set(handles.SLow,'Value',0.25);
set(handles.SHigh,'Value',1.3);
handles.Flag = 0;
handles.ImFlag = 0;

if nargin == 5
    handles.ImageDirectory = varargin{2};
    handles.ImFlag = 1;
end

if isempty(varargin)
    handles.InputFlag = 0;
    varargin{1} = [0 0 0 0];
else
    if sum(varargin{1}) ~= 0
        handles.InputFlag = 1;
        set(handles.PBCrop,'Enable','on');
        set(handles.RBManual,'Enable','off');
        set(handles.RBSize1,'Enable','off');
        set(handles.RBSize2,'Enable','off');
        set(handles.RBDefine,'Enable','off');
        set(handles.PBCrop,'String','Draw');
    end
end

handles.rect = varargin{1};

guidata(hObject, handles);
uiwait(handles.SingleParticleDetection);


% --- Outputs from this function are returned to the command line.
function varargout = CropChipImage_OutputFcn(hObject, eventdata, handles)
if isfield(handles, 'croppedimage')
    handles.output.croppedimage = handles.croppedimage;
    handles.output.ImageDir = handles.ImageDir;
else
    handles.output.croppedimage = [];
end

if isfield(handles,'rect')
    handles.output.rect = handles.rect;
else
    handles.output.rect = [];
end

varargout{1} = handles.output;


% guidata(hObject, handles);


% --- Executes on slider movement.
function SLow_Callback(hObject, eventdata, handles)

handles.ContrastLowLim = get(hObject,'Value');
set(handles.LowValue,'String',num2str(get(handles.SLow,'Value')));

if (handles.ContrastLowLim < handles.ContrastHighLim);
    axes(handles.AxesImage);
    imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
    colormap gray;
else
    errordlg('Upper value should be larger than lower value!');
    return;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function SHigh_Callback(hObject, eventdata, handles)
% hObject    handle to SHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.ContrastHighLim = get(hObject,'Value');
set(handles.HighValue,'String',num2str(get(handles.SHigh,'Value')));

if handles.ContrastLowLim<handles.ContrastHighLim
    axes(handles.AxesImage);
    imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
    colormap gray;
else
    errordlg('Upper value should be larger than lower value!');
    return;
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function SHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in PBCrop.
function PBCrop_Callback(hObject, eventdata, handles)

set(handles.PBCrop,'Enable','off');
set(handles.RBManual,'Enable','off');
set(handles.RBSize1,'Enable','off');
set(handles.RBSize2,'Enable','off');
set(handles.RBDefine,'Enable','off');
set(handles.PBSelectMirror,'Enable','off');
set(handles.SLow,'Enable','off');
set(handles.SHigh,'Enable','off');

set(handles.Instructions, 'String','Double click the rectangle!!!!');

axes(handles.AxesImage);
imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
colormap gray;

if sum(handles.rect) ~= 0
            
            handles.imrecthandle = imrect(handles.AxesImage, handles.rect);
            handles.rect = wait(handles.imrecthandle);
            
            [handles.croppedimage]=imcrop(handles.image,handles.rect);
      
else

            switch handles.Flag
    
                case 1
        
                    [handles.croppedimage handles.rect] = imcrop();
    
                    if isempty(handles.croppedimage)
                        return;
                    end
    
                    handles.rect = round(handles.rect-1);
   
                case 2
     
                    Frame1 = [200 200 1184 555];
                    handles.imrecthandle = imrect(handles.AxesImage, Frame1);
                    handles.rect = wait(handles.imrecthandle);

                    [handles.croppedimage] = imcrop(handles.image , handles.rect);
    
                    if isempty(handles.croppedimage)
                        return;
                    end
        
                    handles.rect = round(handles.rect-1);

                case 3
      
                    Frame2 = [200 200 500 500];
                    handles.imrecthandle = imrect(handles.AxesImage, Frame2);
                    handles.rect = wait(handles.imrecthandle);

                    [handles.croppedimage] = imcrop(handles.image,handles.rect);
    
                    if isempty(handles.croppedimage)
                        return;
                    end
        
                    handles.rect = round(handles.rect-1);
    
                case 4

                    FrameX = str2num(get(handles.EditX,'String'));
                    FrameY = str2num(get(handles.EditY,'String'));
         
                    FrameDefined = [200 200 FrameX FrameY];
        
                    handles.imrecthandle = imrect(handles.AxesImage, FrameDefined);
                    handles.rect = wait(handles.imrecthandle);

                    [handles.croppedimage] = imcrop(handles.image,handles.rect);
    
                    if isempty(handles.croppedimage)
                        return;
                    end
        
                    handles.rect = round(handles.rect-1);
      
            end

end

guidata(hObject, handles);


% --- Executes on button press in PBSelectMirror.
function PBSelectMirror_Callback(hObject, eventdata, handles)

ImageDirectory = handles.ImageDir;

[filename pathname] = uigetfile(ImageDirectory,'Select Mirror File');

if isequal(filename,0) || isequal(pathname,0),
    return;
end

fpath=[pathname filename];
handles.MirrorDir = pathname;

mirror = load(fpath);
handles.MirrorFileWav = mirror.data_wav;
mirror = mirror.frame;
handles.mirror = mirror'; %still transposed

if (handles.IntensityFileWav == handles.MirrorFileWav)
    handles.image = handles.image./handles.mirror;
	axes(handles.AxesImage);
	imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
    colormap gray
	set(handles.PBCrop,'Enable','on');
else
	errordlg('Wavelengths of intensity file and mirror file dont match!','Load-file error!','modal');
    return;
end

guidata(hObject, handles);


% --- Executes on button press in PBSelectFile.
function PBSelectFile_Callback(hObject, eventdata, handles)

if handles.ImFlag == 0
    [filename pathname] = uigetfile('*.mat','Select Image File','frame');
else
    ImageDirectory = handles.ImageDirectory;
    [filename pathname] = uigetfile(ImageDirectory,'Select Mirror File');
end

if isequal(filename,0) || isequal(pathname,0)
    return;
end

fpath = [pathname filename];
handles.ImageDir = pathname;  

image = load(fpath);
handles.IntensityFileWav = image.data_wav;

image = image.frame;
handles.image = image'; %still transposed

FileContent = what(pathname);
MatFileContent = FileContent.mat;
whichFile = strmatch('mir', lower(MatFileContent));
MirrorFile = MatFileContent(whichFile);

if isempty(whichFile)
    set(handles.PBSelectMirror, 'Enable', 'on');
else
    Dialog1 = ' (Mirror File: '; 
    Dialog2 = ' Do you want to use this mirror file or choose another one?';
    choice = questdlg([Dialog2 Dialog1 MirrorFile{1} ')'], 'Mirror File Found!', 'Use','Choose Another File','Choose Another File');
    switch choice
        case 'Use'   
            fpath=[pathname MirrorFile{1}];
            handles.MirrorDir = pathname;

            mirror = load(fpath);
            handles.MirrorFileWav = mirror.data_wav;
            mirror = mirror.frame;
            handles.mirror = mirror';

            if (handles.IntensityFileWav == handles.MirrorFileWav)
                handles.image = handles.image./handles.mirror;
                axes(handles.AxesImage);
                imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
                colormap gray;
                set(handles.Instructions, 'String','Please select a draw option and click the draw button.');
            else
                set(handles.PBSelectMirror, 'Enable', 'on');
            end
        case 'Choose Another File'
            ImageDirectory = handles.ImageDir;
            [filename pathname] = uigetfile(ImageDirectory, 'Select Mirror File');

            if isequal(filename,0) || isequal(pathname,0),
                return;
            end

            fpath=[pathname filename];
            handles.MirrorDir = pathname;

            mirror = load(fpath);
            handles.MirrorFileWav = mirror.data_wav;
            mirror = mirror.frame;
            handles.mirror = mirror';

            if (handles.IntensityFileWav == handles.MirrorFileWav)
                handles.image = handles.image./handles.mirror;
                axes(handles.AxesImage);
                imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
                colormap gray;
                set(handles.Instructions, 'String','Please select a draw option and click the draw button.');
            else
                set(handles.PBSelectMirror, 'Enable', 'on');
            end

    end

end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function PBSelectFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to PBSelectFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


function EditX_Callback(hObject, eventdata, handles)
axes(handles.AxesImage);        
imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
colormap gray;    
handles.DrawnRectangle = rectangle('position', [200 200 str2num(get(handles.EditY,'String')) str2num(get(hObject,'String'))],'EdgeColor',[1 0 0]);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EditX as text
%        str2double(get(hObject,'String')) returns contents of EditX as a double


% --- Executes during object creation, after setting all properties.
function EditX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function EditY_Callback(hObject, eventdata, handles)
axes(handles.AxesImage);        
imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
colormap gray;
handles.DrawnRectangle = rectangle('position', [200 200 str2num(get(handles.EditX,'String')) str2num(get(hObject,'String'))], 'EdgeColor', [1 0 0]);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hints: get(hObject,'String') returns contents of EditY as text
%        str2double(get(hObject,'String')) returns contents of EditY as a double


% --- Executes during object creation, after setting all properties.
function EditY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EditY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in ButtonPanel.
function ButtonPanel_SelectionChangeFcn(hObject, eventdata, handles)

clc;
   
axes(handles.AxesImage);        
imagesc(handles.image,[handles.ContrastLowLim handles.ContrastHighLim]);
colormap gray;

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    
    case 'RBManual'
        handles.Flag = 1;       
        set(handles.PBCrop, 'Enable', 'on');
        set(handles.EditX,'Enable','off');
        set(handles.EditY,'Enable','off');
        set(handles.Instructions, 'String','Click the draw button.');

    case 'RBSize1'
        handles.Flag = 2;
        set(handles.PBCrop, 'Enable', 'on');
        set(handles.EditX,'Enable','off');
        set(handles.EditY,'Enable','off'); 
        handles.DrawnRectangle = rectangle('position', [200 200 1184 555], 'EdgeColor',[1 0 0]);
        set(handles.Instructions, 'String','Click the draw button.');

    case 'RBSize2'
        handles.Flag = 3;
        set(handles.PBCrop, 'Enable', 'on');
        set(handles.EditX,'Enable','off');
        set(handles.EditY,'Enable','off');
        handles.DrawnRectangle = rectangle('position', [200 200 500 500], 'EdgeColor',[1 0 0]);
        set(handles.Instructions, 'String','Click the draw button.');

    case 'RBDefine'
        handles.Flag = 4;
        helpdlg('Click Enter to Preview','Preview');
        set(handles.EditX,'Enable','on');
        set(handles.EditY,'Enable','on');
        set(handles.PBCrop, 'Enable', 'on');
        set(handles.Instructions, 'String','Click the draw button.');
        
end

guidata(hObject, handles);


% --- Executes on button press in PBUserManual.
function PBUserManual_Callback(hObject, eventdata, handles)
% hObject    handle to PBUserManual (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open CCI-Manual.pdf;


% --- Executes during object creation, after setting all properties.
function AxesImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AxesImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate AxesImage

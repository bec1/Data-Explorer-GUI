function varargout = ImageViewerGUI(varargin)
% IMAGEVIEWERGUI MATLAB code for ImageViewerGUI.fig
%      IMAGEVIEWERGUI, by itself, creates a new IMAGEVIEWERGUI or raises the existing
%      singleton*.
%
%      H = IMAGEVIEWERGUI returns the handle to a new IMAGEVIEWERGUI or the handle to
%      the existing singleton*.
%
%      IMAGEVIEWERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMAGEVIEWERGUI.M with the given input arguments.
%
%      IMAGEVIEWERGUI('Property','Value',...) creates a new IMAGEVIEWERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ImageViewerGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ImageViewerGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ImageViewerGUI

% Last Modified by GUIDE v2.5 29-Jan-2016 11:04:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ImageViewerGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ImageViewerGUI_OutputFcn, ...
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


% --- Executes just before ImageViewerGUI is made visible.
function ImageViewerGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ImageViewerGUI (see VARARGIN)

% Process Inputs
mainhObject = varargin{1};

% Create ImageViewer class
obj = ImageViewer(handles.x1,handles.x_XSlice,handles.x_YSlice);

% Default values
set(handles.ImNum_Input, 'String', '0');

% Save to handles
handles.mainhObject = mainhObject;
handles.obj = obj;

% Choose default command line output for ImageViewerGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ImageViewerGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ImageViewerGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function ImNum_Input_Callback(hObject, eventdata, handles)
% hObject    handle to ImNum_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Extract latest list of data from main
mainhandles = guidata(handles.mainhObject);
imnums = mainhandles.dataclass.imnums;
impaths = mainhandles.dataclass.impaths;
imtotal = mainhandles.dataclass.imtotal;

% Process the input
imnum = str2double(get(hObject,'String'));
if imnum==0
    % ask main to update to selected image
elseif imnum==-1
    % Ask main to show the latest image
elseif imnum > 0 && imnum <= imtotal
    imnum = find(imnums==imnum);
    handles.obj.path = impaths{imnum};
else
    set(handles.ImNum_Input,'String','NO');
end
guidata(hObject, handles);


% --- Executes on key press with focus on ImNum_Input and none of its controls.
function ImNum_Input_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ImNum_Input (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if ~strcmp(eventdata.Key,'uparrow') && ~strcmp(eventdata.Key,'downarrow'), return; end

% Extract latest list of data from main
mainhandles = guidata(handles.mainhObject);
imnums = mainhandles.dataclass.imnums;
impaths = mainhandles.dataclass.impaths;
imtotal = mainhandles.dataclass.imtotal;

% Process inputs
imnum = str2double(get(handles.ImNum_Input,'String'));
switch eventdata.Key
    case 'uparrow'
        imnum = imnum + 1;
        if imnum > imtotal, imnum = imtotal; end
        set(handles.ImNum_Input,'String',num2str(imnum));
        imnum = find(imnums==imnum);
        handles.obj.path = impaths{imnum};
    case 'downarrow'
        imnum = imnum - 1;
        if imnum < 1, imnum = 1; end
        set(handles.ImNum_Input,'String',num2str(imnum));
        imnum = find(imnums == imnum);
        handles.obj.path = impaths{imnum};
end
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function ImNum_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImNum_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ODMin_Input_Callback(hObject, eventdata, handles)
% hObject    handle to ODMin_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OD = [str2double(get(hObject,'String')),handles.obj.OD(2)];
if OD(2) <= OD(1), OD(2) = OD(1) + 0.0001; set(handles.ODMax_Input,'String',num2str(OD(2))); end
handles.obj.OD = OD;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ODMin_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ODMin_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ODMax_Input_Callback(hObject, eventdata, handles)
% hObject    handle to ODMax_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OD = [handles.obj.OD(1),str2double(get(hObject,'String'))];
if OD(2) <= OD(1), OD(2) = OD(1) + 0.0001; set(handles.ODMax_Input,'String',num2str(OD(2))); end
handles.obj.OD = OD;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function ODMax_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ODMax_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ODp_Btn.
function ODp_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to ODp_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OD = handles.obj.OD; OD(2) = OD(2) + 0.1;
set(handles.ODMax_Input,'String',num2str(OD(2)));
handles.obj.OD = OD;
guidata(hObject, handles);

% --- Executes on button press in ODm_Btn.
function ODm_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to ODm_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OD = handles.obj.OD; OD(2) = OD(2) - 0.1; if OD(2) <= OD(1), OD(2) = OD(1) + 0.0001; end
set(handles.ODMax_Input,'String',num2str(OD(2)));
handles.obj.OD = OD;
guidata(hObject, handles);


% --- Executes on selection change in Type_Input.
function Type_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Type_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
handles.obj.type = contents{get(hObject,'Value')};
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Type_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Type_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Mark_Btn.
function Mark_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Mark_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = imfreehand(handles.x1,'Closed',false);
pts = []; try pts = h.getPosition; catch; end; pts = round(pts);
handles.obj.markpts = [handles.obj.markpts; pts];
guidata(hObject, handles);

% --- Executes on button press in Clear_Btn.
function Clear_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Clear_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.obj.markpts = [];
guidata(hObject, handles);


% --- Executes on slider movement.
function Slider_XSlice_Callback(hObject, eventdata, handles)
handles.obj.xSliceCenter = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Slider_XSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_XSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function Slider_YSlice_Callback(hObject, eventdata, handles)
handles.obj.ySliceCenter = get(hObject,'Value');
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Slider_YSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Slider_YSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function SliceWidthInput_Callback(hObject, eventdata, handles)
handles.obj.xSliceWidth = round(str2double(get(hObject,'String'))/2);
handles.obj.ySliceWidth = round(str2double(get(hObject,'String'))/2);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function SliceWidthInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SliceWidthInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

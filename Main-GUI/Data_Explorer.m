function varargout = Data_Explorer(varargin)
% DATA_EXPLORER MATLAB code for Data_Explorer.fig
%      DATA_EXPLORER, by itself, creates a new DATA_EXPLORER or raises the existing
%      singleton*.
%
%      H = DATA_EXPLORER returns the handle to a new DATA_EXPLORER or the handle to
%      the existing singleton*.
%
%      DATA_EXPLORER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DATA_EXPLORER.M with the given input arguments.
%
%      DATA_EXPLORER('Property','Value',...) creates a new DATA_EXPLORER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Data_Explorer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Data_Explorer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Data_Explorer

% Last Modified by GUIDE v2.5 01-Dec-2015 21:17:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Data_Explorer_OpeningFcn, ...
                   'gui_OutputFcn',  @Data_Explorer_OutputFcn, ...
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


% --- Executes just before Data_Explorer is made visible.
function Data_Explorer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Data_Explorer (see VARARGIN)

% Add path for functions
root_dir = fileparts(pwd);
addpath(root_dir);
addpath(fullfile(root_dir,'Additional-Functions'));
addpath(fullfile(root_dir,'Snippet-Functions'));
addpath(fullfile(root_dir,'Additional-GUIs'));

% Get analyzed folder path from settings file
settings_filepath = fullfile(fileparts(userpath),'Data_Explorer_GUI_Settings_DONOT_DELETE.mat');
if ~exist(settings_filepath,'file')
    processed_root_folder_path = uigetdir(settings_filepath,'Select the Processed Data Root Folder');
    snippet_folder_path = uigetdir(settings_filepath,'Select Snippet Folder');
    save(settings_filepath,'processed_root_folder_path','snippet_folder_path');
else
    contents = load(settings_filepath,'-mat');
    processed_root_folder_path = contents.processed_root_folder_path;
    snippet_folder_path = contents.snippet_folder_path;
end
class_inputs.datafolder = processed_root_folder_path;
class_inputs.snipfolder = snippet_folder_path;

% Disable Other Buttons until Folder has been selected
set(handles.Properties_Menu,'Enable','off');
set(handles.Refresh_Btn,'Enable','off');

% Initialize Needed Variables
handles.data.OD = 1.5;
handles.data.cropset = [];
handles.data.mode = 1;
handles.data.props.pnames = {'num','name','hide','notes','TOF'};
handles.data.props.widths = {30,150,30,100,50};
handles.data.props.editables = {false,false,true,true,false};
handles.data.current = 0;
handles.data.auto_update = 0;

% Choose default command line output for Data_Explorer
handles.output = hObject;

% Update handles structure
handles.file.settings_filepath = settings_filepath;
handles.file.inputs = class_inputs;
guidata(hObject, handles);

% UIWAIT makes Data_Explorer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Data_Explorer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when selected cell(s) is changed in Data_Explorer_Table.
function Data_Explorer_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Continue only if dataclass exists, if Indices exist and its size(eventdata.Indices,1)==1
if isprop(eventdata,'Indices') && size(eventdata.Indices,1)==1  && isfield(handles,'dataclass')
    imnum = eventdata.Indices(1); if get(handles.Show_Hidden_Input,'Value'), imnum = handles.data.imnumshidden(imnum); end
    imgdat = handles.dataclass.imdata(imnum);
    axes(handles.Cropped_Image_Axes); imshow(imgdat,[0,handles.data.OD]);
end


% --- Executes when entered data in editable cell(s) in Data_Explorer_Table.
function Data_Explorer_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% Extract editted data
hidden = get(handles.Show_Hidden_Input,'Value');
imnum = eventdata.Indices(1);
if hidden, imnum = handles.data.imnumshidden(imnum); end
pname = get(handles.Data_Explorer_Table,'ColumnName');
pname = pname(eventdata.Indices(2));
val = {eventdata.NewData};

% Update data
handles.dataclass = handles.dataclass.savedata(imnum, pname, val);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Data_Explorer_Table_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object deletion, before destroying properties.
function Data_Explorer_Table_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on Data_Explorer_Table and none of its controls.
function Data_Explorer_Table_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Properties_Menu_Callback(hObject, eventdata, handles)
% hObject    handle to Properties_Menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outp = Properties_Selector();
if outp.update
    handles.data.props.pnames = outp.pnames;
    handles.data.props.widths = outp.widths;
    handles.data.props.editables = outp.editables;
    handles = update_data_table(handles);
    guidata(hObject, handles);
end



% --- Executes on button press in Select_Folder_Btn.
function Select_Folder_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Folder_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Prompt user for a directory.
images_folder_path = uigetdir(fileparts(userpath));

% If the path is valid, update selected path
if images_folder_path ~= 0
    % Create data_handler class using provided folder
    handles.file.inputs.imfolder = images_folder_path;
    handles.file.inputs.mode = handles.data.mode;
    handles.dataclass = Data_Handler(handles.file.inputs);
    
    % Add file watch. If it exists from previous folder, turn it off.
    if isfield(handles.file,'filewatch'), handles.file.filewatch.EnableRaisingEvents = false; end
    handles.file.filewatch = System.IO.FileSystemWatcher(images_folder_path);
    handles.file.filewatch.Filter = '*.fits';
    addlistener(handles.file.filewatch,'Created',@(source,arg) eventhandlerFileCreated(source,arg,hObject,handles));
    if handles.data.auto_update
        handles.file.filewatch.EnableRaisingEvents = true;
    end
    
    % Update all the GUI objects
    set(handles.Select_Folder_Disp,'String',[images_folder_path]);
    set(handles.Image_Count_Disp,'String',['Images: ',num2str(handles.dataclass.imtotal),' Added: ',num2str(handles.dataclass.imadded)]);
    handles = update_data_table(handles);
    set(handles.Properties_Menu,'Enable','on');
    set(handles.Refresh_Btn,'Enable','on');
end

% Update GUI data
guidata(hObject, handles);

% --- Executes on button press in Refresh_Btn.
function Refresh_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Refresh_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Update list of images from the data class
handles.dataclass = handles.dataclass.folder_scan;

% Update GUI elements
handles = update_data_table(handles);

% Update GUI data
guidata(hObject, handles);


% --- Executes on button press in Crop_Btn.
function Crop_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Crop_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)





function Max_OD_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Max_OD_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% input = str2double(get(hObject,'String'));
% if input > 0, handles.data.OD = input; end
% plot_current_image(handles);
% % Update handles
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function Max_OD_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_OD_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Max_OD_p_Btn.
function Max_OD_p_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Max_OD_p_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Max_OD_m_Btn.
function Max_OD_m_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Max_OD_m_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Auto_Recrop_Input.
function Auto_Recrop_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Recrop_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function Image1_Axes_Number_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Image1_Axes_Number_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Image1_Axes_Number_Input as text
%        str2double(get(hObject,'String')) returns contents of Image1_Axes_Number_Input as a double


% --- Executes during object creation, after setting all properties.
function Image1_Axes_Number_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image1_Axes_Number_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Image2_Axes_Number_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Image2_Axes_Number_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Image2_Axes_Number_Input as text
%        str2double(get(hObject,'String')) returns contents of Image2_Axes_Number_Input as a double


% --- Executes during object creation, after setting all properties.
function Image2_Axes_Number_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image2_Axes_Number_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Copy_Crop_Btn.
function Copy_Crop_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Copy_Crop_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Show_Hidden_Input.
function Show_Hidden_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Show_Hidden_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of Show_Hidden_Input
handles = update_data_table(handles);

% Update GUI data
guidata(hObject, handles);

% --- Executes on button press in Auto_Atom_Number_Input.
function Auto_Atom_Number_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Atom_Number_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Auto_Atom_Number_Input


% --- Executes on selection change in Analyzed1_X_Input.
function Analyzed1_X_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Analyzed1_X_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Analyzed1_X_Input contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Analyzed1_X_Input


% --- Executes during object creation, after setting all properties.
function Analyzed1_X_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Analyzed1_X_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Analyzed1_Y_Input.
function Analyzed1_Y_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Analyzed1_Y_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Analyzed1_Y_Input contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Analyzed1_Y_Input


% --- Executes during object creation, after setting all properties.
function Analyzed1_Y_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Analyzed1_Y_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Analyzed2_X_input.
function Analyzed2_X_input_Callback(hObject, eventdata, handles)
% hObject    handle to Analyzed2_X_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Analyzed2_X_input contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Analyzed2_X_input


% --- Executes during object creation, after setting all properties.
function Analyzed2_X_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Analyzed2_X_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in Analyzed2_Y_Input.
function Analyzed2_Y_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Analyzed2_Y_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns Analyzed2_Y_Input contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Analyzed2_Y_Input


% --- Executes during object creation, after setting all properties.
function Analyzed2_Y_Input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Analyzed2_Y_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in Condensate_Fraction_Btn.
function Condensate_Fraction_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Condensate_Fraction_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in Auto_Update_Input.
function Auto_Update_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Update_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current state of the toggle
handles.data.auto_update = get(hObject,'Value');

% Set the event to appropriate value, if it exists
if isfield(handles.file,'filewatch') && handles.data.auto_update==1
    handles.file.filewatch.EnableRaisingEvents = true;
%     addlistener(handles.file.filewatch,'Created',@(source,arg) eventhandlerFileCreated(source,arg,handles));
elseif isfield(handles.file,'filewatch') && handles.data.auto_update==0
    handles.file.filewatch.EnableRaisingEvents = false;
%     addlistener(handles.file.filewatch,'Created',@(source,arg) eventhandlerFileCreated(source,arg,handles));
end

% Update GUI data
guidata(hObject, handles);















% --- USER DEFINED FUNCTION ---
function handles = update_data_table(handles)
% Extract data from handles
table = handles.Data_Explorer_Table;
pnames = handles.data.props.pnames;
widths = handles.data.props.widths;
editables = handles.data.props.editables;
hidden = logical(get(handles.Show_Hidden_Input,'Value'));


% Prepare data
[data, imnumshidden] = handles.dataclass.celldata(pnames,hidden);
editables2 = zeros(1,length(editables));
for i=1:length(editables), editables2(i) = editables{i}; end
editables2 = logical(editables2);

% Update Data_Table
set(table,'ColumnName',pnames,...
    'ColumnWidth',widths,...
    'ColumnEditable',editables2,...
    'Data',data);

% Update Handles
handles.data.celldata = data;
handles.data.imnumshidden = imnumshidden;


function eventhandlerFileCreated(source,arg,hObject,handles)
% full path to the added file is located at arg.FullPath (incl. .fits)

handles = guidata(hObject);

% Wait and update list of images from the data class
handles.dataclass = handles.dataclass.folder_scan;

% Update GUI elements
handles = update_data_table(handles);

% Update GUI data
guidata(hObject, handles);













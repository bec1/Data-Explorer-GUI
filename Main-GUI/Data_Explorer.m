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

% Last Modified by GUIDE v2.5 23-Nov-2015 01:27:26

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

% Disable Other Buttons until Folder has been selected
set(handles.Properties_Menu,'Enable','off');
set(handles.Rescan_Btn,'Enable','off');

% Initialize Table
col_names = {'Filename'}; col_format = {'text'}; col_width = {50}; col_edit = logical([0]);
default_data = {'ImgA' ; 'ImgB' ; 'ImgC' ; 'ImgD'};
t = handles.Data_Explorer_Table;
set(t,'ColumnName',col_names,'ColumnEditable',col_edit,'ColumnWidth',col_width,'RearrangeableColumns','on','Data',default_data);
handles.all.names = col_names;
handles.all.editable = col_edit;
handles.all.data = default_data;

% Initialize Needed Variables
handles.current.row = 1;
handles.all.max_od = 0.5; set(handles.Max_OD_Input,'String',num2str(handles.all.max_od));
handles.all.auto_crop = 0; set(handles.Auto_Recrop_Input,'Value',0);

% Choose default command line output for Data_Explorer
handles.output = hObject;

% Update handles structure
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


% --------------------------------------------------------------------
function Data_Explorer_Table_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected cell(s) is changed in Data_Explorer_Table.
function Data_Explorer_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Data_Explorer_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
if length(eventdata.Indices) && isfield(handles.all,'filenames')
    handles.current.row = eventdata.Indices(1);
    handles.current.class = Current_Image(fullfile(handles.load.folder,handles.all.filenames{handles.current.row}));
    if isfield(handles,'crop') && isnan(handles.current.class.crop_set(1)) && handles.all.auto_crop, handles.current.class.crop_set = handles.crop.settings; end
    plot_current_image(handles);
    guidata(hObject, handles);
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
    handles.all.names = outp.selected_names;
    handles.all.editable = outp.selected_editable;
    Rescan_Btn_Callback(hObject,eventdata,handles);
    guidata(hObject, handles);
end



% --- Executes on button press in Select_Folder_Btn.
function Select_Folder_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Select_Folder_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t = uigetdir();
if t(1)>0
    handles.load.folder = t;
    set(handles.Select_Folder_Disp,'String',[handles.load.folder]);
    handles = get_all_fits_files(handles);
    handles.all.num_added = length(handles.all.filenames);
    set(handles.Image_Count_Disp,'String',['Images: ',num2str(length(handles.all.filenames)),' Added: ',num2str(handles.all.num_added)]);
    handles = get_all_name_value(handles);
    handles =  update_data_explorer_table(handles);
    guidata(hObject, handles);
end
set(handles.Properties_Menu,'Enable','on');
set(handles.Rescan_Btn,'Enable','on');




% --- Executes on button press in Rescan_Btn.
function Rescan_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Rescan_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
total_files = length(handles.all.filenames);
handles = get_all_fits_files(handles); 
handles.all.num_added = length(handles.all.filenames) - total_files;
set(handles.Image_Count_Disp,'String',['Images: ',num2str(length(handles.all.filenames)),' Added: ',num2str(handles.all.num_added)]);
handles = get_all_name_value(handles);
handles =  update_data_explorer_table(handles);
guidata(hObject, handles);


% --- Executes on button press in Crop_Btn.
function Crop_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Crop_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If there are no images selected, then exit the function
if ~isfield(handles.current,'class'),disp('Minor Error: Please Select an Image Before Cropping!'); return; end
% If this is the first time using crop, ask user for crop settings.
if ~isfield(handles,'crop')
    axes(handles.Cropped_Image_Axes); imshow(handles.current.class.raw_data,[0,handles.all.max_od]);
    handles.crop.settings = getrect(handles.Cropped_Image_Axes);
% Ask user for new crop settings if image's crop setting is same as current
elseif handles.current.class.crop_set == handles.crop.settings
    axes(handles.Cropped_Image_Axes); imshow(handles.current.class.raw_data,[0,handles.all.max_od]);
    handles.crop.settings = getrect(handles.Cropped_Image_Axes);    
end
% Save crop settings
handles.current.class.crop_set = handles.crop.settings;
% Update Image
plot_current_image(handles);
% Update handles
guidata(hObject, handles);




function Max_OD_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Max_OD_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
input = str2double(get(hObject,'String'));
if input > 0, handles.all.max_od = input; end
plot_current_image(handles);
% Update handles
guidata(hObject, handles);


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
handles.all.max_od = handles.all.max_od + 0.1;
set(handles.Max_OD_Input,'String',num2str(handles.all.max_od));
plot_current_image(handles);
guidata(hObject, handles);

% --- Executes on button press in Max_OD_m_Btn.
function Max_OD_m_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Max_OD_m_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.all.max_od = handles.all.max_od - 0.1;
if handles.all.max_od <= 0.0000001, handles.all.max_od = 0.1; end
set(handles.Max_OD_Input,'String',num2str(handles.all.max_od));
plot_current_image(handles);
guidata(hObject, handles);

% --- Executes on button press in Auto_Recrop_Input.
function Auto_Recrop_Input_Callback(hObject, eventdata, handles)
% hObject    handle to Auto_Recrop_Input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.all.auto_crop = get(hObject,'Value');
guidata(hObject, handles);








% --- USER DEFINED FUNCTION ---
function handles =  update_data_explorer_table(handles)
t = handles.Data_Explorer_Table;
set(t,'ColumnName',handles.all.names,...
    'ColumnEditable',handles.all.editable,...
    'Data',handles.all.data);

function handles = get_all_fits_files(handles)
t = dir(fullfile(handles.load.folder,'*.fits'));
all_filenames = cell(length(t),1);
for i=1:length(t)
    all_filenames{i} = t(i).name;
end
handles.all.filenames = all_filenames;

% function handles = get_current_name_value(handles)
% handles.all.names
% handles.current.row;
% filename = handles.current.filename;
% names = handles.all.names;
% values = num2cell(zeros(size(names)));
% % values = Julian(filename, names);
% handles.current.values = values;

function handles = get_all_name_value(handles)
filenames = handles.all.filenames;
names = handles.all.names;
data = cell(length(filenames),length(names));
for i = 1:length(filenames)
%     values = num2cell(zeros(size(names)));  
    values = GetSnippetValues(filenames{i},names);
    if length(values)~=length(names),values = num2cell(zeros(size(names)));end
    if ~iscell(values),values=num2cell(values);end
    data{i,1} = filenames{i};
    for j = 2:length(names)
        data{i,j} = values{j};
    end
end
handles.all.data = data;

function plot_current_image(handles)
if isfield(handles.current,'class') 
    axes(handles.Cropped_Image_Axes); imshow(handles.current.class.get_image_data,[0,handles.all.max_od]);
    axes(handles.Image1_Axes); imshow(handles.current.class.raw_data,[0,handles.all.max_od]);
end










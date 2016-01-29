function varargout = Data_Explorer(varargin)
% DO NOT EDIT, GUI setup
gui_State = struct('gui_Name',       mfilename, 'gui_Singleton',  1, 'gui_OpeningFcn', @Data_Explorer_OpeningFcn, 'gui_OutputFcn',  @Data_Explorer_OutputFcn, 'gui_LayoutFcn',  [] , 'gui_Callback',   []);
if nargin && ischar(varargin{1}), gui_State.gui_Callback = str2func(varargin{1}); end
if nargout, [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:}); else gui_mainfcn(gui_State, varargin{:}); end

function Data_Explorer_OpeningFcn(hObject, eventdata, handles, varargin)

% Add path for functions
root_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(root_dir);
addpath(fullfile(root_dir,'Additional-Functions'));
addpath(fullfile(root_dir,'Snippet-Functions'));
addpath(fullfile(root_dir,'Additional-GUIs'));
addpath(fullfile(root_dir,'Main-GUI'));

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
set(handles.Create_ImageViewer_Btn,'Enable','off');

% Disable things for Mac
if ~ispc
    set(handles.Auto_Update_Input,'Enable','off');
end

% Initialize Needed Variables
handles.data.cropset = [];
handles.data.mode = 1;
handles.data.props.pnames = {'num','name','hide','notes','TOF'};
handles.data.props.widths = {30,150,30,100,50};
handles.data.props.editables = {false,false,true,true,false};
handles.data.auto_update = 0;

% Initialize other GUIs handles
handles.imageviewers = {};

% Choose default command line output for Data_Explorer
handles.output = hObject;

% Update handles structure
handles.file.settings_filepath = settings_filepath;
handles.file.inputs = class_inputs;
guidata(hObject, handles);

function varargout = Data_Explorer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function App_Settings_Callback(hObject, eventdata, handles)

function Select_Folder_Btn_Callback(hObject, eventdata, handles)
% Prompt user for a directory.
images_folder_path = uigetdir(fileparts(userpath));

% Validate folder name
if images_folder_path==0
    valid_dir = 0;
else
    [~,name,~] = fileparts(images_folder_path);
    expression = '\d\d\d\d-\d\d-\d\d';
    valid_dir = regexp(name,expression) == 1;
end

% If the path is valid, update selected path
if valid_dir
    % Create data_handler class using provided folder
    handles.file.inputs.imfolder = images_folder_path;
    handles.file.inputs.mode = handles.data.mode;
    handles.dataclass = Data_Handler(handles.file.inputs);
    
    % Add file watch. If it exists from previous folder, turn it off.
    if ispc % Only for windows
        if isfield(handles.file,'filewatch'), handles.file.filewatch.EnableRaisingEvents = false; end
        handles.file.filewatch = System.IO.FileSystemWatcher(images_folder_path);
        handles.file.filewatch.Filter = '*.fits';
        addlistener(handles.file.filewatch,'Created',@(source,arg) eventhandlerFileCreated(source,arg,handles.output,handles));
        if handles.data.auto_update
            handles.file.filewatch.EnableRaisingEvents = true;
        end
    end
    
    % Update all the GUI objects
    set(handles.Select_Folder_Disp,'String',[images_folder_path]);
    set(handles.Image_Count_Disp,'String',['Images: ',num2str(handles.dataclass.imtotal),' Added: ',num2str(handles.dataclass.imadded)]);
    handles = update_data_table(handles);
    set(handles.Properties_Menu,'Enable','on');
    set(handles.Refresh_Btn,'Enable','on');
    set(handles.Create_ImageViewer_Btn,'Enable','on');
end

% Update GUI data
guidata(hObject, handles);

function Properties_Menu_Callback(hObject, eventdata, handles)
outp = Properties_Selector();
if outp.update
    handles.data.props.pnames = outp.pnames;
    handles.data.props.widths = outp.widths;
    handles.data.props.editables = outp.editables;
    handles = update_data_table(handles);
    guidata(hObject, handles);
end

function Create_ImageViewer_Btn_Callback(hObject, eventdata, handles)
handles.imageviewers(end+1) = {ImageViewerGUI(handles.output)};
guidata(hObject, handles);

function Data_Explorer_Table_CellSelectionCallback(hObject, eventdata, handles)
% Continue only if dataclass exists, if Indices exist and its size(eventdata.Indices,1)==1
if isprop(eventdata,'Indices') && size(eventdata.Indices,1)==1  && isfield(handles,'dataclass')
    imnum = eventdata.Indices(1); if get(handles.Show_Hidden_Input,'Value'), imnum = handles.data.imnumshidden(imnum); end
    % Update imageviewers if they are set to 0
    for i = 1:length(handles.imageviewers)
        if ishandle(handles.imageviewers{i})
            imhandles = guidata(handles.imageviewers{i});
            if str2double(get(imhandles.ImNum_Input,'String')) == 0
                imhandles.obj.path = handles.dataclass.impaths{imnum};
            end
            guidata(handles.imageviewers{i},imhandles);
        end
    end
end
figure(handles.figure1);

function Data_Explorer_Table_CellEditCallback(hObject, eventdata, handles)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data

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

function Refresh_Btn_Callback(hObject, eventdata, handles)
% Update list of images from the data class
handles.dataclass = handles.dataclass.folder_scan;

% Update GUI elements
handles = update_data_table(handles);
    % Update imageviewers if they are set to 0
for i = 1:length(handles.imageviewers)
    if ishandle(handles.imageviewers{i})
        imhandles = guidata(handles.imageviewers{i});
        if str2double(get(imhandles.ImNum_Input,'String')) == -1
            imhandles.obj.path = handles.dataclass.impaths{1};
        end
        guidata(handles.imageviewers{i},imhandles);
    end
end

% Update GUI data
guidata(hObject, handles);

function Show_Hidden_Input_Callback(hObject, eventdata, handles)
handles = update_data_table(handles);
guidata(hObject, handles);

function Auto_Update_Input_Callback(hObject, eventdata, handles)
% Get the current state of the toggle
handles.data.auto_update = get(hObject,'Value');

% Set the event to appropriate value, if it exists
if isfield(handles.file,'filewatch') && handles.data.auto_update==1
    handles.file.filewatch.EnableRaisingEvents = true;
elseif isfield(handles.file,'filewatch') && handles.data.auto_update==0
    handles.file.filewatch.EnableRaisingEvents = false;
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
pause(5);
handles.dataclass = handles.dataclass.folder_scan;

% Update GUI elements
handles = update_data_table(handles);

% Update GUI data
guidata(hObject, handles);

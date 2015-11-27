function varargout = Properties_Selector(varargin)
% PROPERTIES_SELECTOR MATLAB code for Properties_Selector.fig
%      PROPERTIES_SELECTOR, by itself, creates a new PROPERTIES_SELECTOR or raises the existing
%      singleton*.
%
%      H = PROPERTIES_SELECTOR returns the handle to a new PROPERTIES_SELECTOR or the handle to
%      the existing singleton*.
%
%      PROPERTIES_SELECTOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROPERTIES_SELECTOR.M with the given input arguments.
%
%      PROPERTIES_SELECTOR('Property','Value',...) creates a new PROPERTIES_SELECTOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Properties_Selector_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Properties_Selector_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Properties_Selector

% Last Modified by GUIDE v2.5 26-Nov-2015 13:45:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Properties_Selector_OpeningFcn, ...
                   'gui_OutputFcn',  @Properties_Selector_OutputFcn, ...
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


% --- Executes just before Properties_Selector is made visible.
function Properties_Selector_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Properties_Selector (see VARARGIN)

% Get all property Names and Initialize the Table
handles = get_props(handles); 
set(handles.Property_Table,'Data',handles.props);

% Choose default command line output for Properties_Selector
handles.output = {'Default'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Properties_Selector wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Properties_Selector_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Get default command line output from handles structure
varargout{1} = handles.output;
delete(hObject);
% close(ancestor(hObject,'figure'))


% --- Executes on button press in Close_Btn.
function Close_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Close_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.Property_Table,'Data');
selected = {};
selected(1:2,1:4) = data(1:2,1:4); j=3;
for i = 3:size(data,1)
    if data{i,5}, selected(j,1:4) = data(i,1:4); j=j+1; end
end
handles.props = data;
outp.props = selected';
outp.update = 1;
handles.output = outp;
guidata(hObject, handles);
update_props_file(handles);
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outp.update = 0;
handles.output = outp;
guidata(hObject, handles);
uiresume(handles.figure1);
% Hint: delete(hObject) closes the figure
% delete(hObject);



% --- Executes on button press in Add_Prop_Btn.
function Add_Prop_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to Add_Prop_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.Property_Table,'Data');
handles.props = [data;{'Prop Name',false,50,false,true}];
set(handles.Property_Table,'Data',handles.props);
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in Property_Table.
function Property_Table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to Property_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)



% --- Executes when entered data in editable cell(s) in Property_Table.
function Property_Table_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Property_Table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

% disp(['Indices: ', num2str(eventdata.Indices)])
% disp(eventdata.PreviousData);
% disp(eventdata.EditData);
% disp(class(eventdata.NewData));
% disp(eventdata.Error);












% --- USER DEFINED FUNCTION ---
function handles = get_props(handles)
handles.filepath = fullfile(fileparts(userpath),'Data_Explorer_GUI_Settings_DONOT_DELETE.mat');
if ~exist(handles.filepath,'file')
% Settings file doesnt exist
    props = {...
        'no.','name', 'hide', 'notes','RF23';... % column name
        false, false,  false, false,  true;...   % true=Snippet, false=.mat 
           30,   150,     30,   100,    50;...   % Column Width in pixel
        false, false,   true,  true, false;...   % Column Editable?
         true,  true,   true,  true,  true};     % Include Property
    props = props';
    save(handles.filepath,'props');
    handles.props = props;
else
% Setting file exists
    contents = whos('-file',handles.filepath);
    if ismember('props',{contents.name})
    % and it contains prop
        t = load(handles.filepath,'-mat','props');
        handles.props = t.props;
    else
    % But it doenst contain prop
        props = {...
            'no.','name', 'hide', 'notes','RF23';... % column name
            false, false,  false, false,  true;...   % true=Snippet, false=.mat 
               30,   150,     30,   100,    50;...   % Column Width in pixel
            false, false,   true,  true, false;...   % Column Editable?
             true,  true,   true,  true,  true};     % Include Property
        props = props';
        save(handles.filepath,'props','-append');
        handles.props = props;
    end
end


function update_props_file(handles)
if exist(handles.filepath,'file')
    props = handles.props;
    save(handles.filepath,'props','-append');
end







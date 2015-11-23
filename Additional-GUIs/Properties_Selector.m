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

% Last Modified by GUIDE v2.5 19-Nov-2015 00:03:07

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
handles = get_all_names(handles); 
all_include = cell(size(handles.all_names));
for i =1:length(all_include), all_include{i} = false; end
all_editables = all_include; all_include{1} = true;
data = [handles.all_names,all_include,all_editables];
set(handles.Property_Table,'Data',data);

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
all_data = get(handles.Property_Table,'Data');
selected_names = {}; j=1;
selected_editable = [];
for i = 1:size(all_data,1)
    if all_data{i,2}
        selected_names{j} = all_data{i,1}; 
        selected_editable = [selected_editable, all_data{i,3}];
        j=j+1; 
    end
end
outp.selected_names = selected_names';
outp.selected_editable = logical(selected_editable);
outp.update = 1;
handles.output = outp;
guidata(hObject, handles);
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









% --- USER DEFINED FUNCTION ---
function handles = get_all_names(handles)
% Get from Julian's Program, Make sure its column cell
handles.all_names = {'Filename';'TOF';'RF23';'IRcomp';'Side green evap';'ImagFreq1';'IterationNum'};

classdef Data_Handler
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
properties
    % Initialized by Constructor
    images_folder_path
    processed_file_path
    snippet_folder_path
    images_path = {}
    images_name = {}
    props = {...
        'no.','name', 'hide', 'notes','RF23';... % column name
         true,  true,  false, false,  true;... % true=Snippet, false=.mat 
           30,   150,     30,   100,    50;... % Column Width in pixel
        false, false,   true,  true, false}   % Column Editable?
    all_values = {}
    total_images
    added_images
    
end % properties


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods

%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Data_Handler(images_folder_path,inputs)
    if nargin ~= 2 || ~exist(images_folder_path,'dir'), error('FATAL ERROR: Incorrect folder name or inputs'); end
    
    obj.images_folder_path = images_folder_path;
    obj = setup_processed_data(obj,images_folder_path,inputs.processed_root_folder_path);
    obj.snippet_folder_path = inputs.snippet_folder_path;
    if isfield(inputs,'props'), obj.props = inputs.props; end
    
    % Extract list of images and data
    obj = update_data(obj,1);
    
end % Data_Handler




%%%%%%%%%%%%%%%%%%%%%%%%%% Processed Data Folder/File %%%%%%%%%%%%%%%%%%%%%
function obj = setup_processed_data(obj,images_folder_path,processed_root_folder_path)
    % Extract names/paths
    [~,images_folder_name,~] = fileparts(images_folder_path);
    data_date = datetime(images_folder_name(1:10));
    processed_folder_path = fullfile(processed_root_folder_path,datestr(data_date,'yyyy'),datestr(data_date,'yyyy-mm'),datestr(data_date,'yyyy-mm-dd'));
    processed_file_name = [images_folder_name,'-DataExplorer.mat'];
    obj.processed_file_path = fullfile(processed_folder_path,processed_file_name);
    % Create Matlab storage files
    [~,~,~] = mkdir(processed_folder_path); % This command will NOT overwirte existing files there
    if ~exist(obj.processed_file_path,'file')
        save(obj.processed_file_path,'images_folder_path');
    else
        save(obj.processed_file_path,'images_folder_path','-append');
    end
    
    
end % setup_processed_data

%%%%%%%%%%%%%%%%%%%%%%%%%% Update Image List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = update_data(obj,all)
    % Extract structure with all images
    t = dir(fullfile(obj.images_folder_path,'*.fits'));
    prop_length = size(obj.props); prop_length = prop_length(2);
   
    if all
        old = 0; new = length(t); added = new - old; start = old+1;
        new_images_name = cell(new,1);
        new_images_path = cell(new,1);
        new_values = cell(new,prop_length);
    else
        old = length(obj.images_name); new = length(t); added = new - old; start = old+1;
        new_images_name = cell(new,1); new_images_name(1:old) = obj.images_name(:);
        new_images_path = cell(new,1); new_images_path(1:old) = obj.images_path(:);
        new_values = cell(new,prop_length); new_values(1:old,:) = obj.all_values(:,:);
    end
    
    for i = start:new
        new_images_name{i} = t(i).name; new_images_name{i} = new_images_name{i};
        new_images_path{i} = fullfile(obj.images_folder_path,t(i).name);
        inputs.snippet_folder_path = obj.snippet_folder_path;
        img_class = Current_Image(new_images_path{i},inputs);
        new_values(i,1:2) = {num2str(i),new_images_name{i}};
        new_values(i,3:end) = img_class.get_values(obj.props(:,3:end));
    end
    
    % Flip upside down and update object
    obj.images_name = flipud(new_images_name);
    obj.images_path = flipud(new_images_path);
    obj.all_values = flipud(new_values);
    obj.added_images = added;
end % update_data

%%%%%%%%%%%%%%%%%%%%%%% Extract All Values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = extract_all_values(obj)
    % Load all data from snippet
    
    % Load all values from 
    
    % Extract needed name/value pairs
    values = {};
end % extract all values


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Getter & Setter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function total_images = get.total_images(obj), total_images = length(obj.total_images); end

function obj = set.props(obj,props)
    if size(props,1)==4
        obj.props = props;
        obj = obj.update_data(1);
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % methods

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % Data_Handler


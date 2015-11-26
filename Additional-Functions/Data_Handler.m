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
    images_path = {}
    images_name = {}
    props = {...
        'No.','Name','Notes','RF23';... % column name
         true,  true,  false,  true;... % true=Snippet, false=.mat 
           20,   100,    100,    30;... % Column Width in pixel
        false, false,   true, false;}   % Column Editable?
    all_values = {}
    added_images
    
end % properties


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods

%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Data_Handler(images_folder_path,processed_root_folder_path)
    if nargin ~= 2 || ~exist(images_folder_path,'dir'), error('FATAL ERROR: Incorrect folder name or inputs'); end
    
    obj.images_folder_path = images_folder_path;
    obj = setup_processed_data(obj,images_folder_path,processed_root_folder_path);
    
    % Extract list of images and data
    obj = update_data(obj);
    
end % Data_Handler




%%%%%%%%%%%%%%%%%%%%%%%%%% Processed Data Folder/File %%%%%%%%%%%%%%%%%%%%%
function obj = setup_processed_data(obj,images_folder_path,processed_root_folder_path)
    % Extract names/paths
    [~,images_folder_name,~] = fileparts(images_folder_path);
    data_date = datetime(images_folder_name);
    processed_folder_path = fullfile(processed_root_folder_path,datestr(data_date,'yyyy'),datestr(data_date,'yyyy-mm'),datestr(data_date,'yyyy-mm-dd'));
    processed_file_name = [images_folder_name,'-DataExplorer.mat'];
    obj.processed_file_path = fullfile(processed_folder_path,processed_file_name);
    % Create Matlab storage files
    [~,~,~] = mkdir(processed_folder_path); % This command will NOT overwirte existing files there
    if ~exist(obj.processed_file_path,'file')
        save(obj.processed_file_path,'images_folder_path');
    end
    
    
end % setup_processed_data

%%%%%%%%%%%%%%%%%%%%%%%%%% Update Image List %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = update_data(obj)
    % Extract structure with all images
    t = dir(fullfile(obj.images_folder_path,'*.fits'));
    old = length(obj.images_name); new = length(t); added = new - old;
    prop_length = size(obj.props); prop_length = prop_length(2);
    
    % Extract image names, paths and name/value
    new_images_name = cell(new,1); new_images_name(1:old) = obj.images_name(:);
    new_images_path = cell(new,1); new_images_path(1:old) = obj.images_path(:);
    new_values = cell(new,prop_length); new_values(1:old,:) = obj.all_values(:,:);
    for i = old+1:new
        new_images_name{i} = t(i).name; new_images_name{i} = new_images_name{i};
        new_images_path{i} = fullfile(obj.images_folder_path,t(i).name);
        img_class = Current_Image_2(new_images_path{i});
        new_values(i,1:2) = {num2str(i),new_images_name{i}};
        new_values(i,3:end) = img_class.get_values(obj.props(:,3:end));
    end
    
    % Flip upside down and update object
    obj.images_name = flipud(new_images_name);
    obj.images_path = flipud(new_images_path);
    obj.all_values = flipud(new_values);
    obj.added_images = added;
end % update_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % methods

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % Data_Handler


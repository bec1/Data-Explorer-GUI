classdef Current_Image
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
properties
    % Initialized by Constructor
    filepath
    filename
    fileext
    analyzed_dir
    analyzed_path
    
    % Get using getters
    raw_data

    % Name/Value Pairs
    names
    values

    % Cropping
    crop_set
    
    % Notes and Hidden
    notes
    hide
end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

methods
%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Current_Image(filepath)
    % Add path for functions
    root_dir = fileparts(pwd);
    addpath(root_dir);
    addpath(fullfile(root_dir,'Snippet-Functions'));

    % Continue only if filepath is provided and exists.            
    if nargin==1 && exist(filepath,'file')
        obj.filepath = filepath;
        [pathstr,obj.filename,obj.fileext] = fileparts(filepath);
        [pathstr,name,~] = fileparts(pathstr);
        obj.analyzed_dir = fullfile(pathstr,[name,'-Analyzed']);
        if ~exist(obj.analyzed_dir,'dir'), mkdir(obj.analyzed_dir); end
        obj.analyzed_path = fullfile(obj.analyzed_dir,[obj.filename,'.mat']);
        if ~exist(obj.analyzed_path,'file'), save(obj.analyzed_path,'filepath'); end
    else
        error('Fatal Error: Incorrect Filepath!');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%% get_image_data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function image_data = get_image_data(obj)
    contents = whos('-file',obj.analyzed_path);
    if ismember('crop_set',{contents.name})
        t = load(obj.analyzed_path,'-mat','crop_set');
        obj.crop_set = t.crop_set;
        image_data = imcrop(obj.raw_data,obj.crop_set);
    else
        image_data = obj.raw_data;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%% get_values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function values = get_values(obj,props)
    total_props = length(props(1,:));
    values = cell(1,total_props);
    % Import Matlab File
    t1 = load(obj.analyzed_path,'-mat');
    % Import snippet parameters
    [t2,~] = GetSnippetValues(obj.filename,props(1,:)); t2 = t2.value;
    for i = 1:total_props
        if props{2,i} % Snippet file
            values{i} = t2{i};
        else % Matlab File
            if isfield(t1,props{1,i})
                values{i} = t1.(props{1,i}); 
            else
                values{i} = '-';
            end
        end
    end
    obj.values = values;
    obj.names = props{1,:};
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Getter and Setter Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = get.raw_data(obj), data = load_img(obj.filepath); end
% Crop Settings
function obj = set.crop_set(obj,crop_set)
    % Validate crop settings
    obj.crop_set = crop_set;
    save(obj.analyzed_path,'crop_set','-append');
end
function crop_set = get.crop_set(obj)
    contents = whos('-file',obj.analyzed_path);
    if ismember('crop_set',{contents.name})
        t = load(obj.analyzed_path,'-mat','crop_set');
        crop_set = t.crop_set;
    else
        crop_set = [NaN NaN NaN NaN];
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % Methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


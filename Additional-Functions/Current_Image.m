classdef Current_Image
    
    properties
        % Initialized by Constructor
        filepath
        filename
        fileext
        analyzed_dir
        analyzed_path
        raw_data
        
        % Name/Value Pairs
        names
        values
        
        % Cropping
        crop_set;
    end
    
    methods
        % Create instance of class for given filepath. Create Matlab Analyzed File.
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
                obj.raw_data = load_img(obj.filepath);
            else
                error('Fatal Error: Incorrect Filepath!');
            end
        end
        
        % Find and output cropped image. If doesn't exist, return raw image.
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
        
        % Get values for provided names
        function values = get_values(obj,names)
            values = GetSnippetValues(obj.filename,names);
            % Check validity of values
            if length(values)~=length(names),values = cellstr(num2str(zeros(size(names))));end
            if ~iscell(values),values=num2cell(values);end
            obj.values = values;
            obj.names = names;
        end
        
        
% %%%%%%%%%%%% Getter and Setter Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
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
        
        
    end
    
end


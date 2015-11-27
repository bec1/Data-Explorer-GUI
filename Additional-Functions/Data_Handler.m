classdef Data_Handler
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
properties
    % Images
    imnames = {}
    impaths = {}
    imtimes = {}
    imvars  = {}
    imnums  = []
    imtotal = 0
    
    % Folders
    imfolder
    datafile
    snipfolder
    
    % Data
    alldata = {}
    
    % Mode
    mode = 0 % 0-read only,  1-write,  2-refresh, reload from snippet
    
end % properties


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
methods

%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = Data_Handler(inputs)
    % Process inputs
    obj.imfolder   = inputs.imfolder;
    obj.datafile   = inputs.datafolder;
    obj.snipfolder = inputs.snipfolder;
    obj.mode       = inputs.mode;
    
    % setup data file
    obj = setup_data(obj);
    
    
    
end % Data_Handler

%%%%%%%%%%%%%%%%%%%%%%%%%% process image %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = process_image(obj)
    
end % processed_image

%%%%%%%%%%%%%%%%%%%%%%%%%% folder scan %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = folder_scan(obj)

end % folder_scan

%%%%%%%%%%%%%%%%%%%%%%%%%% getdata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = getdata(obj)

end % getdata

%%%%%%%%%%%%%%%%%%%%%%%%%% savedata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = savedata(obj)

end % savedata

%%%%%%%%%%%%%%%%%%%%%%%%%% celldata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = celldata(obj)

end % celldata

%%%%%%%%%%%%%%%%%%%%%%%%%% imdata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = imdata(obj)

end % imdata

%%%%%%%%%%%%%%%%%%%%%%%%%% refresh %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = refresh(obj)

end % refresh

%%%%%%%%%%%%%%%%%%%%%%%%%% imrow %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = imrow(obj)

end % imrow

%%%%%%%%%%%%%%%%%%%%%%%%%% setup_data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = setup_data(obj)
    image_folder = obj.imfolder;
    [~,imfolder_name,~] = fileparts(image_folder);
    data_date = datetime(imfolder_name(1:10));
    processed_folder_path = fullfile(obj.datafile,datestr(data_date,'yyyy'),datestr(data_date,'yyyy-mm'),datestr(data_date,'yyyy-mm-dd'));
    processed_file_name = [imfolder_name,'-DataExplorer.mat'];
    obj.datafile = fullfile(processed_folder_path,processed_file_name);
    % Create Matlab storage files
    [~,~,~] = mkdir(processed_folder_path); % This command will NOT overwirte existing files there
    if ~exist(obj.datafile,'file'), save(obj.datafile,'image_folder');
    else save(obj.datafile,'image_folder','-append'); end
    % If data exists, then import it
    
    
end % setup_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Getter & Setter %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % methods

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % Data_Handler


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
    
    
    
    % Temporary
    addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Additional-Functions');
    addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Additional-GUIs');
    addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Snippet-Functions');
    
end % Data_Handler

%%%%%%%%%%%%%%%%%%%%%%%%%% process images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = process_images(obj,ims)
    
end % process_images

%%%%%%%%%%%%%%%%%%%%%%%%%% folder scan %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = folder_scan(obj)
    % Old information that might be needed
    oldim1 = obj.imnames{1};
    
    % Extract list of all files
    listing = dir(fullfile(obj.imfolder,'*.fits'));
    obj.imnames = cellfun( @(x) x(1:end-5), {listing(:).name}', 'UniformOutput', false);
    obj.impaths = cellfun( @(x) fullfile(obj.imfolder,x), {listing(:).name}', 'UniformOutput', false);
    obj.imtimes = cellfun( @(x) datenum(x), obj.imnames, 'UniformOutput', false);
    obj.imvars  = matlab.lang.makeValidName(obj.imnames);
    obj.imtotal = length(obj.imnames);
    
    % Order images, newest time first
    [~,I] = sort(obj.imtimes,'descend');
    obj.imnames = obj.imnames(I);
    obj.impaths = obj.impaths(I);
    obj.imtimes = obj.imtimes(I);
    obj.imvars  = obj.imvars(I);
    
    % Check how many new images are added
    new = length(obj.imnames);
    old = length(obj.imnames);
    added = new - old;
    
    % Process the images depending of the case
    if obj.mode==2 || old==0                         % Refresh or first time -- process all images
        obj = obj.process_images(obj.imnames);
    elseif strcmp(obj.imnames{added+1},oldim1)  % Check that new images are added on top
        obj = obj.process_images(obj.imnames(1:added));
    else                                             % Not sure what happened, process all
        obj = obj.process_images(obj.imnames);
    end
    
    % Store Data
    save(obj.datafile,'-struct','obj','alldata','-append');
    
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
% generate processed data folder -- create .mat file -- if it exists,
% import data from it and save it to obj
function obj = setup_data(obj)
    [~,imfolder_name,~] = fileparts(obj.imfolder);
    data_date = datetime(imfolder_name(1:10));
    processed_folder_path = fullfile(obj.datafile,datestr(data_date,'yyyy'),datestr(data_date,'yyyy-mm'),datestr(data_date,'yyyy-mm-dd'));
    processed_file_name = [imfolder_name,'-DataExplorer.mat'];
    obj.datafile = fullfile(processed_folder_path,processed_file_name);
    % Create Matlab storage files
    image_folder = obj.imfolder;
    [~,~,~] = mkdir(processed_folder_path); % This command will NOT overwirte existing files there
    if ~exist(obj.datafile,'file'), save(obj.datafile,'image_folder');
    else save(obj.datafile,'-struct','image_folder','-append'); end
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


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
    imadded = 0
    
    % Folders
    imfolder
    datafile
    snipfolder
    
    % Data
    alldata = struct();
    
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
    
    % Make sure paths to all the functions are in the search list
    root_dir = fileparts(pwd);
    addpath(root_dir);
    addpath(fullfile(root_dir,'Additional-Functions'));
    addpath(fullfile(root_dir,'Snippet-Functions'));
    addpath(fullfile(root_dir,'Additional-GUIs'));
    addpath(fullfile(root_dir,'Main-GUI'));
    
    % setup data file
    obj = obj.setup_data;
    obj = obj.folder_scan;
    
    
%     % Temporary
%     addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Additional-Functions');
%     addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Additional-GUIs');
%     addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Snippet-Functions');
    
end % Data_Handler

%%%%%%%%%%%%%%%%%%%%%%%%%% process images %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = process_images(obj,imnum)
    % Loop through all ims
    for i = imnum
        if ~isfield(obj.alldata,obj.imvars{i}) || obj.mode==2
            % Setup must have default parameters
            im = struct();
            im.name = obj.imnames{i};
            im.hide = false;
            im.notes = '';
            
            % Extract all data from snippet
            snip = GetSnippetValues(im.name, 'SnippetFolder', obj.snipfolder);
            for j = 1:length(snip.parameter), im.(matlab.lang.makeValidName(snip.parameter{j})) = snip.value{j}; end
            
            % Add all nave value pair to all data
            obj.alldata.(obj.imvars{i}) = im;
        end
    end
end % process_images

%%%%%%%%%%%%%%%%%%%%%%%%%% folder scan %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = folder_scan(obj)
    % Old information that might be needed
    oldim = obj.imnames;
    
    % Extract list of all files
    listing = dir(fullfile(obj.imfolder,'*.fits'));
    obj.imnames = cellfun( @(x) x(1:end-5), {listing(:).name}', 'UniformOutput', false);
    obj.impaths = cellfun( @(x) fullfile(obj.imfolder,x), {listing(:).name}', 'UniformOutput', false);
    obj.imtimes = cellfun( @(x) datenum(x,'mm-dd-yyyy_HH_MM_SS'), obj.imnames, 'UniformOutput', false);
    obj.imvars  = matlab.lang.makeValidName(obj.imnames);
    obj.imtotal = length(obj.imnames);
    
    % Order images, newest time first
    [~,I] = sort([obj.imtimes{:}],'descend');
    obj.imnames = obj.imnames(I);
    obj.impaths = obj.impaths(I);
    obj.imtimes = obj.imtimes(I);
    obj.imvars  = obj.imvars(I);
    obj.imnums  = (obj.imtotal:-1:1)';
    
    % Check how many new images are added
    new = length(obj.imnames);
    old = length(obj.imnames);
    added = new - old;
    
    % Process the images depending of the case
    if obj.mode==2 || old==0                         % Refresh or first time -- process all images
        obj = obj.process_images(1:new);
        obj.imadded = new;
    elseif strcmp(obj.imnames{added+1},oldim)  % Check that new images are added on top
        obj = obj.process_images(1:added);
        obj.imadded = added;
    else                                             % Not sure what happened, process all
        obj = obj.process_images(1:new);
        obj.imadded = new;
    end
    
    % Store Data
    if obj.mode ~= 0
        alldata = obj.alldata;
        save(obj.datafile,'alldata','-append');
    end
end % folder_scan

%%%%%%%%%%%%%%%%%%%%%%%%%% getdata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function vals = getdata(obj,imnum,pnames)
    % Prepare
    pnames = matlab.lang.makeValidName(pnames);
    vals = cell(size(pnames));
    
    % Extract all values for the image
    allvals = obj.alldata.(obj.imvars{imnum});
    
    % Extract vals for pnames
    for i = 1:length(pnames)
        if isfield(allvals,pnames{i}), vals{i} = allvals.(pnames{i});
        else vals{i} = 'NaN'; end
    end
end % getdata

%%%%%%%%%%%%%%%%%%%%%%%%%% savedata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = savedata(obj,imnum,pnames,vals)
    % Prepare
    overwritten = 0;
    pnames = matlab.lang.makeValidName(pnames);
    
    % Add all name/value pairs
    for i = 1:length(pnames)
        if isfield(obj.alldata.(obj.imvars{imnum}),pnames{i}), overwritten = 1; end
        obj.alldata.(obj.imvars{imnum}).(pnames{i}) = vals{i};
    end
    
    % Store Data
    if obj.mode ~= 0
        alldata = obj.alldata;
        save(obj.datafile,'alldata','-append');
    end
end % savedata

%%%%%%%%%%%%%%%%%%%%%%%%%% celldata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hidden = true --> Only output visible images
function [data, imnumshidden] = celldata(obj, pnames, hidden)
    % Prepare
    pnames = matlab.lang.makeValidName(pnames);
    plength = length(pnames);
    data = cell(obj.imtotal,plength);
    imnumshidden = zeros(obj.imtotal,1);
    counter = 0;
    
    % Extract name/value for all images
    for i = 1:obj.imtotal
    if ~hidden || ~obj.alldata.(obj.imvars{i}).hide
        counter = counter + 1;
        allvals = obj.alldata.(obj.imvars{i});
        imnumshidden(counter) = i;
        for j = 1:plength
            if strcmp(pnames{j},'num'), data{counter,j} = obj.imnums(i);
            elseif isfield(allvals,pnames{j}), data{counter,j} = allvals.(pnames{j}); 
            else data{counter,j} = 'NaN'; 
            end
        end
    end
    end
    
    % Resize data
    data = data(1:counter,:);
    imnumshidden = imnumshidden(1:counter);
end % celldata

%%%%%%%%%%%%%%%%%%%%%%%%%% imdata %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = imdata(obj,imnum)
    data = load_img(obj.impaths{imnum});
end % imdata

%%%%%%%%%%%%%%%%%%%%%%%%%% refresh %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Refreshed all data from snippet file ONLY if the mode was not read only
% function obj = refresh(obj)
%     if obj.mode ~= 0
%         obj.mode = 2;
%         obj = obj.folder_scan;
%         obj.mode = 1;
%     end
% end % refresh

%%%%%%%%%%%%%%%%%%%%%%%%%% imrow %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function row = imrow(obj, imname)
%     row = 1;
% end % imrow

%%%%%%%%%%%%%%%%%%%%%%%%%% setup_data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate processed data folder -- create .mat file -- if it exists,
% import data from it and save it to obj
function obj = setup_data(obj)
    % Generate data file name and path
    [~,imfolder_name,~] = fileparts(obj.imfolder);
    data_date = datetime(imfolder_name(1:10));
    processed_folder_path = fullfile(obj.datafile,datestr(data_date,'yyyy'),datestr(data_date,'yyyy-mm'),datestr(data_date,'yyyy-mm-dd'));
    obj.datafile = fullfile(processed_folder_path,[imfolder_name,'-DataExplorer.mat']);
    
    % Create data file if it doesn't exist. If it does, extract data from it.
    [~,~,~] = mkdir(processed_folder_path); % This command will NOT overwirte existing files there
    if ~exist(obj.datafile,'file')
        save(obj.datafile,'imfolder_name');
    else
        contents = load(obj.datafile,'-mat');
        if isfield(contents,'alldata'), obj.alldata = contents.alldata; end
    end
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


%% Creating processed data file and folder
% Assumptions
% Image data is stored in a folder whose name starts with yyyy-mm-dd and
% could have additional information at the end
% Subfolder structure ...\yyyy\yyyy-mm\yyyy-mm-dd\Selected_


% User provides images folder path and processed data path
images_folder_path = 'C:\Users\Elder\Dropbox (MIT)\BEC1\Image Data and Cicero Files\Data - Raw Images\2015\2015-11\2015-11-25';
processed_root_folder_path = 'C:\Users\Elder\Dropbox (MIT)\BEC1\Processed Data';

% Extract other names/paths
[~,images_folder_name,~] = fileparts(images_folder_path);
data_date = datetime(images_folder_name);
processed_folder_path = fullfile(processed_root_folder_path,datestr(data_date,'yyyy'),datestr(data_date,'yyyy-mm'),datestr(data_date,'yyyy-mm-dd'));
processed_file_name = [images_folder_name,'-DataExplorer.mat'];
processed_file_path = fullfile(processed_folder_path,processed_file_name);

% Create Matlab storage files
[~,~,~] = mkdir(processed_folder_path); % This command will NOT overwirte existing files there
if ~exist(processed_file_path,'file'), save(processed_file_path,'images_folder_path'); end


%% Somethign else





function [ old_value ] = write_snippet_string( filename, name, value, varargin )

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Inputs:
%       filename    <--     name of the image
%       name/value  <--     single parameter name/value pair
%       varargin    <--     Not Implemented yet
%
%   Outputs:
%       old_value   -->     If the value was replaced, the old_value
%                           Otherwise, then 'none'
%   Description:
%       Write the analyzed name/value for given filename in analyzed
%       snippet file.
%       It will replace any existing value for given name.
%       New file for each day.
%
%   Last Modified By:
%       Date: 11/21/2015 5:08 PM
%       Parth Patel
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






%%% Analyzed Snippet Location %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Snippet_output Location
snippet_location = get_snippet_location();
% Change to Snippet_analyzed Location
snippet_analyzed = fullfile(fileparts(snippet_location),'Snippet_analyzed');
% Extract date for snippet_name; Assuming format mm-dd-yyyy_HH_MM_ss
file_datenumber = datenum(filename(1:19),'mm-dd-yyyy_HH_MM_SS');
snippet_path = [datestr(file_datenumber,'yyyy-mm-dd'),'-analyzed.txt'];
snippet_path = fullfile(snippet_analyzed,snippet_path);



%%% Go through four possibilities %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if exist(snippet_path)
% Snippet Exists ->
    [timestamps,parameter_string] = ReadSnippetFile(snippet_path);
    [match_vector] = MatchSnippetLine(filename,timestamps,5,5);
    if sum(match_vector)==1
    % -> Image Name Exists ->
        edit_string = parameter_string{find(match_vector)};
        if strfind(edit_string,name)
        % -> Name-Values Exists ::
            start_index = strfind(edit_string,name);
            start_index = start_index + length(name)+1;
            end_index = strfind(edit_string(start_index:end),',');
            end_index = end_index(1)+start_index-2;
            old_value = edit_string(start_index:end_index);
            edit_string = [edit_string(1:start_index-1),value,edit_string(end_index+1:end)];
            parameter_string{find(match_vector)} = edit_string;
        else
        % -> Name-Values Doesnt Exist ::
            old_value = 'none';
            edit_string = [edit_string,name,';',value,','];
            parameter_string{find(match_vector)} = edit_string;
        end
    else
    % -> Image Name Doesnt Exists ::
        old_value = 'none';
        edit_string = [name,';',value,','];
        timestamps(length(timestamps)+1) = datetime(file_datenumber,'ConvertFrom','datenum');
        parameter_string{length(parameter_string)+1} = edit_string;
    end
else
% Snippet Doesnt Exist ::
    old_value = 'none';
    timestamps = datetime(file_datenumber,'ConvertFrom','datenum');
    parameter_string{1} = [name,';',value,','];
end




%%% (over)Write the Analyzed Snippet File %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileID = fopen(snippet_path,'w');
for i=1:length(parameter_string)
    fprintf(fileID,'%s\t%s\n',datestr(timestamps(i),'mm-dd-yyyy_HH_MM_SS'),parameter_string{i});
end
fclose(fileID);



end
function [parameter_value,match_timestamp,error_message] = ...
    GetSnippetValues(img_name,select_parameter)

% This function matches a parameter line of the snippet file (located in
% the directory 'snippet_folder') to a given image (specified by 
% 'img_name') within a time difference of a few seconds.
% The optional input varialble 'select_parameter' can be used to select a
% set of parameters for the output variable 'parameter_value'. If
% select_parameter is not specified all available parameters will be
% included in the output variable. Furthermore the optional input variable
% 'snippet_filepath' can be used to specify a non-default filepath for the
% snippet file.
%
% Input variables are of the following type: 
% string: img_name, snippet_filepath
% cell string: select_parameter
%
% Output variables are of the type:
% cell string: parameter_value
% string: snippet_timestamp, error_message


% get corresponding snippet string
[match_snippet_line,match_timestamp,error_message] = GetSnippetString(img_name);

% initialze output parameter
parameter_value = NaN(size(select_parameter));

%%% Extracting the parameters for the matched snippet line
if strcmp(error_message,'no error') % match successful
    
    % Regular expression to pick the values for the selected parameters.
    % Picks: after <parameter> and semicolon the stuff in parantheses(
    % optional +or- then [digits(1+).digits(1+)] or [digits(1+)]) before comma
    %suffix_exp = ';([-+]?\d+\.\d+|\d+),';
    suffix_exp='\;(.*?)\,';
    select_parameter_expression = strcat(select_parameter,suffix_exp);
    parameter_value = regexp(match_snippet_line,select_parameter_expression,'tokens','once');
    
    % regexp outputs nested cells for the existing expression and empty cells
    % for the non-existing expression. The empty cells are converted into
    % 'NaN' nested cells and afterwards everything is flattened out 
    non_existing_parameter = cellfun('isempty',parameter_value);
    parameter_value(non_existing_parameter) = {{'NaN'}};
    parameter_value=[parameter_value{:}];
    
    %convert cell entries from strings to numbers
    %parameter_value = cellfun(@str2num,parameter_value);
    
    if sum(non_existing_parameter)>0
        
        missing_parameters_string = strjoin(select_parameter(non_existing_parameter),', ');
        error_message=strcat('The following parameters do not exist: ',missing_parameters_string);
        
    end
    
end


end

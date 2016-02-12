%% List of images
DATA.paths = {};
DATA.len = length(DATA.paths);

%% Define BGR and ROI rects
BGR.rect = []; % Region for BG [xmin ymin width height]
ROI.rect = []; % Region of interest for atom counting

%% Import data, Correct for BG, Calculate Atom No.
for i = 1:DATA.len
    % Import data
    [~,imdata] = load_img(DATA.paths{i}); % {OD, fOD, WA, WOA, Dark}
    imdata{3} = imdata{3} - imdata{5};
    imdata{4} = imdata{4} - imdata{5};
    
    % Background correction
    
    % Calculate atom numbers
    
    
    
end

%% Clean up
clearvars i imdata
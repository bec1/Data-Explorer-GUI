%% Housekeeping
addpath('/Users/RanchoP/Documents/Data-Explorer-GUI/Additional-Functions');

%% List of images
% % DATA.paths = {};
% % 
DATA.len = length(DATA.paths);
DATA.ODr = DATA.paths;
DATA.ODc = DATA.paths;
DATA.atoms = zeros(DATA.len);
DATA.avgDI = zeros(DATA.len);
% % for i=1:DATA.len, DATA.paths{i} = fullfile('/Users/RanchoP/Desktop/2016-02-11',[DATA.paths{i},'.fits']); end
% % 
PLOT1.x = [];
PLOT1.y = [];
% % 
%CONST.Isat = 481.1; %481.1
 CONST.Isat = inf;

%% First time only -- Display Image for ROI
imdata = load_img(DATA.paths{10});
imshow(imdata,[0 2]);

%% Define BGR and ROI rects
BGR.rect = []; % Region for BG [xmin ymin width height]
ROI.rect = [253,207,30,2]; % Region of interest for atom counting

%% Import data, Correct for BG, Calculate Atom No.
for i = 1:DATA.len
%for i = 5:6
    % Import data
    [~,imdata] = load_img(DATA.paths{i}); % {OD, fOD, WA, WOA, Dark}
    If = imdata{3} - imdata{5};
    Ii = imdata{4} - imdata{5};
    DI = Ii - If;
    
    % Background correction    
    
    % Calculate atom numbers
    If = imcrop(If,ROI.rect);
    Ii = imcrop(Ii,ROI.rect);
    DI = Ii - If;
    DATA.ODc{i} = log(Ii ./ If);
    DATA.ODr{i} = log(Ii ./ If) + DI / CONST.Isat;
    DATA.atoms(i) = sum(reshape(DATA.ODr{i},[],1));
    DATA.avgDI(i) = sum(reshape(DI,[],1));
    
    % Plotting data
    PLOT1.x = [PLOT1.x;reshape(DI,[],1)];
    PLOT1.y = [PLOT1.y;reshape(DATA.ODc{i},[],1)];
end

%% Plots
figure;
% ODc vs DI from all images
% plot(PLOT1.x,PLOT1.y,'.')
plot(DATA.avgDI,DATA.atoms,'*')

%% Clean up
clearvars i imdata If Ii DI ans
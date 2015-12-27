classdef ImageViewer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% PROPERTIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

properties
    % Initialized by Constructor
    xhand
    imdata
    cropset
    
    % Setup Setter Functions
    path
    type = 1     % 1:OD, 2:fOD, 3:WA, 4:WoA, 5:Dark
    OD = [0 1.5]    % [Min Max]
    
    % Marking
    markpts = []
    
    % ROI Cropping
    ROIset
    ROIshow
end % Properties


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

methods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = ImageViewer(varargin)
    % Process Inputs
    obj.xhand = varargin{1};
    
    % Load default image
    obj.imdata{1} = checkerboard(16,16,16); for i = 2:5, obj.imdata{i} = obj.imdata{1}; end
    
    % Display Image
    imshow(obj.imdata{1},'Parent',obj.xhand);
    
end % Conctructor

%%%%%%%%%%%%%%%%%%%%%%%%%% Set path    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = set.path(obj,path)
    % Get new path
    obj.path = path;
    
    % Load the image and display it in proper way
    [~,obj.imdata] = load_img(obj.path);
    imshow_zoom(obj);
    
end % path setter

%%%%%%%%%%%%%%%%%%%%%%%%%% Set type    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = set.type(obj,type)
    % Categorize
    switch type
        case 'OD'   , obj.type = 1;
        case 'fOD'  , obj.type = 2;
        case 'WA'   , obj.type = 3;
        case 'WoA'  , obj.type = 4;
        case 'Dark' , obj.type = 5;
    end
    
    % Update Plot
    imshow_zoom(obj);
    
end % type setter

%%%%%%%%%%%%%%%%%%%%%%%%%% Set OD      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = set.OD(obj,OD)
    % Get new OD and validate it
    obj.OD = OD;
    
    % Update Image
    imshow_zoom(obj);
    
end % OD setter

%%%%%%%%%%%%%%%%%%%%%%%%%% Set markpts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = set.markpts(obj,pts)
    % Get and validate pts
    obj.markpts = pts;

    % Update Image
    imshow_zoom(obj);
    
end % markpts setter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imshow_zoom(obj)
    % Prepare
    plotdata = obj.imdata{obj.type};
    maxOD = max(plotdata(:)); if maxOD <= 5, maxOD = 5; end
    switch obj.type
        case 1, plotOD = obj.OD;
        case 2, plotOD = [0 1.5];
        case 3, plotOD = [0 maxOD];
        case 4, plotOD = [0 maxOD];
        case 5, plotOD = [0 maxOD];
    end
        
    L = get(obj.xhand,{'xlim','ylim'});
    
    % Draw the mark
    for i = 1:size(obj.markpts,1), plotdata(obj.markpts(i,2),obj.markpts(i,1)) = 2*maxOD; end
    
    % Make plots
    axes(obj.xhand);
    imshow(plotdata, plotOD);
    zoom reset; set(obj.xhand,{'xlim','ylim'},L);
    set(obj.xhand,'YDir','normal') ;
    
end % imshow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % methods


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % class


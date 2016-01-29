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
    xX
    xY
    
    % Setup Setter Functions
    path
    type = 1     % 1:OD, 2:fOD, 3:WA, 4:WoA, 5:Dark
    OD = [0 1.5]    % [Min Max]
    xSliceCenter = 11
    ySliceCenter = 11
    xSliceWidth = 5
    ySliceWidth = 5
    
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
    obj.xX = varargin{2};
    obj.xY = varargin{3};
    
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

%%%%%%%%%%%%%%%%%%%%%%%%%% Set Slice Info %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = set.xSliceCenter(obj,num)
    obj.xSliceCenter = num; imshow_zoom(obj);
end
function obj = set.ySliceCenter(obj,num)
    obj.ySliceCenter = num; imshow_zoom(obj);
end
function obj = set.xSliceWidth(obj,num)
    obj.xSliceWidth = num; imshow_zoom(obj);
end
function obj = set.ySliceWidth(obj,num)
    obj.ySliceWidth = num; imshow_zoom(obj);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imshow_zoom(obj)
    % Prepare
    plotdata = obj.imdata{obj.type};
    maxOD = max(plotdata(:)); if maxOD <= 5, maxOD = 5; end
    switch obj.type
        case 1, plotOD = obj.OD;
        case 2, plotOD = [0 1.2];
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
    
    %%%%%%%%%%%%%%%%%%%
    % Prepare
    data = obj.imdata{obj.type};
    ytot = size(data,1);
    xtot = size(data,2);
    xlim = fix(L{1}); ylim = fix(L{2}); 
    if xlim(1)<1, xlim(1) = 1; end; if ylim(1)<1, ylim(1)=1; end
    if xlim(2)>xtot, xlim(2)=xtot; end; if ylim(2)>ytot, ylim(2)=ytot; end
    xsc = fix(obj.xSliceCenter*(xlim(2)-xlim(1)) + xlim(1));
    ysc = fix(obj.ySliceCenter*(ylim(2)-ylim(1)) + ylim(1));
    xsw = obj.xSliceWidth;
    ysw = obj.ySliceWidth;

    if xsc-xsw < 1, xsc = xsw+1; elseif xsc+xsw > xtot, xsc = xtot-xsw; end
    if ysc-ysw < 1, ysc = ysw+1; elseif ysc+ysw > ytot, ysc = ytot-ysw; end
    
    % Get xslice data
    xs = mean(data(ylim(1):ylim(2),xsc-xsw:xsc+xsw),2);
    ys = mean(data(ysc-ysw:ysc+ysw,xlim(1):xlim(2)),1);
    
    % Plot
    axes(obj.xX); plot(ylim(1):ylim(2),xs,'black');
    axes(obj.xY); plot(xlim(1):xlim(2),ys,'black');
    
end % imshow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % methods


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end % class


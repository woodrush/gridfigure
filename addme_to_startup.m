% By executing the code below, you can let figure windows automatically appear in grid style without any commands:
    set(0,'defaultfigurecreatefcn',@(varargin) gfigure('tail','nofocus',varargin{1}));
% By writing this code in startup.m, figrues will appear in grid style on startup of MATLAB.
% (see http://www.mathworks.com/help/matlab/ref/startup.html for details on startup.m)
% The above code alters the 'defaultfigurecreatefcn' property of 'figure'
% so that the 3rd argument is always called on figure window creation (this feature is currently undocumented).

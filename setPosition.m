function setPosition(varargin)
    % function SETPOSITION(varargin)
    %
    % Method for organizing figure windows.
    % To be called from 'sfigure' (see 'help sfigure').
    % This method could be called either for organizing the figure or to change the settings for organizing them.
    % 
    % SETPOSITION(numPos, figNum)       Places figure(figNum) at index no. numPos
    % SETPOSITION('figsize',[560,420])  Setting modification: change figure size
    % SETPOSITION('orientation',true)   Setting modification: organize left to right
    % SETPOSITION('orientation',false)  Setting modification: organize up to down
    % 
    % Default settings could be changed in the m-file for this function (edit SETPOSITION).

    % Authors
    % T. Sugimoto, H. Ikuta
    % 
    % Update History
    % 2014/12/03 v1.0 - Initial Release

    %======================================================================
    % Settings
    %======================================================================
    % Default figure size
    defaultFigsize = [400, 300];
    % default orientation (true: left to right, false: up to down) 
    defaultOrientation = 'row'; % 'col';
    % Order of displays to show figures on
    % The main display is index no. 1, and the subdisplays are indices no. 2, 3, ...
    useDispNoArray = [2 1 3:10];
    % Left Margin
    marginLeft = 16;
    % Top Margin
    marginTop = 95;
    %======================================================================
    % Internal States
    %======================================================================
    persistent figsize
    persistent orientation
    if isempty(figsize)
        figsize = defaultFigsize;
    end
    if isempty(orientation)
        orientation = defaultOrientation;
    end

    %======================================================================
    % Argument handling
    %======================================================================
    args = varargin(:);
    %======================================================================
    % Case: When called for setting modification
    %======================================================================
    if ~isnumeric(args{1})
        for ind = [1 3]
            try
	        	switch args{ind}
		        	case 'figsize'
		        		figsize = args{ind+1};
		        	case 'orientation'
		        		orientation = args{ind+1};
	        	end
	        end
	    end
    %======================================================================
    % Case: When called for figure positioning
    %======================================================================
    elseif isnumeric(args{1}) && isnumeric(args{2})
        numPos = args{1};
        figNum = args{2};
        figure_width = figsize(1);
        figure_height = figsize(2);

        % First row indicates the size of main display, other rows indicate sizes of subdisplays
        dispInfo = get(0,'MonitorPosition');
        % Num of displays
        dispNo = size(dispInfo, 1);
        % Find valid displays and sort them according to the settings
        useDispNoArray = useDispNoArray(useDispNoArray <= dispNo);
        dispInfo = dispInfo(useDispNoArray, :);

        % Screen size of main disp.
        mainScreenSize = get(0,'ScreenSize');
        for i = 1:dispNo
            ScreenSize = dispInfo(i, :);
            % Values:
            % [topleft.x topleft.y bottomright.x bottomright.y]
            screenWidth = ScreenSize(3) - ScreenSize(1);
            screenHeight = ScreenSize(4) - ScreenSize(2);
            hLength = marginLeft + figure_width;
            vLength = marginTop + figure_height;
            % Rows
            rowMax = floor(screenWidth / hLength);
            % Columngs
            colMax = floor(screenHeight / vLength);
            if numPos > rowMax * colMax
                numPos = numPos - rowMax * colMax;
                % Set Topleft to same position and change size
                pos = get(figNum, 'Position');
                set(figNum,'Position',[pos(1), pos(2) + pos(4) - figure_height, figure_width, figure_height]);
                continue
            end
            % row (counting from 0)
            row = mod(numPos - 1, rowMax);
            % column (counting from 0)
            col = ceil(numPos / rowMax);
            if strcmp(orientation,'col')
                % Organize from left to right
                % column (counting from 1)
                col = mod(numPos - 1, colMax) + 1;
                % row (counting from 1)
                row = ceil(numPos / colMax) - 1;
            else
                % Organize from up to down
                % row (counting from 0)
                row = mod(numPos - 1, rowMax);
                % column(counting from 1)
                col = ceil(numPos / rowMax);
            end
            % Specify [left, bottom, width, height]
            left = ScreenSize(1) + marginLeft + hLength * row;
            bottom = mainScreenSize(4) - ScreenSize(2) - vLength * col;
            set(figNum,'Position',[left, bottom, figure_width, figure_height]);
            return
        end        
    else
        error('Invalid arguments to setPosition');
    end        
end

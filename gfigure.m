% set(0,'defaultfigurecreatefcn',@(varargin) gfigure('atend',varargin{1}));
function ret = gfigure(varargin)
    %======================================================================
    % Settings
    %======================================================================
    % Default figure size
    defaultFigsize = [400, 300];
    % default orientation (true: left to right, false: up to down) 
    defaultOrientation = 'row'; % 'col';
    % Order of displays to show figures on
    % The main display is index no. 1, and the subdisplays are indices no. 2, 3, ...
    defaultDispPriority = [2 1 3:10];
    % Left Margin
    marginLeft = 16;
    % Top Margin
    marginTop = 95;
    %======================================================================
    persistent figsize
    persistent orientation
    persistent dispPriority
    if isempty(figsize)
        figsize = defaultFigsize;
    end
    if isempty(orientation)
        orientation = defaultOrientation;
    end
    if isempty(dispPriority)
        dispPriority = defaultDispPriority;
    end
    %======================================================================
	args = parseInputs(varargin);
	if isfield(args,'figsize')
		figsize = args.figsize;
	end
	if isfield(args,'orientation')
		orientation = args.orientation;
	end
	if isfield(args,'dispPriority')
	    dispPriority = args.dispPriority;
	end
    dispArray = 1:size(get(0,'MonitorPosition'),1);
    for dp = dispPriority
    	if dp <= max(dispArray)
    		dispArray(find(dispArray == dp)) = [];
    	else
    		dispPriority(find(dispPriority == dp)) = [];
    	end
    end
    dispPriority = [dispPriority dispArray];
    dispInfo = get(0,'MonitorPosition');
    dispInfo = dispInfo(dispPriority,:)';
    % dispInds = zeros(2,length(dispPriority));
    % for ind = 1:size(2,dispInfo)
    % 	screenSize = dispInfo(:,ind)
    %     screenWidth = screenSize(3) - screenSize(1);
    %     screenHeight = screenSize(4) - screenSize(2);
    %     hLength = marginLeft + figureWidth;
    %     vLength = marginTop + figureHeight;
    %     rowMax = floor(screenWidth / hLength);
    %     colMax = floor(screenHeight / vLength);
    %     dispInds(:,ind) = [rowMax, colMax];
    % end

	if isfield(args,'fighandles')
		for ind = 1:length(args.fighandles)
			figure(args.fighandles(ind));
			numPos = ind;
			if isfield(args,'atend')
				numPos = numPos + length(get(0,'Children')) - 1;
			end
			figure(args.fighandles(ind));
			numPos = ind;
			if isfield(args,'atend')
				numPos = numPos + length(get(0,'Children')) - 1;
			end
			figNum = args.fighandles(ind);
		    figureWidth = figsize(1);
		    figureHeight = figsize(2);
		    mainscreenSize = get(0,'screenSize');
		    for screenSize = dispInfo
		        screenWidth = screenSize(3) - screenSize(1);
		        screenHeight = screenSize(4) - screenSize(2);
		        hLength = marginLeft + figureWidth;
		        vLength = marginTop + figureHeight;
		        rowMax = floor(screenWidth / hLength);
		        colMax = floor(screenHeight / vLength);
		        if numPos > rowMax * colMax
		            numPos = numPos - rowMax * colMax;
		            pos = get(figNum, 'Position');
		            set(figNum,'Position',[pos(1), pos(2) + pos(4) - figureHeight, figureWidth, figureHeight]);
		        else
			        row = mod(numPos - 1, rowMax);
			        col = ceil(numPos / rowMax);
			        if strcmp(orientation,'col')
			            col = mod(numPos - 1, colMax) + 1;
			            row = ceil(numPos / colMax) - 1;
			        else
			            row = mod(numPos - 1, rowMax);
			            col = ceil(numPos / rowMax);
			        end
			        left = screenSize(1) + marginLeft + hLength * row;
			        bottom = mainscreenSize(4) - screenSize(2) - vLength * col;
			        set(figNum,'Position',[left, bottom, figureWidth, figureHeight]);
			        break
			    end
		    end
		end
	end
end
function args = parseInputs(inArgs)
	args = struct('fighandles',sort(get(0, 'Children')));
	ind = 1;
	while ind <= length(inArgs)
		% If 3 consecutive arguments (starting from current) are numerics of length 1
		if isNumericArg(inArgs{ind}) && (length(inArgs) - ind) >= 2 && isNumericArg(inArgs{ind+1}) && isNumericArg(inArgs{ind+2}) ...
			   && isscalar(evalNumericArg(inArgs{ind})) && isscalar(evalNumericArg(inArgs{ind+1})) && isscalar(evalNumericArg(inArgs{ind+2}))
            warning('gfigure:warning', ['Ambiguous call to gfigure: parsing smallest and left/rightmost integer argument as figure handle']);
			indexIsThirdArg = (evalNumericArg(inArgs{ind}) > evalNumericArg(inArgs{ind+2})) + 0;
			args.fighandles = evalNumericArg(inArgs{ind+2*indexIsThirdArg});
			args.figsize = [evalNumericArg(inArgs{ind+1*(1-indexIsThirdArg)}), evalNumericArg(inArgs{ind+1+1*(1-indexIsThirdArg)})];
			ind = ind + 2;
		% If 2 consecutive arguments (starting from current) are numerics of length 1
		elseif isNumericArg(inArgs{ind}) && (length(inArgs) - ind) >= 1 && isNumericArg(inArgs{ind+1}) ...
			   && isscalar(evalNumericArg(inArgs{ind})) && isscalar(evalNumericArg(inArgs{ind+1}))
			args.figsize = [evalNumericArg(inArgs{ind}), evalNumericArg(inArgs{ind+1})];
			ind = ind + 1;
		% If argument is numeric
		elseif isNumericArg(inArgs{ind}) && ~isempty(evalNumericArg(inArgs{ind}))
			args.fighandles = evalNumericArg(inArgs{ind});
		% If argument is not a numeric
		elseif ~isNumericArg(inArgs{ind})
			switch lower(inArgs{ind})
				case 'row'
					args.orientation = 'row';
				case 'col'
					args.orientation = 'col';
				case 'atend'
					args.atend = true;
				case 'disp'
					if (length(inArgs) - ind) >= 1 && isNumericArg(inArgs{ind+1})
						args.dispPriority = evalNumericArg(inArgs{ind+1});
						ind = ind + 1;
					end
			end
		end
		ind = ind + 1;
	end
end
function ret = evalNumericArg(arg)
	if isnumeric(arg)
		ret = arg;
	elseif ~isempty(regexp(arg,'^\d+ *: *\d+$','once'))
		C = textscan(arg, '%s', 'delimiter', ':');
		ret = str2double(C{1}{1}):str2double(C{1}{2});
	elseif ~isempty(regexp(arg,'^ *\d+ *$','once'))
		ret = str2double(arg);
	else
		ret = arg;
	end
end
function ret = isNumericArg(arg)
	ret = isnumeric(evalNumericArg(arg));
end
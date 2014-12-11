function ret = gfigure(varargin)
	args = parseInputs(varargin);
	if isfield(args,'figsize')
		setPosition('figsize',args.figsize);
	end
	if isfield(args,'orientation')
		setPosition('orientation',args.orientation);
	end
	if isfield(args,'fighandles')
		for ind = 1:length(args.fighandles)
			figure(args.fighandles(ind));
			setPosition(ind,args.fighandles(ind));
		end
	end
end
function args = parseInputs(inArgs)
	args = struct('fighandles',sort(get(0, 'Children')));
	ind = 1;
	while ind <= length(inArgs)
		% If argument is not a numeric
		if ~isNumericArg(inArgs{ind})
			switch lower(inArgs{ind})
				case 'row'
					args.orientation = 'row';
				case 'col'
					args.orientation = 'col';
			end
		% If 3 consecutive arguments (starting from current) are numerics of length 1
		elseif isNumericArg(inArgs{ind}) && (length(inArgs) - ind) >= 2 && isNumericArg(inArgs{ind+1}) && isNumericArg(inArgs{ind+2}) ...
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
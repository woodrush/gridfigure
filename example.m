% Show figures
for ind = 1:10
	figure;
	peaks;
end

% Organize figures
gfigure

% Organize specified figures
gfigure 1:10
gfigure 5:10

% Multiscreen, composite calls
gfigure disp 2 400 300

% Organize column-wise
gfigure col
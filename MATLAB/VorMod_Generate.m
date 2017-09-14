% Generates additional variables for the voronoi model
% Run this to generate field, resources, and other variables

%% Generate Control
if ~exist('ctrl_gen_fig_LNSurf', 'var')
    ctrl_gen_fig_LNSurf = true;     % Surf figure for LN field
end
if ~exist('ctrl_gen_fig_LNSurfOver', 'var')
    ctrl_gen_fig_LNSurfOver = true; % Overhead surf figure for LN field
end
if ~exist('ctrl_gen_dat_BSLoc', 'var')
    ctrl_gen_dat_BSLoc = 1;         % Determines BS location gen method
	% 0 - Place BS in grid centered over field
	% 1 - Place BS in PPP; old method
	% 2 - Place BS in nsPPP; same as demand points
end
if ~exist('ctrl_gen_fig_BSScat', 'var')
    ctrl_gen_fig_BSScat = true;     % Scatter figure for BS locations
end
if ~exist('ctrl_gen_fig_BSVor', 'var')
    ctrl_gen_fig_BSVor = true;      % Voronoi figure for BS locations
end
if ~exist('ctrl_gen_fig_PPPDem', 'var')
    ctrl_gen_fig_PPPDem = true;     % Scatter figure for PPP demand points
end

%% Start Generate Timer
cput_start = cputime;
tic;

%% Generate Log-Normal Field
field = lnfield(omega, L, cols, rows, loc, sca);
if ctrl_gen_fig_LNSurf
    figure(1)
    hold off
    surf(field.field, 'linestyle', 'none')
end
if ctrl_gen_fig_LNSurfOver
    figure(2)
    hold off
    surf(field.field, 'linestyle', 'none')
    view(0, 90)
end
drawnow

demand = sum(sum(field.field)) * scale * pix_dist^2 / num_points * ones(num_points, 1);

%% Generate BS Locations
switch ctrl_gen_dat_BSLoc
    case 0
        % BS locations as a grid
        dist = ceil(sqrt(num_BS));
        num_BS = dist^2;
        BS = HilbertCurve([kron(((1:dist)' - 0.5) * cols / dist, ones(dist, 1)), ...
            repmat(((1:dist)' - 0.5) * rows / dist, dist, 1)], [0 cols], [0 rows]);
    case 1
        % BS locations as PPP
        BS = HilbertCurve([cols*rand([num_BS, 1]), ...
            rows*rand([num_BS, 1])], [0 cols], [0 rows]);
    case 2
        % BS locations as nsPPP (demand field)
        BS = HilbertCurve(cell2mat(field.nsPPP(1, num_BS, 1)), [0 cols], [0 rows]);
    otherwise
        error('Incorrect BS Location Generation Control; Exiting\n')
end
if ctrl_gen_fig_BSScat
    figure(3)
    hold off
    scatter(BS(:, 1), BS(:, 2), '.')
    axis([0 cols 0 rows])
end
if ctrl_gen_fig_BSVor
    figure(4)
    hold off
    voronoi(BS(:, 1), BS(:, 2));
    axis([0 cols 0 rows])
end
drawnow

%% Generate Distances
dists = zeros(rows, cols, num_BS);
for r = 1:rows
    for c = 1:cols
        dists(r, c, :) = pix_dist * ...
            sqrt((BS(:, 1) - c) .^ 2 + (BS(:, 2) - r) .^ 2);
    end
end

%% Generate Additional Data; Optimization Model
% determine u[m][s][o]
PPP_real = field.nsPPP(1, num_points, num_real);
u = zeros(num_points, num_BS, num_real);
for s = 1:num_BS
    for o = 1:num_real
        u(:, s, o) = sqrt(  ...
            (PPP_real{o}(:, 1) - BS(s, 1)).^2 + ...
            (PPP_real{o}(:, 2) - BS(s, 2)).^2);
    end
end
u(u > BS_rng / pix_dist) = 0;
u(u ~= 0) = 1;

if ctrl_gen_fig_PPPDem
    figure(5)
    hold off
    scatter(PPP_real{1}(:, 1), PPP_real{1}(:, 2), '.');
    hold on
    for r = 2:num_real
        scatter(PPP_real{r}(:, 1), PPP_real{r}(:, 2), '.');
    end
    hold off
end
drawnow

%% Report Generate Timer
cput = cputime - cput_start;
toc;
fprintf('CPU time for "Generate" is %1.6f seconds\n', cput);
% Reruns the GA with a new BS allocation without changing the demand field

%% Control Parameters
% Reset timestamp
newBS_timestamp = datestr(now, 30);
newBS_path = [newBS_timestamp '_' num2str(ctrl_gen_dat_BSLoc, '%01u') '_' ...
    timestamp];
mkdir('C++ Vormod\Results', newBS_path)
save(['C++ Vormod\Results\' newBS_path '\_Old.mat'])

% Controls the BS allocation
ctrl_gen_dat_BSLoc = 2;

%% Model Startup - Generate
% Generate BS Locations
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
        BS = HilbertCurve(cell2mat(field.nsPPP(1, num_BS, 1)), ...
            [0 cols], [0 rows]);
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

% Generate Distances
dists = zeros(rows, cols, num_BS);
for r = 1:rows
    for c = 1:cols
        dists(r, c, :) = pix_dist * ...
            sqrt((BS(:, 1) - c) .^ 2 + (BS(:, 2) - r) .^ 2);
    end
end

% Generate u
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

if ctrl_mas_log_gen
    save(['C++ Vormod\Results\' newBS_path '\_Gen.mat'])
end

%% Model Startup - AllOn
VorMod_AllOn
if ctrl_mas_log_all
    save(['C++ Vormod\Results\' newBS_path '\_AllOn.mat'])
end

%% Model GA
beta_trk_fit = cell(betarng, 1);
beta_trk_mem = cell(betarng, 1);
beta_cnt = cell(betarng, 1);
beta_x = cell(betarng, 1);
beta_time = cell(betarng, 1);
if ctrl_mas_log_ga
    log_form = ['%0' num2str(ceil(log10(betarng + 1))) 'u'];
end

for iter = 1:betarng
    % Run GA Script, needs betaval (or defaults to betaval = 1)
    betaval = beta(iter);
    VorMod_GenAlg
    
    % Save
    beta_trk_fit{iter} = trk_fit;
    beta_trk_mem{iter} = trk_mem;
    beta_cnt{iter} = [fit_cnt, mem_cnt];
    beta_x{iter} = x_appx;
    beta_time{iter} = cput;
    if ctrl_mas_log_ga
        save(['C++ Vormod\Results\' newBS_path '\_GA' num2str(iter, log_form) '.mat'])
    end
end

%% Model Wrapup Scripts
VorMod_WriteDataNewBS               % Write Data to Files

%% Save Workspace
if ctrl_mas_log_final
    save(['C++ Vormod\Results\' newBS_path '\_Final.mat'])
end

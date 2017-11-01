% Runs the genetic algorithm a single time using given workspace data
% Uses betaval to weight the field for the algorithm (set it prior to being
% run)

%% GA Data Control
if ~exist('ctrl_ga_fig_vor', 'var')
    ctrl_ga_fig_vor = true;         % Voronoi figure for fittest member
end
if ~exist('ctrl_ga_fig_grad', 'var')
    ctrl_ga_fig_grad = true;        % Voronoi gradient figure for fit mem
end
if ~exist('ctrl_ga_dat_xover', 'var')
	ctrl_ga_dat_xover = 1;			% Crossover method control
	% 0 - Uniform crossover w/50% mixing ratio
	% n>0 - n-point crossover
end
if ~exist('betaval', 'var')
    betaval = 1;                    % GA weight for under/over-allocating
end

%% Start GA Timer
cput_start = cputime;
tic;

%% Derive Initial Members
% Boolean string w/Guaranteed Uniqueness
a = 1;
mems = zeros(num_mems, num_BS);
while a <= num_mems
    tmp = randi(2, 1, num_BS) - 1;
    if ~ismember(tmp, mems(1:a-1, :), 'rows')
        mems(a, :) = tmp;
        a = a + 1;
    end
end

% Calculate Fitness
fit = zeros(num_mems, 1);
for a = 1:num_mems
    dist_scen = dists(:, :, logical(mems(a, :)));
    BS_ind = find(mems(a, :));
    [dist_min, dist_ind] = min(dist_scen, [], 3);
    BS_load = zeros(num_BS, 1);
    for r = 1:rows
        for c = 1:cols
            BS_load(BS_ind(dist_ind(r, c))) =   ...
                BS_load(BS_ind(dist_ind(r, c))) +   ...
                betaval * scale * pix_dist^2 * Field.field(r, c);
        end
    end
    
    fit(a) = 1 / (  ...
        sum(mems(a, :)) +   ...
        fit_rng_cost * sum(sum(dist_min > BS_rng - sqrt(2)/2 * pix_dist)));
end

%% Perform Genetic Algorithm
prev_fit = 0;
fit_cnt = 0;
prev_mem = 0;
mem_cnt = 0;
trk_fit = [];
trk_mem = [];
for gen = 1:max_gen
    fprintf('\nProcessing Generation: %d (%d/%d)\nBeta: %1.3f/%1.3f\n', gen, min_gen, max_gen, betaval, betamax);
    mems_tmp = zeros(num_mems, num_BS);
    
    % Elitism - fittest num_elite mems auto enter next gen
    [mems_sort, mems_ind] = sort(fit, 'descend');
    mems_tmp(1:num_elite, :) = mems(mems_ind(1:num_elite), :);
    trk_fit = [trk_fit; mems_sort(1)];
    trk_mem = [trk_mem; sum(mems(mems_ind(1), :), 1)];
    
    % Standard Genetic Algorithm; Selection, Crossover, Mutation
    for a = 2:num_mems
        fit(a) = fit(a) + fit(a - 1);
    end
    
    a = num_elite + 1;
    while a <= num_mems
        % Selection; Select two members of previous generation randomly
            % weighted via roulette method; fittest members most likely
        select = fit(end) * rand(1, 2);
        sel_ind_1 = find(fit == min(fit(fit >= select(1))));
        sel_ind_2 = find(fit == min(fit(fit >= select(2))));
		
		% Crossover; With rate x_rate, perform crossover as directed
			% From two new members, each with parts of the selected
			% parents
			% ctrl_ga_dat_xover = n > 0 => n-point crossover
			% ctrl_ga_dat_xover = 0 => uniform crossover w/50% mix rat
		if rand(1) < x_rate
            if ctrl_ga_dat_xover > 0
				[mem1, mem2] = nPoint_Crossover(mems(sel_ind_1, :), ...
					mems(sel_ind_2, :), ctrl_ga_dat_xover);
			elseif ctrl_ga_dat_xover == 0
				for b = 1:num_BS
					if rand(1) > 0.5
						mem1(b) = mems(sel_ind_1, b);
						mem2(b) = mems(sel_ind_2, b);
					else
						mem1(b) = mems(sel_ind_2, b);
						mem2(b) = mems(sel_ind_1, b);
					end
				end
			else
				error('Incorrect Xover Control; Exiting\n')
            end
        else
            mem1 = mems(sel_ind_1, :);
            mem2 = mems(sel_ind_2, :);
		end
        
        % Mutation; Scan through chromosome, bit by bit
            % With rate mut_rate, the viewed bit flips
        for b = 1:num_BS
            if rand(1) < mut_rate
                mem1(b) = ~mem1(b);
            end
            if rand(2) < mut_rate
                mem2(b) = ~mem2(b);
            end
        end
        
        % Uniqueness; If mem1/mem2 are unique wrt mems_tmp (not equivalent
            % to a member currently in mems_tmp), add mem1/mem2 to mems_tmp
        if ~ismember(mem1, mems_tmp(1:a-1, :), 'rows')
            mems_tmp(a, :) = mem1;
            a = a + 1;
        end
        if a <= num_mems
            if ~ismember(mem2, mems_tmp(1:a-1, :), 'rows')
                mems_tmp(a, :) = mem2;
                a = a + 1;
            end
        end
    end
    mems = mems_tmp;
    
    % Calculate Fitness
    fit = zeros(num_mems, 1);
    for a = 1:num_mems
        dist_scen = dists(:, :, logical(mems(a, :)));
        BS_ind = find(mems(a, :));
        [dist_min, dist_ind] = min(dist_scen, [], 3);
        BS_load = zeros(num_BS, 1);
        for r = 1:rows
            for c = 1:cols
                BS_load(BS_ind(dist_ind(r, c))) =   ...
                    BS_load(BS_ind(dist_ind(r, c))) +   ...
                    betaval * scale * pix_dist^2 * Field.field(r, c);
            end
        end
        
        fit(a) = 1 / (  ...
            sum(mems(a, :)) +   ...
            fit_rng_cost * sum(sum(dist_min > BS_rng - sqrt(2)/2 * pix_dist)) + ...
            ((1 + fit_cap_cost)^gen - 1) * sum(max(0, BS_load - BS_cap)) /  ...
            BS_cap);
    end
    
    % Report Generation Results
    [fit_max, fit_ind] = max(fit);
    BS_load = zeros(num_BS, 1);
    BS_ind = find(mems(fit_ind, :));
    dist_scen = dists(:, :, logical(mems(fit_ind, :)));
    [~, dist_ind] = min(dist_scen, [], 3);
    for r = 1:rows
        for c = 1:cols
            BS_load(BS_ind(dist_ind(r, c))) = ...
                BS_load(BS_ind(dist_ind(r, c))) + ...
                betaval * scale * pix_dist^2 * Field.field(r, c);
        end
    end
    fprintf('Maximum Fitness:\n\t%.6e with %d active BS\n', ...
        fit_max, sum(mems(fit_ind, :))  );
    fprintf('\tOver Cost:\t%.6e\n', ...
        1 / fit_max - sum(mems(fit_ind, :)) );
    
    if prev_fit == fit_max
        fit_cnt = fit_cnt + 1;
    else
        fit_cnt = 0;
        prev_fit = fit_max;
    end
    
    if all(prev_mem == mems(fit_ind, :)) && ...
            (1 / fit_max - sum(mems(fit_ind, :))) > 1
        mem_cnt = mem_cnt + 1;
    else
        mem_cnt = 0;
        prev_mem = mems(fit_ind, :);
        if ctrl_ga_fig_vor
            figure(6)
            voronoi(    ...
                BS(logical(mems(fit_ind, :)), 1),   ...
                BS(logical(mems(fit_ind, :)), 2)    )
            axis([0 cols 0 rows])
        end
        if ctrl_ga_fig_grad
            Plot_VorMod_Grad(figure(7), BS, BS_load, BS_cap, field);
        end
        drawnow
    end
    
    fprintf('Fit Count:\t%i\t%i\n', fit_cnt, num_fit_halt);
    fprintf('Mem Count:\t%i\t%i\n', mem_cnt, num_mem_halt);
    if fit_cnt > num_fit_halt && gen > min_gen
        fprintf('Evolution Fitness Stall; Begin PermSweep\n')
        VorMod_PermSweep
        if ctrl_ps_flag_break
            fprintf('PermSweep Complete w/out Change; Breaking\n')
            break;
        else
            fprintf('PermSweep Complete w/Change; Resetting Counts\n')
            fit_cnt = 0;
            prev_fit = fit_max_sweep;
            mem_cnt = 0;
            prev_mem = mems(1, :);
            if ctrl_ga_fig_vor
                figure(6)
                voronoi(    ...
                    BS(logical(mems(1, :)), 1),   ...
                    BS(logical(mems(1, :)), 2)    )
                axis([0 cols 0 rows])
            end
            if ctrl_ga_fig_grad
                Plot_VorMod_Grad(figure(7), BS, BS_load, BS_cap, field);
            end
            drawnow
        end
    end
    if mem_cnt > num_mem_halt && gen > min_gen && betaval > betamax
        fprintf('Evolution Member/BS Stall; Begin PermSweep\n')
        VorMod_PermSweep
        if ctrl_ps_flag_break
            fprintf('PermSweep Complete w/out Change; Breaking\n')
            break;
        else
            fprintf('PermSweep Complete w/Change; Resetting Counts\n')
            fit_cnt = 0;
            prev_fit = fit_max_sweep;
            mem_cnt = 0;
            prev_mem = mems(1, :);
            if ctrl_ga_fig_vor
                figure(6)
                voronoi(    ...
                    BS(logical(mems(1, :)), 1),   ...
                    BS(logical(mems(1, :)), 2)    )
                axis([0 cols 0 rows])
            end
            if ctrl_ga_fig_grad
                Plot_VorMod_Grad(figure(7), BS, BS_load, BS_cap, field);
            end
            drawnow
        end
    end
end

%% Determine Best Fit
x_appx = BS_load;
x_appx(x_appx > 0) = 1;

%% Report GA Timer
cput = cputime - cput_start;
toc;
fprintf('CPU time for "Gen Alg" for beta = %1.6f is %1.6f seconds\n', ...
    betaval, cput);

% Runs a single depth sweep of the current best solution of the genetic
% algorithm, VorMod_GenAlg.
% Runs after the GA has hit the halting condition
% Takes the fittest solution of the final generation, and tests every
% possible solution that is one step away from the fittest member; that is,
% every solution that is identical to the fittest solution except for one
% flipped bit.

% Initialization
mems_sweep = repmat(mems(fit_ind, :), num_BS, 1);
fit_sweep = zeros(num_BS, 1);

for a = 1:num_BS
    % Determine Sweep Members
    mems_sweep(a, a) = ~mems_sweep(a, a);
    
    % Calculate Fitness
    dist_scen = dists(:, :, logical(mems_sweep(a, :)));
    BS_ind = find(mems_sweep(a, :));
    [dist_min, dist_ind] = min(dist_scen, [], 3);
    BS_load = zeros(num_BS, 1);
    for r = 1:rows
        for c = 1:cols
            BS_load(BS_ind(dist_ind(r, c))) =   ...
                BS_load(BS_ind(dist_ind(r, c))) +   ...
                betaval * scale * pix_dist^2 * field.field(r, c);
        end
    end
    
    fit_sweep(a) = 1 / (  ...
        sum(mems_sweep(a, :)) +   ...
        fit_rng_cost * sum(sum(dist_min > BS_rng - sqrt(2)/2 * pix_dist)) + ...
        ((1 + fit_cap_cost)^gen - 1) * sum(max(0, BS_load - BS_cap)) /  ...
        BS_cap);
end

% Determine fittest of sweep members, and correct if fitter
[fit_max_sweep, fit_ind_sweep] = max(fit_sweep);
if fit_max_sweep > fit_max
    ctrl_ps_flag_break = 0;
    mems = [mems_sweep(fit_ind_sweep, :); mems(1:num_mems-1, :)];
    fit = [fit_sweep(fit_ind_sweep); fit(1:end-1)];
    dist_scen = dists(:, :, logical(mems_sweep(fit_ind_sweep, :)));
    BS_ind = find(mems_sweep(fit_ind_sweep, :));
    [dist_min, dist_ind] = min(dist_scen, [], 3);
    BS_load = zeros(num_BS, 1);
    for r = 1:rows
        for c = 1:cols
            BS_load(BS_ind(dist_ind(r, c))) =   ...
                BS_load(BS_ind(dist_ind(r, c))) +   ...
                betaval * scale * pix_dist^2 * field.field(r, c);
        end
    end
else
    ctrl_ps_flag_break = 1;
end

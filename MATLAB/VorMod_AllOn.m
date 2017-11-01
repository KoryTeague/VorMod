% Tests whether the beta = 1 demand characterization is sufficiently or
    % totally covered by the all-on resource scenario
% Running this script informs whether the generated resources and demand
    % can fundamentally satisfy the whole demand field (beta = 1), and -
    % further - what value of beta can be satisfied.

%% Start All-On Timer
cput_start = cputime;
tic;
    
%% Test Beta == 1 All-On Scenario
[dist_min, dist_ind] = min(dists, [], 3);
if any(any(dist_min > (BS_rng - pix_dist/2 * sqrt(2))))
    % Coverage; somewhere is not satisfied by the BS deployment
    fprintf('Beta = 1 All-On Scenario Insufficient Coverage; Waiting\n')
    pause
    %return
else
    fprintf('Beta = 1 All-On Scenario Sufficient Coverage\n')
end
BS_load = zeros(num_BS, 1);
for r = 1:rows
    for c = 1:cols
        BS_load(dist_ind(r, c)) = BS_load(dist_ind(r, c)) + ...
            scale * pix_dist^2 * Field.field(r, c);
    end
end

if any(BS_load > BS_cap)
    fprintf('Beta = 1 All-On Scenario Insufficient Resources; Waiting\n')
    pause
    %return
else
    fprintf('Beta = 1 All-On Scenario Sufficient Resources\n')
end

%% Discover Beta Max for Sufficient Coverage and Resources
% Beta is a scalar that modifies the demand of the demand field without
% changing the probabilities and overall demand of the optimization
% problem.  Effectively, beta is a scalar to the demand field as the
% genetic algorithm observes it without actually modifying the total amount
% of demand, causing the GA to otherwise "overallocate" in order to account
% for variance of inidividual demand sources (like MSs and other users)
% To this end, the load on any BS (BS_load) is scaled by beta.
% Find max betamax s.t. BS_load * betamax <= BS_cap for all s in S
% Or: betamax == min(BS_cap ./ BS_load)
betamax = min(BS_cap ./ BS_load);
fprintf('Maximum Beta for All-On Scenario Satisfaction: %1.6f\n', betamax);

%% Report All-On Timer
cput = cputime - cput_start;
toc;
fprintf('CPU time for "All-On" is %1.6f seconds\n', cput);

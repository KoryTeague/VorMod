% Generates a new set of demand points for comparing Optimization (CPLEX)
% and Approximation (MATLAB GA) solutions.  Writes new data to VorOptEval
% and VorAppxEval folders for evaluation

%{
id      id of original set it belongs to
id2     id of new set it adds to old set
S
M
O
PPP
%}

%% Control Parameters

% Resources
num_points =    60;
num_real =      20;

% Timestamp
newDem_timestamp = datestr(now, 30);

% Path - data should be in the appropriate directory
p = ['C++ Vormod\Results\' timestamp '\VorAppxEval\'];

%% Generate Demand Points and Associated Data
PPP_new = field.nsPPP(1, num_points, num_real);
u_new = zeros(num_points, num_BS, num_real);
for s = 1:num_BS
    for o = 1:num_real
        u_new(:, s, o) = sqrt(  ...
            (PPP_new{o}(:, 1) - BS(s, 1)).^2 +  ...
            (PPP_new{o}(:, 2) - BS(s, 2)).^2);
    end
end
u_new(u_new > BS_rng / pix_dist) = 0;
u_new(u_new ~= 0) = 1;

%% Create Evaluation Data Set
if ~exist('evalSet', 'var')
    evalSet = struct('id', timestamp, 'id2', newDem_timestamp,  ...
        'S', num_BS, 'M', num_points, 'O', num_real,    ...
        'PPP', PPP_new, 'ncap', u);
else
    evalSet(end + 1 : end + num_real) = struct('id', timestamp, ...
        'id2', newDem_timestamp, 'S', num_BS, 'M', num_points,  ...
        'O', num_real, 'PPP', PPP_new, 'ncap', u);
end

%% Write Evaluation Data Set to File
VorMod_WriteDataNewDem

%% Save Workspace
save(['C++ Vormod\Results\' timestamp '\EvalSet_' newDem_timestamp],    ...
    'evalSet')
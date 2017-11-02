% Parses the output of cpp formulated stage 2 evaluation for GA
% approximation across all betas using CPLEX training data set

if ~exist('betarng', 'var')
    if ~exist('beta', 'var')
        betarng = 1;
        fprintf('No betarng defined.\nDefining as beta = 1\n');
    else
        betarng = length(beta);
        fprintf('No betarng defined.\nDefining as length of beta\n');
    end
end

% Path - data should be in the appropriate directory
% Set so long as the associated data set is loaded into MATLAB (timestamp)
p = ['C++ Vormod\Results\' timestamp '\VorOptEval\'];

% Variable Definition
clear 'VOE'

VOE.alpha = alpha;                  % Vector of scaling coefficient for CPLEX
VOE.rng =   alpharng;               % Length of data set; number of alpha
VOE.id =    timestamp;              % Data set ID; here it's the timestamp
VOE.S =     num_BS;                 % Number of BSs
VOE.M =     num_points;             % Number of demand points per scenario
VOE.O =     num_real;               % Number of realization scenarios
VOE.src =   '';                     % Source Computer

VOE.x =     VOS.x;                  % Binary; BSs selected by CPLEX sol

VOE.del =   cell(VOE.rng, 1);       % Portion of BS s to DP m in scenario o
VOE.tim =   zeros(VOE.rng, 1);      % Time (CPU) to run second stage
VOE.obj =   zeros(VOE.rng, 1);      % Objective function value of 2nd stage
VOE.sat =   zeros(VOE.rng, 1);      % Average demand satisfaction
VOE.cost =  zeros(VOE.rng, 1);      % Solution cost

% Read
log_form = ['%0' num2str(ceil(log10(alpharng + 1))) 'u'];
for index = 1:10:VOE.rng
    fprintf('Reading %i\n', index)
    
    VOE.del{index} = CppPlexFileRead([p 'Vormod'   ...
        num2str(index, log_form) '_out2del.dat']);
    VOE.tim(index) = CppPlexFileRead([p 'Vormod'   ...
        num2str(index, log_form) '_out2tim.dat']);
    VOE.obj(index) = CppPlexFileRead([p 'Vormod'   ...
        num2str(index, log_form) '_out2opt.dat']);
    VOE.sat(index) = satis(VOE.del{index}, demand);
    VOE.cost(index) = sum(VOE.x{index});
end

% Save
save(['C++ Vormod\Results\' timestamp '\VOEres'], 'VOE');

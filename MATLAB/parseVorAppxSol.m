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
p = ['C++ Vormod\Results\' timestamp '\VorAppxSol\'];

% Variable Definition
clear 'VAS'

VAS.beta =  beta;                   % Vector of scaling coefficients for GA
VAS.rng =   betarng;                % Length of data set; number of beta
VAS.id =    timestamp;              % Data set ID; here it's the timestamp
VAS.S =     num_BS;                 % Number of BSs
VAS.M =     num_points;             % Number of demand points per scenario
VAS.O =     num_real;               % Number of realization scenarios
VAS.src =   '';                     % Source Computer

VAS.gnum =  cell2mat(beta_cnt);     % GA number of generations to halt
VAS.gtim =  cell2mat(beta_time);    % GA time (real) to halt
VAS.x =     beta_x;                 % Binary; BSs selected by GA
VAS.gsrc =  '';                     % GA Source Computer

VAS.del =   cell(VAS.rng, 1);       % Portion of BS s to DP m in scenario o
VAS.tim =   zeros(VAS.rng, 1);      % Time (CPU) to run second stage
VAS.obj =   zeros(VAS.rng, 1);      % Objective function value of 2nd stage
VAS.sat =   zeros(VAS.rng, 1);      % Average demand satisfaction
VAS.cost =  zeros(VAS.rng, 1);      % Solution cost

% Read
for index = 1:VAS.rng
    fprintf('Reading %i\n', index)
    
    VAS.del{index} = CppPlexFileRead([p 'Vormod_'   ...
        num2str(index, log_form) '_out2del.dat']);
    VAS.tim(index) = CppPlexFileRead([p 'Vormod_'   ...
        num2str(index, log_form) '_out2tim.dat']);
    VAS.obj(index) = CppPlexFileRead([p 'Vormod_'   ...
        num2str(index, log_form) '_out2opt.dat']);
    VAS.sat(index) = satis(VAS.del{index}, demand);
    VAS.cost(index) = sum(VAS.x{index});
end

% Save
save(['C++ Vormod\Results\' timestamp '\VASres'], 'VAS');

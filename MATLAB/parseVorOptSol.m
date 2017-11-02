% Parses the output of the cpp formulation to generate the entire sequence
% of data, across all alphas
if ~exist('alpharng', 'var')
    if ~exist('alpha', 'var')
        alpharng = 1;
        fprintf('No alpharng defined.\nDefining as alpha = 1\n');
    else
        alpharng = length(alpha);
        fprintf('No alpharng defined.\nDefining as length of alpha');
    end
end

% Path - data should be in the appropriate directory
% Set so long as the associated data set is loaded into MATLAB (timestamp)
p = ['C++ Vormod\Results\' timestamp '\VorOptSol\'];

% Variable Definition
clear 'VOS'

VOS.alpha = alpha;              % Vector of scaling coefficient for CPLEX
VOS.rng =   alpharng;           % Length of data set; number of alpha
VOS.id =    timestamp;          % Data set ID; here it's the timestamp
VOS.S =     num_BS;             % Number of BSs
VOS.M =     num_points;         % Number of demand points per scenario
VOS.O =     num_real;           % Number of realization scenarios
VOS.src =   '';                 % Source computer CPLEX ran on

VOS.x =     cell(VOS.rng, 1);   % Binary; BSs selected
VOS.del =   cell(VOS.rng, 1);   % Portion of BS s to DP m in scenario o
VOS.dmod =  cell(VOS.rng, 1);   % Modified (de-normalized; *field dem) del
VOS.tim =   zeros(VOS.rng, 1);  % Time (CPU) to run
VOS.obj =   zeros(VOS.rng, 1);  % Objective function value
VOS.sat =   zeros(VOS.rng, 1);  % Average demand satisfaction
VOS.cost =  zeros(VOS.rng, 1);  % Solution cost

% Read
for index = 1:VOS.rng
    fprintf('Reading %i\n', index)
    
    VOS.x{index} = CppPlexFileRead([p 'VorMod_outx_'    ...
        num2str(index) '.dat']);
    VOS.del{index} = CppPlexFileRead([p 'VorMod_outdel_'    ...
        num2str(index) '.dat']);
    VOS.dmod{index} = VOS.del{index} *	...
        (sum(sum(Field.field)) * scale * pix_dist^2);
    VOS.tim(index) = CppPlexFileRead([p 'VorMod_outtim_'    ...
        num2str(index) '.dat']);
    VOS.obj(index) = CppPlexFileRead([p 'VorMod_outopt_'    ...
        num2str(index) '.dat']);
    VOS.sat(index) = satis(VOS.dmod{index}, demand);
    VOS.cost(index) = sum(VOS.x{index});
end

% Save
save(['C++ Vormod\Results\' timestamp '\VOSres_'    ...
    strrep(num2str(alpha(1)), '.', '_') '-' ...
    strrep(num2str(alpha(2) - alpha(1)), '.', '_') '-'  ...
    strrep(num2str(alpha(end)), '.', '_')], 'VOS');

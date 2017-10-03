% Sets up the initial variables for the voronoi model
% Run this to setup all initial and derived variables before running either
    % the optimal model or genetic algorithm

%% Start Setup Timer
cput_start = cputime;
tic;

%% Generic Setup

% Establish Field
rows = 100;             % Size of field in pixels       (100)
cols = 100;             %                               (100)
pix_dist = 20;          % Distance between pixels       (20)
omega = 2*pi/30;        % Autocorrelation/Frequency     (2*pi/30)
loc = 0;                % LN Location                   (0)
sca = 1;                % LN Scale                      (1)
L = 50;                 % Depth                         (50)
scale = 2;              % Scaling Factor                (2)

% Resources and Other Settings
num_BS = 60;            %                               (50)
BS_cap = 1.5e6;         %                               (1e6)
BS_rng = 500;           %                               (500)
num_points = 200;       %                               (250)
num_real = 300;         %                               (50)

% Iterations
alpha = 25:25:250;         % Number, Opt Weighted Sweep
alpharng = length(alpha);
beta = 0.5:0.1:2.5;          % Number, GA Weighted Sweep
betarng = length(beta);

% File I/O
cpfn = 'C++ Vormod';
cpfnoptsol = [cpfn '\VorOptSol'];
cpfnappxeval = [cpfn '\VorAppxEval'];
cpfnopteval = [cpfn '\VorOptEval'];

%% Genetic Algorithm Setup

% Fitness costs
fit_cap_cost = 0.015;   % Overcapacity cost             (0.015)
fit_rng_cost = 3;       % Out-of_range cost             (3)

% Rates
x_rate = 0.7;           % Crossover rate                (0.7)
mut_rate = 1/num_BS;    % Mutation rate                 (bit-string; 1/num_BS)

% Generations
max_gen = 1500;         % max number of gens            (1500)
min_gen = 200;          % min number of gens            (200)
num_fit_halt = 50;      % Halt after * w/no fit change  (25)
num_mem_halt = 250;     % Halt after * w/no BS change   (100)

% Other Settings
num_mems = 60;          % Number of members per gen     (100)
num_elite = 2;          % Number of best members kept   (4)

%% Report Setup Timer
cput = cputime - cput_start;
toc;
fprintf('CPU time for "Setup" is %1.6f seconds\n', cput);

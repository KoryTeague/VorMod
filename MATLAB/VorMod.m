% Compilation script which runs all of the Voronoi model through to
% generating associated data, running the Voronoi GA approximation, writing
% the data for running the two-stage opimization problem and evaluate the
% GA solution via the second-stage problem.

%% Initialization
timestamp = datestr(now, 30);
mkdir('Results', timestamp)
save(['Results\' timestamp '\_Old.mat'])
clearvars -except timestamp

%% Control Parameters
CTRL_DRAW_LNFIELD =                 true;       % (true)

%% Field Parameters
% Field Demand
FIELD_NUM_ROWS =                    100;        % (100)
FIELD_NUM_COLS =                    100;        % (100)
FIELD_PIXEL_DISTANCE =              20;         % (20)
FIELD_OMEGA =                       2*pi/30;    % (2*pi/30)
FIELD_LOCATION =                    0;          % (0)
FIELD_SCALE =                       1;          % (1)
FIELD_DEPTH =                       50;         % (50)
FIELD_SCALING_COEFFICIENT =         2;          % (2)

% Field Resources
FIELD_NUM_BASE_STATIONS =           60;         % (60)
FIELD_BASE_STATION_CAPACITY =       1.5e6;      % (1.5e6)
FIELD_BASE_STATION_RANGE =          500;        % (500)

% Data Set Settings
CP_LEARN_NUM_DEMAND_POINTS =        60;         % (60)
CP_LEARN_NUM_DEMAND_REALIZATIONS =  20;         % (20)

%% CPLEX Settings
alpha =                             5:5:100;    % (5:5:100)
alphaLength =                       length(alpha);

%% GA Settings
% Fitness Costs
FITNESS_OVERCAPACITY_COST =         0.015;      % (0.015)
FITNESS_OVERRANGE_COST =            3;          % (3)

% Probability Rates
GA_CROSSOVER_RATE =                 0.7;        % (0.7)
GA_MUTATION_RATE =                  1/FIELD_NUM_BASE_STATIONS;
                                            % (1/FIELD_NUM_BASE_STATIONS)
                                            
% Generation Limits
GA_NUM_MAXIMUM_GENERATIONS =        1500;       % (1500)
GA_NUM_MINIMUM_GENERATIONS =        200;        % (200)
GA_NUM_FITNESS_HALT =               50;         % (50)
GA_NUM_MEMBER_HALT =                100;        % (100)

% Other Settings
GA_NUM_GENERATION_MEMBERS =         80;         % (60)
GA_NUM_GENERATION_ELITISM =         4;          % (2)
GA_BETA =                           0.5:0.1:2.5;
                                                % (0.5:0.1:2.5)
GA_BETA_LENGTH =                    length(GA_BETA);
                                                % (length(GA_BETA))

%% Generate Log-Normal Field
Field = LNField(FIELD_OMEGA, FIELD_DEPTH, FIELD_NUM_ROWS, ...
    FIELD_NUM_COLS, FIELD_LOCATION, FIELD_SCALE);
if CTRL_DRAW_LNFIELD
    Field.drawField(figure(1))
end

%% ----------------------------
% Begin Depreciated

%% Model Startup Scripts
VorMod_Setup                    % Setup/Set Initial Data Parameters
if ctrl_mas_log_setup
    save(['C++ Vormod\Results\' timestamp '\_Setup.mat'])
end
VorMod_Generate                 % Generate Additional Model Data
if ctrl_mas_log_gen
    save(['C++ Vormod\Results\' timestamp '\_Gen.mat'])
end
VorMod_AllOn                    % Test All-On Scenario
if ctrl_mas_log_all
    save(['C++ Vormod\Results\' timestamp '\_AllOn.mat'])
end
%VorMod_WriteOptData             % Write Opt Data to File

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
        save(['C++ Vormod\Results\' timestamp '\_GA' num2str(iter, log_form) '.mat'])
    end
end

%% Model Wrapup Scripts
VorMod_WriteData                % Write Data to Files
%VorMod_WriteGAData              % Write GA Data to File

%% Save Workspace
if ctrl_mas_log_final
    save(['C++ Vormod\Results\' timestamp '\_Final.mat'])
end

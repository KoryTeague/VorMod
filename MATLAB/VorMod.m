% Rewritten VorMod.m
% Kory Teague
% Instead of a compilation script, this is written to be a bit more
% "kosher".  Instead of a long list of direct, global scripts, this is
% written to encapsulate better, utilize MATLAB's OOP capabilities, and
% match to a consistent programming style.
% Generates global constants, combines data associated with specific
% portions of the model into encapsulating structs or objects, and runs
% through generating the models, running the GA, and writing the data to
% file for VOS and VAS (2-stage and GA + 1-stage solutions) cplex models

%% Initialization
timestamp = datestr(now, 30);
mkdir('Results', timestamp)
mkdir(['Results\' timestamp], 'VorOptSol')
mkdir(['Results\' timestamp], 'VorAppxSol')
mkdir(['Results\' timestamp], 'VorOptEval')
mkdir(['Results\' timestamp], 'VorAppxEval')
save(['Results\' timestamp '\_Old.mat'])
clearvars -except timestamp

%% Control Parameters
CTRL_DRAW_LNFIELD =                 true;       % (true)
CTRL_GENERATE_BS_LOCATIONS =        1;          % (1)
CTRL_DRAW_BS_SCATTER =              true;       % (true)
CTRL_DRAW_BS_VORONOI =              true;       % (true)
CTRL_DRAW_DEMAND_POINTS =           true;       % (true)
CTRL_ALLON_TEST_EXIT =              false;      % (false)
CTRL_GENERATION_REPORT =            2;          % (2)
CTRL_GENERATION_REPORT_GRAPH =      5;          % (5)
CTRL_WRITE_OPTIMIZATION_DATA =      true;       % (true)
CTRL_WRITE_GENETIC_ALGORITHM_DATA = true;       % (true)

%% Field Parameters
% Field Demand
FIELD_NUM_ROWS =                    400;        % (100)
FIELD_NUM_COLS =                    400;        % (100)
FIELD_PIXEL_WIDTH =                 15;         % (20)
FIELD_OMEGA =                       0.012673 * FIELD_PIXEL_WIDTH;
                                                % (2*pi/30)
FIELD_LOCATION =                    17.7956;    % (0)
FIELD_SCALE =                       2.1188;     % (1)
FIELD_DEPTH =                       50;         % (50)
FIELD_SCALING_COEFFICIENT =         1e-6;       % (2)

% Field Resources
FIELD_NUM_MACROCELLS    =           25;
FIELD_NUM_PICOCELLS     =           50;
FIELD_NUM_BASE_STATIONS =           FIELD_NUM_MACROCELLS +  ...
    FIELD_NUM_PICOCELLS;                        % (60)
FIELD_BASE_STATION_CAPACITY =   ...
    [2e9 * ones(FIELD_NUM_MACROCELLS, 1);   ...
    5e8 * ones(FIELD_NUM_PICOCELLS, 1)];        % (1.5e6)
FIELD_BASE_STATION_RANGE =  ...
    [2000 * ones(FIELD_NUM_MACROCELLS, 1);  ...
    250 * ones(FIELD_NUM_PICOCELLS, 1)];        % (500)
FIELD_BASE_STATION_COST =   ...
    [1 * ones(FIELD_NUM_MACROCELLS, 1); ...
    0.2 * ones(FIELD_NUM_PICOCELLS, 1)];        % (1)

% Data Set Settings
CP_NUM_SOL_DEMAND_POINTS =          250;         % (60); For sol/learning set
CP_NUM_SOL_DEMAND_REALIZATIONS =    45;         % (20); For sol/learning set

%% CPLEX Settings
alpha =                             [1:1:16, 18:3:30, 40:10:100];    % (5:5:100)
alphaLength =                       length(alpha);

%% GA Settings
% Fitness Costs
FITNESS_OVERCAPACITY_COST =         0.015;      % (0.015)
FITNESS_OVERRANGE_COST =            3;          % (3)

% Probability Rates
GA_CROSSOVER_RATE =                 0.7;        % (0.7)
GA_MUTATION_RATE =                  1 / FIELD_NUM_BASE_STATIONS;
                                            % (1/FIELD_NUM_BASE_STATIONS)
                                            
% Generation Limits
GA_NUM_FITNESS_HALT =               300;        % (50)
GA_NUM_MEMBER_HALT =                600;        % (200)
GA_NUM_MAXIMUM_GENERATIONS =        4000;       % (3000)
GA_NUM_MINIMUM_GENERATIONS =        450 - GA_NUM_FITNESS_HALT;
                                                % (200 - #Fitness Halt)

% Other Settings
GA_NUM_GENERATION_MEMBERS =         80;         % (60)
GA_NUM_GENERATION_ELITISM =         4;          % (2)
GA_UNIQUENESS =                     1;          % (1)
GA_BETA =                           0.5:0.1:2.5;
                                                % (0.5:0.1:2.5)
GA_BETA_LENGTH =                    length(GA_BETA);

%% Generate Log-Normal Field
Field.DemandField = LNField(FIELD_OMEGA, FIELD_DEPTH, FIELD_NUM_ROWS, ...
    FIELD_NUM_COLS, FIELD_LOCATION, FIELD_SCALE, ...
    FIELD_SCALING_COEFFICIENT * FIELD_PIXEL_WIDTH^2);

if CTRL_DRAW_LNFIELD
    Field.DemandField.dispfield(figure(1))
end

Field.baseStationCapacity = FIELD_BASE_STATION_CAPACITY;
Field.baseStationRange = FIELD_BASE_STATION_RANGE;
Field.baseStationCost = FIELD_BASE_STATION_COST;
Field.pixelWidth = FIELD_PIXEL_WIDTH;

%% Generate BS Locations
switch CTRL_GENERATE_BS_LOCATIONS
    case 0
        % BS locations as a grid
        % Changes the number of base stations if number is not square
        dist = ceil(sqrt(FIELD_NUM_BASE_STATIONS));
        FIELD_NUM_BASE_STATIONS = dist^2;
        Field.bsLocations = HilbertCurve( ...
            [kron(((1:dist)' - 0.5) * FIELD_NUM_COLS / dist,    ...
            ones(dist, 1)), ...
            repmat(((1:dist)' - 0.5) * FIELD_NUM_ROWS / dist,   ...
            dist, 1)],  ...
            [0 FIELD_NUM_COLS], [0 FIELD_NUM_ROWS]);
        
        clearvars dist
    case 1
        % BS locations as PPP
        temp_bs = [FIELD_NUM_COLS * rand([FIELD_NUM_MACROCELLS, 1]),    ...
            FIELD_NUM_ROWS * rand([FIELD_NUM_MACROCELLS, 1]);   ...
            cell2mat(Field.DemandField.nonstationaryppp(    ...
                1, FIELD_NUM_PICOCELLS, 1))];
%        Field.bsLocations = HilbertCurve( ...
%            [FIELD_NUM_COLS * rand([FIELD_NUM_BASE_STATIONS, 1]),   ...
%            FIELD_NUM_ROWS * rand([FIELD_NUM_BASE_STATIONS, 1])],   ...
%            [0 FIELD_NUM_COLS], [0 FIELD_NUM_ROWS]);
%        Field.bsLocations = HilbertCurve(temp_bs,   ...
%            [0 FIELD_NUM_COLS], [0 FIELD_NUM_ROWS]);
        Field.bsLocations = temp_bs;
        
        clearvars temp_bs
    case 2
        % BS locations as nsPPP, as per Field
        Field.bsLocations = HilbertCurve(cell2mat(    ...
            Field.DemandField.nonstationaryppp( ...
            1, FIELD_NUM_BASE_STATIONS, 1)),    ...
            [0 FIELD_NUM_COLS], [0 FIELD_NUM_ROWS]);
    otherwise
        error('Incorrect BS Location Generation Control; Exiting\n')
end

if CTRL_DRAW_BS_SCATTER
    figure(2)
    hold off
    scatter(Field.bsLocations(:, 1), Field.bsLocations(:, 2), '.')
    axis([0 FIELD_NUM_COLS 0 FIELD_NUM_ROWS])
end

if CTRL_DRAW_BS_VORONOI
    figure(3)
    hold off
    if size(Field.bsLocations, 1) >= 3
        voronoi(Field.bsLocations(:, 1), Field.bsLocations(:, 2))
        axis([0 FIELD_NUM_COLS 0 FIELD_NUM_ROWS])
    else
        warning('Not enough points to draw Voronoi tesselation.\nNot Drawing.\n')
    end
end

drawnow

%% Generate Distances
Field.pixelDistances = zeros(FIELD_NUM_ROWS, FIELD_NUM_COLS,  ...
    FIELD_NUM_BASE_STATIONS);
for iRows = 1:FIELD_NUM_ROWS
    for jCols = 1:FIELD_NUM_COLS
        Field.pixelDistances(iRows, jCols, :) = FIELD_PIXEL_WIDTH *  ...
            sqrt((Field.bsLocations(:, 1) - jCols) .^ 2 + ...
            (Field.bsLocations(:, 2) - iRows) .^ 2);
    end
end

clearvars iRows jCols

%% Generate Demand Point Realizations and Rate Normalization (u)
SolutionSet = DemandRealizations(FIELD_NUM_BASE_STATIONS,   ...
    CP_NUM_SOL_DEMAND_POINTS,   ...
    CP_NUM_SOL_DEMAND_REALIZATIONS, ...
    Field.DemandField.nonstationaryppp(1, CP_NUM_SOL_DEMAND_POINTS, ...
        CP_NUM_SOL_DEMAND_REALIZATIONS),    ...
    Field.bsLocations, ...
    (FIELD_BASE_STATION_RANGE' / FIELD_PIXEL_WIDTH),    ...
    Field.DemandField.demand / ...
        CP_NUM_SOL_DEMAND_POINTS * ones(CP_NUM_SOL_DEMAND_POINTS, 1),   ...
    timestamp,  ...
    'binary');

if CTRL_DRAW_DEMAND_POINTS
    figure(4)
    hold off
    scatter(SolutionSet(1).demandPoints(:, 1),  ...
        SolutionSet(1).demandPoints(:, 2), '.');
    hold on
    for iRealization = 2:CP_NUM_SOL_DEMAND_REALIZATIONS
        scatter(SolutionSet(iRealization).demandPoints(:, 1),   ...
            SolutionSet(iRealization).demandPoints(:, 2), '.');
    end
    hold off
    
    clearvars iRealization
end

drawnow

%% Test "All On" Criteria
% Prep
[distanceMin, distanceMinIndex] = min(Field.pixelDistances, [], 3);
baseStationMaxRange = zeros(size(distanceMin));
baseStationLoad = zeros(FIELD_NUM_BASE_STATIONS, 1);
for iResource = 1:FIELD_NUM_BASE_STATIONS
    baseStationMaxRange(distanceMinIndex == iResource) =    ...
        FIELD_BASE_STATION_RANGE(iResource) -   ...
        (FIELD_PIXEL_WIDTH/2 * sqrt(2));
    baseStationLoad(iResource) =    ...
        sum(Field.DemandField.demandMod *   ...
        Field.DemandField.field(distanceMinIndex == iResource));
end

% Coverage
if any(any(distanceMin > baseStationMaxRange))
    % Somewhere is not satisfied by the BS deployment
    if CTRL_ALLON_TEST_EXIT
        error('All-On Scenario Insufficient Coverage; Exiting\n')
    else
        warning('All-On Scenario Insufficient Coverage')
    end
else
    fprintf('All-On Scenario Sufficient Coverage; Continuing\n')
end

% Beta = 1 Capacity
if any(baseStationLoad > FIELD_BASE_STATION_CAPACITY)
    % Some resource/base station is over allocated
    if CTRL_ALLON_TEST_EXIT
        error('Beta = 1 All-On Scenario Insufficient Resource Capacity; Exiting\n')
    else
        warning('Beta = 1 All-On Scenario Insufficient Resource Capacity')
    end
else
    fprintf('Beta = 1 All-On Scenario Sufficient Resource Capacity; Continuing\n')
end

% Maximum Beta
% Old notes:
% Beta is a scalar that modifies the demand of the demand field without
% changing the probabilities and overall demand of the optimization
% problem.  Effectively, beta is a scalar to the demand field as the
% genetic algorithm observes it without actually modifying the total amount
% of demand, causing the GA to otherwise "overallocate" in order to account
% for variance of inidividual demand sources (like MSs and other users)
% To this end, the load on any BS (BS_load) is scaled by beta.
% Find max betamax s.t. BS_load * betamax <= BS_cap for all s in S
% Or: betamax == min(BS_cap ./ BS_load)
fprintf('Maximum Beta for All-On Scenario Satisfaction: %1.5e\n',   ...
    min(FIELD_BASE_STATION_CAPACITY ./ baseStationLoad));

clearvars distanceMin distanceMinIndex baseStationMaxRange  ...
    baseStationLoad iResource

pause

%% Genetic Algorithm
% GA_BETA(1)
fprintf('\nProcessing Beta = %1.5e', GA_BETA(1));
VorModGA = VorModGeneticAlgorithm(GA_NUM_GENERATION_MEMBERS,    ...
    FIELD_NUM_BASE_STATIONS, Field, ...
    'beta', GA_BETA(1), ...
    'range', FITNESS_OVERRANGE_COST,    ...
    'capacity', FITNESS_OVERCAPACITY_COST,  ...
    'elite', GA_NUM_GENERATION_ELITISM, ...
    'unique', GA_UNIQUENESS,    ...
    'crossover', GA_CROSSOVER_RATE, ...
    'mutation', GA_MUTATION_RATE,   ...
    'fitcount', GA_NUM_FITNESS_HALT,    ...
    'memcount', GA_NUM_MEMBER_HALT, ...
    'generationreport', CTRL_GENERATION_REPORT, ...
    'graph', CTRL_GENERATION_REPORT_GRAPH,  ...
    'min', GA_NUM_MINIMUM_GENERATIONS,  ...
    'max', GA_NUM_MAXIMUM_GENERATIONS);
VorModGA.computesolution()
VorModGASolution = GeneticAlgorithmSolution();
VorModGASolution.addsolution(VorModGA, GA_BETA(1))

% Generic Beta
for iBeta = 2:GA_BETA_LENGTH
    fprintf('\nProcessing Beta = %1.5e', GA_BETA(iBeta));
    VorModGA.setbeta(GA_BETA(iBeta))
    VorModGA.computesolution()
    VorModGASolution.addsolution(VorModGA, GA_BETA(iBeta))
end

clearvars iBeta

%% Write Data & Save
% Optimization (Learning Set / VOS)
if CTRL_WRITE_OPTIMIZATION_DATA
    %{
    cplexWriteDataTwoStage(['Results\' timestamp 	...
            '\VorOptSol\Vormod.dat'],	...
        timestamp,  ...
        FIELD_NUM_BASE_STATIONS,    ...
        CP_NUM_SOL_DEMAND_POINTS,   ...
        CP_NUM_SOL_DEMAND_REALIZATIONS, ...
        FIELD_BASE_STATION_COST,    ...
        FIELD_BASE_STATION_CAPACITY /   ...
            (sum(sum(Field.DemandField.field)) *    ...
            FIELD_SCALING_COEFFICIENT * FIELD_PIXEL_WIDTH^2),   ...
        ones(CP_NUM_SOL_DEMAND_POINTS, 1) / CP_NUM_SOL_DEMAND_POINTS,   ...
        ones(CP_NUM_SOL_DEMAND_REALIZATIONS, 1) /   ...
            CP_NUM_SOL_DEMAND_REALIZATIONS, ...
        alpha,  ...
        SolutionSet.getratenormalization(1: ...
            CP_NUM_SOL_DEMAND_REALIZATIONS));
    %}
    cplexWriteDataTwoStage(['Results\' timestamp 	...
            '\VorOptSol\Vormod.dat'],	...
        timestamp,  ...
        FIELD_NUM_BASE_STATIONS,    ...
        CP_NUM_SOL_DEMAND_POINTS,   ...
        CP_NUM_SOL_DEMAND_REALIZATIONS, ...
        FIELD_BASE_STATION_COST,    ...
        FIELD_BASE_STATION_CAPACITY / Field.DemandField.demand, ...
        ones(CP_NUM_SOL_DEMAND_POINTS, 1) / CP_NUM_SOL_DEMAND_POINTS,   ...
        ones(CP_NUM_SOL_DEMAND_REALIZATIONS, 1) /   ...
            CP_NUM_SOL_DEMAND_REALIZATIONS, ...
        alpha,  ...
        SolutionSet.getratenormalization(1: ...
            CP_NUM_SOL_DEMAND_REALIZATIONS));
end

% Genetic Algorithm (Learning Set / VAS)
if CTRL_WRITE_GENETIC_ALGORITHM_DATA
    logForm = ['%0' num2str(ceil(log10(GA_BETA_LENGTH + 1))) 'u'];
    %{
    for iBeta = 1:GA_BETA_LENGTH
        cplexWriteDataOneStage(['Results\' timestamp    ...
                '\VorAppxSol\Vormod_' num2str(iBeta, logForm) '.dat'],  ...
            ['VAS; Initial Opt Model Training Scenarios; Beta = '	...
                num2str(GA_BETA(iBeta))],   ...
            timestamp, ...
            FIELD_NUM_BASE_STATIONS,	...
            CP_NUM_SOL_DEMAND_POINTS,	...
            CP_NUM_SOL_DEMAND_REALIZATIONS,	...
            (sum(sum(Field.DemandField.field)) *	...
                FIELD_SCALING_COEFFICIENT * FIELD_PIXEL_WIDTH^2),   ...
            FIELD_BASE_STATION_COST,    ...
            FIELD_BASE_STATION_CAPACITY,    ...
            sum(sum(Field.DemandField.field)) * ...
                FIELD_SCALING_COEFFICIENT * FIELD_PIXEL_WIDTH^2 /   ...
                CP_NUM_SOL_DEMAND_POINTS *  ...
                ones(CP_NUM_SOL_DEMAND_POINTS, 1),  ...
            ones(CP_NUM_SOL_DEMAND_REALIZATIONS, 1) /   ...
                CP_NUM_SOL_DEMAND_REALIZATIONS, ...
            VorModGASolution.bestMembers(   ...
                VorModGASolution.nGenerations(iBeta), :, iBeta),    ...
            SolutionSet.getratenormalization(1: ...
                CP_NUM_SOL_DEMAND_REALIZATIONS));
    end
    %}
    for iBeta = 1:GA_BETA_LENGTH
        cplexWriteDataOneStage(['Results\' timestamp    ...
                '\VorAppxSol\Vormod_' num2str(iBeta, logForm) '.dat'],  ...
            ['VAS; Initial Opt Model Training Scenarios; Beta = '	...
                num2str(GA_BETA(iBeta))],   ...
            timestamp, ...
            FIELD_NUM_BASE_STATIONS,	...
            CP_NUM_SOL_DEMAND_POINTS,	...
            CP_NUM_SOL_DEMAND_REALIZATIONS,	...
            Field.DemandField.demand,   ...
            FIELD_BASE_STATION_COST,    ...
            FIELD_BASE_STATION_CAPACITY,    ...
            Field.DemandField.demand / CP_NUM_SOL_DEMAND_POINTS * ...
                ones(CP_NUM_SOL_DEMAND_POINTS, 1),  ...
            ones(CP_NUM_SOL_DEMAND_REALIZATIONS, 1) /   ...
                CP_NUM_SOL_DEMAND_REALIZATIONS, ...
            VorModGASolution.bestMembers(   ...
                VorModGASolution.nGenerations(iBeta), :, iBeta),    ...
            SolutionSet.getratenormalization(1: ...
                CP_NUM_SOL_DEMAND_REALIZATIONS));
    end
    
    clearvars iBeta logForm
end

% Save
save(['Results\' timestamp '\_GAComplete.mat'])

%% ----------------------------
% Begin Depreciated
%{
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
%}

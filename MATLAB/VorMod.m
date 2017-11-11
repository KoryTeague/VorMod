% Compilation script which runs all of the Voronoi model through to
% generating associated data, running the Voronoi GA approximation, writing
% the data for running the two-stage opimization problem and evaluate the
% GA solution via the second-stage problem.

%% Control Parameters
timestamp = datestr(now, 30);
mkdir('Results', timestamp)
save(['Results\' timestamp '\_Old.mat'])
clearvars -except timestamp

%% Field Parameters
% Field Demand
FIELD_NUM_ROWS =                100;        % (100)
FIELD_NUM_COLS =                100;        % (100)
FIELD_PIXEL_DISTANCE =          20;         % (20)
FIELD_OMEGA =                   2*pi/30;    % (2*pi/30)
FIELD_LOCATION =                0;          % (0)
FIELD_SCALE =                   1;          % (1)
FIELD_DEPTH =                   50;         % (50)
FIELD_SCALING_COEFFICIENT =     2;          % (2)

% Field Resources
FIELD_NUM_BASE_STATIONS =       60;         % (60)
FIELD_BASE_STATION_CAPACITY =   1.5e6;      % (1.5e6)
FIELD_BASE_STATION_RANGE =      500;        % (500)

% Data Set Settings
nDemandPoints =                 60;         % (60)
nDemandRealizations =           20;         % (20)

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

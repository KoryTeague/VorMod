% Compilation script which runs all of the Voronoi model through to
% generating associated data, running the Voronoi GA approximation, writing
% the data for running the two-stage opimization problem and evaluate the
% GA solution via the second-stage problem.

%% Control Parameters
timestamp = datestr(now, 30);
mkdir('C++ Vormod\Results', timestamp)
save(['C++ Vormod\Results\' timestamp '\_Old.mat'])
clearvars -except timestamp

% Master (This) Script
ctrl_mas_log_setup = true;
ctrl_mas_log_gen = true;
ctrl_mas_log_all = true;
ctrl_mas_log_ga = true;
ctrl_mas_log_final = true;
% Generate
ctrl_gen_fig_LNSurf = true;
ctrl_gen_fig_LNSurfOver = true;
ctrl_gen_dat_BSLoc = 1;         % 0 = grid; 1 = PPP; 2 = nsPPP
ctrl_gen_fig_BSScat = true;
ctrl_gen_fig_BSVor = true;
ctrl_gen_fig_PPPDem = true;
% Gen Alg
ctrl_ga_fig_vor = true;
ctrl_ga_fig_grad = true;
ctrl_ga_dat_xover = 0;          % 0 = uniform; n>0 = n-point
% Write Data
ctrl_wd_dat_opt = true;
ctrl_wd_dat_ga = true;

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

%% Save Workspace
if ctrl_mas_log_final
    save(['C++ Vormod\Results\' timestamp '\_Final.mat'])
end

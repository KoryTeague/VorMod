% Writes the optimization (two-stage) data, available before the genetic 
% algorithm runs.

%% Write Data Control
if ~exist('ctrl_wd_dat_opt', 'var')
    ctrl_wd_dat_opt = 1;        % Write data file for optimization model
end

%% Start Write Data Timer
cput_start = cputime;
tic;

%% Write Optimization Model Data
if ctrl_wd_dat_opt
    fileID = fopen([cpfnoptsol '\Vormod.dat'], 'W');
    % Header
    fprintf(fileID, ...
        '// Kory Teague, CPLEX Voronoi Model .dat file\n// %s BS = %u\n', ...
        timestamp, ctrl_gen_dat_BSLoc);
    % S
    CppPlexFileWrite(fileID, num_BS, 0, '%i');
    % M
    CppPlexFileWrite(fileID, num_points, 0, '%i');
    % O
    CppPlexFileWrite(fileID, num_real, 0, '%i');
    % Capacity - report as 1, and apply to other variables
    CppPlexFileWrite(fileID, 1, 0, '%.6e');
    % cost
    CppPlexFileWrite(fileID, ones(num_BS, 1), 1, '%.6e');
    % rateCap
    CppPlexFileWrite(fileID, BS_cap * ones(num_BS, 1) / ...
        (sum(sum(field.field)) * scale * pix_dist^2), 1, '%.6e');
    % demand
    CppPlexFileWrite(fileID, demand /   ...
        (sum(sum(field.field)) * scale * pix_dist^2), 1, '%.6e');
    % prob
    CppPlexFileWrite(fileID, ones(num_real, 1) / num_real, 1, '%.6e');
    % alpha
    CppPlexFileWrite(fileID, alpha, 1, '%.6e');
    % rateNorm
    CppPlexFileWrite(fileID, u, 3, '%i');
    
    fclose(fileID);
end

%% Report Write Data Timer
cput = cputime - cput_start;
toc;
fprintf('CPU time for "Write Optimization Data" is %1.6f seconds\n', cput);

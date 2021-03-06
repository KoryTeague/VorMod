% Writes the genetic algorithm results, available after the genetic
% algorithm iterations run.

%% Write Data Control
if ~exist('ctrl_wd_dat_ga', 'var')
    ctrl_wd_dat_ga = 1;         % Write data file for genetic algorithm
end

%% Start Write Data Timer
cput_start = cputime;
tic;

%% Write Genetic Algorithm Data
if ctrl_wd_dat_ga
    log_form = ['%0' num2str(ceil(log10(betarng + 1))) 'u'];
	for iter = 1:betarng
		fileID = fopen(['C++ Vormod\Results\' timestamp '\VorAppxEval\Vormod_' num2str(iter, log_form) '.dat'], 'W');
		
		% Header
		fprintf(fileID, ...
			'// Kory Teague, CPLEX Voronoi Approximation Model Evaluation .dat file\n// Initial Opt Model Training Scenarios\n// %s BS = %u\n', ...
            timestamp, ctrl_gen_dat_BSLoc);
        % S
        CppPlexFileWrite(fileID, num_BS, 0, '%i');
        % M
        CppPlexFileWrite(fileID, num_points, 0, '%i');
        % O
        CppPlexFileWrite(fileID, num_real, 0, '%i');
        % Capacity
        CppPlexFileWrite(fileID, sum(sum(Field.field)) * scale * pix_dist^2, ...
            0, '%.6e');
        % cost, c[rS]
        CppPlexFileWrite(fileID, ones(num_BS, 1), 1, '%.6e');
        % rateCap, r[rS]
        CppPlexFileWrite(fileID, BS_cap * ones(num_BS, 1), 1, '%1.5f');
        % demand, d[rM]
        CppPlexFileWrite(fileID, demand, 1, '%1.5f');
        % prob, p[rO]
        CppPlexFileWrite(fileID, ones(num_real, 1) / num_real, 1, '%1.5f');
        % x, x[rS]
        CppPlexFileWrite(fileID, beta_x{iter}, 1, '%i');
        % rateNorm, u[rM][rS][rO]
        CppPlexFileWrite(fileID, u, 3, '%i');
        
        fclose(fileID);
	end
end

%% Report Write Data Timer
cput = cputime - cput_start;
toc;
fprintf('CPU time for "Write GA Data" is %1.6f seconds\n', cput);

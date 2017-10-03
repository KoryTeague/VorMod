% Original PLOTSCRIPT for plotting data read from running various VorMod
% CPLEX models.  Specific version are made ("PLOTSCRIPT_*.m", currently for
% "OptSol" and "AppxEval", but also need a "OptEval" in the future).

% Currently depreciated since specific versions have been made.

sat = zeros(1, betarng);
for index = 1:betarng
sat(index) = satis(del_VorAppxEval{index}, demand);
tmp = sum(del_VorOptSol{index}(:, :, 1), 1)';
Plot_VorMod_Grad(figure, BS, tmp, BS_cap, field)
fprintf('Max: %1.5f\t%1.5f\nMin: %1.5f\t%1.5f\n', max(tmp), max(tmp) / BS_cap, min(tmp(tmp > 0)), min(tmp(tmp > 0)) / BS_cap)
end

% Plots set of data read from running VorMod CPLEX model with OptSol
% (Optimization Solution; i.e. solving the "pure" 2-stage optimization
% problem).
% Currently plots the various BS solutions with usage upon the demand
% field, determines minimum and maximum demand usage of the BS within the
% selection, and determines overall demand satisfaction with the current
% solution.

% `alpha` and `alpharng` (which is equivalent to "length(alpha)") should be
% set according to the accompanying dataset.

sat = zeros(1, alpharng);
for index = 1:alpharng
sat(index) = satis(del_VorOptSol{index}, demand);
tmp = sum(del_VorOptSol{index}(:, :, 1), 1)';
Plot_VorMod_Grad(figure(index), BS, tmp, BS_cap, field)
fprintf('%d\nMax: %1.5e\t%1.5e\nMin: %1.5e\t%1.5e\n', index, max(tmp), max(tmp) / BS_cap, min(tmp(tmp > 0)), min(tmp(tmp > 0)) / BS_cap)
end
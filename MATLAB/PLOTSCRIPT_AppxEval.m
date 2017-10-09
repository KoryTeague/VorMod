% Plots set of data read from running VorMod CPLEX model with AppxEval
% (Approximation Evaluation; i.e. solving for demand slicing with demand
% points using the genetic algorithm BS solution as implemented in MATLAB).
% Currently plots the various BS solutions with usage upon the demand
% field, determines minimum and maximum demand usage of the BS within the
% selection, and determines overall demand satisfaction with the current
% solution.

% `beta` and `betarng` (which is equivalent to "length(beta)") should be
% set according to the accompanying dataset.

sat = zeros(1, betarng);
for index = 1:betarng
sat(index) = satis(del_VorAppxEval{index}, demand);
tmp = sum(del_VorAppxEval{index}(:, :, 1), 1)';
Plot_VorMod_Grad(figure(index), BS, tmp, BS_cap, field)
fprintf('\n%d:\tBeta\t%1.3f\nAvg Sat:\t%1.3f\nMax Load:\t%1.3e\t%1.3e\nMin Load:\t%1.3e\t%1.3e\n', index, beta(index), sat(index), max(tmp), max(tmp) / BS_cap, min(tmp(tmp > 0)), min(tmp(tmp > 0)) / BS_cap)
end

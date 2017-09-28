sat = zeros(1, alpharng);
for index = 1:alpharng
sat(index) = satis(del_VorOptSol{index}, demand);
tmp = sum(del_VorOptSol{index}(:, :, 1), 1)';
Plot_VorMod_Grad(figure(index), BS, tmp, BS_cap, field)
fprintf('%d\nMax: %1.5e\t%1.5e\nMin: %1.5e\t%1.5e\n', index, max(tmp), max(tmp) / BS_cap, min(tmp(tmp > 0)), min(tmp(tmp > 0)) / BS_cap)
end
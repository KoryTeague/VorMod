for index = 1:betarng
sat(index) = satis(del_VorAppxEval{index}, demand);
tmp = sum(del_VorAppxEval{index}(:, :, 1), 1)';
Plot_VorMod_Grad(figure, BS, tmp, BS_cap, field)
fprintf('Max: %1.5f\t%1.5f\nMin: %1.5f\t%1.5f\n', max(tmp), max(tmp) / BS_cap, min(tmp(tmp > 0)), min(tmp(tmp > 0)) / BS_cap)
end
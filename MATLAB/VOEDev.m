% Test deviation of satisfaction within the currently active VOE struct.

%{
minsat = VOE.sat;
maxsat = VOE.sat;

for iAlpha = 1:10:VOE.rng
    for iO = 1:VOE.O
        tmpsat = satis(VOE.del{iAlpha}(:, :, iO), demand);
        if tmpsat < minsat(iAlpha)
            minsat(iAlpha) = tmpsat;
        end
        if tmpsat > maxsat(iAlpha)
            maxsat(iAlpha) = tmpsat;
        end
    end
end
%}

sats = zeros((VOE.rng - 1)/ 10 + 1, VOE.O);

for iAlpha = 1:VOE.rng/10 + 1
    for iO = 1:VOE.O
        sats(iAlpha, iO) = ...
            satis(VOE.del{(iAlpha - 1) * 10 + 1}(:, :, iO), demand);
    end
end

figure
boxplot(sats', VOE.alpha(1:10:end), 'PlotStyle', 'compact')

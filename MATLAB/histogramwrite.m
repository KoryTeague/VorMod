for iter = 1:9
subplot(9,1,iter)
histogram(GARunTimes(:, iter), 200:10:850, 'normalization', 'pdf')
xlim([200 850])
ylim([0 0.1])
line([mean(GARunTimes(:, iter)) mean(GARunTimes(:, iter))], get(gca, 'YLim'), 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1)
line([ci_GARunTimes(1, iter) ci_GARunTimes(1, iter)], get(gca, 'YLim'), 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 1)
line([ci_GARunTimes(2, iter) ci_GARunTimes(2, iter)], get(gca, 'YLim'), 'Color', [0 0 0], 'LineStyle', '--', 'LineWidth', 1)
if iter < 9
set(gca, 'XTickLabel', [])
ylabel([num2str(new_GA_BETA(iter), '%2.1f')])
else
ylabel(['\beta = ' num2str(new_GA_BETA(iter), '%2.1f')])
xlabel('CPU Run Time (secs)')
end
end
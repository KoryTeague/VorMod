function Plot_VorMod_Grad( fig, BS, BS_load, BS_cap, field )
%Plot_VorMod_Grad Plots approximation with a gradient on the points
    % fig is the figure to plot to
    % BS is the list of BSs
    % BS_load is the loads attributed to each BS
    % BS_cap is the capacity of the BS
    % field is the lnfield object storing the field to plot over
    
    figure(fig)
    hold off
    surf(field.field-max(max(field.field)), 'linestyle', 'none')
    hold on
    if sum(BS_load>0) > 2
        voronoi(BS(BS_load>0, 1), BS(BS_load>0, 2), 'w')
    end
    scatter(BS(BS_load>0 & BS_load<=BS_cap/5, 1), BS(BS_load>0 & BS_load<=BS_cap/5, 2), 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor', 'k')
    scatter(BS(BS_load>BS_cap/5 & BS_load<=2*BS_cap/5, 1), BS(BS_load>BS_cap/5 & BS_load<=2*BS_cap/5, 2), 's', 'MarkerFaceColor', 'c', 'MarkerEdgeColor', 'k')
    scatter(BS(BS_load>2*BS_cap/5 & BS_load<=3*BS_cap/5, 1), BS(BS_load>2*BS_cap/5 & BS_load<=3*BS_cap/5, 2), 'v', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k')
    scatter(BS(BS_load>3*BS_cap/5 & BS_load<=4*BS_cap/5, 1), BS(BS_load>3*BS_cap/5 & BS_load<=4*BS_cap/5, 2), 'd', 'MarkerFaceColor', 'y', 'MarkerEdgeColor', 'k')
    scatter(BS(BS_load>4*BS_cap/5 & BS_load<=BS_cap, 1), BS(BS_load>4*BS_cap/5 & BS_load<=BS_cap, 2), '^', 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'k')
    scatter(BS(BS_load>BS_cap, 1), BS(BS_load>BS_cap, 2), 100, 'h', 'MarkerFaceColor', 'm', 'MarkerEdgeColor', 'k')
    view(0, 90)
    hold off
    title('Approximation Result with Highlighted Loads')

end

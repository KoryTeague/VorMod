function plotvormodslicing( fig, bsLoc, sel, selVoi, sli, bsCap, bsRad, ...
    field, pixelSize )
%plotvormodslicing Plot VorMod slicing with BS loading
	% fig is the figure handle to plot to
    % bsLoc is a matrix of size (S, 2), where S is the number of BSs; each
        % row represents a single BS, with the first column containing the
        % BS's x-coordinates, and the second column the y-coordinates
    % sel is a boolean column vector of length S indicating which BSs are
        % selected for the network; 1/true indicates the BS is selected,
        % 0/false indicates the BS is not selected
    % selVoi is a binary column vector of length S indicating which BSs
        % are displayed with a voronoi tessellation; 1 indicates the BS is
        % selected for the voronoi tessellation, 0/false indicates the BS
        % is not selected for the voronoi tessellation and is plotted as
        % circles using the BS's coverage radius as radius; selVoi(s) == 1
        % implies sel(s) == 1
    % sli is a matrix of size (M, S), where M is the number of demand
        % points the selection has been sliced to; each entry (m, s) is the
        % rate/slice that BS s has been allocated to demand point m
    % bsCap is a column vector of length S containing BS rate capacities
    % bsRad is a column vector of length S containing BS coverage radii
    % field is a matrix of size (X, Y), where X and Y are the number of
        % pixels of the field in the X and Y directions
    % pixelSize is the singleton indicating the side length of each pixel

    figure(fig)
    set(gcf, 'Position', [1200 300 600 420]);
    hold off
    clf
    ax1 = axes;
    [X, Y] = size(field);
    [gridX, gridY] = meshgrid(pixelSize : pixelSize : pixelSize * X,  ...
        pixelSize : pixelSize : pixelSize * Y);
    surf(ax1, gridX, gridY, field, 'linestyle', 'none');
    view(2)
    ax2 = axes;
    hold on
    if sum(selVoi) > 2
        voronoi(ax2, bsLoc(selVoi == 1, 1) * pixelSize, ...
            bsLoc(selVoi == 1, 2) * pixelSize, 'w');
        scatter(ax2, bsLoc(selVoi == 1, 1) * pixelSize, ...
            bsLoc(selVoi == 1, 2) * pixelSize, 60, 'w');
        scatter(ax2, bsLoc(selVoi == 1, 1) * pixelSize, ...
            bsLoc(selVoi == 1, 2) * pixelSize, 100, 'k');
    else
        warning('Not enough BSs selected for Voronoi tessellation.');
    end
    weights = sum(sli, 1)' ./ bsCap;
    scatter(ax2, bsLoc(sel == 1, 1) * pixelSize,    ...
        bsLoc(sel == 1, 2) * pixelSize, 25, weights(sel == 1), 'filled');
    viscircles(ax2, bsLoc(selVoi == 0 & sel == 1, :) * pixelSize,   ...
        bsRad(selVoi == 0 & sel == 1), 'Color', 'k', 'LineStyle', '--');
    linkaxes([ax1, ax2])
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax1, 'hot')
    colormap(ax2, 'winter')
    caxis(ax2, [0 1])
    set([ax1, ax2], 'Position', [.245 .1 .575 .83]);
    cb1 = colorbar(ax1, 'Position', [.105 .1 .035 .83]);
    cb1.Label.String = 'Rate Intensity (bps/m^2)';
    cb2 = colorbar(ax2, 'Position', [.845 .1 .035 .83]);
    cb2.Label.String = 'Proportional Allocated Capacity';
    x = xlabel(ax1, '(m)');
    set(x, 'Units', 'Normalized', 'Position', [-0.07 -0.03 0]);
    %ylabel(ax1, '(m)')
    xlim(ax1, [0 pixelSize * X])
    ylim(ax1, [0 pixelSize * Y])
    set(ax1, 'FontSize', 14)
    set(ax2, 'FontSize', 14)

end


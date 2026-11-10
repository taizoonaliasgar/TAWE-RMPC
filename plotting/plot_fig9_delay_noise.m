function plot_fig9_delay_noise(source, exportDir)
%PLOT_FIG9_DELAY_NOISE  Fig. 9: MPC-NDO vs. RMPC under (a) 50% stochastic
%   actuation latency and (b) joint-angle measurement noise.

if nargin < 1, source = 'paper'; end
if nargin < 2, exportDir = ''; end

hh = 0.02;
tSpan1 = 0:hh:10;
refData = make_reference('setpoint', tSpan1, 15);
color1 = "#791731"; color2 = "#284B63";

scen    = {'delay', 'noise'};
ylimRUD = {[0, 0.3],      [0, 0.25]};
ylimFE  = {[-0.15, 0.4],  [-0.1, 0.28]};

for s = 1:numel(scen)
    ndo  = load_run(['MPCNDO_' scen{s}], source);
    rmpc = load_run(['RMPC_' scen{s}], source);
    n = size(ndo.state, 2);
    tt = (1:n) * hh;

    figure('Color', 'w', 'Position', [100 100 1200 600]);
    yyaxis left
    ax1 = gca;
    set(ax1, 'Units', 'pixels', 'Position', [130, 110, 940, 470]);
    fe_props = {'LineWidth', 3, 'LineStyle', '-', 'Marker', 'none'};
    plot(tt, refData(1,1:n), 'k', 'LineWidth', 3, 'LineStyle', '-');
    hold on;
    plot(tt, ndo.state(1,1:n),  'Color', color1, fe_props{:});
    plot(tt, rmpc.state(1,1:n), 'Color', color2, fe_props{:});
    yl1 = ylabel('$\mathbf{q_{RUD}~(rad)}$', 'Interpreter', 'latex', 'FontSize', 38);
    set(yl1, 'Clipping', 'off');
    ax = gca; set(ax, 'Box', 'off'); ax.YColor = [0 0 0]; ax.YLim = ylimRUD{s};
    annotation('textbox', [0.11, 0.72, 0.1, 0.1], 'String', '$\mathbf{q_{\mathrm{RUD}}}$', ...
        'FontSize', 30, 'EdgeColor', 'none', 'Interpreter', 'latex');
    annotation('textbox', [0.82, 0.27, 0.1, 0.1], 'String', '$\mathbf{q_{\mathrm{FE}}}$', ...
        'FontSize', 30, 'EdgeColor', 'none', 'Interpreter', 'latex');

    yyaxis right
    hold on;
    fe_props = {'LineWidth', 4, 'LineStyle', '-.', 'Marker', 'none'};
    plot(tt, refData(2,1:n), 'k-.', 'LineWidth', 4);
    plot(tt, ndo.state(2,1:n),  'Color', color1, fe_props{:});
    plot(tt, rmpc.state(2,1:n), 'Color', color2, fe_props{:});
    ylabel('$\mathbf{q_{FE}~(rad)}$', 'Interpreter', 'latex', 'FontSize', 38);
    ax = gca; set(ax, 'Box', 'off'); ax.YColor = [0 0 0]; ax.YLim = ylimFE{s};

    xlabel('$\mathbf{Time~(s)}$', 'Interpreter', 'latex', 'FontSize', 38);
    legend({'$\mathrm{\textbf{Reference}}$', '${\mathrm{\textbf{MPC-NDO}}}$', '${\mathrm{\textbf{RMPC}}}$'}, ...
        'Interpreter', 'latex', 'FontSize', 33, 'Location', 'southwest');
    legend boxoff;
    xlim([1, 8]); grid on; box on;
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'LineWidth', 1.2);

    if ~isempty(exportDir)
        if ~isfolder(exportDir), mkdir(exportDir); end
        exportgraphics(gcf, fullfile(exportDir, sprintf('fig9%s_%s.png', char('a'+s-1), scen{s})), 'Resolution', 300);
    end
end
end

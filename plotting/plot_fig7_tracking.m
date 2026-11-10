function plot_fig7_tracking(source, exportDir)
%PLOT_FIG7_TRACKING  Fig. 7: joint tracking of MPC, NMPC, MPC-NDO and RMPC.
%   (a) set-point regulation, (b) sinusoidal reference.
%
%   plot_fig7_tracking()                 % from results/paper
%   plot_fig7_tracking('rerun')          % from results/rerun
%   plot_fig7_tracking('paper', 'figs')  % also export PNGs to ./figs

if nargin < 1, source = 'paper'; end
if nargin < 2, exportDir = ''; end

hh = 0.02;
tSpan1 = 0:hh:10;
scenarios = {'setpoint', 'sine'};
ylimsRUD  = {[0, 0.26],     [-0.5, 0.5]};
ylimsFE   = {[-0.23, 0.4],  [-0.25, 0.7]};

color1 = "#791731"; color2 = "#284B63"; color3 = "#9E9E9E"; color4 = "#E5751F";
ctrl   = {'MPC', 'NMPC', 'MPCNDO', 'RMPC'};
cols   = {color1, color2, color3, color4};
fe_props  = {'LineWidth', 4, 'LineStyle', '-',  'Marker', 'none'};
fe_props1 = {'LineWidth', 5, 'LineStyle', '--', 'Marker', 'none'};

for s = 1:numel(scenarios)
    refData = make_reference(scenarios{s}, tSpan1, 15);
    runs = cellfun(@(c) load_run([c '_' scenarios{s}], source), ctrl, 'UniformOutput', false);
    n = size(runs{1}.state, 2);
    tt = (1:n) * hh;

    figure('Color', 'w', 'Position', [100 100 1200 600]);
    yyaxis left
    ax1 = gca;
    set(ax1, 'Units', 'pixels', 'Position', [130, 110, 935, 470]);
    patch([3 7 7 3], [-1 -1 1 1], [0.7 0.7 0.7], 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    hold on;
    xline(3, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    xline(7, '--k', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    plot(tt, refData(1,1:n), 'k', fe_props{:});
    for c = 1:numel(ctrl)
        plot(tt, runs{c}.state(1,1:n), 'Color', cols{c}, fe_props{:});
    end
    yl1 = ylabel('$\mathbf{q_{RUD}~(rad)}$', 'Interpreter', 'latex', 'FontSize', 38);
    set(yl1, 'Clipping', 'off');
    ax = gca; set(ax, 'Box', 'off'); ax.YColor = [0 0 0]; ax.YLim = ylimsRUD{s};
    annotation('textbox', [0.11, 0.78, 0.1, 0.1], 'String', '$\mathbf{q_{\mathrm{RUD}}}$', ...
        'FontSize', 30, 'EdgeColor', 'none', 'Interpreter', 'latex');
    annotation('textbox', [0.82, 0.37, 0.1, 0.1], 'String', '$\mathbf{q_{\mathrm{FE}}}$', ...
        'FontSize', 30, 'EdgeColor', 'none', 'Interpreter', 'latex');

    yyaxis right
    hold on;
    plot(tt, refData(2,1:n), 'k', fe_props1{:});
    for c = 1:numel(ctrl)
        plot(tt, runs{c}.state(2,1:n), 'Color', cols{c}, fe_props1{:});
    end
    ylabel('$\mathbf{q_{FE}~(rad)}$', 'Interpreter', 'latex', 'FontSize', 38);
    ax = gca; set(ax, 'Box', 'off'); ax.YColor = [0 0 0]; ax.YLim = ylimsFE{s};

    xlabel('$\mathbf{Time~(s)}$', 'Interpreter', 'latex', 'FontSize', 38);
    legend({'', '$\mathrm{\textbf{Reference}}$', '$\mathrm{\textbf{MPC}}$', '$\mathrm{\textbf{NMPC}}$', ...
            '${\mathrm{\textbf{MPC-NDO}}}$', '${\mathrm{\textbf{RMPC}}}$'}, ...
        'Interpreter', 'latex', 'FontSize', 33, 'Location', 'southwest');
    xlim([1, 8]); grid on; box on;
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'LineWidth', 1.2);

    if ~isempty(exportDir)
        if ~isfolder(exportDir), mkdir(exportDir); end
        exportgraphics(gcf, fullfile(exportDir, sprintf('fig7%s_%s.png', char('a'+s-1), scenarios{s})), 'Resolution', 300);
    end
end
end

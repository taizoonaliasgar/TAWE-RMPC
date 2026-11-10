function plot_fig8_ndo(source, exportDir)
%PLOT_FIG8_NDO  Fig. 8: (a) actual vs. NDO-estimated disturbance torque,
%   (b) u_2 of MPC-NDO vs. RMPC, set-point regulation.

if nargin < 1, source = 'paper'; end
if nargin < 2, exportDir = ''; end

hh = 0.02;
color1 = "#791731"; color2 = "#284B63";

ndo  = load_run('MPCNDO_setpoint', source);
rmpc = load_run('RMPC_setpoint', source);
n = size(ndo.state, 2);
tt = (1:n) * hh;

figure('Color', 'w', 'Position', [100 100 1200 600]);

ax1 = subplot(2,1,1);
set(ax1, 'Units', 'pixels', 'Position', [150, 355, 1030, 225]);
plot(tt, ndo.tremor_torque(2,1:n), 'Color', color2, 'LineWidth', 4);
hold on;
plot(tt, ndo.tau_estimate(2,1:n), 'Color', color1, 'LineWidth', 4);
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'LineWidth', 1.2);
ylabel('{\boldmath$\tau_\mathrm{dist}$}\textbf{~(Nm)}', 'Interpreter', 'latex', 'FontSize', 38);
set(ax1, 'XTickLabel', []);
xlim([1, 8]); grid on; box on;
legend({'$\mathbf{Actual}$', '$\mathbf{Estimate}$'}, 'Interpreter', 'latex', 'FontSize', 33, 'Location', 'southwest');
legend boxoff;

ax2 = subplot(2,1,2);
set(ax2, 'Units', 'pixels', 'Position', [150, 110, 1030, 225]);
plot(tt, ndo.input(4,1:n),  'Color', color1, 'LineWidth', 4);
hold on;
plot(tt, rmpc.input(4,1:n), 'Color', color2, 'LineWidth', 4);
xlabel('$\mathbf{Time~(s)}$', 'Interpreter', 'latex', 'FontSize', 38);
ylabel('$\mathbf{u_2~(Nm)}$', 'Interpreter', 'latex', 'FontSize', 38);
legend({'${\mathrm{\textbf{MPC-NDO}}}$', '${\mathrm{\textbf{RMPC}}}$'}, 'Interpreter', 'latex', 'FontSize', 33, 'Location', 'southwest');
legend boxoff;
xlim([1, 8]); grid on; box on;
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'LineWidth', 1.2);

if ~isempty(exportDir)
    if ~isfolder(exportDir), mkdir(exportDir); end
    exportgraphics(gcf, fullfile(exportDir, 'fig8_ndo.png'), 'Resolution', 300);
end
end

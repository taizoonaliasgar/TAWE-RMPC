function plot_fig10_11_experimental(source, exportDir)
%PLOT_FIG10_11_EXPERIMENTAL  Figs. 10-11: MPC-NDO vs. RMPC under
%   patient-derived tremor. Fig. 10(b) joint states, Fig. 11 control inputs.
%
%   Fig. 10(a), the patient-derived disturbance torque, is drawn only if the
%   run includes a tremor_torque file. That signal is derived from the
%   participant recording, which is not distributed with this repository.

if nargin < 1, source = 'paper'; end
if nargin < 2, exportDir = ''; end

hh = 0.02;
refData = make_reference('exp', 0:hh:12, 15);
color1 = "#791731"; color2 = "#284B63"; color3 = "#9E9E9E"; color4 = "#E5751F";
fe_props  = {'LineWidth', 4, 'LineStyle', '-',  'Marker', 'none'};
fe_props1 = {'LineWidth', 5, 'LineStyle', '--', 'Marker', 'none'};

ndo  = load_run('MPCNDO_exp', source);
rmpc = load_run('RMPC_exp', source);
n = size(ndo.state, 2);
tt = (1:n) * hh;
haveTorque = isfield(ndo, 'tremor_torque');

%% Fig. 10
figure('Color', 'w', 'Position', [100 100 1200 700]);
if haveTorque
    ax1 = subplot(2,1,1);
    set(ax1, 'Units', 'pixels', 'Position', [150, 480, 920, 190]);
    plot(tt, ndo.tremor_torque(1,1:n), 'Color', color1, fe_props{:}); hold on;
    plot(tt, ndo.tremor_torque(2,1:n), 'Color', color2, fe_props{:});
    ax1.YLim = [-0.75, 0.5]; ax1.XLim = [1, 11];
    grid on;
    set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'XTickLabel', []);
    legend({'$\mathbf{\tau_1}$', '$\mathbf{\tau_2}$'}, 'Interpreter', 'latex', 'FontSize', 45, ...
        'Location', 'southwest', 'NumColumns', 2);
    ylabel('{\boldmath$\tau_\mathrm{dist}$}\textbf{~(Nm)}', 'Interpreter', 'latex', 'FontSize', 38);
    ax2 = subplot(2,1,2);
    set(ax2, 'Units', 'pixels', 'Position', [150, 110, 920, 350]);
else
    ax2 = gca;
    set(ax2, 'Units', 'pixels', 'Position', [150, 110, 920, 560]);
end

yyaxis left
ax2.YColor = [0 0 0];
p1 = plot(tt, refData(1,1:n), 'k-', fe_props{:}); hold on;
p2 = plot(tt, ndo.state(1,1:n),  'Color', color3, fe_props{:});
p3 = plot(tt, rmpc.state(1,1:n), 'Color', color4, fe_props{:});
ax3 = gca; ax3.YLim = [-0.3, 0.08];
ylabel('$\mathbf{q_{RUD}~(rad)}$', 'Interpreter', 'latex', 'FontSize', 38);

yyaxis right
ax2.YColor = [0 0 0];
plot(tt, refData(2,1:n), 'k--', fe_props1{:});
plot(tt, ndo.state(2,1:n),  'Color', color3, fe_props1{:});
plot(tt, rmpc.state(2,1:n), 'Color', color4, fe_props1{:});
ylabel('$\mathbf{q_{FE}~(rad)}$', 'Interpreter', 'latex', 'FontSize', 38);
xlabel('$\mathbf{Time~(s)}$', 'Interpreter', 'latex', 'FontSize', 38);
ax4 = gca; ax4.YLim = [-0.16, 0.3]; ax4.XLim = [1, 11];
grid on;
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32);
legend([p1, p2, p3], {'$\mathrm{\textbf{Reference}}$', '${\mathrm{\textbf{MPC-NDO}}}$', '${\mathrm{\textbf{RMPC}}}$'}, ...
    'Interpreter', 'latex', 'FontSize', 33, 'Location', 'southwest');

if ~isempty(exportDir)
    if ~isfolder(exportDir), mkdir(exportDir); end
    exportgraphics(gcf, fullfile(exportDir, 'fig10_exp_states.png'), 'Resolution', 300);
end

%% Fig. 11
figure('Color', 'w', 'Position', [100 100 1200 500]);
yyaxis left
ax1 = gca;
set(ax1, 'Units', 'pixels', 'Position', [120, 110, 970, 360]);
p5 = plot(tt, rmpc.input(3,1:n), 'Color', color4, fe_props{:}); hold on;
p6 = plot(tt, ndo.input(3,1:n),  'Color', color3, fe_props{:});
ylabel('$\mathbf{u_1~(Nm)}$', 'Interpreter', 'latex', 'FontSize', 38);
ax = gca; ax.YColor = [0 0 0]; ax.YLim = [-6, 2]; ax.XLim = [1, 11];
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32);

yyaxis right
plot(tt, rmpc.input(4,1:n), 'Color', color4, fe_props{:}); hold on;
plot(tt, ndo.input(4,1:n),  'Color', color3, fe_props{:});
annotation('textbox', [0.10, 0.75, 0.1, 0.1], 'String', '$\mathbf{u_1}$', ...
    'FontSize', 30, 'EdgeColor', 'none', 'Interpreter', 'latex');
annotation('textbox', [0.86, 0.4, 0.1, 0.1], 'String', '$\mathbf{u_2}$', ...
    'FontSize', 30, 'EdgeColor', 'none', 'Interpreter', 'latex');
ylabel('$\mathbf{u_2~(Nm)}$', 'Interpreter', 'latex', 'FontSize', 38);
ax = gca; ax.YColor = [0 0 0]; ax.YLim = [-1, 6]; ax.XLim = [1, 11];
grid on; box on;
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32);
legend([p5, p6], {'${\mathrm{\textbf{RMPC}}}$', '${\mathrm{\textbf{MPC-NDO}}}$'}, ...
    'Interpreter', 'latex', 'FontSize', 33, 'Location', 'southeast', 'NumColumns', 2);
xlabel('$\mathbf{Time~(s)}$', 'Interpreter', 'latex', 'FontSize', 38);

if ~isempty(exportDir)
    if ~isfolder(exportDir), mkdir(exportDir); end
    exportgraphics(gcf, fullfile(exportDir, 'fig11_exp_inputs.png'), 'Resolution', 300);
end
end

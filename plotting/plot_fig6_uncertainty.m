function plot_fig6_uncertainty(source, exportDir, vertexSet)
%PLOT_FIG6_UNCERTAINTY  Fig. 6: (a) simulated tremor torques, (b) joint-velocity
%   deviations caused by tremor and the RMPC uncertainty-set vertices.
%
%   The velocity-deviation data is results/paper/velocity_deviation_setpoint.mat
%   (variable comparingdq, from an MPC set-point run). Rows 7-8 hold the
%   reduced-model accelerations and rows 11-12 the full-system accelerations,
%   so (row11-row7)*dt and (row12-row8)*dt give the per-step velocity deviation.
%   Vertices come from uncertainty_vertices(vertexSet).

if nargin < 1, source = 'paper'; end
if nargin < 2, exportDir = ''; end
if nargin < 3, vertexSet = 'paper'; end

hh = 0.02;
color1 = "#791731"; color2 = "#284B63";
fe_props = {'LineWidth', 4, 'LineStyle', '-', 'Marker', 'none'};

ndo = load_run('MPCNDO_setpoint', source);
n = size(ndo.state, 2);

%% (a) tremor torques
figure('Color', 'w', 'Position', [100 100 1200 500]);
ax1 = gca;
set(ax1, 'Units', 'pixels', 'Position', [130, 110, 1050, 370]);
plot((1:n)*hh, ndo.tremor_torque(1,1:n), 'Color', color1, fe_props{:}); hold on;
plot((1:n)*hh, ndo.tremor_torque(2,1:n), 'Color', color2, fe_props{:});
legend({'$\mathbf{\tau_1}$', '$\mathbf{\tau_2}$'}, 'Interpreter', 'latex', 'FontSize', 45, 'Location', 'southwest');
xlabel('$\mathbf{Time~(s)}$', 'Interpreter', 'latex', 'FontSize', 38);
ylabel('{\boldmath$\tau_\mathrm{dist}$}\textbf{~(Nm)}', 'Interpreter', 'latex', 'FontSize', 38);
xlim([2, 8]); grid on; box on;
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'LineWidth', 1.2);
if ~isempty(exportDir)
    if ~isfolder(exportDir), mkdir(exportDir); end
    exportgraphics(gcf, fullfile(exportDir, 'fig6a_tremor_torque.png'), 'Resolution', 300);
end

%% (b) velocity deviations and uncertainty set
S = load(fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'paper', ...
    'velocity_deviation_setpoint.mat'), 'comparingdq');
comparingdq = S.comparingdq;
V = uncertainty_vertices(vertexSet);
Vc = [V; V(1,:)];

figure('Color', 'w', 'Position', [100 100 1200 500]);
ax1 = gca;
set(ax1, 'Units', 'pixels', 'Position', [130, 110, 1050, 370]);
plot((comparingdq(11,:)-comparingdq(7,:))*hh, (comparingdq(12,:)-comparingdq(8,:))*hh, ...
    'Color', color2, 'Marker', 'o', 'MarkerSize', 15, 'LineWidth', 3, 'LineStyle', 'none');
hold on;
plot(V(:,1), V(:,2), 'Color', color1, 'Marker', '*', 'MarkerSize', 25, 'LineWidth', 3, 'LineStyle', 'none');
plot(Vc(:,1), Vc(:,2), 'Color', color1, 'LineStyle', '--', 'LineWidth', 2, 'HandleVisibility', 'off');
xlabel('$\mathbf{\delta \dot{q}_1}$', 'Interpreter', 'latex', 'FontSize', 38);
ylabel('$\mathbf{\delta \dot{q}_2}$', 'Interpreter', 'latex', 'FontSize', 38);
legend({'$\mathbf{\tau_{\mathrm{dist}}\Delta t}$', sprintf('$\\mathbf{n_{\\mathcal{W}}=%d}$', size(V,1))}, ...
    'Interpreter', 'latex', 'FontSize', 45, 'Location', 'northeast');
ylim([-1.5, 1.5]); grid on; box on;
set(gca, 'TickLabelInterpreter', 'latex', 'FontSize', 32, 'LineWidth', 1.2);
if ~isempty(exportDir)
    exportgraphics(gcf, fullfile(exportDir, 'fig6b_uncertainty_set.png'), 'Resolution', 300);
end
end

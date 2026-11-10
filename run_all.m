%% Reproduce the paper's tables and figures.
%
%   run_all                      % plot figures + tables from the shipped results
%   rerunSimulations = true;     % ...or regenerate results first (slow; see README)
%   run_all
%
% Figures are exported to ./figs. The experimental-tremor simulations
% (Sec. 6.3) are skipped unless the participant recording is available;
% see README.

setup_paths;

if ~exist('rerunSimulations', 'var'), rerunSimulations = false; end
source = 'paper';

if rerunSimulations
    source = 'rerun';
    jobs = {
        'sim_MPC',             'setpoint'
        'sim_MPC',             'sine'
        'sim_NMPC',            'setpoint'
        'sim_NMPC',            'sine'
        'sim_MPC_NDO',         'setpoint'
        'sim_MPC_NDO',         'sine'
        'sim_RMPC',            'setpoint'
        'sim_RMPC',            'sine'
        'sim_MPC_NDO_delay',   ''
        'sim_RMPC_delay',      ''
        'sim_MPC_NDO_noise',   ''
        'sim_RMPC_noise',      ''
    };
    for k = 1:size(jobs, 1)
        run_one(jobs{k,1}, jobs{k,2});
    end
    if isfile(fullfile('data', 'private', 'Data2_ET0220.mat'))
        run_one('sim_MPC_NDO_exp', '');
        run_one('sim_RMPC_exp', '');
    else
        fprintf('Skipping experimental-tremor runs (participant data not present).\n');
    end
end

compute_rmse_tables(source);
plot_fig6_uncertainty(source, 'figs');
plot_fig7_tracking(source, 'figs');
plot_fig8_ndo(source, 'figs');
plot_fig9_delay_noise(source, 'figs');
try
    plot_fig10_11_experimental(source, 'figs');
catch err
    fprintf('Skipping Figs. 10-11: %s\n', err.message);
end

function run_one(script, scenario)
% Each simulation script runs in its own workspace so variables don't leak
% between runs.
if ~isempty(scenario)
    fprintf('\n=== %s (%s) ===\n', script, scenario);
else
    fprintf('\n=== %s ===\n', script);
end
run(script);
end

function R = load_run(runName, source)
%LOAD_RUN  Load a saved simulation run.
%
%   R = load_run('RMPC_setpoint')            % from results/paper
%   R = load_run('RMPC_setpoint', 'rerun')   % from results/rerun
%
%   Returns a struct with fields
%     state  - 18-by-T simulation state (rows 1-2: q_RUD, q_FE; rows 10-11: their rates)
%     input  - 8-by-T input (rows 3-4: exoskeleton torques u_1, u_2)
%   plus any of these when the corresponding file exists:
%     tremor_torque, tau_estimate, cost, vertex_weights

if nargin < 2 || isempty(source)
    source = 'paper';
end

root = fullfile(fileparts(mfilename('fullpath')), '..', 'results', source);
f = @(prefix) fullfile(root, [prefix runName '.mat']);

if ~isfile(f('state_'))
    error('load_run:missing', 'No results for "%s" in %s.', runName, root);
end

S = load(f('state_'), 'simStateData');  R.state = S.simStateData;
S = load(f('input_'), 'simInputData');  R.input = S.simInputData;

optional = {'tremor_torque_', 'tremortorque',  'tremor_torque';
            'tau_estimate_',  'taud_estimate', 'tau_estimate';
            'cost_',          'J0',            'cost';
            'vertex_weights_','vertexweights', 'vertex_weights'};
for k = 1:size(optional, 1)
    if isfile(f(optional{k,1}))
        S = load(f(optional{k,1}), optional{k,2});
        R.(optional{k,3}) = S.(optional{k,2});
    end
end
end

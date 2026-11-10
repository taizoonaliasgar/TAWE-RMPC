function T = compute_rmse_tables(source)
%COMPUTE_RMSE_TABLES  Recompute the RMSE values in Tables 2, 3 and 4.
%
%   compute_rmse_tables()          % from results/paper
%   compute_rmse_tables('rerun')   % from your own reruns in results/rerun
%
%   RMSE windows follow the original analysis scripts:
%     simulated tremor (Tables 2-3, Table 4 delay/noise): samples 151:350 (t = 3-7 s)
%     patient-derived tremor (Table 4, experimental):     samples 101:500

if nargin < 1, source = 'paper'; end
hh = 0.02;
tSpan1 = 0:hh:10;
ref = make_reference('setpoint', tSpan1, 15);
refExp = make_reference('exp', 0:hh:12, 15);

rows = {
 % table      label                 run                    reference  window
  'Table 2',  'MPC',                'MPC_setpoint',         'sp',  151:350;
  'Table 2',  'NMPC',               'NMPC_setpoint',        'sp',  151:350;
  'Table 2',  'MPC-NDO',            'MPCNDO_setpoint',      'sp',  151:350;
  'Table 2',  'RMPC',               'RMPC_setpoint',        'sp',  151:350;
  'Table 3',  'RMPC nW=4',          'RMPC_setpoint',        'sp',  151:350;
  'Table 3',  'RMPC nW=5',          'RMPC_setpoint_nW5',    'sp',  151:350;
  'Table 3',  'RMPC nW=6',          'RMPC_setpoint_nW6',    'sp',  151:350;
  'Table 4',  'Delay MPC-NDO',      'MPCNDO_delay',         'sp',  151:350;
  'Table 4',  'Delay RMPC',         'RMPC_delay',           'sp',  151:350;
  'Table 4',  'Noise MPC-NDO',      'MPCNDO_noise',         'sp',  151:350;
  'Table 4',  'Noise RMPC',         'RMPC_noise',           'sp',  151:350;
  'Table 4',  'Exp. MPC-NDO',       'MPCNDO_exp',           'exp', 101:500;
  'Table 4',  'Exp. RMPC',          'RMPC_exp',             'exp', 101:500;
};

Tbl = {}; Lbl = {}; RUD = []; FE = [];
for k = 1:size(rows, 1)
    try
        R = load_run(rows{k,3}, source);
    catch
        continue  % run not available in this source
    end
    if strcmp(rows{k,4}, 'exp'), r = refExp; else, r = ref; end
    idx = rows{k,5};
    Tbl{end+1,1} = rows{k,1};                                   %#ok<AGROW>
    Lbl{end+1,1} = rows{k,2};                                   %#ok<AGROW>
    RUD(end+1,1) = sqrt(mean((R.state(1,idx) - r(1,idx)).^2));  %#ok<AGROW>
    FE(end+1,1)  = sqrt(mean((R.state(2,idx) - r(2,idx)).^2));  %#ok<AGROW>
end

T = table(Tbl, Lbl, RUD, FE, 'VariableNames', {'Table', 'Run', 'RMSE_qRUD', 'RMSE_qFE'});
fprintf('\nRMSE (rad) from results/%s\n', source);
disp(T);
end

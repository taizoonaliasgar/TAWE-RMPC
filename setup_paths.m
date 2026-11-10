function setup_paths()
%SETUP_PATHS  Add the TAWE-RMPC folders to the MATLAB path.
%
%   Run once per MATLAB session from anywhere:
%       run('/path/to/TAWE-RMPC/setup_paths.m')
%
%   CasADi (NMPC only) and qpSWIFT (all MPC/RMPC variants) are external
%   dependencies. Add them to the path yourself, or put them in ./external/
%   and they will be picked up automatically.

root = fileparts(mfilename('fullpath'));

dirs = {'model', 'lib', 'controllers', 'uncertainty', 'data', ...
        'simulations', 'plotting', 'external'};
for k = 1:numel(dirs)
    d = fullfile(root, dirs{k});
    if isfolder(d)
        addpath(genpath(d));
    end
end
% derivation scripts are not needed on the path for simulation
rmpath(genpath(fullfile(root, 'model', 'derivation')));

out = fullfile(root, 'results', 'rerun');
if ~isfolder(out), mkdir(out); end

if isempty(which('qpSWIFT'))
    warning('setup_paths:qpSWIFT', ...
        'qpSWIFT not found on the path. MPC/RMPC simulations need it (see README).');
end
end

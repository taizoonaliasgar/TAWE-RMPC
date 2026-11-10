function V = build_uncertainty_set(nW, comparingdq, idx, hh)
%BUILD_UNCERTAINTY_SET  Fit an nW-vertex polygon around tremor-induced
%   joint-velocity deviations (Sec. 5.1, Fig. 6b, Table 3).
%
%   V = build_uncertainty_set(4)              % uses the shipped set-point data
%   V = build_uncertainty_set(nW, comparingdq) % your own simulation data
%
%   comparingdq is the 16-by-T matrix logged by the MPC simulation. Rows 7-8
%   hold the reduced-model joint accelerations and rows 11-12 the full-system
%   joint accelerations. Their difference times the step size hh is the
%   per-step velocity deviation caused by the tremor torque.
%
%   idx (default 152:350) selects the samples while tremor is active
%   (t = 3-7 s at 50 Hz).
%
%   Returns an nW-by-2 vertex matrix in the format of uncertainty_vertices.m.
%   The polygon comes from enclosingPolygonByAngleSampling: sample the
%   convex hull at evenly spaced angles, then expand until every point is
%   enclosed.

if nargin < 1, nW = 4; end
if nargin < 2 || isempty(comparingdq)
    S = load(fullfile(fileparts(mfilename('fullpath')), '..', 'results', 'paper', ...
        'velocity_deviation_setpoint.mat'), 'comparingdq');
    comparingdq = S.comparingdq;
end
if nargin < 3 || isempty(idx), idx = 152:350; end
if nargin < 4 || isempty(hh), hh = 0.02; end

dqunc = [comparingdq(11,idx) - comparingdq(7,idx);
         comparingdq(12,idx) - comparingdq(8,idx)] * hh;
dqunc = dqunc(:, all(isfinite(dqunc), 1));

[V, area] = enclosingPolygonByAngleSampling(dqunc.', nW);
fprintf('nW = %d, polygon area = %.4f\n', nW, area);
end

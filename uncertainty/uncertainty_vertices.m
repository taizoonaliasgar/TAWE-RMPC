function V = uncertainty_vertices(set_name)
%UNCERTAINTY_VERTICES  Vertices d^l of the RMPC uncertainty set W (Sec. 5.1).
%
%   V = uncertainty_vertices()          % paper vertices (default)
%   V = uncertainty_vertices('paper')
%   V = uncertainty_vertices('minRn2')
%
%   Returns an nW-by-2 matrix. Row l is the vertex d^l = [dq1_dot, dq2_dot]
%   (joint-velocity deviation for RUD and FE) used in the RMPC.
%
%   'paper'  - d^1..d^4 as printed in Sec. 5.1 of the paper. The exact
%              values used for the published runs were not saved separately,
%              so reruns may differ slightly from the published numbers.
%   'minRn2' - set saved in data/minRn2.mat (an alternative 4-vertex fit).
%
%   To build a new set from your own simulation data, see
%   uncertainty/build_uncertainty_set.m.

if nargin < 1 || isempty(set_name)
    set_name = 'paper';
end

switch lower(set_name)
    case 'paper'
        V = [-0.72, -0.15;
             -0.17, -1.33;
              0.74, -0.32;
             -0.04,  1.25];
    case 'minrn2'
        S = load('minRn2.mat', 'minRn2');
        V = S.minRn2;
    otherwise
        error('uncertainty_vertices:unknownSet', ...
              'Unknown vertex set "%s". Use ''paper'' or ''minRn2''.', set_name);
end
end

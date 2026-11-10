function weights = compute_vertex_weights(q1_q2, w)
% Inputs:
%   q1_q2: current state position [q1; q2]
%   w: 2xN matrix of uncertainty directions [dq1; dq2] for N vertices
%
% Output:
%   weights: 1xN weight vector to scale cost for each vertex
    [~,wlen] = size(w);
    w_unit = ones(2,wlen);
    raw_weights= 1/wlen*ones(wlen,1);
    % Normalize the uncertainty directions
    for i=1:wlen
        w_unit(:,i) = normalize_columns(w(3:4,i));
    end
    

    % Normalize the state direction
    state_dir = q1_q2 / norm(q1_q2);

    % % Compute angle or distance between state and each vertex direction
    % angles = acos(max(min(dot(w_unit, state_dir), 1), -1));  % Clamp to avoid NaN
    % 
    % % Convert angles into weights: lower angle → higher weight
    % raw_weights = cos(angles);  % Or 1 ./ (1 + angles) for inverse distance
    for i=1:wlen
        raw_weights(i) = dot(w_unit(:,i),state_dir);
    end

    % Ensure non-negativity and normalize
    weights = raw_weights - min(raw_weights);  
    weights = weights / sum(weights + 1e-6);  % Normalize to sum to 1

end

function W = normalize_columns(W)
    norms = sqrt(sum(W.^2,1));
    W = W ./ (norms + 1e-6);  % Avoid division by zero
end

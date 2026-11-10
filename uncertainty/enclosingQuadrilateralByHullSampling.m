function [quad4, area] = enclosingQuadrilateralByHullSampling(P)
% Returns a convex quadrilateral enclosing all points
% Samples from convex hull and expands until all points are enclosed

    % Step 1: Compute convex hull
    k = convhull(P(:,1), P(:,2));
    hull = P(k(1:end-1), :);  % remove duplicate last point

    % Step 2: Sample 4 evenly spaced points from convex hull
    n = size(hull, 1);
    idx = round(linspace(1, n+1, 5));  % 5 indices to get 4 segments
    idx = idx(1:4);
    quad4 = hull(idx, :);

    % Step 3: Expand outward from centroid until all points are inside
    center = mean(quad4, 1);
    scale = 1.05;

    while true
        vectors = quad4 - center;
        testQuad = center + scale * vectors;

        % Check if all points are inside
        inside = inpolygon(P(:,1), P(:,2), ...
                           [testQuad(:,1); testQuad(1,1)], ...
                           [testQuad(:,2); testQuad(1,2)]);

        if all(inside)
            quad4 = testQuad;
            break;
        end

        scale = scale + 0.05;
        if scale > 5
            warning('Could not find enclosing quadrilateral after large expansion.');
            break;
        end
    end

    area = polyarea(quad4(:,1), quad4(:,2));
end

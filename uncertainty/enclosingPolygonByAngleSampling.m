function [poly_out, area] = enclosingPolygonByAngleSampling(P, nvert)
% Returns an nvert-gon enclosing all 2D points using angle-based hull sampling

    % Step 1: Compute convex hull
    k = convhull(P(:,1), P(:,2));
    hull = P(k(1:end-1), :);  % remove duplicate closing point

    % Step 2: Get centroid
    center = mean(hull, 1);

    % Step 3: Compute angles of hull points from centroid
    vectors = hull - center;
    angles = atan2(vectors(:,2), vectors(:,1));
    
    % Step 4: Sort hull points by angle
    [angles_sorted, idx_sorted] = sort(angles);
    hull_sorted = hull(idx_sorted, :);

    % Step 5: Sample nvert evenly spaced angles
    n = size(hull_sorted, 1);
    idx = round(linspace(1, n + 1, nvert + 1));
    idx = mod(idx - 1, n) + 1;
    poly = hull_sorted(idx(1:nvert), :);

    % Step 6: Expand polygon outward
    center = mean(poly, 1);
    vectors = poly - center;
    poly = center + 1.1 * vectors;

    % Step 7: Re-expand if needed to contain all points
    while ~all(inpolygon(P(:,1), P(:,2), [poly(:,1); poly(1,1)], [poly(:,2); poly(1,2)]))
        vectors = poly - center;
        poly = center + 1.05 * vectors;
    end

    poly_out = poly;
    area = polyarea(poly(:,1), poly(:,2));
end

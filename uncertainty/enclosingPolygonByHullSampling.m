function [hex6, area] = enclosingPolygonByHullSampling(P,nvert)
% Always returns a 6-vertex convex polygon enclosing all points
% by sampling convex hull and expanding outward slightly

    % Step 1: Convex hull
    k = convhull(P(:,1), P(:,2));
    hull = P(k(1:end-1), :);  % remove duplicate

    % Step 2: Sample 6 nearly evenly spaced points from hull
    n = size(hull,1);
    idx = round(linspace(1, n, nvert+1));  % 7 to wrap around
    idx = idx(1:nvert);
    hex6 = hull(idx, :);

    % Step 3: Expand polygon slightly from centroid
    center = mean(hex6,1);
    vectors = hex6 - center;
    hex6 = center + 1.1 * vectors;  % 10% outward push to ensure enclosure

    % Step 4: Check and re-expand if needed
    while ~all(inpolygon(P(:,1), P(:,2), [hex6(:,1); hex6(1,1)], [hex6(:,2); hex6(1,2)]))
        vectors = hex6 - center;
        hex6 = center + 1.05 * vectors;
    end

    area = polyarea(hex6(:,1), hex6(:,2));
end

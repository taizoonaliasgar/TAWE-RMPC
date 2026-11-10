function [quad, area] = minimumBoundingQuadrilateral(P)
% Returns a convex quadrilateral enclosing all points with minimum area
% Input:  P - Nx2 matrix of 2D points
% Output: quad - 4x2 matrix of quadrilateral vertices
%         area - polygon area

    % Step 1: Get convex hull
    k = convhull(P(:,1), P(:,2));
    hull = P(k(1:end-1), :);  % remove duplicate
    nh = size(hull, 1);

    minArea = inf;
    quad = [];

    % Step 2: Try all combinations of 4 convex hull points
    combos = nchoosek(1:nh, 4);
    for i = 1:size(combos,1)
        idx = combos(i,:);
        q = hull(idx, :);

        % Ensure it's convex and ordered
        if ~isConvexCCW(q)
            continue;
        end

        % Check if all points are inside
        in = inpolygon(P(:,1), P(:,2), [q(:,1); q(1,1)], [q(:,2); q(1,2)]);
        if all(in)
            a = polyarea(q(:,1), q(:,2));
            if a < minArea
                minArea = a;
                quad = q;
            end
        end
    end

    area = minArea;
end

function tf = isConvexCCW(poly)
% Check if polygon is convex and counterclockwise (required by polyarea)
    n = size(poly,1);
    z = zeros(n,1);
    for i = 1:n
        a = poly(i,:) - poly(mod(i-2,n)+1,:);
        b = poly(mod(i,n)+1,:) - poly(i,:);
        z(i) = a(1)*b(2) - a(2)*b(1);
    end
    tf = all(z > 0) || all(z < 0);
end

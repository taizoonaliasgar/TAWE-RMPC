function [minRect, minArea] = minBoundingRectangle(P)
    % Input: P is Nx2 array of (x, y) points
    % Output: minRect is 4x2 array of rectangle corners
    %         minArea is the area of the rectangle

    % Step 1: Convex hull
    k = convhull(P(:,1), P(:,2));
    hull = P(k(1:end-1), :);  % exclude repeated last point
    n = size(hull, 1);

    minArea = Inf;
    minRect = [];

    for i = 1:n
        % Compute edge angle
        edge = hull(mod(i,n)+1,:) - hull(i,:);
        theta = -atan2(edge(2), edge(1)); % rotation angle to align edge with x-axis
        R = [cos(theta), -sin(theta); sin(theta), cos(theta)];
        
        % Rotate all hull points
        rotHull = (R * hull')';
        
        % Get bounding box in rotated frame
        xmin = min(rotHull(:,1)); xmax = max(rotHull(:,1));
        ymin = min(rotHull(:,2)); ymax = max(rotHull(:,2));
        
        area = (xmax - xmin) * (ymax - ymin);
        
        if area < minArea
            minArea = area;
            % Rectangle corners in rotated frame
            rectRot = [
                xmin, ymin;
                xmax, ymin;
                xmax, ymax;
                xmin, ymax
            ];
            % Transform back to original coordinates
            minRect = (R' * rectRot')';
        end
    end
end

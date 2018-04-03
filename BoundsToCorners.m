function corners = BoundsToCorners(bounds)
%BOUNDSTOCORNERS converts the bounds into four corner points
%   
corners = [ bounds(1,2), bounds(2,2); ...
    bounds(1,1), bounds(2,2); ...
    bounds(1,1), bounds(2,1); ...
    bounds(1,2), bounds(2,1)];
end
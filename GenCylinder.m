function pts = GenCylinder(base, radii, height, uSolar)
%  GENCYLINDER returns points that cast a shadow from a vertically oriented 
%  segment of a conical surface
%
%   base is a [x y z] point at the center of the bottom face
%   radii is [rbottom rtop]
%   height is the vertical distance from base to upper disk
%   uSolar is a unit vector pointing to the Sun
%
% We first calculate horizontal unit vectors along the sun and orthogonal
% to it
    nOnArc = 18; % number of points on each semicircular arc
    dArc = pi / nOnArc;
    % compute a horizontal unit vector along the line to the Sun
    along = [uSolar(1), uSolar(2), 0] ./ sqrt(uSolar(1)^2 + uSolar(2)^2);
    % and its horizontal perpendicular unit vector
    perp = [along(2), -along(1), 0];
    % Preallocate the points for the semicircles
    top = zeros(nOnArc+1,3);
    bottom = top;
    for n=0:nOnArc
        top(n+1,:) = (perp * cos(n * dArc) - along * sin(n * dArc));
        top(n+1,3) = height;
        bottom(n+1,1:2) = -top(n+1,1:2) * radii(1);
        top(n+1,1:2) = top(n+1,1:2) * radii(2);
    end
    % During development, I wanted a closed figure, so I add the first point
    % to the end. Using polyshape means we don't want to do this.
    % pts = [top; bottom; [top(1,:)]] + base;
    pts = [top; bottom] + base;
end


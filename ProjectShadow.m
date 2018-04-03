function pts = ProjectShadow(points, SunAngles, PanelAngles, PanelOrigin)
%PROJECTSHADOW yields the projection of the shadow from points onto the
%  Panel plane
%
%  SunAngles are [theta, phi], with theta measured from straight up
%  Panel Angles are [theta, phi]
%  These angles are assumed in degrees
%  Panel Origin is (x, y, z) in local coordinates
    theta = deg2rad(PanelAngles(1));
    phi = deg2rad(PanelAngles(2));
    ux = [-sin(phi), cos(phi), 0];
    uy = [-cos(theta) * cos(phi), -cos(theta)*sin(phi), sin(theta)];
    uz = [sin(theta)*cos(phi), sin(theta)*sin(phi), cos(theta)];
    uSun = UVector(SunAngles);
    % Compute the matrix that applied to a position yields the xy coordinates
    % of the projected point on the panel plane.
    m = inv([ux; uy; uSun]');
    p = m * (points(1,:) - PanelOrigin)';
    % if the z component of the transformed point is negative, the Sun is
    % shining towards the back of the panel plane, so we should return an
    % empty list?
    if p(3) < 0
        pts = [];
    else
        [npoints,~] = size(points);
        pts = zeros(npoints,2); % preallocate answer
        % There is probably a way to do this without a for loop...
        for n = 1:npoints
            p = m * (points(n,:) - PanelOrigin)';
            pts(n,:) = p(1:2); % chop to just the xy panel coordinate plane
        end
    end
end
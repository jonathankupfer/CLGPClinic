bounds = [0 2; 0 2];
panel = polyshape([0 2 2 0], [0 0 2 2]);
panelAngles = [56, -90];
times = (0:5:1080) / 60 + 4;
location = [34, -117];
the_date = '2018-03-01';

for n = 1:length(times)
    sstate = SolarState(the_date, times(n), location);
    if sstate.hours < sstate.t_sunrise || sstate.hours > sstate.t_sunset
        continue;
    end
    sunAngles = sstate.sun_angles;
    uSolar = UVector(sunAngles);
    cyl = Cylinder([1, -0.3, 0], 0.2, 1, uSolar);
    cone = GenCylinder([1, -0.3, 1], [0.3 0.2], 0.5, uSolar);

    pts = ProjectShadow(cyl, sunAngles, panelAngles, [0 0 0]);
    cpts = ProjectShadow(cone, sunAngles, panelAngles, [0 0 0]);
    if isempty(pts) && isempty(cpts)
        continue;
    end
    if isempty(pts)
        pshadow = polyshape(cpts);
    elseif isempty(cpts)
        pshadow = polyshape(pts);
    else
        pshadow = union(polyshape(cpts(:,1), cpts(:,2)),...
            polyshape(pts(:,1), pts(:,2)));
    end
    clip = intersect(pshadow, panel);
    hold off;
    plot(panel);
    axis([-0.2 2.2 -0.2 2.2]);
    ax = gca;
    ax.FontSize = 14;
    hold on;
    plot(pshadow);
    plot(clip);
    t = duration(times(n),0,0);
    
    title(['Time = ', datestr(t), ...
        ' Sun = [', num2str(sunAngles(1),'%.1f°'), ...
        num2str(sunAngles(2), ' %.1f°] '), ...
        '  Area = ', num2str(clip.area, '%.3f')]);
    drawnow;
    %pause(.125);
end

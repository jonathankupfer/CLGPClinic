%solarwork.m
%generate a matrix for one specific hour on a panel
panelDim=[2 4]; % width x height, in inches
cellDim=[10 40]; % width x height, in number of cells

%%%%%%%

w=panelDim(1);
h=panelDim(2);
bounds = [0 w; 0 h];
panel = polyshape([0 w w 0], [0 0 h h]);

panelAngles = [56, -90];
times = (0:5:1080) / 60 + 4;
location = [34, -117];
the_date = '2018-03-01';

w_cells=linspace(0, w, cellDim(1));
h_cells=linspace(0, h, cellDim(2));
w_cells_1=reshape(repmat(w_cells,length(h_cells),1),[1,cellDim(1)*cellDim(2)]);
h_cells_1=repmat(h_cells,1,length(w_cells));
%A vector with the coordinates of the center of each cell, in inches
cellLocations=[w_cells_1;h_cells_1];

   
    sstate = SolarState(the_date, 9, location);
% %     if sstate.hours < sstate.t_sunrise || sstate.hours > sstate.t_sunset
% %         continue;
%     end
    sunAngles = sstate.sun_angles;
    uSolar = UVector(sunAngles);
    cyl = Cylinder([1, -0.3, 0], 0.2, 1, uSolar);
    cone = GenCylinder([1, -0.3, 1], [0.3 0.2], 0.5, uSolar);

    pts = ProjectShadow(cyl, sunAngles, panelAngles, [0 0 0]);
    cpts = ProjectShadow(cone, sunAngles, panelAngles, [0 0 0]);
%      if isempty(pts) && isempty(cpts)
%          continue;
%      end
    if isempty(pts)
        pshadow = polyshape(cpts);
    elseif isempty(cpts)
        pshadow = polyshape(pts);
    else
        pshadow = union(polyshape(cpts(:,1), cpts(:,2)),...
            polyshape(pts(:,1), pts(:,2)));
    end
    
    strengthslist=ones(1,length(cellLocations));
    for posn = 1:(length(cellLocations)-1)
            if inpolygon(cellLocations(1,posn),cellLocations(2,posn),pshadow.Vertices(:,1),pshadow.Vertices(:,2))
                strengthslist(posn)=0.25;
            end
    end
    
    shapematrix=flipud(reshape(strengthslist,cellDim(2),cellDim(1)));


%            
%     
%     clip = intersect(pshadow, panel);
%     hold off;
%     plot(panel);
%     axis([-0.2 (w+1) -0.2 (h+1)]);
%     ax = gca;
%     ax.FontSize = 14;
%     hold on;
%     plot(pshadow);
%     plot(clip);
%     t = duration(times(n),0,0);
%     
%     title(['Time = ', datestr(t), ...
%         ' Sun = [', num2str(sunAngles(1),'%.1f°'), ...
%         num2str(sunAngles(2), ' %.1f°] '), ...
%         '  Area = ', num2str(clip.area, '%.3f')]);
%     drawnow;
    % pause(.125);
 
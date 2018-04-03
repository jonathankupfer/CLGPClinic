function [W_panel,S_panel,E_panel] = Gen3Panels(type,date,samps)
%Gen3Panels(type,date) generates pure insolation matrices (no
%considerations taken for weather) for three panels at specific angles
%south, west, and east, as determined by the CLGP Clinic field tests. 
% type is either "IdealPV" or "Conventional". 
% date is in the format "YYYY-MM-DD".
% samps is a scalar, and is the number of times you want to sample the
% sunlight.

%%%%%%%%%%%%%%%% unfinished!!!!! Last updated on Github 4/3 %%%%%%%%%%%%%%%%%%%%%%%%%

location = [34, -117]; % This is Claremont.

%Let's start by generating three panels. All 3 panels have the same
%dimensions.
%%%% These numbers are placeholders right now. They need to be verified.

if type=='IdealPV'
    panelDim=[2 4]; % width x height, in inches
    cellDim=[5 6]; % width x height, in number of cells
elseif type=='Conventional'
    panelDim=[3 5]; % width x height, in inches]
    cellDim=[50,60]; % width x height, in number of cells
end

w=panelDim(1);
h=panelDim(2);
bounds = [0 w; 0 h];
S_panel = polyshape([0 w w 0], [0 0 h h]); %S_panel is the only panel affected by the stovepipe.

W_panelAngles=[56, 135];
S_panelAngles=[56, 180]; %different coordinates 
E_panelAngles=[56, 225];

% E and W panels have constant insolation in unweathered conditions. 
W_panel=GenerateIntensities(date, location, W_panelAngles, samps, cellDim);
E_panel=GenerateIntensities(date, location, E_panelAngles, samps, cellDim);

% Now for the slightly less fun part, we have to cast some shade onto the
% S panel. 

w_cells=linspace(0, w, cellDim(1));
h_cells=linspace(0, h, cellDim(2));
w_cells_1=reshape(repmat(w_cells,length(h_cells),1),[1,30]);
h_cells_1=repmat(h_cells,1,length(w_cells));
%A vector with the coordinates of the center of each cell, in inches
cellLocations=[w_cells_1;h_cells_1];

for n=1:((0:5:1080)/60+40)
        sstate = SolarState(the_date, 9, location);
    if sstate.hours < sstate.t_sunrise || sstate.hours > sstate.t_sunset
        continue;
    end
    sunAngles = sstate.sun_angles;
    uSolar = UVector(sunAngles);
    cyl = Cylinder([1, -0.3, 0], 0.2, 1, uSolar);
    cone = GenCylinder([1, -0.3, 1], [0.3 0.2], 0.5, uSolar);

    pts = ProjectShadow(cyl, sunAngles, S_panelAngles, [0 0 0]);
    cpts = ProjectShadow(cone, sunAngles, S_panelAngles, [0 0 0]);
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
    
    strengthslist=ones(1,length(cellLocations));
    for posn = 1:(length(cellLocations)-1)
            if inpolygon(cellLocations(1,posn),cellLocations(2,posn),pshadow.Vertices(:,1),pshadow.Vertices(:,2))
                strengthslist(posn)=0.25;
            end
    end
    
    shapematrix=flipud(reshape(strengthslist,cellDim(2),cellDim(1)));




end
%It's not 3D or normalized for angle yet. GenerateIntensities needs to be
%invloved here. I'm not quite sure how yet. I am close though.  


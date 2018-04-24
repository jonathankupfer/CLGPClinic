function [W_panel,S_panel,E_panel,tvect, hours] = Gen3Panels(type,date,samps)
%Gen3Panels(type,date) generates pure insolation matrices (no
%considerations taken for weather) for three panels at specific angles
%south, west, and east, as determined by the CLGP Clinic field tests. 
% type is either "IdealPV" or "Conventional". 
% date is in the format 'YYYY-MM-DD'. (has to be in single quotes)
% samps is a scalar, and is the number of times you want to sample the
% sunlight.

% % Gen3Panels requires the following libraries: 
% % SolarState.m
% % UVector.m
% % ProjectShadow.m
% % GenCylinder.m
% % getTemperatures.m
% % You must also be running Matlab r2017b (available in Charlie). 

%%%%%%% USER DEFINED PARAMETERS: %%%%%%%%%

location = [34.106294, -117.705026]; % This is Claremont.
SunsToWatts = 1000; % W/m^2
shadeFactor = 0.25; % maybe this varies from idealPV to conventional? This
                    % is the factor by which being in the stovepipe's 
                    % shade decreases the sun's wattage. 

%the cyl is the lower part of the stovepipe, the cone is the upper part.
cylHeight=7; %inches
cylRadius=5.5/2; %inches (i think this is overestimated)
totalHeight=12; %inches
coneHeight=3; %inches
coneRadius=6.5; %inches
pipeDistance=6.5; % inches (distance from bottom of panel to 
                  % center of stovepipe

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Let's start by generating three panels. All 3 panels have the same
%dimensions.
%%%% These numbers are placeholders right now. They need to be verified.

if strcmp(type,'IdealPV')==1
    panelDim=[39 66]; % width x height, in inches
    cellDim=[23 10]; % width x height, in number of cells
    T_size=690; % total cells
elseif strcmp(type,'Conventional')==1
    panelDim=[38.98 65.43]; % width x height, in inches]
    cellDim=[6 10]; % width x height, in number of cells
    T_size=180; % total cells
else 
    return;
end

w=cellDim(1);
h=cellDim(2);


W_panelAngles=[56, -144];
W_vector=UVector(W_panelAngles);
S_panelAngles=[56, -90]; %different coordinates 
S_vector=UVector(S_panelAngles);
E_panelAngles=[56, -45];
E_vector=UVector(E_panelAngles);

% Initialize my variables! 
W_panel = ones(h, w, samps);
S_panel = ones(h, w, samps);
E_panel = ones(h, w, samps);
tvect = ones (1, T_size, samps);

%Now, time to generate today's sunrise and sunset times. 
today=SolarState(date, 0, location);
hours=linspace(today.t_sunrise, today.t_sunset, samps);

% Initializing some variables for use on the south panel... 

w_cells=linspace(0, w, cellDim(1));
h_cells=linspace(0, h, cellDim(2));
w_cells_1=reshape(repmat(w_cells,length(h_cells),1),...
    [1,cellDim(1)*cellDim(2)]);
h_cells_1=repmat(h_cells,1,length(w_cells));
cellLocations=[w_cells_1;h_cells_1];
strengthslist=ones(1,length(cellLocations));

%Now, a single unified for loop for all three panels. 

for hour=linspace(1,samps, samps)
    sst=SolarState(date,hours(hour),location);
    W_suns=sst.suns*SunsToWatts*dot(sst.uSun,W_vector);
    if W_suns<0
        W_suns=0;
    end
    W_panel(:,:,hour)=W_panel(:,:,hour)*W_suns;
    
    S_suns=sst.suns*SunsToWatts*dot(sst.uSun,S_vector);
    if S_suns<0
        S_suns=0;
    end
    
    E_suns=sst.suns*SunsToWatts*dot(sst.uSun,E_vector);
    if E_suns<0
        E_suns=0;
    end
    E_panel(:,:,hour)=E_panel(:,:,hour)*E_suns;
   
   
    %shapes are situated in the center of the southern panel, which is
    %assumed to have its origin at (0,0,0) for shadow projection.
    cyl = Cylinder([0.5*w, -pipeDistance, 0], cylRadius, cylHeight,...
        sst.uSun); 
    cone = GenCylinder([0.5*w, -pipeDistance, totalHeight-coneHeight],...
        [coneRadius cylRadius], coneHeight, sst.uSun);
   
    pts = ProjectShadow(cyl, sst.sun_angles, S_panelAngles, [0 0 0]);
    cpts = ProjectShadow(cone, sst.sun_angles, S_panelAngles, [0 0 0]);
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
    
    for posn = 1:(length(cellLocations)-1)
            if inpolygon(cellLocations(1,posn),cellLocations(2,posn),...
                    pshadow.Vertices(:,1),pshadow.Vertices(:,2))
                strengthslist(posn)=shadeFactor;
            else
                strengthslist(posn)=1;
            end
    end
    
    shapematrix=flipud(reshape(strengthslist,cellDim(2),cellDim(1)));
    S_panel(:,:,hour)=shapematrix*S_suns;
    
    tvect(:,:,hour)=getTemperatures(date, hours(hour)*100, T_size);
end

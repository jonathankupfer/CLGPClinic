function [panelWithTime] = GenerateIntensities(the_date, location, cell_angles, samps, dimCells)
% GenerateIntensities uses the basic physics of the Earth's movement to
% generate a vector with samps entries of the sun's intensity on a
% single solar cell. The cell is in location [lat, long] on date
% 'yyyy-mm-dd', with angles [anglefromground, anglefromsouth] (in degrees)
% and dimensions [height, width] in # of cells.
%
%   the output vector will include data points for sunrise and sunset. Be
%   careful, then, when chosing your value for samps! 
%
% note our experimental values:
%  Claremont = [34.1030 , -117.708]
%  Panel facing due south at angle 56: [0, -0.829, 0.5592]

% We'll construct a cell normal vector from the cell angles. cell_angles(1)
% is the angle from the xy plane, and cell_angles(2) is the angle from
% north (the y axis). 
cell_vector=[sind(cell_angles(1))*sind(cell_angles(2)),...
             sind(cell_angles(1))*cosd(cell_angles(2)),...
             cosd(cell_angles(1))];

SunsToWatts=1000; %suns -> w/m^2

% samps -> a vector of "hours" between sunrise and sunset
today=SolarState(the_date, 0, location);
hours=linspace(today.t_sunrise, today.t_sunset, samps);
%hours=linspace(0, 24, samps);

sun_intensities=ones(1,samps);
panelWithTime=ones(dimCells(1),dimCells(2),samps);

%figure(2);
%title('Sun intensity over the panel (Watts)');
%xlabel('Panel width (cells)');
%ylabel('Panel height (cells)');

for hour = linspace(1,samps,samps)
    sst=SolarState(the_date, hours(hour), location);
    sun_intensities(hour)=dot(sst.uSun,cell_vector)*sst.suns*SunsToWatts;
    if sun_intensities(hour)<0
        sun_intensities(hour)=0;ne
        
    end
    panelWithTime(:,:,hour)=panelWithTime(:,:,hour)*sun_intensities(hour);
    %hold on;
    %pause(0.05)
    %plot(panelWithTime(:,:,hour));
end
    
figure(1);
plot(hours, sun_intensities);
title('Sun intensity (Watts)');
xlabel('time (hours since midnight)');
ylabel('sun intensity (watts)');



end


% This code integrates the weather and insolation model with the system architecture models.
% In order for this code to be run, the following files must also be available:
% % Gen3Panels.m
% % SolarState.m
% % UVector.m
% % ProjectShadow.m
% % GenCylinder.m
% % getTemperatures.m
% % conventional_Temp_Stabilizer.m
% % conventional_Pout_Panel.m
% % idealPV_Pout_Panel.m
% % interpolantWorkspace.mat, a workspace that holds the interpolated data for each system.
% % You must also be running Matlab r2017b (available in Charlie).
% Load interpolant workspace and Ipvout vector.
%load('interpolantsForIntegratedModel.mat');
load('currentSweep.mat');
%% USER INPUTS:
% Define nSamples, the number of linearly spaced samples throughout the day.
nSamples = 25;

% Define convergenceCriteria, the max percent change allowable before convergence of temperature.
convergeCriteria = 0.01;


%% Run weather and insolation model and format the data appropriately:
% Call Gen3Panels function on each set of panels for a given day with nSamples number of samples.
[W_panel_ideal,S_panel_ideal,E_panel_ideal,tvect_ideal,hours] = Gen3Panels('IdealPV','2018-04-01',nSamples);
[W_panel_kyocera, S_panel_kyocera, E_panel_kyocera, tvect_kyocera_hold, hours] = Gen3Panels('Conventional', '2018-04-01', nSamples);

% Populate gvect for idealPV and Kyocera panels to be formatted the correct way.
gvect_ideal = zeros(1,690,nSamples);
for k = 1:nSamples
    for i = 1:10
        for j = 1:23
            gvect_ideal(1, ((i-1)*23)+j,k) = W_panel_ideal(i,j,k);
            gvect_ideal(1, 230+ ((i-1)*23)+j,k) = S_panel_ideal(i,j,k);
            gvect_ideal(1, 460+ ((i-1)*23)+j,k) = E_panel_ideal(i,j,k);
        end
    end
end

gvect_kyocera_hold = zeros(1,180,nSamples);
for k = 1:nSamples
    for i = 1:10
        for j = 1:6
            gvect_kyocera_hold(1, ((i-1)*6)+j, k) = W_panel_kyocera(i,j,k);
            gvect_kyocera_hold(1, 60 + ((i-1)*6) + j, k) = S_panel_kyocera(i,j,k);
            gvect_kyocera_hold(1, 120 + ((i-1)*6) + j, k) = E_panel_ideal(i,j,k);
        end
    end
end

gvect_kyocera = zeros(9,20,nSamples);
for k = 1:nSamples
    for i = 1:9
        for j = 1:20
            gvect_kyocera(i,j,k) = gvect_kyocera_hold(1,j+(i-1)*20,k);
        end
    end
end

tvect_kyocera = zeros(9,20,nSamples);
for k = 1:nSamples
    for i = 1:9
        for j = 1:20
            tvect_kyocera(i,j,k) = tvect_kyocera_hold(1,j+(i-1)*20,k);
        end
    end
end




%% Run each model for each set of samples

% initialize variables to hold output of trailer model
Pout_ideal = zeros(1,4,nSamples);
OpVolt_ideal = zeros(1,4,nSamples);
OpCur_ideal = zeros(1,3,nSamples);
Pout_kyocera = zeros(1,nSamples);
OpVolt_kyocera = zeros(1,10,nSamples);
OpCur_kyocera = zeros(1,nSamples);

% run idealPV model
for i = 1:nSamples
     [ Pout_ideal(1,:,i), OpVolt_ideal(1,:,i), OpCur_ideal(1,:,i)] = idealPV_Pout_Panel( gvect_ideal(1,:,i), tvect_ideal(1,:,i), IdealPVupdinterpolant, currentSweep);
end
% run kyocera model
for i = 1:nSamples
    [Pout_kyocera(1,i), OpVolt_kyocera(1,:,i), OpCur_kyocera(1,i)] = conventional_Temp_Stabilizer( gvect_kyocera(:,:,i), tvect_kyocera(:,:,i), convergeCriteria, Kyoceraupdinterpolant, currentSweep);

end
for i = 1:nSamples
     PoweroutPlotHold_ideal(1,i) = Pout_ideal(1,1,i);
     VoltageoutPlotHold_ideal(1,i) = OpVolt_ideal(1,1,i);
     VoltageoutPlotHold_kyocera(1,i) = OpVolt_kyocera(1,1,i);
end
 

figure
subplot(2,1,1)
plot(1:nSamples-2, PoweroutPlotHold_ideal(2:nSamples-1),'-o')
title('Total Power out for idealPV')
xlabel('time in hours')
ylabel('Instantaneous Power (W)')
subplot(2,1,2)
plot(1:nSamples, VoltageoutPlotHold_ideal,'-o')
title('Total Voltage out for idealPV')
xlabel('time in hours')
ylabel('Instantaneous Voltage (V)')

figure
subplot(2,1,1)
plot(hours(2:nSamples-1), Pout_kyocera(2:nSamples-1),'-o')
title('Total Power out for Conventional Panels')
xlabel('time in hours')
ylabel('Instantaneous Power (W)')
subplot(2,1,2)
plot(hours(2:nSamples-1), VoltageoutPlotHold_kyocera(2:nSamples-1),'-o')
title('Total Voltage out for Conventional Panels')
xlabel('time in hours')
ylabel('Instantaneous Voltage (V)')

    

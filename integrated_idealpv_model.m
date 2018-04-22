%% USER INPUTS:
% Define nSamples, the number of linearly spaced samples throughout the day.
nSamples = 100;

% Define convergenceCriteria, the max percent change allowable before convergence of temperature.
convergeCriteria = 0.01;


%% Run weather and insolation model and format the data appropriately:
% Call Gen3Panels function on each set of panels for a given day with nSamples number of samples.
[W_panel_ideal,S_panel_ideal,E_panel_ideal,tvect_ideal,hours] = Gen3Panels('IdealPV','2018-04-01',nSamples);
[W_panel_kyocera, S_panel_kyocera, E_panel_kyocera, tvect_kyocera, hours] = Gen3Panels('Kyocera', '2018-04-01', nSamples);

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

gvect_kyocera = zeros(1,180,nSamples);
for k = 1:nSamples
    for i = 1:10
        for j = 1:6
            gvect_kyocera(1, ((i-1)*6)+j, k) = W_panel_kyocera(i,j,k);
            gvect_kyocera(1, 60 + ((i-1)*6) + j, k) = S_panel_kyocera(i,j,k);
            gvect_kyocera(1, 120 + ((i-1)*6) + j, k) = E_panel_ideal(i,j,k);
        end
    end
end

% Load interpolant workspace and Ipvout vector.
load('interpolantWorkspace.mat');


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
     [ Pout_ideal(1,:,i), OpVolt_ideal(1,:,i), OpCur_ideal(1,:,i)] = idealPV_Pout_Panel( gvect_ideal(1,:,i), tvect_ideal(1,:,i), interpolant, Ipvout);
end
% run kyocera model
for i = 1:nSamples
    [Pout_kyocera(1,i), OpVolt_kyocera(1,:,i), OpCur_kyocera(1,i)] = conventional_Temp_Stabilizer( gvect_kyocera(1,:,i), tvect_kyocera(1,:,i), convergeCriteria, Kyocerainterpolant, Ipvout);


for i = 1:nSamples
     PoweroutPlotHold_ideal(1,i) = Pout_ideal(1,1,i);
     VoltageoutPlotHold_ideal(1,i) = OpVolt_ideal(1,1,i);
     VoltageoutPlotHold_kyocera(1,i) = OpVolt_kyocera(1,1,i);
end
 

figure
subplot(2,1,1)
plot(hours, PoweroutPlotHold_ideal,'-o')
title('Total Power out for idealPV')
xlabel('time in hours')
ylabel('Instantaneous Power (W)')
subplot(2,1,2)
plot(hours, VoltageoutPlotHold_ideal,'-o')
title('Total Voltage out for idealPV')
xlabel('time in hours')
ylabel('Instantaneous Voltage (V)')

figure
subplot(2,1,1)
plot(hours, Pout_kyocera,'-o')
title('Total Power out for Kyocera')
xlabel('time in hours')
ylabel('Instantaneous Power (W)')
subplot(2,1,2)
plot(hours, VoltageoutPlotHold_kyocera,'-o')
title('Total Voltage out for idealPV')
xlabel('time in hours')
ylabel('Instantaneous Voltage (V)')

    

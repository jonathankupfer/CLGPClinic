nSamples = 100;

[W_panel_ideal,S_panel_ideal,E_panel_ideal,tvect_ideal,hours] = Gen3Panels('IdealPV','2018-04-01',nSamples);


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

Ipvout = Ipvout;

Pout_ideal = zeros(1,4,nSamples);
OpVolt_ideal = zeros(1,4,nSamples);
OpCur_ideal = zeros(1,3,nSamples);

for i = 1:nSamples
     [ Pout_ideal(1,:,i), OpVolt_ideal(1,:,i), OpCur_ideal(1,:,i)] = idealPV_Pout_Panel( gvect_ideal(1,:,i), tvect_ideal(1,:,i), interpolant, Ipvout);
end
 
for i = 1:nSamples
     PoweroutPlotHold(1,i) = Pout_ideal(1,1,i);
     VoltageoutPlotHold(1,i) = OpVolt_ideal(1,1,i);
end
 

figure
subplot(2,1,1)
plot(hours, PoweroutPlotHold,'-o')
title('Total Power out')
xlabel('time in hours')
ylabel('Instantaneous Power (W)')
subplot(2,1,2)
plot(hours, VoltageoutPlotHold,'-o')
title('Total Voltage out')
xlabel('time in hours')
ylabel('Instantaneous Voltage (V)')


    
% D. Asnes and J. Kupfer
% Spring 2018

function [ PowerOut, OperatingVoltage, OperatingCurrent] = ...
    idealPV_Pout_Panel(Gvect, Tvect, interpolant, currents)
% Pass in a Gvect (a vector of G values and Tvect (a vector of T values), and an interpolant 
% to pull data from (taken from GENERATEVPVINTERPOLANT and a vector for a current sweep
% This Function passes out three vectors:
%   - PowerOut: a vector of the total power and the power of each panel
%   - OpVolt: The total operating voltage and the voltage of each panel (in this order)
%   - OpCurrent: The operating current of each panel
% When a vector passes out infomration regarding each panel, it does so
% in the West, South, East order.
% These calculations are made based on the system architecture described in
% the documentation.

% Define the number of cells
numCell = 230;

% Loop through panels and run pull the data from the interpolant.
for i = 1:numCell
    VoutPanel1(:,i) = Vsim(interpolant, currents, Gvect(1,i), Tvect(1,i));
    VoutPanel2(:,i) = Vsim(interpolant, currents, Gvect(1,numCell+ i), Tvect(1,numCell + i));
    VoutPanel3(:,i) = Vsim(interpolant, currents, Gvect(1,2*numCell+ i), Tvect(1,2*numCell + i));
end
% disp(sprintf('(G1, T1) = (%g, %g)  (G2, T2) = (%g, %g) (G3, T3) = (%g, %g)',...
%    Gvect(1,1), Tvect(1,1), Gvect(1,231), Tvect(1,231), Gvect(1, 461), Tvect(1,461)))

% define variable height as length of elements in current sweep
height = length(VoutPanel1(:,1));

% if an cell is outputting negative voltage, replace that with nan
% do this for all three panels
V_NonNeg1 =  VoutPanel1;
V_NonNeg1(V_NonNeg1 < 0) = nan;
V_NonNeg2 =  VoutPanel2;
V_NonNeg2(V_NonNeg2 < 0) = nan;
V_NonNeg3 =  VoutPanel3;
V_NonNeg3(V_NonNeg3 < 0) = nan;


%compute max power point
Vsum1 = zeros(height,1);
Vsum2 = zeros(height,1);
Vsum3 = zeros(height,1);
Power1 = zeros(height,1);
Power2 = zeros(height,1);
Power3 = zeros(height,1);

for i = 1:height
    % vector of sum of output voltage for a given current value
    Vsum1(i) = sum(V_NonNeg1(i,:));
    Vsum2(i) = sum(V_NonNeg2(i,:));
    Vsum3(i) = sum(V_NonNeg3(i,:));
    
    % vector of power output
    %Power1(i) = Vsum1(i).*currents(i);
    %Power2(i) = Vsum2(i).*currents(i);
    %Power3(i) = Vsum3(i).*currents(i);
end

Power1 = Vsum1 .* currents';
Power2 = Vsum2 .* currents';
Power3 = Vsum3 .* currents';

% find the max power out for each bank and the index
[MaxPout1, Index1] = max(Power1);
[MaxPout2, Index2] = max(Power2);
[MaxPout3, Index3] = max(Power3);
% some of these are reporting NaNs
% Doesn't happen with the Kyocera, though. Should we set them to zero?
% TODO: I will do that, but it is worth thinking about.

TotalPower = NotNaN(MaxPout1) + NotNaN(MaxPout2) + NotNaN(MaxPout3);

OpVolt1 = NotNaN(Vsum1(Index1));
OpVolt2 = NotNaN(Vsum2(Index2));
OpVolt3 = NotNaN(Vsum3(Index3));
TotalVoltage = OpVolt1 + OpVolt2 + OpVolt3;

% define the output variables.
PowerOut = [TotalPower, MaxPout1, MaxPout2, MaxPout3];
%Gvect(1,1);
%Gvect(1,231)
%Gvect(1,461)

OperatingVoltage = [TotalVoltage, OpVolt1, OpVolt2, OpVolt3];

OperatingCurrent = [currents(Index1), currents(Index2), currents(Index3)];


% the following functionality is commented out, but it updates the temperature of each cell
% based on the heat turning into energy that goes into the battery. In order to turn on this functioanlity,
% this code needs to be uncommented, and rather than running just the idealpV_pout script, the idealpv_temp_stabilizer
% script must be run.


% % Update temperature for next iteration:
% PowerUpdate1 = zeros(numCell);
% PowerUpdate2 = zeros(numCell);
% PowerUpdate3 = zeros(numCell);
% TempChangeUpdate = zeros(3*numCell);

% 
% for i = 1:numCell
%     PowerUpdate1 = V_NonNeg1(Index1,i).*OperatingCurrent(1);
%     PowerUpdate2 = V_NonNeg2(Index2,i).*OperatingCurrent(2);
%     PowerUpdate3 = V_NonNeg3(Index3,i).*OperatingCurrent(3);
% end

% 
% TempChangeUpdate(1:numCell) = PowerUpdate1.*1.5;
% TempChangeUpdate(numCell+1:2*numCell)= PowerUpdate2.*1.5;
% TempChangeUpdate(2*numCell+1:3*numCell)= PowerUpdate3.*1.5;
% 

end



function v = NotNaN(x)
    SetNANsToZero = false;
    if SetNANsToZero
        if isnan(x)
            v = 0;
        else
            v = x;
        end
    else
        v = x;
    end
end
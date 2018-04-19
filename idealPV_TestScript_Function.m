slope = .1;
stepSize = 0.02;
stopTime = 10;
initialOutput = 0.001;

numCell = 10;
Gvect = 25.*ones(30,1);
Tvect = 500.*ones(30,1);

% Loop through Panel 1

for i = 1:numCell
    Gcell = Gvect(i);
    Tcell = Tvect(i);
    sim('kkimpv_userIramp');
    VoutPanel1(:,i) = Vpvout;
end

% Loop through Panel 2
for i = 1:numCell
    Gcell = Gvect(numCell + i);
    Tcell = Tvect(numCell + i);
    sim('kkimpv_userIramp');
    VoutPanel2(:,i) = Vpvout;
end

% Loop through Panel 3
for i = 1:numCell
    Gcell = Gvect(numCell*2 + i);
    Tcell = Tvect(numCell*2 + i);
    sim('kkimpv_userIramp');
    VoutPanel3(:,i) = Vpvout;
end

% define variable height as length of elements in current sweep
height = length(VoutPanel1(:,1));

% if an cell is outputting negative voltage, replace that with nan
% do this for all three panels
V_NonNeg1 = zeros(height,numCell);
V_NonNeg2 = zeros(height,numCell);
V_NonNeg3 = zeros(height,numCell);

for i = 1:numCell
    % for panel 1
    for j = 1:height
        if VoutPanel1(j,i) < 0
            V_NonNeg1(j,i) = nan;
        else
            V_NonNeg1(j,i) = VoutPanel1(j,i);
        end
    end
    
    % for panel 2
    for j = 1:height
        if VoutPanel2(j,i) < 0
            V_NonNeg2(j,i) = nan;
        else
            V_NonNeg2(j,i) = VoutPanel2(j,i);
        end
    end
        
    % for panel 3
    for j = 1:height
        if VoutPanel3(j,i) < 0
            V_NonNeg3(j,i) = nan;
        else
            V_NonNeg3(j,i) = VoutPanel3(j,i);
        end
    end
end


% idealPV controller

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
    Power1(i) = Vsum1(i).*Ipvout(i);
    Power2(i) = Vsum2(i).*Ipvout(i);
    Power3(i) = Vsum3(i).*Ipvout(i);
end

% find the max power out for each bank and the index
[MaxPout1, Index1] = max(Power1);
[MaxPout2, Index2] = max(Power2);
[MaxPout3, Index3] = max(Power3);
TotalPower = MaxPout1 + MaxPout2 + MaxPout3;

OpVolt1 = Vsum1(Index1);
OpVolt2 = Vsum2(Index2);
OpVolt3 = Vsum3(Index3);


PowerOut = [TotalPower, MaxPout1, MaxPout2, MaxPout3];

OperatingVoltage = [OpVolt1, OpVolt2, OpVolt3];

OperatingCurrent = [Ipvout(Index1), Ipvout(Index2), Ipvout(Index3)];

% Update temperature for next iteration:
PowerUpdate1 = zeros(numCell);
PowerUpdate2 = zeros(numCell);
PowerUpdate3 = zeros(numCell);
TempChangeUpdate = zeros(3*numCell);


for i = 1:numCell
    PowerUpdate1 = V_NonNeg1(Index1,i).*OperatingCurrent(1);
    PowerUpdate2 = V_NonNeg2(Index2,i).*OperatingCurrent(2);
    PowerUpdate3 = V_NonNeg3(Index3,i).*OperatingCurrent(3);
end


TempChangeUpdate(1:numCell) = PowerUpdate1.*1.5;
TempChangeUpdate(numCell+1:2*numCell)= PowerUpdate2.*1.5;
TempChangeUpdate(numCell*2+1:numCell*3)= PowerUpdate3.*1.5;
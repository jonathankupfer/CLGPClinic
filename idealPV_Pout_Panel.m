function [ PowerOut, OperatingVoltage, OperatingCurrent ] = idealPV_Pout_Panel( GUpper, GLower, TUpper, TLower)
% Pass in a GUpper and GLower (two vectors of irradiance for cells in upper 
% and lower banks), TUpper and TLower (two vectors of ambient temperature 
% for cells inupper and lower banks. Function passes out three vectors:
% PowerOut, OpVolt, and OpCurrent. In PowerOut, the first index is total 
% power out, the second index is power out from upper bank and the third 
% index is power out from lower bank. OpVolt and OpCurrent are indexed by
% Upper and then Lower.

% Vbd = -23.5;
numCellUpper = 192;
numCellLower = 48;
GUpper = 500.*ones(1,numCellUpper);
GUpper(11:30) = [630 630 630 500 500 630 600 100 600 500 630 630 630 500 500 630 600 0 600 500];
GUpper(131:150) = [630 630 630 500 500 630 600 100 600 500 630 630 630 500 500 630 600 0 600 500];

GLower = 500.*ones(1,numCellLower);
GLower(11:30) = [630 630 630 500 500 630 600 100 600 500 630 630 630 500 500 630 600 0 600 500];

GUpper(3) = 0;
GLower(2) = 10;
TUpper = TUpper.*ones(1,numCellUpper);
TLower = TLower.*ones(1,numCellLower);



% Loop through upper cell bank
for i = 1:numCellUpper
    Gcell = GUpper(i);
    Tcell = TUpper(i);
    sim('kkimpv');
    VoutUpper(:,i) = Vpvout;
end

% Loop through lower cell bank
for i = 1:numCellLower
    Gcell = GLower(i);
    Tcell = TLower(i);
    sim('kkimpv');
    VoutLower(:,i) = Vpvout;
end

% define variable height as length of elements in current sweep
height = length(VoutUpper(:,1));

% if an cell is outputting negative voltage, replace that with nan
% do this for upper bank
VUp_NonNeg = zeros(height,numCellUpper);

for i = 1:numCellUpper
    for j = 1:height
        if VoutUpper(j,i) < 0
            VUp_NonNeg(j,i) = nan;
        else
            VUp_NonNeg(j,i) = VoutUpper(j,i);
        end
    end
end

% if an cell is outputting negative voltage, replace that with nan
% do this for lower bank
VLow_NonNeg = zeros(height,numCellLower);

for i = 1:numCellLower
    for j = 1:height
        if VoutLower(j,i) < 0
            VLow_NonNeg(j,i) = nan;
        else
            VLow_NonNeg(j,i) = VoutLower(j,i);
        end
    end
end

% idealPV controller

VsumUpper = zeros(height,1);
VsumLower = zeros(height,1);
PowerUp = zeros(height,1);
PowerLow = zeros(height,1);

for i = 1:height
    % vector of sum of output voltage for a given current value
    VsumUpper(i) = sum(VUp_NonNeg(i,:));
    VsumLower(i) = sum(VLow_NonNeg(i,:));
    
    % vector of power output
    PowerUp(i) = VsumUpper(i).*Ipvout(i);
    PowerLow(i) = VsumLower(i).*Ipvout(i);
end

% find the max power out for each bank and the index
[MaxPoutUp, IndexUp] = max(PowerUp);
[MaxPoutLow, IndexLow] = max(PowerLow);
TotalPower = MaxPoutUp + MaxPoutLow;

OpVoltUp = VsumUpper(IndexUp);
OpVoltLow = VsumLower(IndexLow);


PowerOut = [TotalPower, MaxPoutUp, MaxPoutLow];

OperatingVoltage = [OpVoltUp, OpVoltLow];

OperatingCurrent = [Ipvout(IndexUp), Ipvout(IndexLow)];


end


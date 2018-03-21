

cellsPerString = 4;
numStrings = 3;

Gstring1 = 600.*ones(1, cellsPerString);
Gstring2 = 500.*ones(1, cellsPerString);
Gstring2(3) = 0;
Gstring2(4) = 0;
Gstring3 = [600, 500, 0, 0]

Tstring1 = 25.*ones(1, cellsPerString);
Tstring2 = 25.*ones(1, cellsPerString);
Tstring3 = 25.*ones(1, cellsPerString);

% Calculate Vout for String 1
for i = 1:cellsPerString
    Gcell = Gstring1(i);
    Tcell = Tstring1(i);
    sim('kkimpv');
    VoutString1(:,i) = Vpvout;
end

% Calculate Vout for String 2
for i = 1:cellsPerString
    Gcell = Gstring2(i);
    Tcell = Tstring2(i);
    sim('kkimpv');
    VoutString2(:,i) = Vpvout;
end

% Calculate Vout for String 3
for i = 1:cellsPerString
    Gcell = Gstring3(i);
    Tcell = Tstring3(i);
    sim('kkimpv');
    VoutString3(:,i) = Vpvout;
end

% define variable height as length of elements in current sweep
height = length(VoutString1(:,1));

VsumString1 = zeros(height,1);
VsumString2 = zeros(height,1);
VsumString3 = zeros(height,1);
PowerString1 = zeros(height,1);
PowerString2 = zeros(height,1);
PowerString3 = zeros(height,1);

for i = 1:height
    % vector of sum of output voltage for a given current value
    VsumString1(i) = sum(VoutString1(i,:));
    VsumString2(i) = sum(VoutString2(i,:));
    VsumString3(i) = sum(VoutString3(i,:)); 
    
    % vector of power output
    PowerString1(i) = VsumString1(i).*Ipvout(i);
    PowerString2(i) = VsumString2(i).*Ipvout(i);
    PowerString3(i) = VsumString3(i).*Ipvout(i);
end

% find the max power out for each bank and the index
[MaxPout1, Index1] = max(PowerString1);
[MaxPout2, Index2] = max(PowerString2);
[MaxPout3, Index3] = max(PowerString3);

TotalPower = MaxPout1 + MaxPout2 + MaxPout3;

DynamicConduct1 = zeros(1, cellsPerString);
DynamicConduct2 = zeros(1, cellsPerString);
DynamicConduct3 = zeros(1, cellsPerString);

for i = 1:cellsPerString
    dV1 = VoutString1(Index1 + 1, i) - VoutString1(Index1, i);
    dV2 = VoutString2(Index2 + 1, i) - VoutString2(Index2, i);
    dV3 = VoutString3(Index3 + 1, i) - VoutString3(Index3, i);
    dI = Ipvout(i+1) - Ipvout(i);
    DynamicConduct1(i) = dI/dV1;
    DynamicConduct2(i) = dI/dV2;
    DynamicConduct3(i) = dI/dV3;
end
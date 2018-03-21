function [ MaxPout, OpCurrent, OpTemp ] = conventional_Pout_Panel( GMatrix, TMatrix )
% Input GMatrix and TMatrix, vectors of G and T for a given conventional
% cell and output PowerOut, the max power of that panel; OpVoltage and 
% OpCurrent, the operating voltage and current for that power production,
% and OpTemp, a vector of temperatures to update for the next iteration.

%% Defining variables used

cellsPerString = 20;
numStrings = 3;

%Gstring1 = 630.*ones(1, cellsPerString);
%Gstring2 = 500.*ones(1, cellsPerString);
%Gstring3 = 0.*ones(1, cellsPerString);
Gstring1 = [630 630 630 500 500 630 600 100 600 500 630 630 630 500 500 630 600 0 600 500];
Gstring2 = [500 630 600 630 630 630 500 630 630 500 100 600 630 600 0 630 500 500 600 500];
Gstring3 = [500 500 100 100 100 100 100 100 0 100 630 630 100 500 500 630 600 100 0 100];

Tstring1 = 25.*ones(1, cellsPerString);
Tstring2 = 25.*ones(1, cellsPerString);
Tstring3 = 25.*ones(1, cellsPerString);

% Update temp variable - 0 if dont go in loop, 1 if go into loop
UpdateTemp = 1;

%% Running Simulation to calculate Vout Vectors
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

%% Calculate maximum power point
% define variable height as length of elements in current sweep
height = length(VoutString1(:,1));

% Initialize vectors used to calculate power
VsumString1 = zeros(height,1);
VsumString2 = zeros(height,1);
VsumString3 = zeros(height,1);
PowerString1 = zeros(height,1);
PowerString2 = zeros(height,1);
PowerString3 = zeros(height,1);

% Loop through each current value in the current sweep
for i = 1:height
    % vector of sum of output voltage for a given current value
    VsumString1(i) = sum(VoutString1(i,:));
    VsumString2(i) = sum(VoutString2(i,:));
    VsumString3(i) = sum(VoutString3(i,:)); 
    VsumTotal(i) = VsumString1(i) + VsumString2(i) + VsumString3(i);
    % vector of power output
    PowerTotal(i) = VsumTotal(i)*Ipvout(i);
    
    % PowerString1(i) = VsumString1(i).*Ipvout(i);
    % PowerString2(i) = VsumString2(i).*Ipvout(i);
    % PowerString3(i) = VsumString3(i).*Ipvout(i);
end

% find the max power out for each bank and the index
[MaxPout, Index] = max(PowerTotal);
OpCurrent = Ipvout(Index);

%% Updating Temperature   
% Assuming we have vector RevBiasN for string N that tells us if a cell is
% in reverse bias (binary 1 yes/0 no)...

% Initialize output temperature variables
OpTempShift1 = zeros(1, cellsPerString);
OpTempShift2 = zeros(1, cellsPerString);
OpTempShift3 = zeros(1, cellsPerString);

if updateTemp == 1
    RevBias1 = zeros(1,cellsPerString);
    RevBias2 = zeros(1,cellsPerString);
    RevBias3 = zeros(1,cellsPerString);

    % If cell M in string N is in reverse bias RevBiasN(M) = 1
    for i = 1:cellsPerString
        if VoutString1(Index,i) < 0
            RevBias1(i) = VoutString1(Index,i)*Ipvout(Index);
        end
        if VoutString2(Index,i) < 0
            RevBias2(i) = VoutString2(Index2,i)*Ipvout(Index);
        end
        if VoutString3(Index,i) < 0
            RevBias3(i) = VoutString3(Index3,i)*Ipvout(Index);
        end
    end

    % Add 10 degrees (some nominal amount) to each cell that is under reverse
    % bias
    % We are subtracting the RevBias values because each value is negative
    % power because under reverse bias
    for i = 1:cellsPerString
        if RevBias1(i) ~= 0
            OpTempShift1(i) = OpTempShift1(i) - RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i) = OpTempShift2(i) - RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i) = OpTempShift3(i) - RevBias3(i)*1.5;
        end
    end

    % Add 5 degrees (some nominal amount) to neighbor cells of cells in reverse
    % bias
    for i = 1
        if RevBias1(i) ~= 0
            OpTempShift1(i+1) = OpTempShift1(i+1) - .5*RevBias1(i)*1.5;
            OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i+1) = OpTempShift2(i+1)- .5*RevBias2(i)*1.5;
            OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias2(i)*1.5;
            OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i+1) = OpTempShift3(i+1)- .5*RevBias3(i)*1.5;
            OpTempShift3(i+10) = OpTempShift3(i+10)- .5*RevBias3(i)*1.5;
            OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias3(i)*1.5;
        end
    end
    for i = 2:9
        if RevBias1(i) ~= 0
            OpTempShift1(i-1) = OpTempShift1(i-1) - .5*RevBias1(i)*1.5;
            OpTempShift1(i+1) = OpTempShift1(i+1) - .5*RevBias1(i)*1.5;
            OpTempShift1(i+10) = OpTempShift1(i+10) - .5*RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i-1) = OpTempShift2(i-1) - .5*RevBias2(i)*1.5;
            OpTempShift2(i+1) = OpTempShift2(i+1) - .5*RevBias2(i)*1.5;
            OpTempShift2(i+10) = OpTempShift2(i+10) - .5*RevBias2(i)*1.5;
            OpTempShift1(i+10) = OpTempShift1(i+10) - .5*RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i-1) = OpTempShift3(i-1) - .5*RevBias3(i)*1.5;
            OpTempShift3(i+1) = OpTempShift3(i+1) - .5*RevBias3(i)*1.5;
            OpTempShift3(i+10) = OpTempShift3(i+10) - .5*RevBias3(i)*1.5;
            OpTempShift2(i+10) = OpTempShift2(i+10) - .5*RevBias3(i)*1.5;
        end
    end
    for i = 10
        if RevBias1(i) ~= 0
            OpTempShift1(i-1) = OpTempShift1(i-1)- .5*RevBias1(i)*1.5;
            OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i-1) = OpTempShift2(i-1)- .5*RevBias2(i)*1.5;
            OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias2(i)*1.5;
            OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i-1) = OpTempShift3(i-1)- .5*RevBias3(i)*1.5;
            OpTempShift3(i+10) = OpTempShift3(i+10)- .5*RevBias3(i)*1.5;
            OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias3(i)*1.5;
        end
    end
    for i = 11
        if RevBias1(i) ~= 0
            OpTempShift1(i+1) = OpTempShift1(i+1)- .5*RevBias1(i)*1.5;
            OpTempShift1(i-10) = OpTempShift1(i-10)- .5*RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i+1) = OpTempShift2(i+1)- .5*RevBias2(i)*1.5;
            OpTempShift2(i-10) = OpTempShift2(i-10)- .5*RevBias2(i)*1.5;
            OpTempShift1(i-10) = OpTempShift1(i-10)- .5*RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i+1) = OpTempShift3(i+1)- .5*RevBias3(i)*1.5;
            OpTempShift3(i-10) = OpTempShift3(i-10)- .5*RevBias3(i)*1.5;
            OpTempShift2(i-10) = OpTempShift2(i-10)- .5*RevBias3(i)*1.5;
        end
    end
    for i = 12:19
        if RevBias1(i) ~= 0
            OpTempShift1(i-1) = OpTempShift1(i-1)- .5*RevBias1(i)*1.5;
            OpTempShift1(i+1) = OpTempShift1(i+1) - .5*RevBias1(i)*1.5;
            OpTempShift1(i-10) = OpTempShift1(i-10) - .5*RevBias1(i)*1.5;
            OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i-1) = OpTempShift2(i-1) - .5*RevBias2(i)*1.5;
            OpTempShift2(i+1) = OpTempShift2(i+1) - .5*RevBias2(i)*1.5;
            OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias2(i)*1.5;
            OpTempShift3(i-10) = OpTempShift3(i-10) - .5*RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i-1) = OpTempShift3(i-1) - .5*RevBias3(i)*1.5;
            OpTempShift3(i+1) = OpTempShift3(i+1) - .5*RevBias3(i)*1.5;
            OpTempShift3(i-10) = OpTempShift3(i-10) - .5*RevBias3(i)*1.5;
        end
    end
    for i = 20
        if RevBias1(i) ~= 0
            OpTempShift1(i-1) = OpTempShift1(i-1) - .5*RevBias1(i)*1.5;
            OpTempShift1(i-10) = OpTempShift1(i-10) - .5*RevBias1(i)*1.5;
        end
        if RevBias2(i) ~= 0
            OpTempShift2(i-1) = OpTempShift2(i-1) - .5*RevBias2(i)*1.5;
            OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias2(i)*1.5;
            OpTempShift1(i-10) = OpTempShift1(i-10) - .5*RevBias2(i)*1.5;
        end
        if RevBias3(i) ~= 0
            OpTempShift3(i-1) = OpTempShift3(i-1) - .5*RevBias3(i)*1.5;
            OpTempShift3(i-10) = OpTempShift3(i-10) - .5*RevBias3(i)*1.5;
            OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias3(i)*1.5;
        end
    end
end

for i = 1:20
    OpTemp(i) = OpTempShift1(i);
    OpTemp(20+i)= OpTempShift2(i);
    OpTemp(40+i)= OpTempShift3(i);
end




%% Bypass diodes
% How do we deal with bypass diodes and negative voltage
% Option 1: if sumVoltage of cells is neg or less than 0.6, then
% Option 2: Dynamic Conductance (??)
end


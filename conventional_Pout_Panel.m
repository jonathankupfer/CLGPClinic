function [ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect )
% Input GMatrix and TMatrix, vectors of G and T for a given conventional
% cell and output PowerOut, the max power of that panel; OpVoltage and 
% OpCurrent, the operating voltage and current for that power production,
% and OpTemp, a vector of temperatures to update for the next iteration.

%% Defining variables used

cellsPerString = 20;
% we're treating 3 panels with 3 strings each as one panel with 9 strings.
numStrings = 9;

%% Running Simulation to calculate Vout Vectors
% Calculate Vout for String 1
for i = 1:cellsPerString
    Gcell = Gvect(i);
    Tcell = Tvect(i);
    sim('kkimpv');
    VoutString1(:,i) = Vpvout;
end

% Calculate Vout for String 2
for i = 1:cellsPerString
    Gcell = Gvect(numCells + i);
    Tcell = Tvect(numCells + i);
    sim('kkimpv');
    VoutString2(:,i) = Vpvout;
end

% Calculate Vout for String 3
for i = 1:cellsPerString
    Gcell = Gvect(2*numCells + i);
    Tcell = Tvect(2*numCells + i);
    sim('kkimpv');
    VoutString3(:,i) = Vpvout;
end

% Calculate Vout for String 4
for i = 1:cellsPerString
    Gcell = Gvect(3*numCells + i);
    Tcell = Tvect(3*numCells + i);
    sim('kkimpv');
    VoutString4(:,i) = Vpvout;
end

% Calculate Vout for String 5
for i = 1:cellsPerString
    Gcell = Gvect(4*numCells + i);
    Tcell = Tvect(4*numCells + i);
    sim('kkimpv');
    VoutString5(:,i) = Vpvout;
end

% Calculate Vout for String 6
for i = 1:cellsPerString
    Gcell = Gvect(5*numCells + i);
    Tcell = Tvect(5*numCells + i);
    sim('kkimpv');
    VoutString6(:,i) = Vpvout;
end

% Calculate Vout for String 7
for i = 1:cellsPerString
    Gcell = Gvect(6*numCells + i);
    Tcell = Tvect(6*numCells + i);
    sim('kkimpv');
    VoutString7(:,i) = Vpvout;
end

% Calculate Vout for String 8
for i = 1:cellsPerString
    Gcell = Gvect(7*numCells + i);
    Tcell = Tvect(7*numCells + i);
    sim('kkimpv');
    VoutString8(:,i) = Vpvout;
end

% Calculate Vout for String 9
for i = 1:cellsPerString
    Gcell = Gvect(8*numCells + i);
    Tcell = Tvect(8*numCells + i);
    sim('kkimpv');
    VoutString9(:,i) = Vpvout;
end

%% Calculate maximum power point
% define variable height as length of elements in current sweep
height = length(VoutString1(:,1));

% Initialize vectors used to calculate power
VsumString1 = zeros(height,1);
VsumString2 = zeros(height,1);
VsumString3 = zeros(height,1);
VsumString4 = zeros(height,1);
VsumString5 = zeros(height,1);
VsumString6 = zeros(height,1);
VsumString7 = zeros(height,1);
VsumString8 = zeros(height,1);
VsumString9 = zeros(height,1);

VsumTotal = zeros(height,1);
PowerTotal = zeros(height,1);

% Loop through each current value in the current sweep
for i = 1:height
    % vector of sum of output voltage for a given current value
    VsumString1(i) = sum(VoutString1(i,:));
    VsumString2(i) = sum(VoutString2(i,:));
    VsumString3(i) = sum(VoutString3(i,:)); 
    VsumString4(i) = sum(VoutString4(i,:));
    VsumString5(i) = sum(VoutString5(i,:));
    VsumString6(i) = sum(VoutString6(i,:)); 
    VsumString7(i) = sum(VoutString7(i,:));
    VsumString8(i) = sum(VoutString8(i,:));
    VsumString9(i) = sum(VoutString9(i,:)); 
    VsumTotal(i) = VsumString1(i) + VsumString2(i) + VsumString3(i) + VsumString4(i) + VsumString5(i) + VsumString6(i) + VsumString7(i) + VsumString8(i) + VsumString9(i);
    % vector of power output
    PowerTotal(i) = VsumTotal(i)*Ipvout(i);
    
    % PowerString1(i) = VsumString1(i).*Ipvout(i);
    % PowerString2(i) = VsumString2(i).*Ipvout(i);
    % PowerString3(i) = VsumString3(i).*Ipvout(i);
end

% find the max power out for all 9 strings.
[MaxPout, Index] = max(PowerTotal);
OpCurrent = Ipvout(Index);

%% Bypass Diodes
BypassDiode = zeros(1,numStrings);
if (VSumString1(Index) < 0.6 || min(Gvect(1:20)) < 0.1)
    BypassDiode(1) = 1;
    MaxPout = MaxPout - (VsumString1(Index) - 0.6) * OpCurrent;
end
if (VSumString2(Index) < 0.6 || min(Gvect(21:40)) < 0.1)
    BypassDiode(2) = 1;
    MaxPout = MaxPout - (VsumString2(Index) - 0.6) * OpCurrent;
end
if (VSumString3(Index) < 0.6 || min(Gvect(41:60)) < 0.1)
    BypassDiode(3) = 1;
    MaxPout = MaxPout - (VsumString3(Index) - 0.6) * OpCurrent;
end
if (VSumString4(Index) < 0.6 || min(Gvect(61:80)) < 0.1)
    BypassDiode(4) = 1;
    MaxPout = MaxPout - (VsumString4(Index) - 0.6) * OpCurrent;
end
if (VSumString5(Index) < 0.6 || min(Gvect(81:100)) < 0.1)
    BypassDiode(5) = 1;
    MaxPout = MaxPout - (VsumString5(Index) - 0.6) * OpCurrent;
end
if (VSumString6(Index) < 0.6 || min(Gvect(101:120)) < 0.1)
    BypassDiode(6) = 1;
    MaxPout = MaxPout - (VsumString6(Index) - 0.6) * OpCurrent;
end
if (VSumString7(Index) < 0.6 || min(Gvect(121:140)) < 0.1)
    BypassDiode(7) = 1;
    MaxPout = MaxPout - (VsumString7(Index) - 0.6) * OpCurrent;
end
if (VSumString8(Index) < 0.6 || min(Gvect(141:160)) < 0.1)
    BypassDiode(8) = 1;
    MaxPout = MaxPout - (VsumString8(Index) - 0.6) * OpCurrent;
end
if (VSumString9(Index) < 0.6 || min(Gvect(161:180)) < 0.1)
    BypassDiode(9) = 1;
    MaxPout = MaxPout - (VsumString9(Index) - 0.6) * OpCurrent;
end
    
    
    
    


%% Updating Temperature   
% Assuming we have vector RevBiasN for string N that tells us if a cell is
% in reverse bias (binary 1 yes/0 no)...

% This is currently implemented for strings 1-3 (*NOT* 4-9)

% Initialize output temperature variables
OpTempShift1 = zeros(1, cellsPerString);
OpTempShift2 = zeros(1, cellsPerString);
OpTempShift3 = zeros(1, cellsPerString);




RevBias1 = zeros(1,cellsPerString);
RevBias2 = zeros(1,cellsPerString);
RevBias3 = zeros(1,cellsPerString);

% If cell M in string N is in reverse bias RevBiasN(M) = 1
%in the case that the bypass diode does NOT activate
for i = 1:9
    if BypassDiode(i) == 0
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
    end
end

forwardVoltage1 = 0; %initiating variable to be used below
negativeVoltage1 = 0; %initiating
proportionalReverseBias1 = zeros(1,cellsPerString);
updatedVoltages1 = zeros(1,cellsPerString);

%%now begin the cases for which bypass diode does activate%%
if BypassDiode(1) == 1 
    for i = 1:cellsPerString

        if VoutString1(Index,i)>0
            forwardVoltage1 = forwardVoltage1 + VoutString1(Index,i);
        end

        if VoutString1(Index,i)<0
            negativeVoltage1 = negativeVoltage1 + VoutString1(Index,i);
        end
    end
    forwardVoltage1 = forwardVoltage1 - .6; %to account for bypass diode voltage drop
    
    for k = 1:cellsPerString
        if VoutString1(Index,k)<0
          proportionalReverseBias1(k) = abs(VoutString1(Index,k) / negativeVoltage1);
          updatedVoltages1(k) = VoutString1(Index,k) * proportionalReverseBias1(k); %updated value will be negative

        else
          updatedVoltages1(k) = VoutString1(Index,k); %keep voltages of forward bias cells the same
        end %updated voltages now holds the updated voltage for each cell in the string
    end
    for j = 1:cellsPerString
        if VoutString1(Index,j) < 0
            RevBias1(j) = VoutString1(Index,j)*Ipvout(Index);
        end
    end
   
end
%at the end of this loop, we have RevBias1 which contains the negative
%power dissiptation Watts of each reverse biased cell => which is what we
%pass through to the temperature section

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Temperature updates begin here
%below is temperature update and propogation in string/surroundings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add 10 degrees (some nominal amount) to each cell that is under reverse
% bias
for i = 1:cellsPerString
    if RevBias1(i) ~= 0
        OpTempShift1(i) = OpTempShift1(i) - RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i) = OpTempShift2(i) - RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i) = OpTempShift3(i) - RevBias3(i)/1.3;
    end
end

% Add 5 degrees (some nominal amount) to neighbor cells of cells in reverse
% bias
for i = 1
    if RevBias1(i) ~= 0
        OpTempShift1(i+1) = OpTempShift1(i+1) - .5*RevBias1(i)/1.3;
        OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i+1) = OpTempShift2(i+1)- .5*RevBias2(i)/1.3;
        OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias2(i)/1.3;
        OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i+1) = OpTempShift3(i+1)- .5*RevBias3(i)/1.3;
        OpTempShift3(i+10) = OpTempShift3(i+10)- .5*RevBias3(i)/1.3;
        OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias3(i)/1.3;
    end
end
for i = 2:9
    if RevBias1(i) ~= 0
        OpTempShift1(i-1) = OpTempShift1(i-1) - .5*RevBias1(i)/1.3;
        OpTempShift1(i+1) = OpTempShift1(i+1) - .5*RevBias1(i)/1.3;
        OpTempShift1(i+10) = OpTempShift1(i+10) - .5*RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i-1) = OpTempShift2(i-1) - .5*RevBias2(i)/1.3;
        OpTempShift2(i+1) = OpTempShift2(i+1) - .5*RevBias2(i)/1.3;
        OpTempShift2(i+10) = OpTempShift2(i+10) - .5*RevBias2(i)/1.3;
        OpTempShift1(i+10) = OpTempShift1(i+10) - .5*RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i-1) = OpTempShift3(i-1) - .5*RevBias3(i)/1.3;
        OpTempShift3(i+1) = OpTempShift3(i+1) - .5*RevBias3(i)/1.3;
        OpTempShift3(i+10) = OpTempShift3(i+10) - .5*RevBias3(i)/1.3;
        OpTempShift2(i+10) = OpTempShift2(i+10) - .5*RevBias3(i)/1.3;
    end
end
for i = 10
    if RevBias1(i) ~= 0
        OpTempShift1(i-1) = OpTempShift1(i-1)- .5*RevBias1(i)/1.3;
        OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i-1) = OpTempShift2(i-1)- .5*RevBias2(i)/1.3;
        OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias2(i)/1.3;
        OpTempShift1(i+10) = OpTempShift1(i+10)- .5*RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i-1) = OpTempShift3(i-1)- .5*RevBias3(i)/1.3;
        OpTempShift3(i+10) = OpTempShift3(i+10)- .5*RevBias3(i)/1.3;
        OpTempShift2(i+10) = OpTempShift2(i+10)- .5*RevBias3(i)/1.3;
    end
end
for i = 11
    if RevBias1(i) ~= 0
        OpTempShift1(i+1) = OpTempShift1(i+1)- .5*RevBias1(i)/1.3;
        OpTempShift1(i-10) = OpTempShift1(i-10)- .5*RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i+1) = OpTempShift2(i+1)- .5*RevBias2(i)/1.3;
        OpTempShift2(i-10) = OpTempShift2(i-10)- .5*RevBias2(i)/1.3;
        OpTempShift1(i-10) = OpTempShift1(i-10)- .5*RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i+1) = OpTempShift3(i+1)- .5*RevBias3(i)/1.3;
        OpTempShift3(i-10) = OpTempShift3(i-10)- .5*RevBias3(i)/1.3;
        OpTempShift2(i-10) = OpTempShift2(i-10)- .5*RevBias3(i)/1.3;
    end
end
for i = 12:19
    if RevBias1(i) ~= 0
        OpTempShift1(i-1) = OpTempShift1(i-1)- .5*RevBias1(i)/1.3;
        OpTempShift1(i+1) = OpTempShift1(i+1) - .5*RevBias1(i)/1.3;
        OpTempShift1(i-10) = OpTempShift1(i-10) - .5*RevBias1(i)/1.3;
        OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i-1) = OpTempShift2(i-1) - .5*RevBias2(i)/1.3;
        OpTempShift2(i+1) = OpTempShift2(i+1) - .5*RevBias2(i)/1.3;
        OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias2(i)/1.3;
        OpTempShift3(i-10) = OpTempShift3(i-10) - .5*RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i-1) = OpTempShift3(i-1) - .5*RevBias3(i)/1.3;
        OpTempShift3(i+1) = OpTempShift3(i+1) - .5*RevBias3(i)/1.3;
        OpTempShift3(i-10) = OpTempShift3(i-10) - .5*RevBias3(i)/1.3;
    end
end
for i = 20
    if RevBias1(i) ~= 0
        OpTempShift1(i-1) = OpTempShift1(i-1) - .5*RevBias1(i)/1.3;
        OpTempShift1(i-10) = OpTempShift1(i-10) - .5*RevBias1(i)/1.3;
    end
    if RevBias2(i) ~= 0
        OpTempShift2(i-1) = OpTempShift2(i-1) - .5*RevBias2(i)/1.3;
        OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias2(i)/1.3;
        OpTempShift1(i-10) = OpTempShift1(i-10) - .5*RevBias2(i)/1.3;
    end
    if RevBias3(i) ~= 0
        OpTempShift3(i-1) = OpTempShift3(i-1) - .5*RevBias3(i)/1.3;
        OpTempShift3(i-10) = OpTempShift3(i-10) - .5*RevBias3(i)/1.3;
        OpTempShift2(i-10) = OpTempShift2(i-10) - .5*RevBias3(i)/1.3;
    end
end

for i = 1:20 %converts multiple string update into one long string to pass as one string
    TempChangeUpdate(i) = OpTempShift1(i);
    TempChangeUpdate(20+i)= OpTempShift2(i);
    TempChangeUpdate(40+i)= OpTempShift3(i);
end






%% Bypass diodes
% How do we deal with bypass diodes and negative voltage
% Option 1: if sumVoltage of cells is neg or less than 0.6, then
% Option 2: Dynamic Conductance (??)
end


function [ PowerOut, OpVoltage, OpCurrent, OpTempShift] = conventional_Pout_Panel( Gvect, Tvect, interpolant, currents )
% Input GMatrix and TMatrix, vectors of G and T for a given conventional
% cell and output PowerOut, the max power of that panel; OpVoltage and 
% OpCurrent, the operating voltage and current for that power production,
% and OpTemp, a vector of temperatures to update for the next iteration.

%% Defining variables used

cellsPerString = 20;
% we're treating 3 panels with 3 strings each as one panel with 9 strings.
numStrings = 9;

%% Running Simulation to calculate Vout Vectors
% Calculate Vout for all 9 strings

% temporary definitions for calling the simulink model (jk 4/26)


Tn = 25;
Voc = 38.3 / 60;
Isc = 9.26 * frac;
Rseries = 0.0042 * frac;
Rshunt = 91.8 * frac;
Kv = -0.0022;
Ki = 0.0004 * frac;
currentMargin = 1.2;

for j = 1:numStrings
    for i = 1:cellsPerString
        VoutString(j,:,i)=Vsim(interpolant, currents, Gvect(j,i), Tvect(j,i));
        if Gvect(j,i) == 0
            Gcell = gvect(j,i);
            Tcell = tvect(j,i);
            Imax = currentMargin * Isc * Gcell / 1000;
            sim('kkKyocera');
            VoutString(j,:,i) = 
        end
    end
end

%% Calculate maximum power point
% define variable height as length of elements in current sweep
height = length(VoutString(1,:,1));

% Initialize vectors used to calculate power
VsumString = zeros(height,numStrings);

VsumTotal = zeros(height,1);
PowerTotal = zeros(height,1);

% Loop through each current value in the current sweep
for j = 1:numStrings
    for i = 1:height
        % vector of sum of output voltage for a given current value
        VsumString(i,j) = sum(VoutString(j,i,:));
    end
end

for i = 1:height
        % We must optimize power for one current value through all strings
        VsumTotal(i) = sum(VsumString(i,:));
        % vector of power output
        PowerTotal(i) = VsumTotal(i)*currents(i);
end

% find the max power out for all 9 strings.
[MaxPout, Index] = max(PowerTotal(:,1));
OpCurrent = currents(Index);
OpVoltage(1) = sum(VsumString(Index,:));
OpVoltage(2:10) = (VsumString(Index,:));
PowerOut = PowerTotal(Index,1);

%% Bypass Diodes
BypassDiode = zeros(1,numStrings);
for j = 1:numStrings
    if (VsumString(Index,j) < 0.6 | min(Gvect((1+(j-1)*20):(20+(j-1)*20))) < 0.1)
        BypassDiode(1,j) = 1;
        MaxPout = MaxPout - (VsumString(Index,j) - 0.6) * OpCurrent;
    end
end    


%% Updating Temperature   
% Assuming we have vector Power for string N that tells us if a cell is
% in reverse bias (binary 1 yes/0 no)...

% This is currently implemented for strings 1-3 (*NOT* 4-9)

% Initialize output temperature variables
OpTempShift = zeros(numStrings, cellsPerString);

PowerPerCell = zeros(numStrings,cellsPerString);

% If cell M in string N is in reverse bias RevBias(N,M) = power of cell
%in the case that the bypass diode does NOT activate
for j = 1:numStrings
    if BypassDiode(j) == 0
        for i = 1:cellsPerString
            PowerPerCell(j,i) = VoutString(j,Index,i)*currents(Index); % in W
        end
    end
end

forwardVoltage = zeros(1,numStrings); %initiating variable to be used below
negativeVoltage = zeros(1,numStrings); %initiating
proportionalReverseBias = zeros(cellsPerString, numStrings);
updatedVoltages = zeros(cellsPerString, numStrings);

%%now begin the cases for which bypass diode does activate%%
for j = 1:numStrings
    if BypassDiode(j) == 1 
        for i = 1:cellsPerString

            if VoutString(j,Index,i)>0
                forwardVoltage(j) = forwardVoltage(j) + VoutString(j,Index,i);
            end

            if VoutString(j,Index,i)<0
                negativeVoltage(j) = negativeVoltage(j) + VoutString(j,Index,i);
            end
        end
        
        forwardVoltage(j) = forwardVoltage(j) - .6; %to account for bypass diode voltage drop

        for k = 1:cellsPerString
            if VoutString(j,Index,k)<0
              proportionalReverseBias(k,j) = abs(VoutString(j,Index,k) / negativeVoltage(j));
              updatedVoltages(k,j) = VoutString(j,Index,k) * proportionalReverseBias(k,j); %updated value will be negative

            else
              updatedVoltages(k,j) = VoutString(j,Index,k); %keep voltages of forward bias cells the same
            end %updated voltages now holds the updated voltage for each cell in the string
        end
    end
end

for i = 1:numStrings
    for j = 1:cellsPerString
        rhs = PowerPerCell(i,j) + updatedVoltages(j,i)*currents(Index);
        PowerPerCell(i,j) = rhs;
    end
end

%at the end of this loop, we have PowerPerCell which contains the total
%power dissiptation Watts of each cell => which is what we
%pass through to the temperature section. Note, they are positive if the
%operating under forward bias, and neg if operating under rev bias.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Temperature updates begin here
%below is temperature update and propogation in string/surroundings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Update temp by 1.5 deg C per Watt of production. Add heat if in rev bias,
% subtract heat if in forward bias. Do this for each cell.
for i = 1:numStrings
    for j = 1:cellsPerString
        OpTempShift(i,j) = OpTempShift(i,j) - PowerPerCell(i,j)*1.5;
    end
end
%% Dont care about things below this for now
% Propagate by a factor of heatProp for neighboring cells of cells in
% reverse bias.

% heatProp = 0;
% 
% % the following loops go through the indices of each cell in a string:
% % j = which string, i = which cell:
% for j = [1,4,7]
%     for i = 1
%         if OpTempShift(j,i) > 0
%             OpTempShift(j,i+1) = OpTempShift(j,i+1) + heatProp*OpTempShift(j,i);
%             OpTempShift(j,i+10) = OpTempShift(j, j,i+10) + heatProp*OpTempShift(j,i);
%         end
%         if OpTempShift(j+1,i) > 0
%             OpTempShift(j+1,i+1) = OpTempShift(j+1,i+1) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1,i+10) = OpTempShift(j+1,i+10) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j,i+10) = OpTempShift(j,i+10) + heatProp*OpTempShift(j+1,i);
%         end
%         if OpTempShift(j+2,i) > 0
%             OpTempShift(j+2,i+1) = OpTempShift(j+2,i+1) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2,i+10) = OpTempShift(j+2,i+10) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+1,i+10) = OpTempShift(j+1,i+10) + heatProp*OpTempShift(j+2,i);
%         end
%     end
%     for i = 2:9
%         if OpTempShift(j,i) > 0
%             OpTempShift(j, i-1) = OpTempShift(j, i-1) + heatProp*OpTempShift(j,i);
%             OpTempShift(j, i+1) = OpTempShift(j, i+1) + heatProp*OpTempShift(j,i);
%             OpTempShift(j, i+10) = OpTempShift(j, i+10) + heatProp*OpTempShift(j,i);
%         end
%         if OpTempShift(j+1,i) > 0
%             OpTempShift(j+1, i-1) = OpTempShift(j+1, i-1) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i+1) = OpTempShift(j+1, i+1) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i+10) = OpTempShift(j+1, i+10) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j, i+10) = OpTempShift(j, i+10) + heatProp*OpTempShift(j+1,i);
%         end
%         if OpTempShift(j+2,i) > 0
%             OpTempShift(j+2, i-1) = OpTempShift(j+2, i-1) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i+1) = OpTempShift(j+2, i+1) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i+10) = OpTempShift(j+2, i+10) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+1, i+10) = OpTempShift(j+1, i+10) + heatProp*OpTempShift(j+2,i);
%         end
%     end
%     for i = 10
%         if OpTempShift(j,i) > 0
%             OpTempShift(j, i-1) = OpTempShift(j, i-1)+ heatProp*OpTempShift(j,i);
%             OpTempShift(j, i+10) = OpTempShift(j, i+10)+ heatProp*OpTempShift(j,i);
%         end
%         if OpTempShift(j+1,i) > 0
%             OpTempShift(j+1, i-1) = OpTempShift(j+1, i-1)+ heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i+10) = OpTempShift(j+1, i+10)+ heatProp*OpTempShift(j+1,i);
%             OpTempShift(j, i+10) = OpTempShift(j, i+10)+ heatProp*OpTempShift(j+1,i);
%         end
%         if OpTempShift(j+2,i) > 0
%             OpTempShift(j+2, i-1) = OpTempShift(j+2, i-1)+ heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i+10) = OpTempShift(j+2, i+10)+ heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+1, i+10) = OpTempShift(j+1, i+10)+ heatProp*OpTempShift(j+2,i);
%         end
%     end
%     for i = 11
%         if OpTempShift(j,i) > 0
%             OpTempShift(j, i+1) = OpTempShift(j, i+1)+ heatProp*OpTempShift(j,i);
%             OpTempShift(j, i-10) = OpTempShift(j, i-10)+ heatProp*OpTempShift(j,i);
%         end
%         if OpTempShift(j+1,i) > 0
%             OpTempShift(j+1, i+1) = OpTempShift(j+1, i+1)+ heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i-10) = OpTempShift(j+1, i-10)+ heatProp*OpTempShift(j+1,i);
%             OpTempShift(j, i-10) = OpTempShift(j, i-10)+ heatProp*OpTempShift(j+1,i);
%         end
%         if OpTempShift(j+2,i) > 0
%             OpTempShift(j+2, i+1) = OpTempShift(j+2, i+1)+ heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i-10) = OpTempShift(j+2, i-10)+ heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+1, i-10) = OpTempShift(j+1, i-10)+ heatProp*OpTempShift(j+2,i);
%         end
%     end
%     for i = 12:19
%         if OpTempShift(j,i) > 0
%             OpTempShift(j, i-1) = OpTempShift(j, i-1)+ heatProp*OpTempShift(j,i);
%             OpTempShift(j, i+1) = OpTempShift(j, i+1) + heatProp*OpTempShift(j,i);
%             OpTempShift(j, i-10) = OpTempShift(j, i-10) + heatProp*OpTempShift(j,i);
%             OpTempShift(j+1, i-10) = OpTempShift(j+1, i-10) + heatProp*OpTempShift(j,i);
%         end
%         if OpTempShift(j+1,i) > 0
%             OpTempShift(j+1, i-1) = OpTempShift(j+1, i-1) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i+1) = OpTempShift(j+1, i+1) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i-10) = OpTempShift(j+1, i-10) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+2, i-10) = OpTempShift(j+2, i-10) + heatProp*OpTempShift(j+1,i);
%         end
%         if OpTempShift(j+2,i) > 0
%             OpTempShift(j+2, i-1) = OpTempShift(j+2, i-1) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i+1) = OpTempShift(j+2, i+1) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i-10) = OpTempShift(j+2, i-10) + heatProp*OpTempShift(j+2,i);
%         end
%     end
%     for i = 20
%         if OpTempShift(j,i) > 0
%             OpTempShift(j, i-1) = OpTempShift(j, i-1) + heatProp*OpTempShift(j,i);
%             OpTempShift(j, i-10) = OpTempShift(j, i-10) + heatProp*OpTempShift(j,i);
%         end
%         if OpTempShift(j+1,i) > 0
%             OpTempShift(j+1, i-1) = OpTempShift(j+1, i-1) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j+1, i-10) = OpTempShift(j+1, i-10) + heatProp*OpTempShift(j+1,i);
%             OpTempShift(j, i-10) = OpTempShift(j, i-10) + heatProp*OpTempShift(j+1,i);
%         end
%         if OpTempShift(j+2,i) > 0
%             OpTempShift(j+2, i-1) = OpTempShift(j+2, i-1) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+2, i-10) = OpTempShift(j+2, i-10) + heatProp*OpTempShift(j+2,i);
%             OpTempShift(j+1, i-10) = OpTempShift(j+1, i-10) + heatProp*OpTempShift(j+2,i);
%         end
%     end
% end
end


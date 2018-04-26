function [StablePOut, StableOpVolt, StableOpCur] = ...
    conventional_Temp_Stabilizer( Gvect, Tvect, convergeCriteria, interpolant, currents)
%Takes in Tvector and Gvector as row matrices and outputs stabilized
%operating values for all three panels.
[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = ...
    conventional_Pout_Panel( Gvect, Tvect, interpolant, currents);

TempChangeUpdateHold = TempChangeUpdate;

Tvect = Tvect - TempChangeUpdate;

[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = ...
    conventional_Pout_Panel( Gvect, Tvect, interpolant, currents);

PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;

while (max(PercentChangeTempUpdate) > convergeCriteria)
    TempChangeUpdateHold = TempChangeUpdate;
    Tvect = Tvect - TempChangeUpdate;
    [ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = ...
        conventional_Pout_Panel( Gvect, Tvect, interpolant, currents);
    PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;
end

StablePOut = PowerOut;
StableOpVolt = OperatingVoltage;
StableOpCur = OperatingCurrent;
end

    
    
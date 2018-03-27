function [StablePOut, StableOpVolt, StableOpCur] = conventional_Temp_Stabilizer( Gvect, Tvect)
%Takes in Tvector and Gvector as row matrices and outputs stabilized
%operating values for all three panels.
    
[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect);

TempChangeUpdateHold = TempChangeUpdate;

Tvect = Tvect - TempChangeUpdate;

[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect);

PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;

while (max(PercentChangeTempUpdate) > 0.0001)
    TempChangeUpdateHold = TempChangeUpdate;
    Tvect = Tvect - TempChangeUpdate;
    [ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect);
    PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;
end

StablePOut = PowerOut;
StableOpVolt = OperatingVoltage;
StableOpCur = OperatingCurrent;
end

    
    
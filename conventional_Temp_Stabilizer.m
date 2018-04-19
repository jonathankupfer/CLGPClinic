function [StablePOut, StableOpVolt, StableOpCur] = conventional_Temp_Stabilizer( Gvect, Tvect, convergeCriteria, interpolant, Ipvout)
%Takes in Tvector and Gvector as row matrices and outputs stabilized
%operating values for all three panels.
[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect, interpolant, Ipvout);

TempChangeUpdateHold = TempChangeUpdate;

Tvect = Tvect - TempChangeUpdate;

[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect, interpolant, Ipvout);

PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;

while (max(PercentChangeTempUpdate) > convergeCriteria)
    TempChangeUpdateHold = TempChangeUpdate;
    Tvect = Tvect - TempChangeUpdate;
    [ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = conventional_Pout_Panel( Gvect, Tvect, interpolant, Ipvout);
    PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;
end

StablePOut = PowerOut;
StableOpVolt = OperatingVoltage;
StableOpCur = OperatingCurrent;
end

    
    
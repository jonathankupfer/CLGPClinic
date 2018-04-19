function [StablePOut, StableOpVolt, StableOpCur] = idealPV_Temp_Stabilizer( Gvect, Tvect, convergeCriteria)
%Takes in Tvector and Gvector as row matrices and outputs stabilized
%operating values for all three panels.
convergeCriteria = .1;

[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = idealPV_Pout_Panel( Gvect, Tvect);

TempChangeUpdateHold = TempChangeUpdate;

Tvect = Tvect - TempChangeUpdate;

[ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = idealPV_Pout_Panel( Gvect, Tvect);

PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;

while (max(PercentChangeTempUpdate) > convergeCriteria)
    TempChangeUpdateHold = TempChangeUpdate;
    Tvect = Tvect - TempChangeUpdate;
    [ PowerOut, OperatingVoltage, OperatingCurrent, TempChangeUpdate] = idealPV_Pout_Panel( Gvect, Tvect);
    PercentChangeTempUpdate = abs(TempChangeUpdateHold - TempChangeUpdate)./TempChangeUpdateHold;
end

StablePOut = PowerOut;
StableOpVolt = OperatingVoltage;
StableOpCur = OperatingCurrent;
end

    
    
Gvect = 700.*ones(9,20);
Gvect(5,10) = 20;
Tvect = 35.*ones(9,20);

convergeCriteria = 0.01;
[StablePOut, StableOpVolt, StableOpCur] = conventional_Temp_Stabilizer( Gvect, Tvect, convergeCriteria, Kyocerainterpolant, Ipvout);
%[ PowerOut, OperatingVoltage, OperatingCurrent, OpTempShift] = conventional_Pout_Panel( Gvect, Tvect, interpolant, Ipvout );
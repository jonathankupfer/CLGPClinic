Gvect(1:230,1) = 500.*ones(230,1);
Gvect(231:460,1) = 900.*ones(230,1);
Gvect(461:690,1) = 450.*ones(230,1);
Tvect(1:230,1) = 29.*ones(230,1);
Tvect(231:460,1) = 37.*ones(230,1);
Tvect(461:690,1) = 27.*ones(230,1);

[ Pt, OperatingVoltage, OperatingCurrent] = idealPV_Pout_Panel( Gvect, Tvect, IdealPVinterpolant, Ipvout);
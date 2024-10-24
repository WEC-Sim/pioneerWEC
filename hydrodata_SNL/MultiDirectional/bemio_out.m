hydro = struct();

% hydro = readWAMIT(hydro,'wec_and_nsif.out',[]);
% hydro = radiationIRF(hydro,100,[],[],[],[]);
% hydro = radiationIRFSS(hydro,[],[]);
% hydro = excitationIRF(hydro,100,[],[],[],[]);
hydro = readH5ToStruct('wec_and_nsif_clean.h5');
cbCorr = -0.219;
hydro.cb(3,1) = cbCorr;
KhsCorr = 3.8201e4;
hydro.Khs(4,4,1) = KhsCorr/(1000*9.81);
hydro.Khs(5,5,1) = KhsCorr/(1000*9.81);
hydro = rmfield(hydro,'gbm');
hydro.file = 'wec_and_nsif_clean_cb_corrected';

writeBEMIOH5(hydro)
% plotBEMIO(hydro)
%save('wec_and_nsif_clean.mat','-mat')

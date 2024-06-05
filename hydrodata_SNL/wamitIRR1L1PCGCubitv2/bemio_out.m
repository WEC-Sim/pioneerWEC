hydro = struct();

hydro = readWAMIT(hydro,'wec_and_nsif.out',[]);
hydro = radiationIRF(hydro,100,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,100,[],[],[],[]);

hydro.cb(3,1) = -.235;
hydro.cb(3,2) = -7;
hydro.Khs(6,6,1) = 0.0995;
hydro.Khs(6,6,2) = 0.0995;

writeBEMIOH5(hydro)
plotBEMIO(hydro)
save('wamit_wec_and_nsif.mat','-mat')
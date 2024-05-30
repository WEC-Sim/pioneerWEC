hydro = struct();

hydro = readWAMIT(hydro,'wec_and_nsif.out',[]);
hydro = radiationIRF(hydro,100,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,100,[],[],[],[]);
writeBEMIOH5(hydro)
plotBEMIO(hydro)
save('wamit_wec_and_nsif.mat','-mat')
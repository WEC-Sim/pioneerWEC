hydro = struct();

<<<<<<< Updated upstream
hydro = readWAMIT(hydro,'wec_and_nsif.out',[]);
hydro = radiationIRF(hydro,100,[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,100,[],[],[],[]);

=======
% hydro = readWAMIT(hydro,'wec_and_nsif.out',[]);
% hydro = radiationIRF(hydro,100,[],[],[],[]);
% hydro = radiationIRFSS(hydro,[],[]);
% hydro = excitationIRF(hydro,100,[],[],[],[]);
hydro = readH5ToStruct('wec_and_nsif_clean.h5');
>>>>>>> Stashed changes
hydro.cb(3,1) = -.235;
hydro.cb(3,2) = -7;
hydro.Khs(6,6,1) = 0.0995;
hydro.Khs(6,6,2) = 0.0995;
<<<<<<< Updated upstream

writeBEMIOH5(hydro)
plotBEMIO(hydro)
save('wamit_wec_and_nsif.mat','-mat')
=======
% hydro.md_mc = zeros(12,1,length(hydro.w));
% hydro.md_mc(1,:,:) = .01;
% hydro.md_mc(7,:,:) = .01;
% writeBEMIOH5(hydro)
% plotBEMIO(hydro)
% save('wamit_wec_and_nsif.mat','-mat')
>>>>>>> Stashed changes

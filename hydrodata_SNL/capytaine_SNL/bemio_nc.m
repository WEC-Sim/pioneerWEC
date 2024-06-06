hydro = struct();

hydro = readCAPYTAINE(hydro,'pioneer_NSIF_box.nc', 'hs_NSIF_box');
hydro = radiationIRF(hydro,[],[],[],[],[]);
hydro = radiationIRFSS(hydro,[],[]);
hydro = excitationIRF(hydro,[],[],[],[],[]);
%writeBEMIOH5(hydro)

hydro2 = readH5ToStruct('../wamitIRR1L1PCGCubit/wec_and_nsif_cubit_clean.h5');
hydro2 = addDefaultPlotVars(hydro2);

plotBEMIO(hydro, hydro2)
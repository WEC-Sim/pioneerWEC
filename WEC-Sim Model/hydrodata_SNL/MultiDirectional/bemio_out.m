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

% add in 340 degrees using the 2nd 
hydro.theta(18) = 340;
exVars = ["ex_re","ex_im","sc_re","sc_im","fk_re","fk_im","md_mc"];

% surge, sway, pitch, and roll should be opposite of the number 9
dofOpposites = [1,2,4,5];

for ii = 1:length(exVars)
    hydro.(exVars(ii))(:,18,:) = hydro.(exVars(ii))(:,9,:);
    hydro.(exVars(ii))(dofOpposites,18,:) = -hydro.(exVars(ii))(dofOpposites,9,:);
end

exVarsMaPh = ["ex_ma","ex_ph"]; % 

for ii = 1:length(exVarsMaPh)
    if contains(exVarsMaPh(ii),'ma')
        hydro.(exVarsMaPh(ii))(:,18,:) = abs(hydro.ex_re(:,18,:) + 1j*hydro.ex_im(:,18,:));
    else
        hydro.(exVarsMaPh(ii))(:,18,:) = angle(hydro.ex_re(:,18,:) + 1j*hydro.ex_im(:,18,:));
    end
end

scVarsMaPh = ["sc_ma","sc_ph"]; % 

for ii = 1:length(scVarsMaPh)
    if contains(scVarsMaPh(ii),'ma')
        hydro.(scVarsMaPh(ii))(:,18,:) = abs(hydro.sc_re(:,18,:) + 1j*hydro.sc_im(:,18,:));
    else
        hydro.(scVarsMaPh(ii))(:,18,:) = angle(hydro.sc_re(:,18,:) + 1j*hydro.sc_im(:,18,:));
    end
end

fkVarsMaPh = ["fk_ma","fk_ph"]; %

for ii = 1:length(fkVarsMaPh)
    if contains(fkVarsMaPh(ii),'ma')
        hydro.(fkVarsMaPh(ii))(:,18,:) = abs(hydro.ex_re(:,18,:) + 1j*hydro.sc_im(:,18,:));
    else
        hydro.(fkVarsMaPh(ii))(:,18,:) = angle(hydro.ex_re(:,18,:) + 1j*hydro.sc_im(:,18,:));
    end
end

hydro = excitationIRF(hydro,100,[],[],[],[]);

hydro.file = 'wec_and_nsif_clean_cb_corrected_340';

writeBEMIOH5(hydro)
% plotBEMIO(hydro)
%save('wec_and_nsif_clean.mat','-mat')

% correcting hydrostatics of pioneer

KhsOrig = 2.1847e4; % this is WAMITs est of Khs.
CgOrig = 0.2980; % this is the correct Cg (from drawing)
CbOrig = -0.7054 + CgOrig; % this is the WAMIT calcd Cb (assuming as solid box)
CbCorr = -0.219; % this is the corrected Cb (from drawing)
dispVol = 5.1095; % m^3, displaced volume
rho = 1000; % fluid density kg/m^3
g = 9.81; % gravity (m/s^2)

mass = 3747;

% this gets to the "mesh only" contribution to Khs. This shouldn't change
% in the original vs corrected values
KhsMesh = KhsOrig - (rho*g*dispVol*(CbOrig - CgOrig));

% now corrected as mesh plus the contribution of corrected Cb-Cg
KhsCorr = KhsMesh + (mass*g*(CbCorr - CgOrig));
close all
clear all
clc

hydro = readH5ToStruct('wec_and_nsif_clean.h5');

F_exc = hydro.rho*hydro.g*(hydro.ex_re + hydro.ex_im*1j);
A = hydro.rho*hydro.A;
B = hydro.rho*hydro.w'.*reshape(hydro.B,202,12,12);
K_hs = hydro.rho*hydro.g*hydro.Khs;
K_hs = [K_hs(:,:,1),zeros(6);zeros(6),K_hs(:,:,2)];

mass = 3747;
inertia = 7484;
buoyImpedance = [];
for ii = 1:length(hydro.w)
    B = hydro.rho*hydro.w(ii).*hydro.B(:,:,12);
    buoyImpedance(:,:,ii) = 1j*hydro.w(ii).*(inertia + A(:,:,ii)) + B + K_hs.*(1/(1j*hydro.w(ii)'));
end


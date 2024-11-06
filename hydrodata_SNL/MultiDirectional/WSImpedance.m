%%
close all
clear;
clc;

%% 
% calc impedance from WS

bodyTest = readBEMIOH5('wec_and_nsif_clean.h5',1,0);
%body = load('C:\Users\dforbus\pioneerSNL_fresh\pioneerSNL\minTunedModel\bodyRun')

%% correct hydrostatics
KhsOrig = bodyTest.hydro_coeffs.linear_restoring_stiffness(4,4) % this is WAMITs est of Khs.
CgOrig = bodyTest.properties.centerGravity(3); % this is the correct Cg (from drawing)
CbOrig = bodyTest.properties.centerBuoyancy(3); % this is the WAMIT calcd Cb (assuming as solid box)
CbCorr = -0.219; % this is the corrected Cb (from drawing)
dispVol = bodyTest.properties.volume; % m^3, displaced volume
rho = 1000; % fluid density kg/m^3
g = 9.81; % gravity (m/s^2)
m = 3747; % buoy mass in kg
I = 7484; % correct for pitch inertia

% this gets to the "mesh only" contribution to Khs. This shouldn't change
% in the original vs corrected values
KhsMesh = KhsOrig*rho*g - (rho*g*dispVol*(CbOrig - CgOrig));

% now corrected as mesh plus the contribution of corrected Cb-Cg
KhsCorr = KhsMesh + (m*g*(CbCorr-CgOrig));

%% calculate impedance

% this is just a shorthand to facilitate calculation
Bmat([1:6],[1:6],:) = bodyTest.hydro_coeffs.radiation_damping.all([1:6],[1:6],:);
Amat([1:6],[1:6],:) = bodyTest.hydro_coeffs.added_mass.all([1:6],[1:6],:);
Kmat = bodyTest.hydro_coeffs.linear_restoring_stiffness;
% create a frequency matrix to facilitate multiplication
w = permute(bodyTest.simulation_parameters.w,[1,3,2]);
wMat = repmat(w,[6,6,1]);
% de-normalize
Bmat = Bmat .* wMat .* rho;
Amat = Amat .* rho;
Kmat = Kmat .* rho .* g; 
% apply corrected Khs
Kmat(4,4)=KhsCorr; Kmat(5,5)=KhsCorr;
Kmat = repmat(Kmat,[1,1,length(w)]);



Z = 1i .* wMat .* (I + Amat) + Bmat + Kmat./(1i.*wMat);

%% plot

for k=1:6
    for kk = 1:6
       figure(1) % real parts
        subplot(6,6,6*(k-1)+kk)
        plot(squeeze(w),squeeze(real(Z(k,kk,:))),'b','LineWidth',1.2)
        grid on;

       figure(2) % imag parts
        subplot(6,6,6*(k-1)+kk)
        plot(squeeze(w),squeeze(imag(Z(k,kk,:))),'b','LineWidth',1.2)
        grid on;

       figure(3) % abs
        subplot(6,6,6*(k-1)+kk)
        plot(squeeze(w),squeeze(abs(Z(k,kk,:))),'b','LineWidth',1.2)
        grid on;

       figure(4) % angle
        subplot(6,6,6*(k-1)+kk)
        plot(squeeze(w),squeeze(angle(Z(k,kk,:))),'b','LineWidth',1.2)
        grid on;

    end
end

% labeling
for k=1:4
    for kk=1:6
    figure(k)
    subplot(6,6,1+6*(kk-1)) % y axis
    switch k
        case 1
            ylabel('Real(Z)')
        case 2
            ylabel('Imag(Z)')
        case 3
            ylabel('|Z|')
        case 4
            ylabel('angle(Z)')
    end
    subplot(6,6,30+kk)
    xlabel('\omega (rad/s)')
    end
end

%%

figure()
% subplot(4,1,1)
% plot(squeeze(w),squeeze(real(Z(5,5,:))),'b','LineWidth',1.2)
% grid on;
% 
% subplot(4,1,2)
% plot(squeeze(w),squeeze(imag(Z(5,5,:))),'b','LineWidth',1.2)
% grid on;

subplot(2,1,1)
semilogy(squeeze(w)/(2*pi),squeeze(abs(Z(5,5,:))),'LineWidth',1.2)
grid on;
xlim([min(squeeze(w)/(2*pi)),max(squeeze(w)/(2*pi))])
ylabel('|Z|')

subplot(2,1,2)
plot(squeeze(w)/(2*pi),squeeze(angle(Z(5,5,:))),'LineWidth',1.2)
grid on;
xlim([min(squeeze(w)/(2*pi)),max(squeeze(w)/(2*pi))])
xlabel('\omega (Hz)')
ylabel('angle(Z)')

% find natural frequency
natFreq = interp1(squeeze(angle(Z(5,5,:))),squeeze(w)/(2*pi),0);
natPeriod = 1/natFreq;

xline(natFreq,'--','LineWidth',1.2);
text(0.35, 0.05, ['Natural Frequency = ',num2str(natFreq,'%3.3f'),' s']);

% set(gcf, 'PaperPosition', [0 0 6 4])
% set(gcf, 'PaperSize', [6 4])
% print(gcf, strcat('../../paperFigs/BEMImpedance.pdf'), '-dpdf', '-fillpage','-r1000','-vector')
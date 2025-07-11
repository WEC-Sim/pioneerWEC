close all
clear all
clc

load('mcrRAO_FINAL.mat');

figure()
plot(mcr.cases(:,2),mcr.posRMSXY(:,[1]),'-.k')
hold on
plot(mcr.cases(:,2),mcr.posRMSXY(:,[3]),'--k')
plot(mcr.cases(:,2),mcr.posRMSXY(:,[5]),'-k')
ylabel('Response (m or rad)')
xlabel('Period (s)')
legend({'Surge','Heave','Pitch'})

figure()
plot(mcr.cases(:,2),mcr.posRMSXY(:,[5])*180/pi/waves.height,'-k')
ylabel(strcat('Pitch Response RMS (',char(176),'/m)'))
xlabel('Period (s)')
xlim([2, 10])

% set(gcf, 'PaperPosition', [0 0 5 4])
% set(gcf, 'PaperSize', [5 4])
% print(gcf, strcat('../paperFigs/RAO.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

figure()
plot(1./mcr.cases(:,2),mcr.excForceRMSXY(:,[1])./(mcr.velRMSXY(:,[1])*180/pi),'-.k')
hold on
plot(1./mcr.cases(:,2),mcr.excForceRMSXY(:,[3])./(mcr.velRMSXY(:,[3])*180/pi),'--k')
plot(1./mcr.cases(:,2),mcr.excForceRMSXY(:,[5])./(mcr.velRMSXY(:,[5])*180/pi),'-k')
ylabel('Impedance (m/Ns)')
xlabel('Period (s)')
legend({'Surge','Heave','Pitch'})


figure()
loglog(1./mcr.cases(:,2),mcr.excForceRMSXY(:,[5])./(mcr.velRMSXY(:,[5])*180/pi),'-k')
ylabel(strcat('Pitch Impedance Magnitude (Nms/',char(176),')'))
xlabel('Frequency (Hz)')
xlim([.1, .5])

% set(gcf, 'PaperPosition', [0 0 5 4])
% set(gcf, 'PaperSize', [5 4])
% print(gcf, strcat('../paperFigs/Impedance.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

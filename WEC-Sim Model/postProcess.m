% clear all
% close all
% clc
% 
load('mcrRes4SS_FINAL.mat');
% 
load('obsData/processedDataPS')

weights = [.48 .22 .21 .09];

if length(mcr.cases)==4
    for ii = 1:length(mcr.cases)
        velRMSObs(ii,:) = [processedData{ii}.rmsTransPS, processedData{ii}.rmsRotPS*180/pi];
        velRMSWS(ii,:) = [mcr.velRMSPS(ii,1:3), mcr.velRMSPS(ii,4:6)*180/pi];
        velRMSDiff(ii,1:3) = processedData{ii}.rmsTransPS - mcr.velRMSPS(ii,1:3);
        velRMSDiff(ii,4:6) = (processedData{ii}.rmsRotPS - mcr.velRMSPS(ii,4:6))*180/pi;
        velRMSDiffPercent(ii,1:3) = (processedData{ii}.rmsTransPS - mcr.velRMSPS(ii,1:3))./processedData{ii}.rmsTransPS*100;
        velRMSDiffPercent(ii,4:6) = (processedData{ii}.rmsRotPS - mcr.velRMSPS(ii,4:6))./processedData{ii}.rmsRotPS*100;
    end


fprintf("Observed RMS with respect to preferred axis. \n")
disp(velRMSObs)

fprintf("WEC-Sim RMS with respect to preferred axis: \n")
disp(velRMSWS)

fprintf("RMS Difference: \n")
disp(velRMSDiff)

fprintf("Percent RMS Difference: \n")
disp(velRMSDiffPercent)

% calculate total weighted error for all directions
fprintf("Weighted error: \n")
weightedError = weights*abs(velRMSDiffPercent)

else
    figure()
    plot(mcr.cases(:,2),mcr.posAmpXY(:,[1]),'-.k')
    hold on
    plot(mcr.cases(:,2),mcr.posAmpXY(:,[3]),'--k')
    plot(mcr.cases(:,2),mcr.posAmpXY(:,[5]),'-k')
    ylabel('Response (m or rad)')
    xlabel('Period (s)')
    legend({'Surge','Heave','Pitch'})

    figure()
    plot(mcr.cases(:,2),mcr.posAmpXY(:,[5])*180/pi,'-k')
    ylabel(strcat('Pitch Response (',char(176),')'))
    xlabel('Period (s)')

    % set(gcf, 'PaperPosition', [0 0 5 4])
    % set(gcf, 'PaperSize', [5 4])
    % print(gcf, strcat('./paperFigs/RAO.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

    figure()
    plot(mcr.cases(:,2),mcr.velAmpXY(:,[1])./mcr.excForceAmpXY(:,[1]),'-.k')
    hold on
    plot(mcr.cases(:,2),mcr.velAmpXY(:,[3])./mcr.excForceAmpXY(:,[3]),'--k')
    plot(mcr.cases(:,2),mcr.velAmpXY(:,[5])./mcr.excForceAmpXY(:,[5]),'-k')
    ylabel('Impedance (m/Ns)')
    xlabel('Period (s)')
    legend({'Surge','Heave','Pitch'})


    figure()
    semilogx(1./mcr.cases(:,2),mcr.excForceAmpXY(:,[5])./(mcr.velAmpXY(:,[5])*180/pi),'-k')
    ylabel(strcat('Pitch Impedance Magnitude (Nms/',char(176),')'))
    xlabel('Frequency (Hz)')
    
    % set(gcf, 'PaperPosition', [0 0 5 4])
    % set(gcf, 'PaperSize', [5 4])
    % print(gcf, strcat('./paperFigs/Impedance.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

end


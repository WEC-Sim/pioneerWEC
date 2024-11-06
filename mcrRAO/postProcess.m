% clear all
% close all
% clc
% 
load('mcrResRAO_3DOF_cb_corrected.mat');
% 
% load('obsData/processedDataPS')

weights = [.48 .22 .21 .09];

if length(mcr.cases)==4
    for ii = 1:length(mcr.cases)
        velRMSObs(ii,:) = [processedData{ii}.rmsTransPS, processedData{ii}.rmsRotPS*180/pi];
        velRMSWS(ii,:) = [mcr.velRMSPS(ii,1:3), mcr.velRMSPS(ii,4:6)*180/pi]
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
    plot(mcr.cases(:,2),mcr.posRMSXY(:,[1]),'-.k')
    hold on
    plot(mcr.cases(:,2),mcr.posRMSXY(:,[3]),'--k')
    plot(mcr.cases(:,2),mcr.posRMSXY(:,[5]),'-k')
    ylabel('Response (m or rad)')
    xlabel('Period (s)')
    legend({'Surge','Heave','Pitch'})

    figure()
    plot(mcr.cases(:,2),mcr.posRMSXY(:,[5])*180/pi,'-k')
    ylabel(strcat('Pitch Response RMS (',char(176),')'))
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
    semilogx(1./mcr.cases(:,2),mcr.excForceRMSXY(:,[5])./(mcr.velRMSXY(:,[5])*180/pi),'-k')
    ylabel(strcat('Pitch Impedance Magnitude (Nms/',char(176),')'))
    xlabel('Frequency (Hz)')
    xlim([.1, .5])
    
    % set(gcf, 'PaperPosition', [0 0 5 4])
    % set(gcf, 'PaperSize', [5 4])
    % print(gcf, strcat('../paperFigs/Impedance.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

end


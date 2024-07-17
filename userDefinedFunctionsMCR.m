%% User Defined Functions for MCR run

% find 100 s
[~,startInd] = min(abs(200-output.bodies(1).time));

mcr.posStd(imcr,:) = std(output.bodies(1).position(startInd:end,:));
mcr.velStd(imcr,:) = std(output.bodies(1).velocity(startInd:end,:));
mcr.accStd(imcr,:) = std(output.bodies(1).acceleration(startInd:end,:));
mcr.forceStd(imcr,:) = std(output.bodies(1).forceTotal(startInd:end,:));

% convert to x-y axes consistent with wave direction:
waveAngleN = waves.direction;
output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];
output.bodies(1).forceTotalXY = [output.bodies(1).forceTotal(:,1:3)*rotz(waveAngleN),output.bodies(1).forceTotal(:,4:6)*rotz(waveAngleN)];
output.bodies(1).forceExcitationXY = [output.bodies(1).forceExcitation(:,1:3)*rotz(waveAngleN),output.bodies(1).forceExcitation(:,4:6)*rotz(waveAngleN)];

mcr.posStdXY(imcr,:) = std(output.bodies(1).positionXY(startInd:end,:));
mcr.velStdXY(imcr,:) = std(output.bodies(1).velocityXY(startInd:end,:));
mcr.accStdXY(imcr,:) = std(output.bodies(1).accelerationXY(startInd:end,:));
mcr.forceStdXY(imcr,:) = std(output.bodies(1).forceTotalXY(startInd:end,:));
mcr.excForceStdXY(imcr,:) = std(output.bodies(1).forceExcitationXY(startInd:end,:));

mcr.posAmpXY(imcr,:) = range(output.bodies(1).positionXY(startInd:end,:))/2;
mcr.velAmpXY(imcr,:) = range(output.bodies(1).velocityXY(startInd:end,:))/2;
mcr.accAmpXY(imcr,:) = range(output.bodies(1).accelerationXY(startInd:end,:))/2;
mcr.forceAmpXY(imcr,:) = range(output.bodies(1).forceTotalXY(startInd:end,:))/2;
mcr.excForceAmpXY(imcr,:) = range(output.bodies(1).forceExcitationXY(startInd:end,:))/2;

if imcr == length(mcr.cases)
    
    save('mcrResPCT.mat')
    
    % figure()
    % plot(mcr.cases(:,2),mcr.posAmpXY(:,[1]),'-.k')
    % hold on
    % plot(mcr.cases(:,2),mcr.posAmpXY(:,[3]),'--k')
    % plot(mcr.cases(:,2),mcr.posAmpXY(:,[5]),'-k')
    % ylabel('Response (m or rad)')
    % xlabel('Period (s)')
    % legend({'Surge','Heave','Pitch'})

    figure()
    plot(mcr.cases(:,2),mcr.posAmpXY(:,[5])*180/pi,'-k')
    ylabel(strcat('Pitch Response (',char(176),')'))
    xlabel('Period (s)')

    % set(gcf, 'PaperPosition', [0 0 5 4])
    % set(gcf, 'PaperSize', [5 4])
    % print(gcf, strcat('./paperFigs/RAO.pdf'), '-dpdf', '-fillpage','-r1000','-image')

    % figure()
    % plot(mcr.cases(:,2),mcr.velAmpXY(:,[1])./mcr.excForceAmpXY(:,[1]),'-.k')
    % hold on
    % plot(mcr.cases(:,2),mcr.velAmpXY(:,[3])./mcr.excForceAmpXY(:,[3]),'--k')
    % plot(mcr.cases(:,2),mcr.velAmpXY(:,[5])./mcr.excForceAmpXY(:,[5]),'-k')
    % ylabel('Impedance (m/Ns)')
    % xlabel('Period (s)')
    % legend({'Surge','Heave','Pitch'})

    %freqs = 

    figure()
    semilogx(1./mcr.cases(:,2),mcr.excForceAmpXY(:,[5])./(mcr.velAmpXY(:,[5])*180/pi),'-k')
    ylabel(strcat('Pitch Impedance Magnitude (Nms/',char(176),')'))
    xlabel('Frequency (Hz)')
    
    % set(gcf, 'PaperPosition', [0 0 5 4])
    % set(gcf, 'PaperSize', [5 4])
    % print(gcf, strcat('./paperFigs/Impedance.pdf'), '-dpdf', '-fillpage','-r1000','-image')
end

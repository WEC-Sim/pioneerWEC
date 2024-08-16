%% User Defined Functions for MCR run

% find 100 s
[~,startInd] = min(abs(100-output.bodies(1).time));


mcr.posRMS(imcr,:) = rms(output.bodies(1).position(startInd:end,:));
mcr.velRMS(imcr,:) = rms(output.bodies(1).velocity(startInd:end,:));
mcr.accRMS(imcr,:) = rms(output.bodies(1).acceleration(startInd:end,:));
mcr.forceRMS(imcr,:) = rms(output.bodies(1).forceTotal(startInd:end,:));

% convert to x-y axes consistent with wave direction:
waveAngleN = waves.direction;
mcr.waveDir(imcr) = waveAngleN;
output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];
output.bodies(1).forceTotalXY = [output.bodies(1).forceTotal(:,1:3)*rotz(waveAngleN),output.bodies(1).forceTotal(:,4:6)*rotz(waveAngleN)];
output.bodies(1).forceExcitationXY = [output.bodies(1).forceExcitation(:,1:3)*rotz(waveAngleN),output.bodies(1).forceExcitation(:,4:6)*rotz(waveAngleN)];

mcr.posRMSXY(imcr,:) = rms(output.bodies(1).positionXY(startInd:end,:));
mcr.velRMSXY(imcr,:) = rms(output.bodies(1).velocityXY(startInd:end,:));
mcr.accRMSXY(imcr,:) = rms(output.bodies(1).accelerationXY(startInd:end,:));
mcr.forceRMSXY(imcr,:) = rms(output.bodies(1).forceTotalXY(startInd:end,:));
mcr.excForceRMSXY(imcr,:) = rms(output.bodies(1).forceExcitationXY(startInd:end,:));

mcr.posAmpXY(imcr,:) = range(output.bodies(1).positionXY(startInd:end,:))/2;
mcr.velAmpXY(imcr,:) = range(output.bodies(1).velocityXY(startInd:end,:))/2;
mcr.accAmpXY(imcr,:) = range(output.bodies(1).accelerationXY(startInd:end,:))/2;
mcr.forceAmpXY(imcr,:) = range(output.bodies(1).forceTotalXY(startInd:end,:))/2;
mcr.excForceAmpXY(imcr,:) = range(output.bodies(1).forceExcitationXY(startInd:end,:))/2;

angleVec = waveAngleN-90:0.5:waveAngleN+90;
% Run through all valid angles to find ideal orientation for specific trial
for qa = 1:length(angleVec)
    velocityRotCheck(qa,:) = rms(output.bodies(1).velocity(startInd:end,4:6)*rotz(angleVec(qa)));
end

% Find maximum value for the primary axis
[RMSPeak,angleIndex] = max(velocityRotCheck(:,2)); % find max pitch response
peakAngle = angleVec(angleIndex);

% convert to primary and secondary axes:
mcr.primaryAxis(imcr) = peakAngle;
output.bodies(1).positionPS = [output.bodies(1).position(:,1:3)*rotz(peakAngle),output.bodies(1).position(:,4:6)*rotz(peakAngle)];
output.bodies(1).velocityPS = [output.bodies(1).velocity(:,1:3)*rotz(peakAngle),output.bodies(1).velocity(:,4:6)*rotz(peakAngle)];
output.bodies(1).accelerationPS = [output.bodies(1).acceleration(:,1:3)*rotz(peakAngle),output.bodies(1).acceleration(:,4:6)*rotz(peakAngle)];
output.bodies(1).forceTotalPS = [output.bodies(1).forceTotal(:,1:3)*rotz(peakAngle),output.bodies(1).forceTotal(:,4:6)*rotz(peakAngle)];
output.bodies(1).forceExcitationPS = [output.bodies(1).forceExcitation(:,1:3)*rotz(peakAngle),output.bodies(1).forceExcitation(:,4:6)*rotz(peakAngle)];

mcr.posRMSPS(imcr,:) = rms(output.bodies(1).positionPS(startInd:end,:));
mcr.velRMSPS(imcr,:) = rms(output.bodies(1).velocityPS(startInd:end,:));
mcr.accRMSPS(imcr,:) = rms(output.bodies(1).accelerationPS(startInd:end,:));
mcr.forceRMSPS(imcr,:) = rms(output.bodies(1).forceTotalPS(startInd:end,:));
mcr.excForceRMSPS(imcr,:) = rms(output.bodies(1).forceExcitationPS(startInd:end,:));

mcr.posAmpPS(imcr,:) = range(output.bodies(1).positionPS(startInd:end,:))/2;
mcr.velAmpPS(imcr,:) = range(output.bodies(1).velocityPS(startInd:end,:))/2;
mcr.accAmpPS(imcr,:) = range(output.bodies(1).accelerationPS(startInd:end,:))/2;
mcr.forceAmpPS(imcr,:) = range(output.bodies(1).forceTotalPS(startInd:end,:))/2;
mcr.excForceAmpPS(imcr,:) = range(output.bodies(1).forceExcitationPS(startInd:end,:))/2;


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

    % figure()
    % plot(mcr.cases(:,2),mcr.posAmpXY(:,[5])*180/pi,'-k')
    % ylabel(strcat('Pitch Response (',char(176),')'))
    % xlabel('Period (s)')

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

    % figure()
    % semilogx(1./mcr.cases(:,2),mcr.excForceAmpXY(:,[5])./(mcr.velAmpXY(:,[5])*180/pi),'-k')
    % ylabel(strcat('Pitch Impedance Magnitude (Nms/',char(176),')'))
    % xlabel('Frequency (Hz)')
    
    % set(gcf, 'PaperPosition', [0 0 5 4])
    % set(gcf, 'PaperSize', [5 4])
    % print(gcf, strcat('./paperFigs/Impedance.pdf'), '-dpdf', '-fillpage','-r1000','-image')
end

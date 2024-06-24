%% User Defined Functions for MCR run

% find 100 s
[~,startInd] = min(abs(100-output.bodies(1).time));

mcr.posStd(imcr,:) = std(output.bodies(1).position(startInd:end,:));
mcr.velStd(imcr,:) = std(output.bodies(1).velocity(startInd:end,:));
mcr.accStd(imcr,:) = std(output.bodies(1).acceleration(startInd:end,:));
mcr.forceStd(imcr,:) = std(output.bodies(1).forceTotal(startInd:end,:));

% convert to x-y axes consistent with wave direction:
waveAngleN = 90-waves.direction;
output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];
output.bodies(1).forceTotalXY = [output.bodies(1).forceTotal(:,1:3)*rotz(waveAngleN),output.bodies(1).forceTotal(:,4:6)*rotz(waveAngleN)];

mcr.posStdXY(imcr,:) = std(output.bodies(1).positionXY(startInd:end,:));
mcr.velStdXY(imcr,:) = std(output.bodies(1).velocityXY(startInd:end,:));
mcr.accStdXY(imcr,:) = std(output.bodies(1).accelerationXY(startInd:end,:));
mcr.forceStdXY(imcr,:) = std(output.bodies(1).forceTotalXY(startInd:end,:));

mcr.posAmpXY(imcr,:) = range(output.bodies(1).positionXY(startInd:end,:))/2;
mcr.velAmpXY(imcr,:) = range(output.bodies(1).velocityXY(startInd:end,:))/2;
mcr.accAmpXY(imcr,:) = range(output.bodies(1).accelerationXY(startInd:end,:))/2;
mcr.forceAmpXY(imcr,:) = range(output.bodies(1).forceTotalXY(startInd:end,:))/2;

if imcr == length(mcr.cases)
    %save(filename)
    save('mcrResPCT.mat')
end

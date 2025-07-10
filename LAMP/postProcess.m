close all

% plot 120 s intervals on top of each other

numRepeats = floor(output.bodies(1).time(end)/120);

dofNames = ["surge","sway","heave","roll","pitch","yaw"];
dofUnits = ["m","m","m","rad","rad","rad"];

rmsPos = {};

if plotFlag == 1
    for ii = 1:6
        repeatNames = [];
        figure()
        for jj = 1:numRepeats
            [~,startInd] = min(abs(120*(jj-1) - output.bodies(1).time));
            [~,endInd] = min(abs(120*jj - output.bodies(1).time));
    
            plot(output.bodies(1).time(startInd:endInd)-120*(jj-1), output.bodies(1).position(startInd:endInd,ii))
            hold on
            xlabel('time (s)')
            ylabel([dofNames(ii) 'disp' dofUnits(ii)])

            repeatNames = [repeatNames, strcat("repeat ", num2str(jj))];

        end
        legend(repeatNames)
    end
    if strcmp(waveType,'PM')
        waves.plotSpectrum();
    end
    waves.plotElevation();
end

for ii = 1:6
    for jj = 1:numRepeats
        [~,startInd] = min(abs(120*(jj-1) - output.bodies(1).time));
        [~,endInd] = min(abs(120*jj - output.bodies(1).time));
        rmsPos.(dofNames(ii))(jj) = rms(output.bodies(1).position(startInd:endInd,ii));
    end
end

timeVec = output.bodies(1).time;
positionVec = output.bodies(1).position;
velocityVec = output.bodies(1).velocity;
accelerationVec = output.bodies(1).acceleration;
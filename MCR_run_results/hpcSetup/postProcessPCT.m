close all

delete('matDir/*')
files = dir('*.mat');
if ~isempty(dir('*.mat'))
	for jj = 1:length(files)
		if contains(files(jj).name, 'savedData')
	    		movefile(files(jj).name, 'matDir','f');
		end
	end
end

files = dir('matDir/*.mat');

fileCount = 0;
mcrNew = {};
mcrNew = mcr;

for jj = 1:length(files)
    if contains(files(jj).name, 'savedData')
        disp(files(jj).name)
        load(['matDir/',files(jj).name])
        
        fileCount = fileCount+1;

        % find 100 s
        [~,startInd] = min(abs(100-output.bodies(1).time));
        

        mcrNew.waveHeight(fileCount) = waves.height;
        mcrNew.wavePeriod(fileCount) = waves.period;
	      mcrNew.waveDirection(fileCount) = waves.direction;
        mcrNew.waveDirection_MCR(fileCount) = waveDir;
        mcrNew.aboveWaterMass(fileCount) = aboveWaterMass;
        mcrNew.cdSurge(fileCount) = body(1).quadDrag.cd(1);
        mcrNew.cdHeave(fileCount) = body(1).quadDrag.cd(3);
        mcrNew.cdPitch(fileCount) = body(1).quadDrag.cd(5);
        mcrNew.xLoc(fileCount) = xLoc;
        mcrNew.yLoc(fileCount) = yLoc;
  
	mcrNew.posRMS(fileCount,:) = rms(output.bodies(1).position(startInd:end,:));
        mcrNew.velRMS(fileCount,:) = rms(output.bodies(1).velocity(startInd:end,:));
	mcrNew.accRMS(fileCount,:) = rms(output.bodies(1).acceleration(startInd:end,:));
        mcrNew.forceRMS(fileCount,:) = rms(output.bodies(1).forceTotal(startInd:end,:));

	% convert to x-y axes consistent with wave direction:
	waveAngleN = waves.direction;
	output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
	output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
	output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];
	output.bodies(1).forceTotalXY = [output.bodies(1).forceTotal(:,1:3)*rotz(waveAngleN),output.bodies(1).forceTotal(:,4:6)*rotz(waveAngleN)];

        mcrNew.posRMSXY(fileCount,:) = rms(output.bodies(1).positionXY(startInd:end,:));
        mcrNew.velRMSXY(fileCount,:) = rms(output.bodies(1).velocityXY(startInd:end,:));
	mcrNew.accRMSXY(fileCount,:) = rms(output.bodies(1).accelerationXY(startInd:end,:));
        mcrNew.forceRMSXY(fileCount,:) = rms(output.bodies(1).forceTotalXY(startInd:end,:));

	angleVec = waveAngleN-90:0.5:waveAngleN+90;
	% Run through all valid angles to find ideal orientation for specific trial
	for qa = 1:length(angleVec)
	    velocityRotCheck(qa,:) = rms(output.bodies(1).velocity(startInd:end,4:6)*rotz(angleVec(qa)));
	end

	% Find maximum value for the primary axis
	[RMSPeak,angleIndex] = max(velocityRotCheck(:,2)); % find max pitch response
	peakAngle = angleVec(angleIndex);

	% convert to primary and secondary axes:
	mcrNew.primaryAxis(fileCount) = peakAngle;
	output.bodies(1).positionPS = [output.bodies(1).position(:,1:3)*rotz(peakAngle),output.bodies(1).position(:,4:6)*rotz(peakAngle)];
	output.bodies(1).velocityPS = [output.bodies(1).velocity(:,1:3)*rotz(peakAngle),output.bodies(1).velocity(:,4:6)*rotz(peakAngle)];
	output.bodies(1).accelerationPS = [output.bodies(1).acceleration(:,1:3)*rotz(peakAngle),output.bodies(1).acceleration(:,4:6)*rotz(peakAngle)];
	output.bodies(1).forceTotalPS = [output.bodies(1).forceTotal(:,1:3)*rotz(peakAngle),output.bodies(1).forceTotal(:,4:6)*rotz(peakAngle)];

	mcrNew.posRMSPS(fileCount,:) = rms(output.bodies(1).positionPS(startInd:end,:));
	mcrNew.velRMSPS(fileCount,:) = rms(output.bodies(1).velocityPS(startInd:end,:));
	mcrNew.accRMSPS(fileCount,:) = rms(output.bodies(1).accelerationPS(startInd:end,:));
	mcrNew.forceRMSPS(fileCount,:) = rms(output.bodies(1).forceTotalPS(startInd:end,:));

    end
end


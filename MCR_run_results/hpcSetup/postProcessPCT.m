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
        mcrNew.aboveWaterMass(fileCount) = aboveWaterMass;
        mcrNew.cdSurge(fileCount) = body(1).quadDrag.cd(1);
        mcrNew.cdHeave(fileCount) = body(1).quadDrag.cd(3);
        mcrNew.cdPitch(fileCount) = body(1).quadDrag.cd(5);

	mcrNew.posStd(fileCount,:) = std(output.bodies(1).position(startInd:end,:));
        mcrNew.velStd(fileCount,:) = std(output.bodies(1).velocity(startInd:end,:));
	mcrNew.accStd(fileCount,:) = std(output.bodies(1).acceleration(startInd:end,:));
        mcrNew.forceStd(fileCount,:) = std(output.bodies(1).forceTotal(startInd:end,:));

	% convert to x-y axes consistent with wave direction:
	waveAngleN = 90-waves.direction;
	output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
	output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
	output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];
	output.bodies(1).forceTotalXY = [output.bodies(1).forceTotal(:,1:3)*rotz(waveAngleN),output.bodies(1).forceTotal(:,4:6)*rotz(waveAngleN)];

        mcrNew.posStdXY(fileCount,:) = std(output.bodies(1).positionXY(startInd:end,:));
        mcrNew.velStdXY(fileCount,:) = std(output.bodies(1).velocityXY(startInd:end,:));
	mcrNew.accStdXY(fileCount,:) = std(output.bodies(1).accelerationXY(startInd:end,:));
        mcrNew.forceStdXY(fileCount,:) = std(output.bodies(1).forceTotalXY(startInd:end,:));
    end
end


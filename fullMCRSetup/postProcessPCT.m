close all

% load in the previous results

delete('matDir/*')
if ~isempty(dir('*.mat'))
    movefile('*.mat', 'matDir');
end

files = dir('matDir/*.mat');

fileCount = 0;

for jj = 1:length(files)
    if contains(files(jj).name, 'savedData')
        disp(files(jj).name)
        load(['matDir/',files(jj).name])
        
        fileCount = fileCount+1;

        % find 100 s
        [~,startInd] = min(abs(100-output.bodies(1).time));
        
        mcrOverall.waveHeight(numPar*(ii-1)+fileCount) = waves.height;
        mcrOverall.wavePeriod(numPar*(ii-1)+fileCount) = waves.period;
        mcrOverall.aboveWaterMass(numPar*(ii-1)+fileCount) = aboveWaterMass;
        mcrOverall.cdSurge(numPar*(ii-1)+fileCount) = cdSurge;
        mcrOverall.cdHeave(numPar*(ii-1)+fileCount) = cdHeave;
        mcrOverall.cdPitch(numPar*(ii-1)+fileCount) = cdPitch;
        mcrOverall.posStd(numPar*(ii-1)+fileCount,:) = std(output.bodies(1).position(startInd:end,:));
        mcrOverall.velStd(numPar*(ii-1)+fileCount,:) = std(output.bodies(1).velocity(startInd:end,:));
        mcrOverall.forceStd(numPar*(ii-1)+fileCount,:) = std(output.bodies(1).forceTotal(startInd:end,:));
    end
end

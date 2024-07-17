clear all
close all

if ~isempty(dir('*.mat'))
    movefile('*.mat', 'matDir');
end
files = dir('matDir/*.mat');

mcrOverall = {};
fileCount = 0;

for ii = 1:length(files)
    if contains(files(ii).name, 'savedData')
        disp(files(ii).name)
        load(['matDir/',files(ii).name])
        
        fileCount = fileCount+1;

        if fileCount == 1
            mcrOverall = mcr;
        end

        % find 100 s
        [~,startInd] = min(abs(100-output.bodies(1).time));
        
        mcrOverall.posStd(fileCount,:) = std(output.bodies(1).position(startInd:end,:));
        mcrOverall.velStd(fileCount,:) = std(output.bodies(1).velocity(startInd:end,:));
        mcrOverall.forceStd(fileCount,:) = std(output.bodies(1).forceTotal(startInd:end,:));
    end
end

mcrOverall.cases = mcr.cases;

% save mcrResPCT.mat mcrOverall
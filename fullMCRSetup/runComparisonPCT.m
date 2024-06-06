close all
clear all
clc

tic

% Define WEC-Sim source and add to MATLAB path
wecSimSource = fullfile('../WEC-Sim/source');
addpath(genpath(wecSimSource));
clear wecSimSource

%%
load('../realData_Jantzen/processedDataStd.mat');

heights = [processedData(:).Hm0]';
periods = [processedData(:).Tp]';
heights = heights(1:2);
periods = periods(1:2);
aboveWaterMasses = [100 200]; %[-800; 0; 800; 1600];
cdSurge = .5;%[0.5; .75; 1.0; 1.25];
cdHeave = .5;%[0.5; .75; 1.0; 1.25];
cdPitch = .5;%[0.5; .75; 1.0; 1.25];


caseCount = 1;
% set it up as for each variable combo, we run all heights and periods:
for iMass = 1:length(aboveWaterMasses)
    for iSurge = 1:length(cdSurge)
        for iHeave = 1:length(cdHeave)
            for iPitch = 1:length(cdPitch)
                for iHP = 1:length(heights)
                    heightsVec(caseCount) = heights(iHP);
                    periodsVec(caseCount) = periods(iHP);
                    massVec(caseCount) = aboveWaterMasses(iMass);
                    surgeVec(caseCount) = cdSurge(iSurge);
                    heaveVec(caseCount) = cdHeave(iHeave);
                    pitchVec(caseCount) = cdPitch(iPitch);

                    caseCount = caseCount+1;
                end
            end
        end
    end
end

mcrOverall = struct();
mcrOverall.header = ["waves.height", "waves.period", "aboveWaterMass", "cdSurge", "cdHeave", "cdPitch"];
mcrOverall.cases = [heightsVec', periodsVec', massVec', surgeVec', heaveVec', pitchVec'];

mcr.header = ["waves.height", "waves.period", "aboveWaterMass", "cdSurge", "cdHeave", "cdPitch"];

% split all the mcr cases up so that they don't all try to run in 1
% parallel loop - 100 cases at once seems reasonable
numPar = 2;
for ii = 1:ceil(size(mcrOverall.cases,1)/numPar)
    if ii*numPar > size(mcrOverall.cases,1)
        mcr.cases = mcrOverall.cases(1+numPar*(ii-1):end,:);
    else
        mcr.cases = mcrOverall.cases(1+numPar*(ii-1):ii*numPar,:);
    end
    
    save mcrCases mcr
    
    wecSimPCT
    
    postProcessPCT
end

save mcrResPCT.mat mcrOverall

toc

% load('../realData_Jantzen/processedDataStd.mat');
% postProcess
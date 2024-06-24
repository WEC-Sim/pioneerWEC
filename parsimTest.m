close all
clear all
clc

tic

% Define WEC-Sim source and add to MATLAB path
wecSimSource = fullfile('../WEC-Sim/source');
addpath(genpath(wecSimSource));
clear wecSimSource

%%
load('./realData_Jantzen/processedDataStd.mat');

heights = [processedData(:).Hm0]';
periods = [processedData(:).Tp]';
heights = 1.5;
periods = 7.7;
aboveWaterMasses = [100];
cdSurge = [0.5];
cdHeave = [0.5];
cdPitch = [0.5];



caseCount = 1;
% set it up as for each variable combo, we run all heights and periods:
for iMass = 1:length(aboveWaterMasses)
    for iSurge = 1:length(cdSurge)
        for iHeave = 1:length(cdHeave)
            for iPitch = 1:length(cdPitch)
                for iHP = 1:length(heights)
                    simObj(caseCount) = Simulink.SimulationInput('pioneerSNL');

                    simObj(caseCount) = simObj(caseCount).setVariable("waves.height",heights(iHP)); %, "waves.period", periods(iHP), ...
                        %"aboveWaterMass", aboveWaterMasses(iMass), "cdSurge", cdSurge(iSurge), "cdHeave", cdHeave(iHeave), "cdPitch", cdPitch(iPitch)

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

wecSimInputFile
initializeWecSim
out = parsim(simObj, 'ShowSimulationManager', 'on');
%postProcessWecSim
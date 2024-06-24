close all
clear all
clc

% Define WEC-Sim source and add to MATLAB path
wecSimSource = fullfile('../WEC-Sim/source');
addpath(genpath(wecSimSource));
clear wecSimSource

% %%
% load('./realData_Jantzen/processedDataStd.mat');

waveFiles = {'obsData/spectrumFile202.mat' 'obsData/spectrumFile313.mat' 'obsData/spectrumFile349.mat' 'obsData/spectrumFile419.mat'};
waveDirs = [240.9309   48.4308  107.6652  108.3043];

for i = 1:length(waveFiles)
    waveFiles = string(waveFiles);
end

mcr = struct();
mcr.header = ["waves.spectrumFile", "waves.direction"];
mcr.cases = [waveFiles', waveDirs'];

save mcrCases mcr

wecSimPCT

postProcessPCT
% 
% load('./realData_Jantzen/processedDataStd.mat');
% postProcess
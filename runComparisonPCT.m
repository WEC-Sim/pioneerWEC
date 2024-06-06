close all
clear all
clc

% Define WEC-Sim source and add to MATLAB path
wecSimSource = fullfile('../WEC-Sim/source');
addpath(genpath(wecSimSource));
clear wecSimSource

%%
load('./realData_Jantzen/processedDataStd.mat');

heights = [processedData(:).Hm0]';
periods = [processedData(:).Tp]';

mcr = struct();
mcr.header = ["waves.height", "waves.period"];
mcr.cases = [heights, periods];

save mcrCases mcr

wecSimPCT

postProcessPCT

load('./realData_Jantzen/processedDataStd.mat');
postProcess
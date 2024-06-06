close all
clear all
clc

%%
load('./realData_Jantzen/processedDataStd.mat');

heights = [processedData(:).Hm0]';
periods = [processedData(:).Tp]';

mcr = struct();
mcr.header = ["waves.height", "waves.period"];
mcr.cases = [heights(1:2), periods(1:2)];

save mcrCases mcr

wecSimMCR

postProcess
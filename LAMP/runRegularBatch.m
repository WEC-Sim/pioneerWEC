clear all
close all
clc

% This script is intended to run one wave case and plot

waveType = 'regular'; 

frequencyVec = [0.2 0.25 0.3 0.35 0.4 0.45 0.5];
periodVec = 1./frequencyVec;
heightVec = [0.25 1];

plotFlag = 0; % turns plotting on to compare repeat periods
numRepeats = 8;

batchRes = {}; % set up saving structure
waveCount = 1;

for TCount = 1:length(periodVec)
    for hCount = 1:length(heightVec)
        wavePeriod = periodVec(TCount);
        waveHeight = heightVec(hCount);
        
        wecSim
        
        postProcess % plots and sets up results for saving

        batchRes{waveCount}.wavePeriod = wavePeriod;
        batchRes{waveCount}.waveHeight = waveHeight;
        batchRes{waveCount}.rmsPos = rmsPos;
        batchRes{waveCount}.time = timeVec; 
        batchRes{waveCount}.position = positionVec; 
        batchRes{waveCount}.velocity = velocityVec; 
        batchRes{waveCount}.acceleration = accelerationVec; 

        waveCount = waveCount + 1;
    end
end

save regularBatch.mat batchRes
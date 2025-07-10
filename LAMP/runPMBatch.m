clear all
close all
clc

% This script is intended to run one wave case and plot

waveType = 'PM';

% frequencyVec = defined by period
periodVec = [5 6 7 8];
heightVec = [0.5 1 1.5];

plotFlag = 0; % turns plotting on to compare repeat periods
numRepeats = 6;

batchRes = {}; % set up saving structure
waveCount = 1;

for TCount = 1:length(periodVec)
    for hCount = 1:length(heightVec)
        wavePeriod = periodVec(TCount);
        waveHeight = heightVec(hCount);

        PMWaveCreation(wavePeriod,waveHeight); % create the spectrum data file with 120 s repeat period
        
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

save PMBatch.mat batchRes
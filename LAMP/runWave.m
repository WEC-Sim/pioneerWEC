clear all
close all
clc

% This script is intended to run one wave case and plot

waveType = 'PM'; % 'PM' or 'regular'

waveHeight = 1.5;
wavePeriod = 5;

plotFlag = 1; % turns plotting on to compare repeat periods
numRepeats = 6; % number of repeat 120 s periods

if strcmp(waveType, 'PM')
    PMWaveCreation(wavePeriod,waveHeight); % if using a Pierson Moskowitz spectrum, create the spectrum data file with 120 s repeat period
end

wecSim

postProcess
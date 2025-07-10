clear all
close all
clc

load regularBatch.mat % select PMBatch or regularBatch

dofNames = ["surge","sway","heave","roll","pitch","yaw"];
dofUnits = ["m","m","m","rad","rad","rad"];

waveHeight = 1; % select the height and period for extraction
wavePeriod = 2; %1/0.25

plotFlag = 0;

for ii = 1:length(batchRes)
    if batchRes{ii}.wavePeriod == wavePeriod && batchRes{ii}.waveHeight == waveHeight
        waveNum = ii;
    end
end

figure()
plot(batchRes{waveNum}.time, batchRes{waveNum}.position(:,1))
hold on

load ryanError.mat
plot(timeVec, positionVec(:,1))

legend('mine', 'ryans')

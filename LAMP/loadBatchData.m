clear all
close all
clc

load PMBatch.mat % select PMBatch or regularBatch

dofNames = ["surge","sway","heave","roll","pitch","yaw"];
dofUnits = ["m","m","m","rad","rad","rad"];

waveHeight = 1.5; % select the height and period for extraction
wavePeriod = 5; %1/0.25

plotFlag = 1;

for ii = 1:length(batchRes)
    if batchRes{ii}.wavePeriod == wavePeriod && batchRes{ii}.waveHeight == waveHeight
        waveNum = ii;
    end
end

numRepeats = floor(batchRes{waveNum}.time(end)/120);
if plotFlag == 1
    for ii = 1:6
        repeatNames = [];
        figure()
        for jj = 1:numRepeats
            [~,startInd] = min(abs(120*(jj-1) - batchRes{waveNum}.time));
            [~,endInd] = min(abs(120*jj - batchRes{waveNum}.time));
    
            plot(batchRes{waveNum}.time(startInd:endInd)-120*(jj-1), batchRes{waveNum}.position(startInd:endInd,ii))
            hold on
            xlabel('time (s)')
            ylabel([dofNames(ii) 'disp' dofUnits(ii)])

            repeatNames = [repeatNames, strcat("repeat ", num2str(jj))];

        end
        legend(repeatNames)
        title(['T = ' num2str(batchRes{waveNum}.wavePeriod) 's, H = ' num2str(batchRes{waveNum}.waveHeight) 'm'])
    end
end

% select repeat period that's rms value is closest to average pitch
meanPitchRMS = mean(batchRes{waveNum}.rmsPos.pitch(3:end));
[minDiff, minInd] = min(abs(batchRes{waveNum}.rmsPos.pitch(3:end) - meanPitchRMS));
repeatNumToUse = minInd+2; % add the first 2 back in
fprintf('Repeat #%.0f is the repeat number to use.\n',repeatNumToUse)
fprintf('Repeat #%.0f is %.2f%% from the mean rms.\n',repeatNumToUse,100*minDiff/meanPitchRMS)

% clear all
% close all
% clc
% 
% waveType = 'regular'; % or 'regular'
% 
% load([waveType, 'Batch.mat']) % select PMBatch or regularBatch

for ii = 1:length(batchRes)

    % select repeat period that's rms value is closest to average pitch
    meanPitchRMS = mean(batchRes{ii}.rmsPos.pitch(3:end));
    [minDiff, minInd] = min(abs(batchRes{ii}.rmsPos.pitch(3:end) - meanPitchRMS));
    repeatNumToUse = minInd+2; % add the first 2 back in
    fprintf('Repeat #%.0f is the repeat number to use.\n',repeatNumToUse)
    fprintf('Repeat #%.0f is %.2f%% from the mean rms.\n',repeatNumToUse,100*minDiff/meanPitchRMS)

    % extract "most average" repeat and ramp positions up and down
    [~,startInd] = min(abs((120*(repeatNumToUse-1)-5) - batchRes{ii}.time)); % add 5 second buffer on either end
    [~,endInd] = min(abs((120*(repeatNumToUse)+5) - batchRes{ii}.time));

    posRepeat = batchRes{ii}.position(startInd:endInd,:);
    posRepeatZeroMean = posRepeat - mean(posRepeat); % set mean for each dof to zero
    timeRepeat = batchRes{ii}.time(startInd:endInd);

    time130 = timeRepeat - timeRepeat(1);

    wRamp = tukeywin(length(posRepeatZeroMean),10/120);
    pos130 = wRamp.*posRepeatZeroMean;

    ts130 = timeseries(pos130,time130);

    saveName = ['trajectoryFiles/',waveType, '_T',num2str(batchRes{ii}.wavePeriod),'_H',num2str(batchRes{ii}.waveHeight),'.mat'];
    save(saveName, "ts130")

end

figure()
plot(time130,pos130)
legend()

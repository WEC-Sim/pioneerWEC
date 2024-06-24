clear all
close all
clc

load('dataWaves.mat')
load('NED_IMU.mat')

% runs from Jantzen
snips = [202 419 313 349];

processedData = {};

for ii = 1:length(snips)
    startTimes(ii) = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    endTimes(ii) = NED_IMU.Time(NED_IMU.Info.EndIndex(snips(ii)));
    [~,waveIndex(ii)] = min(abs(dataWaves.preferred_time-startTimes(ii)));

    psd = dataWaves.psd_m2pHz(:,waveIndex(ii));
    psd(isnan(psd)) = 0;

    figure()
    % plot wave characteristics
    subplot(3,1,1)
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),psd)
    %xlabel('Frequency (Hz)')
    ylabel('Power Spectral Density (m2/Hz)')
    
    dirWaves = dataWaves.dirMeanToNorth_deg(:,waveIndex(ii));
    dirWaves(abs(dirWaves)>1e3) = 0;
    dirWaves(isnan(dirWaves)) = 0;
    dirSpread = dataWaves.dirSpread_deg(:,waveIndex(ii));
    dirSpread(abs(dirSpread)>1e3) = 0;
    dirSpread(isnan(dirSpread)) = 0;

    subplot(3,1,2)
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),dirWaves)
    %xlabel('Frequency (Hz)')
    ylabel('Direction to North (deg)')
    
    subplot(3,1,3)
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),dirSpread)
    xlabel('Frequency (Hz)')
    ylabel('Directional Spread (deg)')

    % for each of the waves, calculate the weighted direction and spread
    avgDir(ii) = 360-(sum(dirWaves.*psd)/sum(psd) + 90); % add 90 to be with respect to E
    avgSpread(ii) = sum(dirSpread.*psd)/sum(psd); 

    spectrumData(:,1) = dataWaves.freq_Hz(:,waveIndex(ii));
    spectrumData(:,2) = psd;
    
    save(['spectrumFile' num2str(snips(ii)) '.mat'],'spectrumData')

    % extract and process IMU data
    processedData{ii}.NEDTime = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii))) - NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    [~,startIndVel] = min(abs(100-processedData{ii}.NEDTime));
    [~,startIndPos] = min(abs(200-processedData{ii}.NEDTime));

    % convert to x-y axes consistent with wave direction:
    waveAngleN = 90-avgDir(ii);

    processedData{ii}.NEDTimeVel = processedData{ii}.NEDTime(startIndVel:end);
    processedData{ii}.NEDTimePos = processedData{ii}.NEDTime(startIndPos:end);

    processedData{ii}.NEDAcc = NED_IMU.Acc(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(waveAngleN);
    processedData{ii}.NEDGyrAcc = NED_IMU.Alpha(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(waveAngleN);
    processedData{ii}.NEDGyrVel = NED_IMU.Gyr(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(waveAngleN);
    processedData{ii}.NEDGyrVel = processedData{ii}.NEDGyrVel(startIndVel:end,:);

    processedData{ii}.NEDAccSTD = std(NED_IMU.Acc(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:));
    processedData{ii}.NEDGyrAccSTD = std(NED_IMU.Alpha(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:));
    processedData{ii}.NEDGyrVelSTD = std(processedData{ii}.NEDGyrVel);

    dt = processedData{ii}.NEDTime(2) - processedData{ii}.NEDTime(1);
    % High Pass filter the accelerometer data to get less drift
    d = designfilt('highpassfir', ...       % Response type
        'StopbandFrequency',0.025, ...     % Frequency constraints
        'PassbandFrequency',0.05, ...
        'DesignMethod','kaiserwin', ...  % Design method
        'SampleRate',1/dt);               % Sample rate

    vel = cumtrapz(processedData{ii}.NEDTime,processedData{ii}.NEDAcc(:,:));
    velNew = filter(d,vel);
    pos = cumtrapz(processedData{ii}.NEDTime,velNew);
    posNew = filter(d,pos);

    gyrVel = cumtrapz(processedData{ii}.NEDTime,processedData{ii}.NEDGyrAcc(:,:));
    gyrVelNew = filter(d,gyrVel);
    gyrPos = cumtrapz(processedData{ii}.NEDTime,gyrVelNew);
    gyrPosNew = filter(d,gyrPos);

    processedData{ii}.NEDVel = velNew(startIndVel:end,:);
    processedData{ii}.NEDPos = posNew(startIndPos:end,:);
    processedData{ii}.NEDVelSTD = std(velNew(startIndVel:end,:));
    processedData{ii}.NEDPosSTD = std(posNew(startIndPos:end,:));
    processedData{ii}.NEDGyrPos = gyrPosNew(startIndPos:end,:);
    processedData{ii}.NEDGyrPosSTD = std(gyrPosNew(startIndPos:end,:));

    figure()
    plot(processedData{ii}.NEDTime,vel)
    hold on
    plot(processedData{ii}.NEDTime,velNew)

    figure()
    plot(processedData{ii}.NEDTime,pos)
    hold on
    plot(processedData{ii}.NEDTime,posNew)

    figure()
    plot(processedData{ii}.NEDTime,gyrPos)
    hold on
    plot(processedData{ii}.NEDTime,gyrPosNew)

end

avgDir
avgSpread

% save processedData.mat processedData

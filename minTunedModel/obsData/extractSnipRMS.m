clc, clear all, close all

load('NED_IMU.mat')
load('dataWaves.mat')

% runs from Jantzen
snips = [197 422 141 332];

for ii = 1:length(snips)
    startTimes(ii) = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    endTimes(ii) = NED_IMU.Time(NED_IMU.Info.EndIndex(snips(ii)));
    [~,waveIndex(ii)] = min(abs(dataWaves.preferred_time-mean([startTimes(ii),endTimes(ii)])));
    processedData{ii}.waveDir = dataWaves.dirMeanToNorth_deg(:,waveIndex(ii));
    processedData{ii}.waveDir(processedData{ii}.waveDir>320) = processedData{ii}.waveDir(processedData{ii}.waveDir>320) - 360;
    processedData{ii}.psd = dataWaves.psd_m2pHz(:,waveIndex(ii));
    processedData{ii}.psd(isnan(processedData{ii}.psd)) = 0;
    processedData{ii}.waveDir(abs(processedData{ii}.waveDir)>1e3) = 0;
    processedData{ii}.waveDir(isnan(processedData{ii}.waveDir)) = 0;
    processedData{ii}.meanWaveDir = sum(processedData{ii}.waveDir.*processedData{ii}.psd)/sum(processedData{ii}.psd);
    processedData{ii}.meanWaveDirWS = 360 - (processedData{ii}.meanWaveDir + 90);

    figure()
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),processedData{ii}.waveDir)
    %xlabel('Frequency (Hz)')
    ylabel('Direction to North (deg)')

    % extract and process IMU data
    processedData{ii}.NEDTime = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii))) - NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    [~,startIndVel] = min(abs(100-processedData{ii}.NEDTime));

    processedData{ii}.NEDGyrAcc = NED_IMU.Alpha(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:);
    processedData{ii}.NEDGyrVel = NED_IMU.Gyr(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:);

    angleVec = processedData{ii}.meanWaveDir-90:0.5:processedData{ii}.meanWaveDir+90;
    % Run through all valid angles to find ideal orientation for specific trial
    for qa = 1:length(angleVec)
        velocityRotCheck(qa,:) = rms(processedData{ii}.NEDGyrVel*rotz(angleVec(qa)));
    end
    
    % Find maximum value for the primary axis
    [RMSPeak,angleIndex] = max(velocityRotCheck(:,2)); % find max pitch response
    peakAngle = angleVec(angleIndex);

    % convert to primary and secondary axes:
    processedData{ii}.primaryAxis = peakAngle;
    processedData{ii}.primaryAxisWS = 360 - (peakAngle + 90); % convert to WEC-Sim coordinate axes
    processedData{ii}.NEDGyrVelPS = processedData{ii}.NEDGyrVel*rotz(peakAngle);
    processedData{ii}.rmsRotPS = rms(processedData{ii}.NEDGyrVelPS);

    dt = processedData{ii}.NEDTime(2) - processedData{ii}.NEDTime(1);
    % High Pass filter the accelerometer data to get less drift
    d = designfilt('highpassfir', ...       % Response type
        'StopbandFrequency',0.025, ...     % Frequency constraints
        'PassbandFrequency',0.05, ...
        'DesignMethod','kaiserwin', ...  % Design method
        'SampleRate',1/dt);               % Sample rate
    
    processedData{ii}.NEDAccPS = NED_IMU.Acc(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(peakAngle);
    vel = cumtrapz(processedData{ii}.NEDTime,processedData{ii}.NEDAcc(:,:));
    velNew = filter(d,vel);
    processedData{ii}.NEDVelPS = velNew(startIndVel:end,:);
    processedData{ii}.rmsTransPS = rms(velNew(startIndVel:end,:));

end

% save processedDataPS.mat processedData
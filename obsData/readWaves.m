clear all
close all
clc

load('dataWaves.mat')
load('NED_IMU.mat')

% runs from Jantzen
snips = [197 422 141 332];
nBins = 10; % this is the number of direction bins (recommend odd number)
processedData = {};

fileTime = ncread('./all_comparison/ooiSpectra-mab/WSS_MARK.nc','time'); %WSS_MARK
Hm0 = ncread('./all_comparison/ooiSpectra-mab/WSS_MARK.nc','significant_wave_height');

rho = 1000;
g = 9.81;

for ii = 1:length(snips)
    startTimes(ii) = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    endTimes(ii) = NED_IMU.Time(NED_IMU.Info.EndIndex(snips(ii)));
    [~,waveIndex(ii)] = min(abs(dataWaves.preferred_time-mean([startTimes(ii),endTimes(ii)])));

    [~,fileWaveIndex(ii)] = min(abs(fileTime-mean([startTimes(ii),endTimes(ii)])));

    psd(:,ii) = dataWaves.psd_m2pHz(:,waveIndex(ii));
    psd(isnan(psd(:,ii)),ii) = 0;

    figure()
    % plot wave characteristics
    subplot(3,1,1)
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),psd(:,ii))
    %xlabel('Frequency (Hz)')
    ylabel('Power Spectral Density (m2/Hz)')
    
    dirWaves(:,ii) = dataWaves.dirMeanToNorth_deg(:,waveIndex(ii));
    dirWaves(abs(dirWaves(:,ii))>1e3,ii) = 0;
    dirWaves(isnan(dirWaves(:,ii)),ii) = 0;
    dirSpread(:,ii) = dataWaves.dirSpread_deg(:,waveIndex(ii));
    dirSpread(abs(dirSpread(:,ii))>1e3,ii) = 0;
    dirSpread(isnan(dirSpread(:,ii)),ii) = 0;

    dirWaves(dirWaves(:,ii)>320,ii) = dirWaves(dirWaves(:,ii)>320,ii) - 360;

    subplot(3,1,2)
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),dirWaves(:,ii))
    %xlabel('Frequency (Hz)')
    ylabel('Direction to North (deg)')
    
    subplot(3,1,3)
    plot(dataWaves.freq_Hz(:,waveIndex(ii)),dirSpread(:,ii))
    xlabel('Frequency (Hz)')
    ylabel('Directional Spread (deg)')

    % for each of the waves, calculate the weighted direction and spread
    
    avgDir(ii) = 360-(sum(dirWaves(:,ii).*psd(:,ii))/sum(psd(:,ii)) + 90); % add 90 to be with respect to E
    avgSpread(ii) = sum(dirSpread(:,ii).*psd(:,ii))/sum(psd(:,ii)); 

    spectrumData(:,1) = dataWaves.freq_Hz(:,waveIndex(ii));
    spectrumData(:,2) = psd(:,ii);
    
    % save(['spectrumFile' num2str(snips(ii)) '.mat'],'spectrumData')

    % extract and process IMU data
    processedData{ii}.NEDTime = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii))) - NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    [~,startIndVel] = min(abs(100-processedData{ii}.NEDTime));
    [~,startIndPos] = min(abs(200-processedData{ii}.NEDTime));

    % convert to x-y axes consistent with wave direction:
    waveAngleN = avgDir(ii);

    processedData{ii}.NEDTimeVel = processedData{ii}.NEDTime(startIndVel:end);
    processedData{ii}.NEDTimePos = processedData{ii}.NEDTime(startIndPos:end);
    
    % because north is x and east is y, they need to be flipped to be
    % consistent with WEC-Sim
    NED_IMU.Acc = NED_IMU.Acc(:,[2 1 3]);
    NED_IMU.Alpha = NED_IMU.Alpha(:,[2 1 3]);
    NED_IMU.Gyr = NED_IMU.Gyr(:,[2 1 3]);

    processedData{ii}.NEDAcc = NED_IMU.Acc(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(waveAngleN);
    processedData{ii}.NEDGyrAcc = NED_IMU.Alpha(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(waveAngleN);
    processedData{ii}.NEDGyrVel = NED_IMU.Gyr(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:)*rotz(waveAngleN);
    processedData{ii}.NEDGyrVel = processedData{ii}.NEDGyrVel(startIndVel:end,:);

    processedData{ii}.NEDAccSTD = std(NED_IMU.Acc(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:))*rotz(waveAngleN);
    processedData{ii}.NEDGyrAccSTD = std(NED_IMU.Alpha(NED_IMU.Info.StartIndex(snips(ii)):NED_IMU.Info.EndIndex(snips(ii)),:))*rotz(waveAngleN);
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

    disp([processedData{ii}.NEDVelSTD([1 3]),processedData{ii}.NEDGyrVelSTD(2)])
    % 
    % figure()
    % plot(processedData{ii}.NEDTime,vel)
    % hold on
    % plot(processedData{ii}.NEDTime,velNew)
    % 
    % figure()
    % plot(processedData{ii}.NEDTime,pos)
    % hold on
    % plot(processedData{ii}.NEDTime,posNew)
    % 
    % figure()
    % plot(processedData{ii}.NEDTime,gyrPos)
    % hold on
    % plot(processedData{ii}.NEDTime,gyrPosNew)

end

avgDir
avgSpread

% save processedData.mat processedData
%% make WEC-Sim wave series (frequency independent direction and spread)

for k=1:length(avgSpread)
    dirPts(:,k) =  linspace(-2*avgSpread(k),2*avgSpread(k),nBins) 
    spreadBins(:,k) = spreadFunction(dirPts(:,k),avgSpread(k));
    outDirPts(:,k) = dirPts(:,k) +avgDir(k);  
    checkSum(:,k) = trapz(dirPts(:,k),spreadBins(:,k));
    spreadBins(:,k) = spreadBins(:,k)./checkSum(k); % scales spread bins to 1 (needed for wecSim)
    temp = diff(cumtrapz(dirPts(:,k),spreadBins(:,k)));
    binWeights(:,k) = temp;%./checkSum(k); 
    temp2 = movmean(outDirPts(:,k),2);
    dirBins(:,k) = temp2(2:end);
   
    clear temp temp2
end

for ii = 1:4

    waveNum = ii;
    
    % pre-calculate excitation force (frequency dependent direction and spread)
    clear dirPts spreadBins outDirPts checkSum spreadBins temp binWeights temp2 dirBins fExcRe fExcIm fExcMd
    
    hydroData = readBEMIOH5('../hydrodata_SNL/wamitIRR1L1PCGCubitv2/wec_and_nsif_clean.h5',1,2);
    body(1) = bodyClass('../hydrodata_SNL/wamitIRR1L1PCGCubitv2/wec_and_nsif_clean.h5');
    %hydroForcePre(body,body.hydroData.simulation_parameters.w,body.hydroData.simulation_parameters.direction,30,
    loadHydroData(body,hydroData);
    % example first wave snippet
    [WGRD,DGRD]=meshgrid(body.hydroData.simulation_parameters.w,[body.hydroData.simulation_parameters.direction, 360]);  % wrap 0 to 360 degrees
    for k=1:length(2*pi*dataWaves.freq_Hz(~isnan(dataWaves.dirMeanToNorth_deg(:,waveIndex(waveNum))),waveIndex(waveNum)))
        dirPts(k,:) = linspace(-2*dataWaves.dirSpread_deg(1,k),2*dataWaves.dirSpread_deg(1,k),nBins);
        spreadBins(k,:) = spreadFunction(dirPts(k,:),dataWaves.dirSpread_deg(1,k));
        outDirPts(k,:) = dirPts(k,:) + dataWaves.dirMeanToNorth_deg(k,waveIndex(waveNum));
        checkSum = trapz(dirPts(k,:),spreadBins(k,:));
        spreadBins(k,:) = spreadBins(k,:)./checkSum;                            % this scales so we do not lose energy due to directional bin discretization. 
        temp = diff(cumtrapz(dirPts(k,:),spreadBins(k,:)));
        binWeights(k,:)= temp;
        temp2 = movmean(outDirPts(k,:),2);
        dirBins(k,:) = wrapTo360(temp2(2:end)); 
        dirBins(k,isnan(dirBins(k,:))) = 0;
    end
    % rotate bins to WEC-Sim frame here
    dirBins = 360-(dirBins + 90); % flip direction (CW to CCW) and add 90 to be with respect to E
    
    Wq = repmat(2*pi*dataWaves.freq_Hz(~isnan(dataWaves.dirMeanToNorth_deg(:,waveIndex(waveNum))),waveIndex(waveNum)),[1,nBins-1]);
    % wrap excitation coefficients to 360
    fExcCoeffsRe = body.hydroData.hydro_coeffs.excitation.re;
    fExcCoeffsIm = body.hydroData.hydro_coeffs.excitation.im;
    fExcCoeffsMD = body.hydroData.hydro_coeffs.mean_drift;
    fExcCoeffsRe(:,18,:) = fExcCoeffsRe(:,1,:);
    fExcCoeffsIm(:,18,:) = fExcCoeffsIm(:,1,:);
    fExcCoeffsMD(:,18,:) = fExcCoeffsMD(:,1,:);
    for kk =1:6
        [fExcRe(kk,:,:)]=rho * g * interp2(WGRD,DGRD,squeeze(fExcCoeffsRe(kk,:,:)),Wq.',dirBins.','spline'); % this table is explicitly at bin and frequency
        [fExcIm(kk,:,:)]=rho * g * interp2(WGRD,DGRD,squeeze(fExcCoeffsIm(kk,:,:)),Wq.',dirBins.','spline');
        [fExcMd(kk,:,:)]=rho * g * interp2(WGRD,DGRD,squeeze(fExcCoeffsMD(kk,:,:)),Wq.',dirBins.','spline'); % no longer extrapolating
    end
     
    % calc exc force (as in generalized irrF)
     
    TSim = 1400; % time to simulate, in seconds. 
    dt = 0.1; % simulation time step
    tVec = dt:dt:TSim;
    randPhase = 2 * pi * rand(size(dirBins)); % at each frequency, a random phase for each direction
    df = mean(diff(Wq(:,1)))./(2*pi);
    ASpec = sqrt(binWeights).* repmat(sqrt(2*dataWaves.psd_m2pHz(~isnan(dataWaves.dirMeanToNorth_deg(:,waveIndex(waveNum))),waveIndex(waveNum))*df),[1,nBins-1]);% wave amplitude at each frequency, repmat to match matrix dimensions, multiplied by spread factor (=1 summed over all directions)
    ASpec_MD = binWeights.* repmat((2*dataWaves.psd_m2pHz(~isnan(dataWaves.dirMeanToNorth_deg(:,waveIndex(waveNum))),waveIndex(waveNum))*df),[1,nBins-1]);% wave amplitude at each frequency, repmat to match matrix dimensions, multiplied by spread factor (=1 summed over all directions)
    for k=1:length(tVec) % time stepping, solves at (0,0) position.
        for kk = 1:6; % DOF loop
            ExcMat = ASpec .* (squeeze(fExcRe(kk,:,:)).' .* cos(Wq*tVec(k) + randPhase) - squeeze(fExcIm(kk,:,:)).' .* sin(Wq * tVec(k) + randPhase) + ASpec_MD .* squeeze(real(fExcMd(kk,:,:))).');
            fExc(k,kk) = sum(sum(ExcMat));
            clear ExcMat;
        end
    end
    
    % create timeseries and save
    fExcTS = timeseries(fExc,tVec);
    waveDir = avgDir(waveNum);
    % save(['excitationForceWave',num2str(waveNum),'.mat'],'fExcTS', 'waveDir')
end
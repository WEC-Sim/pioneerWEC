clear all
close all
clc

load("NED_IMU.mat")
load('dataWaves.mat')

% runs from Jantzen
snips = [197 422 141 332];
nBins = 10; % this is the number of direction bins (recommend odd number)
processedData = {};

rho = 1000;
g = 9.81;
dataWaveSnips = {};

for ii = 1:4
    clear dataWaveSnip

    startTimes(ii) = NED_IMU.Time(NED_IMU.Info.StartIndex(snips(ii)));
    endTimes(ii) = NED_IMU.Time(NED_IMU.Info.EndIndex(snips(ii)));
    [~,waveIndex(ii)] = min(abs(dataWaves.preferred_time-mean([startTimes(ii),endTimes(ii)])));
    disp(waveIndex(ii))

    % dataWaves_fns = fieldnames(dataWaves);
    % 
    % for jj = 1:length(dataWaves_fns)
    %     if size(dataWaves.(dataWaves_fns{jj}),2) == 1
    %         dataWaveSnips.(dataWaves_fns{jj})(ii) = dataWaves.(dataWaves_fns{jj})(waveIndex(ii));
    %     else
    %         dataWaveSnips.(dataWaves_fns{jj})(:,ii) = dataWaves.(dataWaves_fns{jj})(:,waveIndex(ii));
    %     end
    % end

    inds = ~isnan(dataWaves.freq_Hz(:,waveIndex(ii))) & dataWaves.dirSpread_deg(:,waveIndex(ii)) > 0;

    dataWaveSnip(:,1) = dataWaves.freq_Hz(inds,waveIndex(ii));
    dataWaveSnip(:,2) = dataWaves.psd_m2pHz(inds,waveIndex(ii));
    dataWaveSnip(:,3) = 360 - (dataWaves.dirMeanToNorth_deg(inds,waveIndex(ii)) + 90); % converted to WS coordinate system
    dataWaveSnip(:,4) = dataWaves.dirSpread_deg(inds,waveIndex(ii));
    endPoint = length(dataWaveSnip);
    for jj = 1:length(dataWaveSnip)
        if abs(dataWaveSnip(jj,3)) > 360 || abs(dataWaveSnip(jj,4)) > 180 || any(isnan(dataWaveSnip(jj,:)))
            endPoint = jj-1;
            break
        end
    end
    dataWaveSnip = dataWaveSnip(1:endPoint,:);
    save(['dirSpectrum_' num2str(snips(ii)) '.mat'],'dataWaveSnip')
    if ii == 1 || ii == 3
        avgDir(ii) = sum(wrapTo180(dataWaveSnip(:,3)).*dataWaveSnip(:,2))/sum(dataWaveSnip(:,2));
    else
        avgDir(ii) = sum(dataWaveSnip(:,3).*dataWaveSnip(:,2))/sum(dataWaveSnip(:,2));
    end
end

avgDir = wrapTo360(avgDir)
% save('dataWaveSnips.mat','dataWaveSnips')

%%

for ii = 1

    waveNum = ii;
    
    % pre-calculate excitation force (frequency dependent direction and spread)
    clear dirPts spreadBins outDirPts checkSum spreadBins temp binWeights temp2 dirBins fExcRe fExcIm fExcMd
    
    hydroData = readBEMIOH5('../hydrodata_SNL/wamitIRR1L1PCGCubitv2/wec_and_nsif_clean.h5',1,2);
    body(1) = bodyClass('../hydrodata_SNL/wamitIRR1L1PCGCubitv2/wec_and_nsif_clean.h5');
    %hydroForcePre(body,body.hydroData.simulation_parameters.w,body.hydroData.simulation_parameters.direction,30,
    loadHydroData(body,hydroData,1);
    % example first wave snippet
    [WGRD,DGRD]=meshgrid(body.hydroData.simulation_parameters.w,[body.hydroData.simulation_parameters.direction, 360]);  % wrap 0 to 360 degrees

    inds = ~isnan(dataWaves.freq_Hz(:,waveIndex(waveNum))) & dataWaves.dirSpread_deg(:,waveIndex(waveNum)) > 0;

    for k=1:length(2*pi*dataWaves.freq_Hz(inds,waveIndex(waveNum)))
        dirPts(k,:) = linspace(-2*dataWaves.dirSpread_deg(k,waveIndex(waveNum)),2*dataWaves.dirSpread_deg(k,waveIndex(waveNum)),nBins);
        spreadBins(k,:) = spreadFunction(dirPts(k,:),dataWaves.dirSpread_deg(k,waveIndex(waveNum)));
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
    dirBins = wrapTo360(dirBins);
    
    Wq = repmat(2*pi*dataWaves.freq_Hz(inds,waveIndex(waveNum)),[1,nBins-1]);
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
    ASpec = sqrt(binWeights).* repmat(sqrt(2*dataWaves.psd_m2pHz(inds,waveIndex(waveNum))*df),[1,nBins-1]);% wave amplitude at each frequency, repmat to match matrix dimensions, multiplied by spread factor (=1 summed over all directions)
    ASpec_MD = binWeights.* repmat((2*dataWaves.psd_m2pHz(inds,waveIndex(waveNum))*df),[1,nBins-1]);% wave amplitude at each frequency, repmat to match matrix dimensions, multiplied by spread factor (=1 summed over all directions)
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
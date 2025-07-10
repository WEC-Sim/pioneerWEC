function PMWaveCreation(wavePeriod,waveHeight)
% Script to create wave elevation import file

    hydroData = readBEMIOH5('hydroData/wec_and_nsif_clean_cb_corrected_340.h5', 1, 2);
    
    omega = hydroData.simulation_parameters.w;
    minFrequency = min(omega);
    maxFrequency = max(omega);
    
    bemCount_interp = 500000;
    omegaSpectrum = (minFrequency:(maxFrequency-minFrequency)/bemCount_interp:maxFrequency)';
    dOmegaSpectrum = mean(diff(omegaSpectrum));
    
    frequency = omegaSpectrum/(2*pi);
    Tp = wavePeriod;
    Hs = waveHeight;
    
    % Pierson-Moskowitz Spectrum from IEC TS 62600-2 ED2 Annex C.2 (2019)
    bPM = (5/4)*(1/Tp)^(4);
    aPM =  bPM*(Hs/2)^2;
    fSpectrum  = (aPM*frequency.^(-5).*exp(-bPM*frequency.^(-4)));            % Wave Spectrum [m^2-s] for 'EqualEnergy'
    waveSpectrum = fSpectrum./(2*pi);                                       % Wave Spectrum [m^2-s/rad]
    
    energySpect = cumtrapz(squeeze(frequency),squeeze(fSpectrum));
    
    f1 = 1/120;
    df = 1/120;
    frequency_120 = min(omega/(2*pi)):df:max(omega/(2*pi));
    
    % Pierson-Moskowitz Spectrum from IEC TS 62600-2 ED2 Annex C.2 (2019)
    bPM = (5/4)*(1/Tp)^(4);
    aPM =  bPM*(Hs/2)^2;
    fSpectrum_120  = (aPM*frequency_120.^(-5).*exp(-bPM*frequency_120.^(-4)));            % Wave Spectrum [m^2-s] for 'EqualEnergy'
    waveSpectrum_120 = fSpectrum_120./(2*pi);                                       % Wave Spectrum [m^2-s/rad]
    
    energySpect_120 = cumtrapz(frequency_120,fSpectrum_120);
    
    fprintf('120 s spectrum contains %.2f%% of energy of full spectrum \n',100*energySpect_120(end)/energySpect(end))
    
    % figure()
    % plot(frequency,fSpectrum)
    % hold on
    % plot(frequency_120,fSpectrum_120,'--')
    % xlabel('freq (hz)')
    % ylabel('spectrum (m2s)')
    % legend('equal energy', '120 s')
    
    spectrumMat = [frequency_120',fSpectrum_120'];
    save 'spectrumData.mat' 'spectrumMat'

end
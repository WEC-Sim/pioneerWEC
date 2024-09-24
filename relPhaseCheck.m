function [freq,Cxy,Pxy,angP] = relPhaseCheck(X,Y,nWin,nOver,Fs,thresh,makeFigs)

% inputs:
% X: time domain position data for DOF 1
% Y: time domain position data for DOF 2
% nWin: window length for freq domain analysis (samples)
% nOver: window overlap (samples)
% Fs: sampling frequency
% thresh: decimal of max amplitude coherence below which will be sent to
%      zero for phase coherence analysis
% makeFigs: boolean query, 1 to make figures

% outputs: 
% freq: frequencies analyzed, in Hz
% Cxy: Magnitude-squared coherence (length = length(freq))
% Pxy: cross spectrum 
% angP: phase lag angle (y against x) at frequencies above threshold (rad)

%% magnitude squared coherence
[Cxy,freq]=mscohere(X,Y,hamming(nWin),nOver,[],Fs)

if makeFigs ==1;
    figure; clf;
    plot(freq,Cxy)
    xlabel('Frequency (Hz)')
    ylabel('Mag Sq Coherence')
    grid on;
end

%% cross spectra
[Pxy,~]= cpsd(X,Y,hamming(nWin),nOver,[],Fs);

% parse by threshold
PxyParsed = Pxy;
PxyParsed(Cxy < thresh) = 0;

% calculate phase lag angle 
angP = angle(PxyParsed);

if makeFigs ==1;
    figure; clf;
    plot(freq,Pxy,'b')
    hold on; grid on
    plot(freq,PxyParsed)
    xlabel('Frequency (Hz)')
    ylabel('Cross Spectra')
    legend('Full','Parsed')

    figure; clf;
    plot(freq,angP,'b')
    hold on; grid on
    xlabel('Frequency (Hz)')
    ylabel('Phase Lag (rad)')
    legend('Full','Parsed')
end

end
clear
close all
clc

waveFiles = string({'obsData/spectrumFile197.mat' 'obsData/spectrumFile422.mat' 'obsData/spectrumFile141.mat' 'obsData/spectrumFile332.mat'});
waveDirs = [252.0421   56.5412  285.4639   97.5443];
excFiles = ["obsData/excitationForceWave1.mat", "obsData/excitationForceWave2.mat", "obsData/excitationForceWave3.mat", "obsData/excitationForceWave4.mat"];

for ii = 1:4
	fileVec(ii) = string(waveFiles(ii));
	dirVec(ii) = waveDirs(ii);
    excFileVec(ii) = string(excFiles(ii));
end

mcr = struct();
mcr.header = ["LoadFile"];
mcr.cases = [excFiles'];

%%
save mcrCases mcr

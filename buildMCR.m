clear
close all
clc

waveFiles = string({'obsData/spectrumFile202.mat' 'obsData/spectrumFile313.mat' 'obsData/spectrumFile349.mat' 'obsData/spectrumFile419.mat'});
waveDirs = [240.9309 48.4308 107.6652 108.3043];

for ii = 1:4
	fileVec(ii) = string(waveFiles(ii));
	dirVec(ii) = waveDirs(ii);
end

mcr = struct();
mcr.header = ["waves.spectrumFile", "waves.direction"];
mcr.cases = {fileVec', dirVec'};

%%
save mcrCases mcr

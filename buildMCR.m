clear
close all
clc

waveFiles = ["obsData/dirSpectrum_197.mat" "obsData/dirSpectrum_422.mat" "obsData/dirSpectrum_141.mat" "obsData/dirSpectrum_332.mat"];
waveDirs = wrapTo360([-108.3115   52.1207  -74.4436   96.5309]);

L0 = 15+19.8;
surgeDisp = sqrt(L0^2 - 20.5^2);

for ii = 1:4
	fileVec(ii) = waveFiles(ii);
	dirVec(ii) = waveDirs(ii);
    xLoc(ii) = surgeDisp*cosd(waveDirs(ii));
    yLoc(ii) = surgeDisp*sind(waveDirs(ii));
end

mcr = struct();
mcr.header = ["waves.spectrumFile","waveDir","xLoc","yLoc"];
mcr.cases = [[fileVec'],[dirVec'],[xLoc'],[yLoc']];

%%
save mcrCases mcr

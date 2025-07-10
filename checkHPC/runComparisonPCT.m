function runComparisonPCT(parCount,numPar)

tic 

% Define WEC-Sim source and add to MATLAB path
wecSimSource = fullfile('../WEC-SimPNR');
addpath(genpath(wecSimSource));
clear wecSimSource

%%
fileID = fopen('mcrCases.txt','r');
waveNum = str2num(fgets(fileID));
surgeVec = str2num(fgets(fileID));
heaveVec = str2num(fgets(fileID));
pitchVec = str2num(fgets(fileID));
yawVec = str2num(fgets(fileID));
fclose(fileID);

waveFiles = ["obsData/dirSpectrum_197.mat", "obsData/dirSpectrum_422.mat", "obsData/dirSpectrum_141.mat", "obsData/dirSpectrum_332.mat"];
waveDirs = [252.0421   56.5412  285.4639   97.5443];

for ii = 1:length(waveNum)
	fileVec(ii) = string(waveFiles(waveNum(ii)));
	dirVec(ii) = waveDirs(waveNum(ii));
end


breakFlag = 0;
if (length(waveNum) + numPar) == numPar*parCount
	breakFlag = 1;
elseif length(waveNum) < numPar*parCount
  spectrumFiles = fileVec((1+numPar*(parCount-1)):end)';
	waveDirs = dirVec((1+numPar*(parCount-1)):end)';
	cdSurges = surgeVec((1+numPar*(parCount-1)):end)';
	cdHeaves = heaveVec((1+numPar*(parCount-1)):end)';
	cdPitches = pitchVec((1+numPar*(parCount-1)):end)';
  cdYaws = yawVec((1+numPar*(parCount-1)):end)';
else
  spectrumFiles = fileVec((1+numPar*(parCount-1)):numPar*parCount)';
	waveDirs = dirVec((1+numPar*(parCount-1)):numPar*parCount)';
	cdSurges = surgeVec((1+numPar*(parCount-1)):numPar*parCount)';
	cdHeaves = heaveVec((1+numPar*(parCount-1)):numPar*parCount)';
	cdPitches = pitchVec((1+numPar*(parCount-1)):numPar*parCount)';
  cdYaws = yawVec((1+numPar*(parCount-1)):numPar*parCount)';
end


for ii = 1:length(waveDirs)
  spectrumFile = spectrumFiles(ii);
	waveDir = waveDirs(ii);
	cdSurge = cdSurges(ii);
	cdHeave = cdHeaves(ii);
	cdPitch = cdPitches(ii);
  cdYaw = cdYaws(ii);
	caseFileVec(ii) = "caseFile"+num2str(ii)+".mat";
	save(['caseFile',num2str(ii),'.mat'],'spectrumFile','waveDir','cdSurge','cdHeave','cdPitch','cdYaw')
end

mcr = struct();
mcr.header = ["LoadFile"];
mcr.cases = [caseFileVec'];

% split all the mcr cases up so that they don't all try to run in 1
% parallel loop - 50 cases at once seems reasonable
    
if breakFlag ~=1 
	save mcrCases mcr

	wecSimPCT
 
  close_system('pioneerSNL',0)
    
	postProcessPCT

	save(['mcrResPCT' num2str(parCount) '.mat'], 'mcrNew')
end

toc

end
function runComparisonPCT(parCount,numPar)

tic

% Define WEC-Sim source and add to MATLAB path
wecSimSource = fullfile('../WEC-Sim/source');
addpath(genpath(wecSimSource));
clear wecSimSource

%%
fileID = fopen('mcrCases.txt','r');
waveNum = str2num(fgets(fileID));
massVec = str2num(fgets(fileID));
surgeVec = str2num(fgets(fileID));
heaveVec = str2num(fgets(fileID));
pitchVec = str2num(fgets(fileID));
fclose(fileID);

waveFiles = string({'../../obsData/spectrumFile197.mat' '../../obsData/spectrumFile422.mat' '../../obsData/spectrumFile141.mat' '../../obsData/spectrumFile332.mat'});
excFiles = ["../../obsData/excitationForceWave1.mat", "../../obsData/excitationForceWave2.mat", "../../obsData/excitationForceWave3.mat", "../../obsData/excitationForceWave4.mat"];
waveDirs = [252.0421   56.5412  285.4639   97.5443];

for ii = 1:length(waveNum)
	fileVec(ii) = string(waveFiles(waveNum(ii)));
	excFileVec(ii) = excFiles(waveNum(ii));
	dirVec(ii) = waveDirs(waveNum(ii));
end



breakFlag = 0;
if (length(waveNum) + numPar) == numPar*parCount
	breakFlag = 1;
elseif length(waveNum) < numPar*parCount
	excFiles = excFileVec((1+numPar*(parCount-1)):end)';
	waveDirs = dirVec((1+numPar*(parCount-1)):end)';
	aboveWaterMasses = massVec((1+numPar*(parCount-1)):end)';
	cdSurges = surgeVec((1+numPar*(parCount-1)):end)';
	cdHeaves = heaveVec((1+numPar*(parCount-1)):end)';
	cdPitches = pitchVec((1+numPar*(parCount-1)):end)';
else
	excFiles = excFileVec((1+numPar*(parCount-1)):numPar*parCount)';
	waveDirs = dirVec((1+numPar*(parCount-1)):numPar*parCount)';
	aboveWaterMasses = massVec((1+numPar*(parCount-1)):numPar*parCount)';
	cdSurges = surgeVec((1+numPar*(parCount-1)):numPar*parCount)';
	cdHeaves = heaveVec((1+numPar*(parCount-1)):numPar*parCount)';
	cdPitches = pitchVec((1+numPar*(parCount-1)):numPar*parCount)';
end


for ii = 1:length(waveDirs)
	load(excFiles(ii)); % load in data from excitation file
	waveDir = waveDirs(ii);
	aboveWaterMass = aboveWaterMasses(ii);
	body(1).quadDrag.cd(1) = cdSurges(ii);
    body(1).quadDrag.cd(2) = cdSurges(ii);
	body(1).quadDrag.cd(3) = cdHeaves(ii);
	body(1).quadDrag.cd(4) = cdPitches(ii);
    body(1).quadDrag.cd(5) = cdPitches(ii);
	caseFileVec(ii) = "caseFile"+num2str(ii)+".mat";
	save(['caseFile',num2str(ii),'.mat'],'fExcTS', 'waveDir','aboveWaterMass','cdSurge','cdHeave','cdPitch')
end

mcr = struct();
mcr.header = ["LoadFile"];
mcr.cases = [caseFileVec'];

% split all the mcr cases up so that they don't all try to run in 1
% parallel loop - 50 cases at once seems reasonable
    
if breakFlag ~=1 
	save mcrCases mcr

	wecSimPCT
    
	postProcessPCT

	save(['mcrResPCT' num2str(parCount) '.mat'], 'mcrNew')
end

toc

end
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

waveFiles = string({'obsData/spectrumFile202.mat' 'obsData/spectrumFile313.mat' 'obsData/spectrumFile349.mat' 'obsData/spectrumFile419.mat'});
waveDirs = [240.9309 48.4308 107.6652 108.3043];

for ii = 1:length(waveNum)
	fileVec(ii) = string(waveFiles(waveNum(ii)));
	dirVec(ii) = waveDirs(waveNum(ii));
end

breakFlag = 0;
if (length(waveNum) + numPar) == numPar*parCount
	breakFlag = 1;
elseif length(waveNum) < numPar*parCount
	mcr = struct();
	mcr.header = ["waves.spectrumFile", "waves.direction", "aboveWaterMass", "body(1).quadDrag.cd(1)", "body(1).quadDrag.cd(3)", "body(1).quadDrag.cd(5)"];
	mcr.cases = {fileVec((1+numPar*(parCount-1)):end)', dirVec((1+numPar*(parCount-1)):end)', massVec((1+numPar*(parCount-1)):end)', surgeVec((1+numPar*(parCount-1)):end)', heaveVec((1+numPar*(parCount-1)):end)', pitchVec((1+numPar*(parCount-1)):end)'};

else
	mcr = struct();
	mcr.header = ["waves.spectrumFile", "waves.direction", "aboveWaterMass", "body(1).quadDrag.cd(1)", "body(1).quadDrag.cd(3)", "body(1).quadDrag.cd(5)"];
	mcr.cases = {fileVec((1+numPar*(parCount-1)):numPar*parCount)', dirVec((1+numPar*(parCount-1)):numPar*parCount)', massVec((1+numPar*(parCount-1)):numPar*parCount)', surgeVec((1+numPar*(parCount-1)):numPar*parCount)', heaveVec((1+numPar*(parCount-1)):numPar*parCount)', pitchVec((1+numPar*(parCount-1)):numPar*parCount)'};

end

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
close all
clear all
clc

% files = dir('*.mat');
% files = dir('../hpc_HeaveAM/*.mat');
files = dir('../hpc_negMorison/*.mat');

mcrOverall = {};
mcrHeaveAM = {};
mcrMorison = {};

load(strcat('../hpc_negMorison/',files(1).name))
mcrOverall = mcrNew;

waveDirs = [240.9309   48.4308  107.6652  108.3043];
waveNums = [1 2 3 4];

ignoreFields = ["header","cases"];
horizCatFields = ["waveDirection","aboveWaterMass", "cdSurge", "cdHeave", "cdPitch"];
vertCatFields = ["posStd", "velStd", "accStd", "forceStd","posStdXY", "velStdXY", "accStdXY", "forceStdXY"];

fns = fieldnames(mcrOverall);

% FIX - loop through files names and sort them
for ii = 1:length(files)
    fileInd(ii) = sscanf(files(ii).name,'mcrResPCT%f.mat');
end

[~,fileInds] = sort(fileInd);

for ii = 2:length(files)
    load(files(fileInds(ii)).name)

    for jj = 1:size(mcrOverall.cases,2)
        mcrOverall.cases{jj} = [mcrOverall.cases{jj};mcrNew.cases{jj}];
    end

    for jj = 1:length(fns)
        if any(strcmp(fns{jj},horizCatFields))
            mcrOverall.(fns{jj}) = [mcrOverall.(fns{jj}),mcrNew.(fns{jj})];
        elseif any(strcmp(fns{jj},vertCatFields))
            mcrOverall.(fns{jj}) = [mcrOverall.(fns{jj});mcrNew.(fns{jj})];
        end
    end

end

mcrOverall = rmfield(mcrOverall,{'waveHeight','wavePeriod'}); % delete wave height and period fields
% add wave numbers
mcrOverall.waveNum = [];
for ii = 1:length(mcrOverall.aboveWaterMass)/4
    mcrOverall.waveNum = [mcrOverall.waveNum, waveNums];
end

fns = fieldnames(mcrOverall);
for ii = 1:length(fns)
    if any(strcmp(fns{ii},[horizCatFields,"waveNum"]))
        mcrOverall.(fns{ii}) = mcrOverall.(fns{ii})';
    end
end

% compare the standard deviations for each run to the standard deviations
% from the observed data
load('../obsData/processedData')
for ii = 1:length(mcrOverall.aboveWaterMass)
    mcrOverall.velStdDiff(ii,1:3) = processedData{mcrOverall.waveNum(ii)}.NEDVelSTD - mcrOverall.velStdXY(ii,1:3);
    mcrOverall.velStdDiff(ii,4:6) = processedData{mcrOverall.waveNum(ii)}.NEDGyrVelSTD - mcrOverall.velStdXY(ii,4:6);
    mcrOverall.velStdPercentDiff(ii,1:3) = 100*(processedData{mcrOverall.waveNum(ii)}.NEDVelSTD - mcrOverall.velStdXY(ii,1:3))./processedData{mcrOverall.waveNum(ii)}.NEDVelSTD;
    mcrOverall.velStdPercentDiff(ii,4:6) = 100*(processedData{mcrOverall.waveNum(ii)}.NEDGyrVelSTD - mcrOverall.velStdXY(ii,4:6))./processedData{mcrOverall.waveNum(ii)}.NEDGyrVelSTD;
    mcrOverall.velObjFun(ii) = mean(abs([mcrOverall.velStdPercentDiff(ii,1), mcrOverall.velStdPercentDiff(ii,3), mcrOverall.velStdPercentDiff(ii,3)]));
end

mcrOverall.velObjFun = mcrOverall.velObjFun';

mcrWave = {};
fns = fieldnames(mcrOverall);
% sort by wave
for ii = 1:4
    perWaveCount = 1;
    for jj = 1:length(mcrOverall.aboveWaterMass)
        if mcrOverall.waveNum(jj) == ii
            for kk = 1:length(fns)
                if ~any(strcmp(fns{kk},ignoreFields))
                    mcrWave{ii}.(fns{kk})(perWaveCount,:) = mcrOverall.(fns{kk})(jj,:);
                end
            end
            perWaveCount = perWaveCount+1;
        end
    end
end

% for waves, calculate the mean absolute percent error
for ii = 1:length(mcrWave{1}.aboveWaterMass)
    errorVals(ii) = mean([mcrWave{1}.velObjFun(ii), mcrWave{2}.velObjFun(ii), mcrWave{3}.velObjFun(ii), mcrWave{4}.velObjFun(ii)]);
end



% for all combinations of variables and dofs, create plots of the
% pitch response difference

tuneVars = ["aboveWaterMass","cdSurge","cdHeave","cdPitch"];
DOFs = ["Surge", "Heave", "Pitch"];
DOFNums = [1 3 5];

% for directions, calculate the mean absolute percent error
for ii = 1:length(mcrWave{1}.aboveWaterMass)
    for jj = 1:length(DOFs)
        errorValDir(ii,jj) = mean([abs(mcrWave{1}.velStdPercentDiff(ii,DOFNums(jj))), abs(mcrWave{2}.velStdPercentDiff(ii,DOFNums(jj))), abs(mcrWave{3}.velStdPercentDiff(ii,DOFNums(jj))), abs(mcrWave{4}.velStdPercentDiff(ii,DOFNums(jj)))]);
    end
end

errorValDirMorison = errorValDir;
save('../errorDirMorison.mat', 'errorValDirMorison')

%% Plot each dof error
cdList = ["cdSurge","cdHeave","cdPitch"];
figure()
%figure('Position', [10 10 400 600])
for ii = 1:length(DOFs)
    %subplot(3,1,ii)
    scatter(ii,errorValDir(:,ii))
    hold on
end

xlabel('')
ylabel(strcat('Error (%) - ',DOFs(ii)))

ax = gca;
ax.XTick = [1, 2, 3];
ax.XTickLabels = {'Surge','Heave','Pitch'};
close all
clear all
clc

files = dir('*.mat');

mcrOverall = {};

load(files(1).name)
mcrOverall = mcrNew;
waveDirs = [240.9309   48.4308  107.6652  108.3043];
waveNums = [1 2 3 4];
weights = [.48 .22 .21 .09];

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
load('../../obsData/processedData')
for ii = 1:length(mcrOverall.aboveWaterMass)
    mcrOverall.velStdDiff(ii,1:3) = processedData{mcrOverall.waveNum(ii)}.NEDVelSTD - mcrOverall.velStdXY(ii,1:3);
    mcrOverall.velStdDiff(ii,4:6) = (processedData{mcrOverall.waveNum(ii)}.NEDGyrVelSTD - mcrOverall.velStdXY(ii,4:6))*180/pi;
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
        errorValDir(ii,jj) = mean([mcrWave{1}.velStdPercentDiff(ii,DOFNums(jj)), mcrWave{2}.velStdPercentDiff(ii,DOFNums(jj)), mcrWave{3}.velStdPercentDiff(ii,DOFNums(jj)), mcrWave{4}.velStdPercentDiff(ii,DOFNums(jj))]);
        errorValDirAbs(ii,jj) = mean([abs(mcrWave{1}.velStdPercentDiff(ii,DOFNums(jj))), abs(mcrWave{2}.velStdPercentDiff(ii,DOFNums(jj))), abs(mcrWave{3}.velStdPercentDiff(ii,DOFNums(jj))), abs(mcrWave{4}.velStdPercentDiff(ii,DOFNums(jj)))]);
        errorValSum(ii,jj) = weights(1)*abs(mcrWave{1}.velStdPercentDiff(ii,DOFNums(jj))) + weights(2)*abs(mcrWave{2}.velStdPercentDiff(ii,DOFNums(jj))) + weights(3)*abs(mcrWave{3}.velStdPercentDiff(ii,DOFNums(jj))) + weights(4)*abs(mcrWave{4}.velStdPercentDiff(ii,DOFNums(jj)));    
        for kk = 1:4
            errorValWave(ii,jj,kk) = mcrWave{kk}.velStdDiff(ii,DOFNums(jj));    
            errorValWavePct(ii,jj,kk) = mcrWave{kk}.velStdPercentDiff(ii,DOFNums(jj));    
        end
    end
end

waveNum = 1;

for ii = 1:length(mcrWave{1}.aboveWaterMass)
    overallError(ii) = mean([mcrWave{1}.velObjFun(ii),mcrWave{2}.velObjFun(ii),mcrWave{3}.velObjFun(ii),mcrWave{4}.velObjFun(ii)]);
end

%% Plot each dof with respect to the cd in that dof
cdList = ["cdSurge","cdHeave","cdPitch"];
figure('Position', [10 10 400 600])
for ii = 1:length(DOFs)
    subplot(3,1,ii)
    scatter(eval(strcat('mcrWave{1}.',cdList(ii))),errorValDir(:,ii),'ok')
    xlabel(cdList(ii))
    ylabel(strcat('Error (%) - ',DOFs(ii)))
end

figure('Position', [10 10 400 600])
for ii = 1:length(DOFs)
    subplot(3,1,ii)
    scatter(eval(strcat('mcrWave{1}.',cdList(ii))),errorValDirAbs(:,ii),'ok')
    xlabel(cdList(ii))
    ylabel(strcat('Absolute Error (%) - ',DOFs(ii)))
end

%% Plot all dofs in a subplot for each sea state

cdList = ["cdSurge","cdHeave","cdPitch"];
cdLabels = ["C_{D,surge}","C_{D,heave}","C_{D,pitch}"];
unitsStr = ["m","m","rad"];
for ii = 1:4
    figure('Position', [10 10 400 600])
    for jj = 1:length(DOFs)
        subplot(3,1,jj)
        scatter(eval(strcat('mcrWave{',num2str(ii),'}.',cdList(jj))),errorValWave(:,jj,ii),'ok')
        xlabel(cdLabels(jj))
        ylabel(strcat('Error (', unitsStr(jj),')'))
        yyaxis right
        ax = gca;
        ax.YColor = 'k';
        if jj <= 2
            ylim(100*[min(errorValWave(:,jj,ii)/processedData{ii}.NEDVelSTD(DOFNums(jj))), max(errorValWave(:,jj,ii)/processedData{ii}.NEDVelSTD(DOFNums(jj)))])
        else
            ylim(100*[min(errorValWave(:,jj,ii)/processedData{ii}.NEDGyrVelSTD(DOFNums(jj)-3)), max(errorValWave(:,jj,ii)/processedData{ii}.NEDGyrVelSTD(DOFNums(jj)-3))])
        end
        ylabel(strcat('% Error'))
        title(DOFs(jj))
        xlim([1.5,8.5])
    end
    sgtitle(strcat('Sea State: ', num2str(ii))) 

    % set(gcf, 'PaperPosition', [0 0 6 10])
    % set(gcf, 'PaperSize', [6 10])
    % print(gcf, strcat('../paperFigs/seaState',num2str(ii),'.pdf'), '-dpdf', '-fillpage','-r1000','-image')
end

%% Plot all dofs in a subplot for each sea state - All 4 sea states on 1 plot!

cdList = ["cdSurge","cdHeave","cdPitch"];
cdLabels = ["C_{D,surge}","C_{D,heave}","C_{D,pitch}"];
unitsStr = ["m","m",char(176)];

% find minimum percentages for each dof
minPercent = inf*ones(1,3);
maxPercent = -inf*ones(1,3);

figure('Position', [10 10 1000 400])
for jj = 1:length(DOFs)
    subplot(1,3,jj)
    for ii = 1:4
        scatter(eval(strcat('mcrWave{',num2str(ii),'}.',cdList(jj))),errorValWave(:,jj,ii),'o')
        hold on
    end
    xlabel(cdLabels(jj))
    ylabel(strcat('Error (', unitsStr(jj),')'))
    yAxisLims = ylim();
    yyaxis right
    ax = gca;
    ax.YColor = 'k';
    if jj <= 2
        ylim(100*[yAxisLims(1)/processedData{ii}.NEDVelSTD(DOFNums(jj)), yAxisLims(2)/processedData{ii}.NEDVelSTD(DOFNums(jj))])
    else
        ylim(100*[yAxisLims(1)/(processedData{ii}.NEDGyrVelSTD(DOFNums(jj)-3)*180/pi), yAxisLims(2)/(processedData{ii}.NEDGyrVelSTD(DOFNums(jj)-3)*180/pi)])
    end
    ylabel(strcat('% Error'))
    title(DOFs(jj))
    xlim([1.5,8.5])
end

legend(["Sea State 1","Sea State 2","Sea State 3","Sea State 4"],Location="southeast")

% ps = get(gcf, 'Position');
% ratio =  ps(4) / ps(3);
% paperWidth = 12;
% paperHeight = paperWidth*ratio;
% 
% set(gcf, 'papersize', [paperWidth paperHeight]);
% set(gcf, 'PaperPosition', [0    0   paperWidth paperHeight]);
% % set(gcf, 'PaperPosition', [0 0 10 4])
% % set(gcf, 'PaperSize', [10 4])
% print(gcf, strcat('../paperFigs/allSeaStatesResheaveAM.pdf'), '-dpdf', '-fillpage','-r1000','-image')

%% Plot summed error

cdList = ["cdSurge","cdHeave","cdPitch"];
cdLabels = ["C_{D,surge}","C_{D,heave}","C_{D,pitch}"];
unitsStr = ["m","m","rad"];
figure('Position', [10 10 800 600])
for ii = 1:length(DOFs)
    subplot(2,2,ii)
    scatter(eval(strcat('mcrWave{1}.',cdList(ii))),errorValSum(:,ii),'ok')
    xlabel(cdLabels(jj))
    ylabel(strcat('Weighted Error (%)'))
    title(DOFs(ii))
    xlim([1.5,8.5])
end

surgeInd = find(mcrWave{1}.cdSurge == 8);
heaveInd = find(mcrWave{1}.cdHeave == 2);
pitchInd = find(mcrWave{1}.cdPitch == 6);
optInds = intersect(intersect(surgeInd, heaveInd),pitchInd);

subplot(2,2,4)
scatter(mcrWave{1}.aboveWaterMass(optInds),errorValSum(optInds,3),'ok','filled')
xlabel('Above Water Inertia (kgm^2)')
ylabel(strcat('Weighted Error (%)'))
title('Pitch')
xlim([-22,42])

set(gcf, 'PaperPosition', [0 0 8 6])
set(gcf, 'PaperSize', [8 6])
print(gcf, strcat('../paperFigs/weightedErrorheaveAM.pdf'), '-dpdf', '-fillpage','-r1000','-image')


%% Plot combinations for all waves and each degree of freedom
for ii = 1:length(DOFs)
    for jj = 1:length(tuneVars)
        figure()
        scatter(eval(strcat('mcrWave{1}.',tuneVars(jj))),errorValDir(:,ii))
        xlabel(tuneVars(jj))
        ylabel(strcat('Mean Absolute Velocity Error (%) - ',DOFs(ii)))
    end
end


%% Plot best combinations for all waves
for ii = 1:length(tuneVars)
    figure()
    scatter(eval(strcat('mcrWave{',num2str(waveNum),'}.',tuneVars(ii))),overallError)
    xlabel(tuneVars(ii))
    ylabel('Mean Absolute Velocity Error (%)')
    colorbar
    colormap winter
end

%% Plot all combinations for mean absolute velocity error

for ii = 1:length(tuneVars)
    figure('Position', [10 10 900 600])
    for jj = 1:length(tuneVars)

        ax1 = subplot(2,2,jj);
        scatter3(eval(strcat('mcrWave{',num2str(waveNum),'}.',tuneVars(ii))),eval(strcat('mcrWave{',num2str(waveNum),'}.',tuneVars(jj))), ...
            overallError,10,overallError)
        colormap(gca,"winter")
        xlabel(tuneVars(ii))
        ylabel(tuneVars(jj))
        if ii == 1 || jj == 3
            zlabel('Mean Absolute Velocity Error (%)')
        end

    end
end

%% Plot all combinations for a specific wave

% start by creating surface of 2 variables for pitch response
figure()
scatter3(mcrWave{1}.aboveWaterMass,mcrWave{1}.cdSurge,mcrWave{1}.velStdDiff(:,5),8,abs(mcrWave{1}.velStdDiff(:,5)))
xlabel('Above Water Mass (kg)')
ylabel('Cd Surge')
colormap(gca,"winter")

for ii = 1:length(DOFs)
    for jj = 1:length(tuneVars)
        figure()
        scatter(eval(strcat('mcrWave{1}.',tuneVars(jj))),mcrWave{waveNum}.velStdPercentDiff(:,DOFNums(ii)))
        xlabel(tuneVars(jj))
        ylabel(strcat('Velocity Error (%) - ',DOFs(ii)))
        % add in text to specific the value comparison
    end
end

% for ii = 1:length(DOFs)
%     for jj = 1:length(tuneVars)
%         figure('Position', [10 10 900 600])
%         numPlots = 1;
%         for kk = 1:length(tuneVars)
% 
%             ax1 = subplot(2,2,numPlots);
%             scatter3(eval(strcat('mcrWave{',num2str(waveNum),'}.',tuneVars(jj))),eval(strcat('mcrWave{',num2str(waveNum),'}.',tuneVars(kk))), ...
%                 mcrWave{waveNum}.velStdPercentDiff(:,DOFNums(ii)),10,mcrWave{waveNum}.velStdPercentDiff(:,DOFNums(ii)))
%             colormap(gca,"winter")
%             xlabel(tuneVars(jj))
%             ylabel(tuneVars(kk))
%             if kk == 1 || kk == 3
%                 zlabel(strcat(DOFs(ii),' STD % Diff (Observed-WEC-Sim)'))
%             end
% 
%             numPlots = numPlots+1;
%         end
%     end
% end


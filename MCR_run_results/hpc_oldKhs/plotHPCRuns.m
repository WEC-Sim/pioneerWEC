close all
clear all
clc

files = dir('*.mat');

mcrOverall = {};

load(files(1).name)
mcrOverall = mcrNew;
% waveDirs = [252.0421   56.5412  285.4639   97.5443];
waveNums = [1 2 3 4];
weights = [.48 .22 .21 .09];

ignoreFields = ["header","cases"];
horizCatFields = ["waveDirection","aboveWaterMass", "cdSurge", "cdHeave", "cdPitch","primaryAxis"];
vertCatFields = ["posRMS","velRMS","accRMS","forceRMS","posRMSPS", "velRMSPS", "accRMSPS", "forceRMSPS","posRMSXY", "velRMSXY", "accRMSXY", "forceRMSXY"];

fns = fieldnames(mcrOverall);

% FIX - loop through files names and sort them
for ii = 1:length(files)
    fileInd(ii) = sscanf(files(ii).name,'mcrResPCT%f.mat');
end
[~,fileInds] = sort(fileInd);

for ii = 2:length(files)
    load(files(fileInds(ii)).name)
    disp(ii)

    %for jj = 1:size(mcrOverall.cases,1)
    %   mcrOverall.cases{jj} = mcrNew.cases{jj};
    %end

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

% compare the rms for each run to the standard deviations
% from the observed data
load('../../obsData/processedDataPS')
for ii = 1:length(processedData)
    processedData{ii}.rmsTransPS = abs(processedData{ii}.rmsTransPS*rotz(90));
    processedData{ii}.rmsRotPS = abs(processedData{ii}.rmsRotPS*rotz(90));
end
for ii = 1:length(mcrOverall.aboveWaterMass)
    mcrOverall.velRMSDiff(ii,1:3) = processedData{mcrOverall.waveNum(ii)}.rmsTransPS - mcrOverall.velRMSPS(ii,1:3);
    mcrOverall.velRMSDiff(ii,4:6) = (processedData{mcrOverall.waveNum(ii)}.rmsRotPS - mcrOverall.velRMSPS(ii,4:6))*180/pi;
    mcrOverall.velRMSPercentDiff(ii,1:3) = 100*(processedData{mcrOverall.waveNum(ii)}.rmsTransPS - mcrOverall.velRMSPS(ii,1:3))./processedData{mcrOverall.waveNum(ii)}.rmsTransPS;
    mcrOverall.velRMSPercentDiff(ii,4:6) = 100*(processedData{mcrOverall.waveNum(ii)}.rmsRotPS - mcrOverall.velRMSPS(ii,4:6))./processedData{mcrOverall.waveNum(ii)}.rmsRotPS;
    mcrOverall.velObjFun(ii) = mean(abs([mcrOverall.velRMSPercentDiff(ii,1), mcrOverall.velRMSPercentDiff(ii,3), mcrOverall.velRMSPercentDiff(ii,5)]));
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
DOFs = ["Preferred Axis Translation", "Heave", "Preferred Axis Rotation","Secondary Axis Rotation"]; % "Secondary Axis Rotation",
DOFNums = [1 3 5 4];

% for directions, calculate the mean absolute percent error
for ii = 1:length(mcrWave{1}.aboveWaterMass)
    for jj = 1:length(DOFs)
        errorValDir(ii,jj) = mean([mcrWave{1}.velRMSPercentDiff(ii,DOFNums(jj)), mcrWave{2}.velRMSPercentDiff(ii,DOFNums(jj)), mcrWave{3}.velRMSPercentDiff(ii,DOFNums(jj)), mcrWave{4}.velRMSPercentDiff(ii,DOFNums(jj))]);
        errorValDirAbs(ii,jj) = mean([abs(mcrWave{1}.velRMSPercentDiff(ii,DOFNums(jj))), abs(mcrWave{2}.velRMSPercentDiff(ii,DOFNums(jj))), abs(mcrWave{3}.velRMSPercentDiff(ii,DOFNums(jj))), abs(mcrWave{4}.velRMSPercentDiff(ii,DOFNums(jj)))]);
        errorValSum(ii,jj) = weights(1)*abs(mcrWave{1}.velRMSPercentDiff(ii,DOFNums(jj))) + weights(2)*abs(mcrWave{2}.velRMSPercentDiff(ii,DOFNums(jj))) + weights(3)*abs(mcrWave{3}.velRMSPercentDiff(ii,DOFNums(jj))) + weights(4)*abs(mcrWave{4}.velRMSPercentDiff(ii,DOFNums(jj)));    
        for kk = 1:4
            errorValWave(ii,jj,kk) = mcrWave{kk}.velRMSDiff(ii,DOFNums(jj));    
            errorValWavePct(ii,jj,kk) = mcrWave{kk}.velRMSPercentDiff(ii,DOFNums(jj));    
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
cdLabels = ["C_{d,surge}","C_{d,heave}","C_{d,pitch}"];
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
            ylim(100*[min(errorValWave(:,jj,ii)/processedData{ii}.rmsTransPS(DOFNums(jj))), max(errorValWave(:,jj,ii)/processedData{ii}.rmsTransPS(DOFNums(jj)))])
        else
            ylim(100*[min(errorValWave(:,jj,ii)/processedData{ii}.rmsRotPS(DOFNums(jj)-3)), max(errorValWave(:,jj,ii)/processedData{ii}.rmsRotPS(DOFNums(jj)-3))])
        end
        ylabel(strcat('% Error'))
        title(DOFs(jj))
        xlim([1.5,8.5])
    end
    sgtitle(strcat('Sea State: ', num2str(ii))) 

    % set(gcf, 'PaperPosition', [0 0 6 10])
    % set(gcf, 'PaperSize', [6 10])
    % print(gcf, strcat('../paperFigs/seaState',num2str(ii),'.pdf'), '-dpdf', '-fillpage','-r1000','-vector')
end

%% Plot all dofs in a subplot for each sea state - All 4 sea states on 1 plot!

cdList = ["cdSurge","cdHeave","cdPitch","cdPitch"];
cdLabels = ["C_{d,surge}","C_{d,heave}","C_{d,pitch}","C_{d,pitch}"];
unitsStr = ["m","m",char(176),char(176)];

% find minimum percentages for each dof
minPercent = inf*ones(1,4);
maxPercent = -inf*ones(1,4);

xLims = [1.5 8.5; 0.25 2.25; .75 2.75; .75 2.75];

figure('Position', [10 10 1000 400])
for jj = 1:3%length(DOFs)
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
        ylim(100*[yAxisLims(1)/processedData{ii}.rmsTransPS(DOFNums(jj)), yAxisLims(2)/processedData{ii}.rmsTransPS(DOFNums(jj))])
    else
        ylim(100*[yAxisLims(1)/(processedData{ii}.rmsRotPS(DOFNums(jj)-3)*180/pi), yAxisLims(2)/(processedData{ii}.rmsRotPS(DOFNums(jj)-3)*180/pi)])
    end
    ylabel(strcat('% Error'))
    title(DOFs(jj))

    xlim(xLims(jj,:))
    if jj == 2
        set(gca,'Xtick',0:.5:2)
    elseif jj > 2
        set(gca,'Xtick',0:.5:3)
    end
end

legend(["Sea State A","Sea State B","Sea State C","Sea State D"],Location="southeast")

ps = get(gcf, 'Position');
ratio =  ps(4) / ps(3);
paperWidth = 12;
paperHeight = paperWidth*ratio;

% set(gcf, 'papersize', [paperWidth paperHeight]);
% set(gcf, 'PaperPosition', [0    0   paperWidth paperHeight]);
% set(gcf, 'PaperPosition', [0 0 10 4])
% set(gcf, 'PaperSize', [10 4])
% print(gcf, strcat('../../paperFigs/allSeaStatesRes.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

%% Plot preferred axis angle

for ii = 1:4
    obsPrimaryDirection(ii) = processedData{ii}.primaryAxisWS;
    waveDirs(ii) = processedData{ii}.meanWaveDirWS;
end

% add 90 degrees to WEC-Sim preferred angle such that primaryAxis is about
% which angle the pitch is maximized
mcrOverall.preferredAngle = mcrOverall.primaryAxis - 90;

figure()
plot(mcrOverall.waveNum,mcrOverall.preferredAngle,'ok')
hold on
plot(1:4,obsPrimaryDirection,'*','MarkerEdgeColor',[0 0.5 0],'LineWidth', 1.5, MarkerSize=8)
plot(1:4,waveDirs,'+b','LineWidth', 1.2,MarkerSize=8)
xlim([0.75 4.25])
% ylim([-20 310])
legend('WEC-Sim','Observed','Mean Wave Direction','Position',[0.35 0.75 0.1 0.1])
xlabel('Sea State')
ylabel('Preferred Rotation Axis (deg)')
set(gca,'Xtick',1:4)

% set(gcf, 'PaperPosition', [0 0 5 4])
% set(gcf, 'PaperSize', [5 4])
% print(gcf, strcat('../../paperFigs/preferredAxis.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

%% Plot summed error

%cdList = ["cdSurge","cdHeave","cdPitch"];
%cdLabels = ["C_{d,surge}","C_{d,heave}","C_{d,pitch}"];
unitsStr = ["m","m","rad"];
figure('Position', [10 10 800 600])
xLims = [1 9; 0.25 2.25; .75 2.75; .75 2.75];

for ii = 1:length(cdList)
    subplot(2,2,ii)
    scatter(eval(strcat('mcrWave{1}.',cdList(ii))),errorValSum(:,ii),'ok')
    xlabel(cdLabels(ii))
    ylabel(strcat('Weighted Error (%)'))
    title(DOFs(ii))
    xlim(xLims(ii,:))
    if ii == 3
        ylim([6 22])
    end
end

surgeInd = find(mcrWave{1}.cdSurge == 6);
heaveInd = find(mcrWave{1}.cdHeave == 0.5);
pitchInd = find(mcrWave{1}.cdPitch == 1.5);
optInds = intersect(intersect(surgeInd, heaveInd),pitchInd);

for ii = 1:4
    primaryAxisOpt(ii) = mcrWave{ii}.primaryAxis(optInds(2));
end

% subplot(2,2,4)
% scatter(mcrWave{1}.aboveWaterMass(optInds),errorValSum(optInds,3),'ok','filled')
% xlabel('Above Water Inertia (kgm^2)')
% ylabel(strcat('Weighted Error (%)'))
% title('Pitch')
%xlim([-22,42])

% set(gcf, 'PaperPosition', [0 0 8 6])
% set(gcf, 'PaperSize', [8 6])
% print(gcf, strcat('../../paperFigs/weightedError.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

%% Plot for above water inertia
surgeInd = find(mcrWave{1}.cdSurge == 6);
heaveInd = find(mcrWave{1}.cdHeave == 0.5);
pitchInd = find(mcrWave{1}.cdPitch == 1.5);
optInds = intersect(intersect(surgeInd, heaveInd),pitchInd);

figure()
scatter(mcrWave{1}.aboveWaterMass(optInds),errorValSum(optInds,3),'ok','filled')
xlabel('Above Water Inertia (kgm^2)')
ylabel(strcat('Weighted Error (%)'))
title('Pitch')
xlim([-23,43])

% set(gcf, 'PaperPosition', [0 0 5 4])
% set(gcf, 'PaperSize', [5 4])
% print(gcf, strcat('../../paperFigs/aboveWaterInertia.pdf'), '-dpdf', '-fillpage','-r1000','-vector')

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
scatter3(mcrWave{1}.aboveWaterMass,mcrWave{1}.cdSurge,mcrWave{1}.velRMSDiff(:,5),8,abs(mcrWave{1}.velRMSDiff(:,5)))
xlabel('Above Water Mass (kg)')
ylabel('Cd Surge')
colormap(gca,"winter")

for ii = 1:length(DOFs)
    for jj = 1:length(tuneVars)
        figure()
        scatter(eval(strcat('mcrWave{1}.',tuneVars(jj))),mcrWave{waveNum}.velRMSPercentDiff(:,DOFNums(ii)))
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


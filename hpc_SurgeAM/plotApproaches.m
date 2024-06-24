close all
clear all
clc

load('../errorDirAllAbs.mat')

approaches = who;
%approaches = [approaches(1),approaches(3)];

%% Plot each dof error for each approach
DOFs = ["Surge", "Heave", "Pitch"];
cdList = ["cdSurge","cdHeave","cdPitch"];

figure('Position', [10 10 600 300])
for ii = 1:length(DOFs)
    subplot(1,3,ii)
    for jj = 1:length(approaches)
        scatter(jj,eval(strcat(approaches{jj},'(:,',num2str(ii),')')),'.k')
        hold on
    end
   
    ylabel(strcat('Error (%) - ',DOFs(ii)))
    xlim([.5, 3.5])
    ax = gca;
    ax.XTick = [1, 2, 3];
    ax.XTickLabels = {'Heave AM','Morison','Surge AM'};
end

% set(gcf, 'PaperPosition', [0 0 10 5])
% set(gcf, 'PaperSize', [10 5])
% print(gcf, '../paperFigs/approachCompare.pdf', '-dpdf', '-fillpage')



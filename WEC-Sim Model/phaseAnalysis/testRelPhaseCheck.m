% tests relPhaseCheck
clear
close all;
clc
% Note from Dom: Not entirely sure I have a complete picture of the field
% data post processing so don't take this to the bank w/o checking my work!

load ../obsData/processedDataPS.mat

% spectral parameters - field data
nWin = 300; % window length (samples)
nOver = 240; % overlap (samples)
Fs = 10; % sampling frequency Hz
makeFigs = 0; % make figures?
thresh = 0.5; % parsing threshold (decimal, out of 1)

% spectral parameters - WS
WSnWin = 600; % window length (samples)
WSnOver = 480; % overlap (samples)
WSFs = 20; % sampling frequency Hz
WSthresh = 0.5;

% query seastate
qSS = 1; 
loadStr = ['outputSS' num2str(qSS) '.mat'];
load(loadStr);

processedData{1,qSS}.primaryAxis = processedData{1,qSS}.primaryAxis + 90; % add 90 degrees to primary axis to move preferred axis rotation from 4th column to 5th column

% grab integer number of windows
processedData{1,qSS}.NEDVelPS = processedData{1,qSS}.NEDVel*rotz(processedData{1,qSS}.primaryAxis);
processedData{1,qSS}.NEDGyrVelPS = processedData{1,qSS}.NEDGyrVel*rotz(processedData{1,qSS}.primaryAxis);
processedData{1,qSS}.NEDGyrPosPS = processedData{1,qSS}.NEDGyrPos*rotz(processedData{1,qSS}.primaryAxis);
transDOFs = processedData{1,qSS}.NEDVelPS;
rotDOFs = processedData{1,qSS}.NEDGyrVelPS;
fieldtestDOFs = processedData{1,qSS}.NEDGyrPosPS;

% relative phase, field data
[f,Cxyf11,Pxyf11,angP11]= relPhaseCheck(transDOFs(:,1),rotDOFs(:,1),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf12,Pxyf12,angP12]= relPhaseCheck(transDOFs(:,1),rotDOFs(:,2),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf13,Pxyf13,angP13]= relPhaseCheck(transDOFs(:,1),rotDOFs(:,3),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf21,Pxyf21,angP21]= relPhaseCheck(transDOFs(:,2),rotDOFs(:,1),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf22,Pxyf22,angP22]= relPhaseCheck(transDOFs(:,2),rotDOFs(:,2),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf23,Pxyf23,angP23]= relPhaseCheck(transDOFs(:,2),rotDOFs(:,3),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf31,Pxyf31,angP31]= relPhaseCheck(transDOFs(:,3),rotDOFs(:,1),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf32,Pxyf32,angP32]= relPhaseCheck(transDOFs(:,3),rotDOFs(:,2),nWin,nOver,Fs,thresh, makeFigs);
[~,Cxyf33,Pxyf33,angP33]= relPhaseCheck(transDOFs(:,3),rotDOFs(:,3),nWin,nOver,Fs,thresh, makeFigs);
% [~,Cxyftest,Pxyftest,angPtest]= relPhaseCheck(transDOFs(:,1),transDOFs(:,1),nWin,nOver,Fs,thresh, makeFigs); % should be 1 everywhere Cxy, 0 everywhere angP 
[~,Cxyftest,Pxyftest,angPtest]= relPhaseCheck(rotDOFs(:,2),fieldtestDOFs(:,2),nWin,nOver,Fs,thresh, 1); % should be 1 everywhere Cxy, 0 everywhere angP 


% plot field
% figure; clf;
% plot(f,angP11);
% hold on; grid on;
% plot(f,angP12);
% plot(f,angP13);
% plot(f,angP21);
% plot(f,angP22);
% plot(f,angP23);
% plot(f,angP31);
% plot(f,angP32);
% plot(f,angP33);
% plot(f,angPtest);
% xlabel('freq (hz)')
% ylabel('phase lag (rad)')
% legend('11','12','13','21','22','23','31','32','33','test')
% title('Observed Data')

% wecSim output 
WStransDOFs = output.bodies(1).velocityPS(:,[1:3])*rotz(90); % rotate each 90 degrees to align preferred axis rotation with 5th column
WSrotDOFs = output.bodies(1).velocityPS(:,[4:6])*rotz(90);
WStestDOFs = output.bodies(1).positionPS(:,[4:6])*rotz(90);

% relative phase, WS data
[fWS,WSCxyf11,WSPxyf11,WSangP11]= relPhaseCheck(WStransDOFs(:,1),WSrotDOFs(:,1),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf12,WSPxyf12,WSangP12]= relPhaseCheck(WStransDOFs(:,1),WSrotDOFs(:,2),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf13,WSPxyf13,WSangP13]= relPhaseCheck(WStransDOFs(:,1),WSrotDOFs(:,3),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf21,WSPxyf21,WSangP21]= relPhaseCheck(WStransDOFs(:,2),WSrotDOFs(:,1),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf22,WSPxyf22,WSangP22]= relPhaseCheck(WStransDOFs(:,2),WSrotDOFs(:,2),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf23,WSPxyf23,WSangP23]= relPhaseCheck(WStransDOFs(:,2),WSrotDOFs(:,3),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf31,WSPxyf31,WSangP31]= relPhaseCheck(WStransDOFs(:,3),WSrotDOFs(:,1),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf32,WSPxyf32,WSangP32]= relPhaseCheck(WStransDOFs(:,3),WSrotDOFs(:,2),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxyf33,WSPxyf33,WSangP33]= relPhaseCheck(WStransDOFs(:,3),WSrotDOFs(:,3),WSnWin,WSnOver,WSFs,WSthresh, makeFigs);
[~,WSCxtest2,WSPxytest,WSangtest]= relPhaseCheck(WSrotDOFs(:,2),WStestDOFs(:,2),WSnWin,WSnOver,WSFs,WSthresh, 1); % should be 90 leading over excited band

% plot field
% figure; clf;
% plot(fWS,WSangP11);
% hold on; grid on;
% plot(fWS,WSangP12);
% plot(fWS,WSangP13);
% plot(fWS,WSangP21);
% plot(fWS,WSangP22);
% plot(fWS,WSangP23);
% plot(fWS,WSangP31);
% plot(fWS,WSangP32);
% plot(fWS,WSangP33);
% plot(fWS,WSangtest)
% xlabel('freq (hz)')
% ylabel('phase lag (rad)')
% legend('11','12','13','21','22','23','31','32','33','test')
% title('WEC-Sim Results')

figure; clf;


subplot(3,3,1)
polarplot(angP11,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP11,fWS,'*r','LineWidth',1.2)
rlim([0 1])
t = title('Secondary Axis');
fs = get(t,'FontSize');
t = text(-.48,-.1,'Secondary Axis','Units','normalized','FontSize',fs,'FontWeight','bold');
set(t,'Rotation',90);

% xlim([0 1])
% ylabel('Phase lag (rad)')

subplot(3,3,2)
a1=polarplot(angP12,f,'ob','LineWidth',1.2);
grid on; hold on;
polarplot(WSangP12,fWS,'*r','LineWidth',1.2)
rlim([0 1])
%a1.Title.String='Rotational DOF'
%a1.Title.Location= 'NorthOutside'
title('Preferred Axis')

subplot(3,3,3)
polarplot(angP13,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP13,fWS,'*r','LineWidth',1.2)
rlim([0 1])
title('Vertical Axis');

subplot(3,3,4)
polarplot(angP21,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP21,fWS,'*r','LineWidth',1.2)
%ylabel('Phase lag (rad)')
rlim([0 1])
%title('Translational DOF')
t = text(-.48,-.02,'Preferred Axis','Units','normalized','FontSize',fs,'FontWeight','bold');
set(t,'Rotation',90);

t = sgtitle('Rotational DOFs');
sg_fs = get(t,'FontSize');
sg_fw = get(t,'FontWeight');

t = text(-.8,-.5,'Translational DOFs','Units','normalized','FontSize',sg_fs,'FontWeight',sg_fw);
set(t,'Rotation',90);

subplot(3,3,5)
polarplot(angP22,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP22,fWS,'*r','LineWidth',1.2)
rlim([0 1])


subplot(3,3,6)
polarplot(angP23,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP23,fWS,'*r','LineWidth',1.2)
rlim([0 1])
legend('Field','Sim')


subplot(3,3,7)
polarplot(angP31,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP31,fWS,'*r','LineWidth',1.2)
%ylabel('Phase lag (rad)')
%xlabel('Freq. (Hz)')
rlim([0 1])
t = text(-.48,.04,'Vertical Axis','Units','normalized','FontSize',fs,'FontWeight','bold');
set(t,'Rotation',90);

subplot(3,3,8)
polarplot(angP32,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP32,fWS,'*r','LineWidth',1.2)
%xlabel('Freq. (Hz)')
rlim([0 1])

subplot(3,3,9)
polarplot(angP33,f,'ob','LineWidth',1.2)
grid on; hold on;
polarplot(WSangP33,fWS,'*r','LineWidth',1.2)
%xlabel('Freq. (Hz)')
rlim([0 1])

set(gcf, 'PaperSize', [7 6]);
set(gcf, 'PaperPosition', [0 0 7.55 6]);

% set(gcf, 'PaperPosition', [0 0 5 4])
% set(gcf, 'PaperSize', [5 4])
% print(gcf, strcat('./paperFigs/polarPhaseSS',num2str(qSS),'.pdf'), '-dpdf', '-fillpage','-r1000','-image')


% tests relPhaseCheck
close all;
% Note from Dom: Not entirely sure I have a complete picture of the field
% data post processing so don't take this to the bank w/o checking my work!

load obsData/processedDataPS.mat
load WS_wave1_res.mat

% spectral parameters - field data
nWin = 300; % window length (samples)
nOver = 200; % overlap (samples)
Fs = 10; % sampling frequency Hz
makeFigs = 0; % make figures?
thresh = 0.5; % parsing threshold (decimal, out of 1)

% spectral parameters - WS
WSnWin = 600; % window length (samples)
WSnOver = 480; % overlap (samples)
WSFs = 20; % sampling frequency Hz

% grab integer number of windows
processedData{1,1}.NEDVelPS = processedData{1,1}.NEDVel*rotz(processedData{1,1}.primaryAxis);
processedData{1,1}.NEDGyrVelPS = processedData{1,1}.NEDGyrVel*rotz(processedData{1,1}.primaryAxis);
processedData{1,1}.NEDGyrPosPS = processedData{1,1}.NEDGyrPos*rotz(processedData{1,1}.primaryAxis);
transDOFs = processedData{1,1}.NEDVelPS;
offsetInd = length(processedData{1,1}.NEDGyrVelPS)-length(transDOFs)+1; % because translational vel and rotational pos start 100 seconds into the test data
rotDOFs = processedData{1,1}.NEDGyrVelPS(offsetInd:end,:);
fieldtestDOFs = processedData{1,1}.NEDGyrPosPS;

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
[~,Cxyftest,Pxyftest,angPtest]= relPhaseCheck(rotDOFs(:,2),fieldtestDOFs(:,2),nWin,nOver,Fs,thresh, makeFigs); % should be 1 everywhere Cxy, 0 everywhere angP 


% plot field
figure; clf;
plot(f,angP11);
hold on; grid on;
plot(f,angP12);
plot(f,angP13);
plot(f,angP21);
plot(f,angP22);
plot(f,angP23);
plot(f,angP31);
plot(f,angP32);
plot(f,angP33);
plot(f,angPtest);
xlabel('freq (hz)')
ylabel('phase lag (rad)')
legend('11','12','13','21','22','23','31','32','33','test')
title('Observed Data')

% wecSim output 
WStransDOFs = output.bodies(1).velocityPS(:,[1:3]);
WSrotDOFs = output.bodies(1).velocityPS(:,[4:6]);
WStestDOFs = output.bodies(1).positionPS(:,[4:6]);

% relative phase, WS data
[fWS,WSCxyf11,WSPxyf11,WSangP11]= relPhaseCheck(WStransDOFs(:,1),WSrotDOFs(:,1),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf12,WSPxyf12,WSangP12]= relPhaseCheck(WStransDOFs(:,1),WSrotDOFs(:,2),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf13,WSPxyf13,WSangP13]= relPhaseCheck(WStransDOFs(:,1),WSrotDOFs(:,3),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf21,WSPxyf21,WSangP21]= relPhaseCheck(WStransDOFs(:,2),WSrotDOFs(:,1),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf22,WSPxyf22,WSangP22]= relPhaseCheck(WStransDOFs(:,2),WSrotDOFs(:,2),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf23,WSPxyf23,WSangP23]= relPhaseCheck(WStransDOFs(:,2),WSrotDOFs(:,3),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf31,WSPxyf31,WSangP31]= relPhaseCheck(WStransDOFs(:,3),WSrotDOFs(:,1),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf32,WSPxyf32,WSangP32]= relPhaseCheck(WStransDOFs(:,3),WSrotDOFs(:,2),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxyf33,WSPxyf33,WSangP33]= relPhaseCheck(WStransDOFs(:,3),WSrotDOFs(:,3),WSnWin,WSnOver,WSFs,thresh, makeFigs);
[~,WSCxtest2,WSPxytest,WSangtest]= relPhaseCheck(WSrotDOFs(:,2),WStestDOFs(:,2),WSnWin,WSnOver,WSFs,thresh, makeFigs); % should be 90 leading over excited band

% plot field
figure; clf;
plot(fWS,WSangP11);
hold on; grid on;
plot(fWS,WSangP12);
plot(fWS,WSangP13);
plot(fWS,WSangP21);
plot(fWS,WSangP22);
plot(fWS,WSangP23);
plot(fWS,WSangP31);
plot(fWS,WSangP32);
plot(fWS,WSangP33);
plot(fWS,WSangtest)
xlabel('freq (hz)')
ylabel('phase lag (rad)')
legend('11','12','13','21','22','23','31','32','33','test')
title('WEC-Sim Results')

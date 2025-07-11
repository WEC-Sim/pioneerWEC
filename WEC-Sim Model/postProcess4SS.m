close all
clear all
clc

load('mcrRes4SS_FINAL.mat');
load('obsData/processedDataPS')

weights = [.48 .22 .21 .09];

for ii = 1:length(mcr.cases)
    velRMSObs(ii,:) = [processedData{ii}.rmsTransPS, processedData{ii}.rmsRotPS*180/pi];
    velRMSWS(ii,:) = [mcr.velRMSPS(ii,1:3), mcr.velRMSPS(ii,4:6)*180/pi];
    velRMSDiff(ii,1:3) = processedData{ii}.rmsTransPS - mcr.velRMSPS(ii,1:3);
    velRMSDiff(ii,4:6) = (processedData{ii}.rmsRotPS - mcr.velRMSPS(ii,4:6))*180/pi;
    velRMSDiffPercent(ii,1:3) = (processedData{ii}.rmsTransPS - mcr.velRMSPS(ii,1:3))./processedData{ii}.rmsTransPS*100;
    velRMSDiffPercent(ii,4:6) = (processedData{ii}.rmsRotPS - mcr.velRMSPS(ii,4:6))./processedData{ii}.rmsRotPS*100;
end

fprintf("Observed RMS with respect to preferred axis. \n")
disp(velRMSObs)

fprintf("WEC-Sim RMS with respect to preferred axis: \n")
disp(velRMSWS)

fprintf("RMS Difference: \n")
disp(velRMSDiff)

fprintf("Percent RMS Difference: \n")
disp(velRMSDiffPercent)

% calculate total weighted error for all directions
fprintf("Weighted error: \n")
weightedError = weights*abs(velRMSDiffPercent)




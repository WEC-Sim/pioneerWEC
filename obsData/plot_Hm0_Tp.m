close all
clear all
clc

load('NED_IMU.mat')

% runs from Jantzen
% times from Python selection:
snipTimes = [3921495803.067, 3922032202.633, 3921395004.100, 3921870203.282];

for ii = 1:length(NED_IMU.Info.StartIndex)
    startTime = NED_IMU.Time(NED_IMU.Info.StartIndex(ii));
    endTime = NED_IMU.Time(NED_IMU.Info.EndIndex(ii));
    meanNEDTimes(ii) = mean([startTime,endTime]);
end

% find closest snips
for ii = 1:length(snipTimes)
    [~,closestSnips(ii)] = min(abs(meanNEDTimes-snipTimes(ii)));
end

% selected points from Mark's diagram:
Hm0_bins = [1.36, 1.40, 2.69, 3.53];
Te_bins = [4.51, 6.37, 5.74, 8.24];

fileTime = ncread('./dir_comparison/ooiSpectra-mab/WSS_MARK.nc','time'); %WSS_MARK
Hm0 = ncread('./dir_comparison/ooiSpectra-mab/WSS_MARK.nc','significant_wave_height');
Tp = ncread('./dir_comparison/ooiSpectra-mab/WSS_MARK.nc','peak_wave_period');
Te = 0.858*Tp;

% find closest WAVESS
for ii = 1:length(snipTimes)
    [~,closestWAVESS(ii)] = min(abs(fileTime-snipTimes(ii)));
end

figure()
plot(Te_bins,Hm0_bins,'b*')
hold on
plot(Te,Hm0,'o',"MarkerEdgeColor","#D95319")
plot(Te(closestWAVESS),Hm0(closestWAVESS),'g+')

fprintf('Snip Numbers: %f %f %f %f',closestSnips)
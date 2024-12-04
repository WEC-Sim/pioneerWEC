clear
close all
clc

load('obsData/excitationForceWave3.mat')

figure()
plot(fExcTS.Time, fExcTS.Data(:,1))

mean(fExcTS.Data(:,1))
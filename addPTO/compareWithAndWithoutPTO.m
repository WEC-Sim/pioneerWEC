close all
clear all
clc

load fixedPTOFullDir.mat

outputFixedPTO = output;
wavesFixedPTO = waves;

clearvars -except outputFixedPTO wavesFixedPTO

load ../noPTO/noPTOFullDir.mat

outputNoPTO = output;
wavesNoPTO = waves;

clearvars -except outputFixedPTO outputNoPTO wavesFixedPTO wavesNoPTO

load PTOFullDir.mat

outputPTO = output;

figure()
plot(outputNoPTO.bodies(1).time,outputNoPTO.bodies(1).position(:,1))
hold on
plot(outputFixedPTO.bodies(1).time,outputFixedPTO.bodies(1).position(:,1))
plot(outputPTO.bodies(1).time,outputPTO.bodies(1).position(:,1),'--')
xlabel('time (s)')
ylabel('surge disp (m)')
legend('No PTO','Fixed PTO','PTO')

figure()
plot(outputNoPTO.bodies(1).time,outputNoPTO.bodies(1).position(:,3))
hold on
plot(outputFixedPTO.bodies(1).time,outputFixedPTO.bodies(1).position(:,3))
plot(outputPTO.bodies(1).time,outputPTO.bodies(1).position(:,3),'--')
xlabel('time (s)')
ylabel('heave disp (m)')
legend('No PTO','Fixed PTO','PTO')

figure()
plot(outputNoPTO.bodies(1).time,outputNoPTO.bodies(1).position(:,5))
hold on
plot(outputFixedPTO.bodies(1).time,outputFixedPTO.bodies(1).position(:,5))
plot(outputPTO.bodies(1).time,outputPTO.bodies(1).position(:,5),'--')
xlabel('time (s)')
ylabel('pitch disp (rad)')
legend('No PTO','Fixed PTO','PTO')

figure()
plot(outputNoPTO.wave.time,outputNoPTO.wave.elevation)
hold on
plot(outputFixedPTO.wave.time,outputFixedPTO.wave.elevation)
xlabel('time (s)')
ylabel('wave elev (m)')
legend('No PTO','Fixed PTO')
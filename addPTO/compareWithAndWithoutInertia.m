close all
clear all
clc

load ../noPTO/noPTOFullDir.mat

outputFixedPTO = output;
wavesFixedPTO = waves;

clearvars -except outputFixedPTO wavesFixedPTO

load fixedPTOFullDir_Inertia.mat

outputInertia = output;

figure()
plot(outputFixedPTO.bodies(1).time,outputFixedPTO.bodies(1).position(:,1))
hold on
plot(outputInertia.bodies(1).time,outputInertia.bodies(1).position(:,1))
xlabel('time (s)')
ylabel('surge disp (m)')
legend('No PTO','PTO Inertia')

figure()
plot(outputFixedPTO.bodies(1).time,outputFixedPTO.bodies(1).position(:,3))
hold on
plot(outputInertia.bodies(1).time,outputInertia.bodies(1).position(:,3))
xlabel('time (s)')
ylabel('heave disp (m)')
legend('No PTO','PTO Inertia')

figure()
plot(outputFixedPTO.bodies(1).time,outputFixedPTO.bodies(1).position(:,5))
hold on
plot(outputInertia.bodies(1).time,outputInertia.bodies(1).position(:,5))
xlabel('time (s)')
ylabel('pitch disp (rad)')
legend('No PTO','PTO Inertia')

figure()
plot(outputFixedPTO.wave.time,outputFixedPTO.wave.elevation)
hold on
plot(outputInertia.wave.time,outputInertia.wave.elevation)
xlabel('time (s)')
ylabel('wave elev (m)')
legend('No PTO','PTO Inertia')
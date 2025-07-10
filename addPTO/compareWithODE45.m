close all
clear all
clc

load fixedPTOode23t.mat

outputODE23t = output;
%wavesFixedPTO = waves;

clearvars -except outputODE23t %wavesFixedPTO

load fixedPTOode45.mat

outputODE45 = output;

figure()
plot(outputODE23t.bodies(1).time,outputODE23t.bodies(1).position(:,1))
hold on
plot(outputODE45.bodies(1).time,outputODE45.bodies(1).position(:,1))
xlabel('time (s)')
ylabel('surge disp (m)')
legend('No PTO','PTO Inertia')

figure()
plot(outputODE23t.bodies(1).time,outputODE23t.bodies(1).position(:,3))
hold on
plot(outputODE45.bodies(1).time,outputODE45.bodies(1).position(:,3))
xlabel('time (s)')
ylabel('heave disp (m)')
legend('No PTO','PTO Inertia')

figure()
plot(outputODE23t.bodies(1).time,outputODE23t.bodies(1).position(:,5))
hold on
plot(outputODE45.bodies(1).time,outputODE45.bodies(1).position(:,5))
xlabel('time (s)')
ylabel('pitch disp (rad)')
legend('No PTO','PTO Inertia')

figure()
plot(outputODE23t.wave.time,outputODE23t.wave.elevation)
hold on
plot(outputODE45.wave.time,outputODE45.wave.elevation)
xlabel('time (s)')
ylabel('wave elev (m)')
legend('No PTO','PTO Inertia')
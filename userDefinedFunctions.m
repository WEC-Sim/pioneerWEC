% intentionally empty for now

load('./realData_Jantzen/DataSnip100.mat');

[~,startInd] = min(abs(100-output.bodies(1).time));

figure()
plot(InverseDynamics.Time,InverseDynamics.Position(:,5)*180/pi)
hold on
plot(output.bodies(1).time(startInd:end)-output.bodies(1).time(startInd),output.bodies(1).position(startInd:end,5)*180/pi)
xlabel('Time (s)')
ylabel('Pitch Rotation (deg)')
legend('Observed Data','WEC-Sim')

figure()
plot(InverseDynamics.Time,InverseDynamics.Position(:,3))
hold on
plot(output.bodies(1).time(startInd:end)-output.bodies(1).time(startInd),output.bodies(1).position(startInd:end,3))
xlabel('Time (s)')
ylabel('Heave Position (m)')
legend('Observed Data','WEC-Sim')

output.plotResponse(1,1)

figure()
plot(output.mooring.time,output.mooring.forceMooring)
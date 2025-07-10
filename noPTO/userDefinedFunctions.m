%Example of user input MATLAB file for post processing
close all

%Plot waves
waves.plotElevation(simu.rampTime);
try 
    waves.plotSpectrum();
catch
end

%Plot heave response for body 1
output.plotResponse(1,3);

%Plot heave response for body 2
% output.plotResponse(2,3);

%Plot heave forces for body 1
output.plotForces(1,3);

%Plot heave forces for body 2
% output.plotForces(2,3);

%Plot pitch response for body 1
output.plotResponse(1,5);

%Plot pitch response for body 1
output.plotForces(1,5);

%Save waves and response as video
% output.saveViz(simu,body,waves,...
%     'timesPerFrame',5,'axisLimits',[-150 150 -150 150 -50 20],...
%     'startEndTime',[100 125]);

% expected force
% theoreticalSpringForce = -springStiffness10.*RelativeAngle.signals.values;
% theoreticalPTOForce = -ptoDamping.*RelativeVelocity.signals.values/(gearRatio*beltGearRatio);
% theoreticalForce = theoreticalSpringForce + theoreticalPTOForce;
% 
% % plot pendulum position and spring torque
% figure()
% plot(RelativeAngle.time,RelativeAngle.signals.values)
% hold on
% yyaxis right
% plot(springAndMotorTorque,'--')
% plot(RelativeAngle.time,theoreticalForce,':k')
% legend('Angle','Torque','Theoretical (no fric)')


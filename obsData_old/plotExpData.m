close all
clear all
clc

files = dir('*.mat');

%processedData = {};
forces = {'Surge','Sway','Heave','Roll','Pitch'};

g = 9.81;
periods = 1:.5:20;
% calculate wave breaking:
for ii = 1:length(periods)
    L = g*periods(ii)^2/(2*pi);
    k = 2*pi/L;
    HL_max = 0.142*tanh(k*30);
    H_max(ii) = HL_max*L;
end

figure()
plot(periods,H_max)
hold on
%xlabel('Period (s)')
%ylabel('Max height before breaking (m)')

clearvars periods

processedData = {};

%figure()
for ii = 1:length(files)
    load(files(ii).name)
    fprintf('Hm0 = %f, Tp = %f \n',InverseDynamics.Hm0,InverseDynamics.Tp)
    plot(InverseDynamics.Tp,InverseDynamics.Hm0,'r*')
    hold on

    % calculate the standard deviation of the motion
    for jj = 1:size(InverseDynamics.Position, 2)
        processedData(ii).posStd(jj) = std(InverseDynamics.Position(:,jj));
        processedData(ii).velStd(jj) = std(InverseDynamics.Velocity(:,jj));
        if ismember(jj, 1:3)
            processedData(ii).forceStd(jj) = std(InverseDynamics.(strcat(forces{jj},'Force')));
        else
            processedData(ii).forceStd(jj) = std(InverseDynamics.(strcat(forces{jj},'Torque')));
        end
    end
    processedData(ii).Hm0 = InverseDynamics.Hm0;
    processedData(ii).Tp = InverseDynamics.Tp;
    processedData(ii).motionAngleSurge = atan(std(InverseDynamics.NED_IMU.Acc(:,1))/std(InverseDynamics.NED_IMU.Acc(:,2)))*180/pi;
    processedData(ii).motionAnglePitch = atan(std(InverseDynamics.NED_IMU.Gyr(:,1))/std(InverseDynamics.NED_IMU.Gyr(:,2)))*180/pi;
    processedData(ii).meanDirection = InverseDynamics.MeanDirection;

   
end

xlabel('Peak Period (s)')
ylabel('Significant Wave Height (m)')

figure()
plot(InverseDynamics.Time,InverseDynamics.Position(:,5))
yline(processedData(ii).posStd(5),'--')
yline(-processedData(ii).posStd(5),'--')
xlabel('Time(s)')
ylabel('Pitch Rotation (rad)')
legend('Instantaneous','Standard Deviation')

processedPitchStd = [];
processedPitchVelStd = [];

for ii = 1:length(processedData)
    heights(ii) = processedData(ii).Hm0;
    periods(ii) = processedData(ii).Tp;
    processedPitchStd(ii) = processedData(ii).posStd(5)*180/pi;
    % processedPitchVelStd(ii) = processedData(ii).velStd(5)*180/pi;
    processedHeaveStd(ii) = processedData(ii).posStd(3);
end

% plot pitch response vs. effective RAO
figure()
plot(periods, processedPitchStd'./heights,'ro')

xlabel('Peak Period (s)')
ylabel('Pitch Position STD / Wave Height (deg/m)')

heightsVec = .7:.1:4.1;
periodsVec = 3.5:.5:17;
pitchStdMatObs = zeros(length(periodsVec),length(heightsVec));

for ii = 1:length(heights)
    [~, indHeights] = min(abs(heights(ii)-heightsVec));
    [~, indPeriods] = min(abs(periods(ii)-periodsVec));
    pitchStdMatObs(indPeriods,indHeights) = processedPitchStd(ii);
end

pitchStdMatObs(pitchStdMatObs==0) = NaN;

figure()
h = heatmap(periodsVec,heightsVec,pitchStdMatObs','MissingDataColor',[1 1 1]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('Observed Pitch STD (deg)')

% processedData = processedData(1:3);

save processedDataStd.mat processedData
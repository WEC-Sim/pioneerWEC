clc, clear all, close all
% load('XYZ_IMU.mat')
load('NED_IMU.mat')
NumSmips = length(NED_IMU.Info.SnipNumber);

RMSPeak = zeros(1,NumSmips);
OffPeak = zeros(1,NumSmips);
PeakAngle = zeros(1,NumSmips);
RMS_Xaxis = zeros(1,NumSmips);
RMS_Yaxis = zeros(1,NumSmips);

for qq = 1:NumSmips
StartIndex = NED_IMU.Info.StartIndex(qq);
EndIndex = NED_IMU.Info.EndIndex(qq);

% Grab your rotation rates
Omega = NED_IMU.Gyr(StartIndex:EndIndex,:);
% Run through rotation loop to find primary axis of rotation
GuessAngle = 75;
Angle = GuessAngle-90:0.5:GuessAngle+90;
PrimaryAxis   = zeros(1,360);
SecondaryAxis =  zeros(1,360);
%RMS velocities about IMU axes
RMS_Xaxis(qq) = rms(Omega(:,1));
RMS_Yaxis(qq) = rms(Omega(:,2));

% Run through all valid angles to find ideal orientation for specific trial
for qa = 1:length(Angle)
PrimaryAxis(qa)   = rms( cosd(Angle(qa))*Omega(:,1) + sind(Angle(qa))*Omega(:,2));
SecondaryAxis(qa) = rms(-sind(Angle(qa))*Omega(:,1) + cosd(Angle(qa))*Omega(:,2));
end
% Find maximum value for the primary axis
[RMSPeak(qq),AngleIndex] = max(PrimaryAxis);
PeakAngle(qq) = Angle(AngleIndex);
OffPeak(qq) = SecondaryAxis(AngleIndex);
end

meanAngle = mean(PeakAngle);
XY_Ratio = RMS_Yaxis./RMS_Xaxis;
PeakRatio = RMSPeak./OffPeak;

% It happns that this value is crazy close to just average. not worth
% plotting
WeightedMeanAngle = sum(PeakAngle.*PeakRatio)/sum(PeakRatio);

for qq2 = 1:NumSmips
StartIndex = NED_IMU.Info.StartIndex(qq2);
EndIndex = NED_IMU.Info.EndIndex(qq2);

% Grab your rotation rates
Omega = NED_IMU.Gyr(StartIndex:EndIndex,:);

AvgPrimaryRMS(qq2)   = rms(cosd(meanAngle)*Omega(:,1) + sind(meanAngle)*Omega(:,2));
AvgSecondaryRMS(qq2) = rms(-sind(meanAngle)*Omega(:,1) + cosd(meanAngle)*Omega(:,2));
end

MeanRatio = AvgPrimaryRMS./AvgSecondaryRMS;

%% =========================================================================
% ------------------When In Doubt, Plot it Out-----------------------------
% =========================================================================
Color1 = [0.0  0.7  0.7];
Color1B = Color1*.75;
Color2 = [0.  0.0  0.6];
Color2B = Color2*.75;
Color3 = [0.0  0.7  0.0];
Color3B = Color3*0.75;
Color4 = [0.0  0.0  0.9];
Color4B = Color4*0.75;
XRange = [1,NumSmips];

% figure(1)
% hold on
% plot(RMS_Xaxis,'o','Color',Color1)
% plot(XRange,mean(RMS_Xaxis)*[1,1],'--','LineWidth',1.5,'Color',Color1B)
% plot(RMS_Yaxis,'o','Color',Color2)
% plot(XRange,mean(RMS_Yaxis)*[1,1],'--','LineWidth',1.5,'Color',Color2B)
% title('RMS Angular Velocities for Snippets, in IMU Frame')
% xlabel('Snip Number')
% ylabel('RMS Velocity (rad/s, rms)')
% legend('North','','East','')

figure(2)
SQ(1) = subplot(2,1,1);
plot(RMSPeak,'o','Color',Color1)
hold on
plot(XRange,mean(RMSPeak)*[1,1],'--','LineWidth',1.5,'Color',Color1B)
plot(OffPeak,'o','Color',Color2)
plot(XRange,mean(OffPeak)*[1,1],'--','LineWidth',1.5,'Color',Color2B)
grid on
title('RMS Angular Velocities for Snippets, Rotated to Each Snips Dominant Axis')
xlabel('Snip Number')
ylabel('RMS Velocity (rad/s, rms)')
legend('Primary axis','','Secondary axis','')


SQ(2) = subplot(2,1,2);
plot(PeakAngle,'ko')
grid on
title('Rotation Angle, East of North')
xlabel('Snip Number')
ylabel('Angle (deg)')
xlim([150 200])
ylim([0 180])

linkaxes(SQ,'x')

% figure(3)
% plot(AvgPrimaryRMS,'o','Color',Color1)
% hold on
% plot(XRange,mean(AvgPrimaryRMS)*[1,1],'--','LineWidth',1.5,'Color',Color1B)
% plot(AvgSecondaryRMS,'o','Color',Color2)
% plot(XRange,mean(AvgSecondaryRMS)*[1,1],'--','LineWidth',1.5,'Color',Color2B)
% title('RMS Angular Velocities for Snippets, Rotated to Average Dominant Axis')
% xlabel('Snip Number')
% ylabel('RMS Velocity (rad/s, rms)')
% legend('Primary axis','','Secondary axis','')


% figure(4)
% plot(XY_Ratio,'Color',Color1)
% hold on
% plot(XRange,mean(XY_Ratio)*[1,1],'--','LineWidth',1.5,'Color',Color1B)
% plot(MeanRatio,'Color',Color2)
% plot(XRange,mean(MeanRatio)*[1,1],'--','LineWidth',1.5,'Color',Color2B)
% plot(PeakRatio,'Color',Color3)
% plot(XRange,mean(PeakRatio)*[1,1],'--','LineWidth',1.5,'Color',Color3B)
% title('Ratio of Chosen Axis to Orthogonal')
% xlabel('Snip Number')
% ylabel('Ratio of Velocities')
% legend('IMU Y as Primary','', 'Average Trial Optimal as Primary','','Individual Trial Optimal as Primary','')
% 
% fprintf('Ideal angle is %2.1f degrees offset from "X"\n',meanAngle)
% 
% 
% figure(5)
% histogram(PeakAngle)
% hold on
% plot(mean(PeakAngle)*[1,1],[0,100],'k--','LineWidth',2)
figure(6)
WSSTime = ncread('WSS_MARK.nc','time');
WSSHead = ncread('WSS_MARK.nc','mean_direction');

SP(1) = subplot(2,1,1);
hold on
plot(NED_IMU.Info.SnipMeanTime,NED_IMU.Info.SnipNumber,'-o')
grid on
xlabel('Time (s)')
ylabel('Snip Number')

WSSSnips = interp1(NED_IMU.Info.SnipMeanTime,NED_IMU.Info.SnipNumber,WSSTime);

SP(2) = subplot(2,1,2);
hold on
plot(WSSTime,WSSHead,'-o')
grid on
xlabel('Time (s)')
ylabel('Wave Heading')
linkaxes(SP,'x')

figure()
plot(WSSSnips,WSSHead,'-o')
grid on
xlabel('Snip Number')
ylabel('Wave Heading')
xlim([150 200])
ylim([0 180])
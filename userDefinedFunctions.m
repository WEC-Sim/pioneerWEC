% intentionally empty for now
close all

fprintf('\n Wave Number: %1.0f',waveNum)

load('./obsData/processedDataPS.mat');

[~,startInd] = min(abs(100-output.bodies(1).time));

responsesData = ["NEDAcc","NEDVel","NEDPos"];
responsesDataGyr = ["NEDGyrAcc","NEDGyrVel","NEDGyrPos"];
responsesTime = ["","Vel","Pos"];
responsesWS = ["acceleration","velocity","position"];
DOFs = ["Surge", "Heave", "Pitch"];
DOFNums = [1 3 5];

% for iResponse = 1:3
%     for jDOF = 1:3
%         figure()
%         if DOFNums(jDOF) > 3
%             plot(eval(strcat('processedData{waveNum}.NEDTime',responsesTime(iResponse))),eval(strcat('processedData{waveNum}.',responsesDataGyr(iResponse),'(:,',num2str(DOFNums(jDOF)-3),')')))
%         else
%             plot(eval(strcat('processedData{waveNum}.NEDTime',responsesTime(iResponse))),eval(strcat('processedData{waveNum}.',responsesData(iResponse),'(:,',num2str(DOFNums(jDOF)),')')))
%         end
%         hold on
%         plot(output.bodies(1).time(startInd:end)-output.bodies(1).time(startInd),eval(strcat('output.bodies(1).',responsesWS(iResponse),'(startInd:end,',num2str(DOFNums(jDOF)),')')))
%         xlabel('Time (s)')
%         ylabel(strcat(DOFs(jDOF),' ',responsesWS(iResponse),' (m)'))
%         legend('Observed Data','WEC-Sim')
% 
%     end
% end


output.plotResponse(1,1)

figure()
plot(output.mooring.time,output.mooring.forceMooring)


% convert to x-y axes consistent with wave direction:
waveAngleN = waves.direction;
output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];

fprintf("\n RMS with respect to wave direction. \n Angle: %f \n RMS: %f, %f, %f, %f, %f, %f \n \n",waveAngleN,rms(output.bodies(1).velocityXY(:,:)))

Angle = waveAngleN-90:0.5:waveAngleN+90;
PrimaryAxis   = zeros(1,360);
SecondaryAxis =  zeros(1,360);
%RMS velocities about IMU axes
RMS_Xaxis = rms(output.bodies(1).velocity(:,4)); % roll
RMS_Yaxis = rms(output.bodies(1).velocity(:,5)); % pitch

% Run through all valid angles to find ideal orientation for specific trial
for qa = 1:length(Angle)
    velocityRotCheck(qa,:) = rms(output.bodies(1).velocity(:,4:6)*rotz(Angle(qa)));
end
% Find maximum value for the primary axis
[RMSPeak,AngleIndex] = max(velocityRotCheck(:,2)); % find max pitch response
peakAngle = Angle(AngleIndex);
peakAngle = peakAngle + 90; % preferred axis angle is the axis about which maximum pitch occurs
OffPeak = SecondaryAxis(AngleIndex);

% convert to primary and secondary axes:
waveAngleN = peakAngle;
output.bodies(1).positionPS = [output.bodies(1).position(:,1:3)*rotz(peakAngle),output.bodies(1).position(:,4:6)*rotz(peakAngle)];
output.bodies(1).velocityPS = [output.bodies(1).velocity(:,1:3)*rotz(peakAngle),output.bodies(1).velocity(:,4:6)*rotz(peakAngle)];
output.bodies(1).accelerationPS = [output.bodies(1).acceleration(:,1:3)*rotz(peakAngle),output.bodies(1).acceleration(:,4:6)*rotz(peakAngle)];

fprintf("RMS with respect to primary axis (WEC-Sim). \n Angle: %f \n RMS: %f, %f, %f, %f, %f, %f \n \n",peakAngle,rms(output.bodies(1).velocityPS(:,:)))

% RMS from observed data
% compare the rms for each run to the standard deviations
% from the observed data
load('obsData/processedDataPS')

velRMSDiff(1:3) = processedData{waveNum}.rmsTransPS - rms(output.bodies(1).velocityPS(:,1:3));
velRMSDiff(4:6) = (processedData{waveNum}.rmsRotPS - rms(output.bodies(1).velocityPS(:,4:6)))*180/pi;
velRMSPercentDiff(1:3) = 100*(processedData{waveNum}.rmsTransPS - rms(output.bodies(1).velocityPS(:,1:3)))./processedData{waveNum}.rmsTransPS;
velRMSPercentDiff(4:6) = 100*(processedData{waveNum}.rmsRotPS - rms(output.bodies(1).velocityPS(:,4:6)))./processedData{waveNum}.rmsRotPS;

fprintf("RMS with respect to primary axis (Observed). \n Angle: %f \n RMS: %f, %f, %f, %f, %f, %f \n \n",processedData{waveNum}.meanWaveDirWS,processedData{waveNum}.rmsTransPS,processedData{waveNum}.rmsRotPS)

save ss1_res.mat

% % compare excitation force to Dom's calculations
% load('./obsData/excitationForce.mat')
% dofNames = {'Surge','Sway','Heave','Roll','Pitch','Yaw'};
% for ii = 1:6
%     figure()
%     plot(output.bodies(1).time,output.bodies(1).forceExcitation(:,ii))
%     hold on
%     plot(tVec,fExc(:,ii))
%     title(dofNames(ii))
%     ylabel('Excitation Force (N)')
%     xlabel('Time (s)')
%     legend('WEC-Sim Excitation', 'Dom Excitation')
% end

% disp('Observed STD')
% disp(processedData{1, waveNum}.NEDVelSTD)
% disp(processedData{1, waveNum}.NEDGyrVelSTD)
% disp('WEC-Sim STD')
% disp(std(output.bodies(1).velocityXY(startInd:end,:)))
% 
% disp('Observed - WEC-Sim')
% disp(processedData{1, waveNum}.NEDVelSTD - std(output.bodies(1).velocityXY(startInd:end,1:3)))
% disp(processedData{1, waveNum}.NEDGyrVelSTD - std(output.bodies(1).velocityXY(startInd:end,4:6)))
% disp('Observed - WEC-Sim (%)')
% disp(100*(processedData{1, waveNum}.NEDVelSTD - std(output.bodies(1).velocityXY(startInd:end,1:3)))./processedData{1, waveNum}.NEDVelSTD)
% disp(100*(processedData{1, waveNum}.NEDGyrVelSTD -std(output.bodies(1).velocityXY(startInd:end,4:6)))./processedData{1,waveNum}.NEDGyrVelSTD)
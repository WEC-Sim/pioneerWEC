% intentionally empty for now

load('./obsData/processedData.mat');

[~,startInd] = min(abs(100-output.bodies(1).time));

responsesData = ["NEDAcc","NEDVel","NEDPos"];
responsesDataGyr = ["NEDGyrAcc","NEDGyrVel","NEDGyrPos"];
responsesTime = ["","Vel","Pos"];
responsesWS = ["acceleration","velocity","position"];
DOFs = ["Surge", "Heave", "Pitch"];
DOFNums = [1 3 5];

for iResponse = 1:3
    for jDOF = 1:3
        figure()
        if DOFNums(jDOF) > 3
            plot(eval(strcat('processedData{waveNum}.NEDTime',responsesTime(iResponse))),eval(strcat('processedData{waveNum}.',responsesDataGyr(iResponse),'(:,',num2str(DOFNums(jDOF)-3),')')))
        else
            plot(eval(strcat('processedData{waveNum}.NEDTime',responsesTime(iResponse))),eval(strcat('processedData{waveNum}.',responsesData(iResponse),'(:,',num2str(DOFNums(jDOF)),')')))
        end
        hold on
        plot(output.bodies(1).time(startInd:end)-output.bodies(1).time(startInd),eval(strcat('output.bodies(1).',responsesWS(iResponse),'(startInd:end,',num2str(DOFNums(jDOF)),')')))
        xlabel('Time (s)')
        ylabel(strcat(DOFs(jDOF),' ',responsesWS(iResponse),' (m)'))
        legend('Observed Data','WEC-Sim')

    end
end


output.plotResponse(1,1)

figure()
plot(output.mooring.time,output.mooring.forceMooring)


% convert to x-y axes consistent with wave direction:
waveAngleN = 90-waves.direction;
output.bodies(1).positionXY = [output.bodies(1).position(:,1:3)*rotz(waveAngleN),output.bodies(1).position(:,4:6)*rotz(waveAngleN)];
output.bodies(1).velocityXY = [output.bodies(1).velocity(:,1:3)*rotz(waveAngleN),output.bodies(1).velocity(:,4:6)*rotz(waveAngleN)];
output.bodies(1).accelerationXY = [output.bodies(1).acceleration(:,1:3)*rotz(waveAngleN),output.bodies(1).acceleration(:,4:6)*rotz(waveAngleN)];

disp('Observed STD')
disp(processedData{1, waveNum}.NEDVelSTD)
disp(processedData{1, waveNum}.NEDGyrVelSTD)
disp('WEC-Sim STD')
disp(std(output.bodies(1).velocityXY(startInd:end,:)))

disp('Observed - WEC-Sim')
disp(processedData{1, waveNum}.NEDVelSTD - std(output.bodies(1).velocityXY(startInd:end,1:3)))
disp(processedData{1, waveNum}.NEDGyrVelSTD - std(output.bodies(1).velocityXY(startInd:end,1:3)))
disp('Observed - WEC-Sim (%)')
disp(100*(processedData{1, waveNum}.NEDVelSTD - std(output.bodies(1).velocityXY(startInd:end,1:3)))./processedData{1, waveNum}.NEDVelSTD)
disp(100*(processedData{1, waveNum}.NEDGyrVelSTD - std(output.bodies(1).velocityXY(startInd:end,4:6)))./processedData{1, waveNum}.NEDGyrVelSTD)
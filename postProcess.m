clear all
close all
clc

load('mcrResPCTSurgeAM.mat');
mcrSurgeAM = mcrOverall;
load('mcrResPCTHeaveAM.mat');
mcrHeaveAM = mcrOverall;

load('./realData_Jantzen/processedDataStd.mat');


% if exist('mcrOverall')
%     mcr = mcrOverall;
% end

processedPitchStd = [];
processedPitchVelStd = [];
heights = mcrSurgeAM.cases(:,1);
periods = mcrSurgeAM.cases(:,2);

for ii = 1:length(processedData)
    processedPitchStd(ii) = processedData(ii).posStd(5)*180/pi;
    % processedPitchVelStd(ii) = processedData(ii).velStd(5)*180/pi;
    processedHeaveStd(ii) = processedData(ii).posStd(3);
end

% plot pitch response vs. period
figure()
plot(periods, processedPitchStd,'ro')
hold on
plot(periods, mcrSurgeAM.posStd(:,5)*180/pi,'b*')
plot(periods, mcrHeaveAM.posStd(:,5)*180/pi,'g*')

xlabel('Peak Period (s)')
ylabel('Pitch Position STD (deg)')
legend('Observed Data','WEC-Sim (Surge AM)','WEC-Sim (Heave AM)')

% plot pitch response vs. height
figure()
plot(heights, processedPitchStd,'ro')
hold on
plot(heights, mcrSurgeAM.posStd(:,5)*180/pi,'b*')
plot(heights, mcrHeaveAM.posStd(:,5)*180/pi,'g*')

xlabel('Signicant Wave Height (m)')
ylabel('Pitch Position STD (deg)')
legend('Observed Data','WEC-Sim (Surge AM)','WEC-Sim (Heave AM)')

% plot pitch response vs. effective RAO
figure()
plot(periods, processedPitchStd'./heights,'ro')
hold on
plot(periods, mcrSurgeAM.posStd(:,5)*(180/pi)./heights,'b*')
plot(periods, mcrHeaveAM.posStd(:,5)*(180/pi)./heights,'g*')

xlabel('Peak Period (s)')
ylabel('Pitch Position STD / Wave Height (deg/m)')
legend('Observed Data','WEC-Sim (Surge AM)','WEC-Sim (Heave AM)')

% x = periods;
% y = heights;
% z = processedPitchStd';
% z2 = mcr.posStd(:,5)*180/pi;

% dt = delaunayTriangulation(x,y);
% tri = dt.ConnectivityList;
% 
% xi = dt.Points(:,1); 
% yi = dt.Points(:,2); 
% 
% F = scatteredInterpolant(x,y,z);
% F2 = scatteredInterpolant(x,y,z2);
% zi = F(xi,yi);
% zi2 = F2(xi,yi);
% 
% figure()
% trisurf(tri,xi,yi,zi) 
% hold on
% trisurf(tri,xi,yi,zi2) 
% xlabel('Peak Period (s)')
% ylabel('Significant Wave Height (m)')
% zlabel('Pitch Position STD (m)')
% legend('Observed Data','WEC-Sim')

heightsVec = .7:.1:4.1;
periodsVec = 3.5:.5:17;
pitchStdMatObs = zeros(length(periodsVec),length(heightsVec));
pitchStdMatWS_Surge = zeros(length(periodsVec),length(heightsVec));
pitchStdMatWS_Heave = zeros(length(periodsVec),length(heightsVec));
heaveStdMatObs = zeros(length(periodsVec),length(heightsVec));
heaveStdMatWS = zeros(length(periodsVec),length(heightsVec));
% pitchVelStdMatObs = zeros(length(periodsVec),length(heightsVec));
% pitchVelStdMatWS = zeros(length(periodsVec),length(heightsVec));

for ii = 1:length(heights)
    [~, indHeights] = min(abs(heights(ii)-heightsVec));
    [~, indPeriods] = min(abs(periods(ii)-periodsVec));
    pitchStdMatObs(indPeriods,indHeights) = processedPitchStd(ii);
    pitchStdMatWS_Surge(indPeriods,indHeights) = mcrSurgeAM.posStd(ii,5)*180/pi;
    pitchStdMatWS_Heave(indPeriods,indHeights) = mcrHeaveAM.posStd(ii,5)*180/pi;
    
    % heaveStdMatObs(indPeriods,indHeights) = processedHeaveStd(ii);
    % heaveStdMatWS(indPeriods,indHeights) = mcr.posStd(ii,3);
    % pitchVelStdMatObs(indPeriods,indHeights) = processedPitchVelStd(ii);
    % pitchVelStdMatWS(indPeriods,indHeights) = mcr.velStd(ii,5)*180/pi;
end

pitchStdMatObs(pitchStdMatObs==0) = NaN;
pitchStdMatWS_Surge(pitchStdMatWS_Surge==0) = NaN;
pitchStdMatWS_Heave(pitchStdMatWS_Heave==0) = NaN;
% heaveStdMatObs(heaveStdMatObs==0) = NaN;
% heaveStdMatWS(heaveStdMatWS==0) = NaN;

figure()
h = heatmap(periodsVec,heightsVec,pitchStdMatObs','MissingDataColor',[1 1 1]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('Observed Pitch STD (deg)')

figure()
h = heatmap(periodsVec,heightsVec,pitchStdMatWS_Surge','MissingDataColor',[1 1 1]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('WEC-Sim Pitch STD (deg) - Surge AM')

figure()
h = heatmap(periodsVec,heightsVec,pitchStdMatWS_Heave','MissingDataColor',[1 1 1]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('WEC-Sim Pitch STD (deg) - Heave AM')

figure()
h = heatmap(periodsVec,heightsVec,100*(pitchStdMatWS_Surge' - pitchStdMatWS_Heave')./pitchStdMatWS_Surge','MissingDataColor',[1 1 1]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('WEC-Sim Pitch STD difference () - Surge vs. Heave AM')

minColor = min([100*(pitchStdMatWS_Surge'-pitchStdMatObs')./pitchStdMatObs';100*(pitchStdMatWS_Heave'-pitchStdMatObs')./pitchStdMatObs'],[],'all');
maxColor = max([100*(pitchStdMatWS_Surge'-pitchStdMatObs')./pitchStdMatObs';100*(pitchStdMatWS_Heave'-pitchStdMatObs')./pitchStdMatObs'],[],'all');

figure()
h = heatmap(periodsVec,heightsVec,100*(pitchStdMatWS_Surge'-pitchStdMatObs')./pitchStdMatObs','MissingDataColor',[1 1 1],'ColorLimits',[minColor maxColor]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
h.Colormap = cool;
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('Pitch STD % Difference (WEC-Sim - Observed (Surge AM))')

figure()
h = heatmap(periodsVec,heightsVec,100*(pitchStdMatWS_Heave'-pitchStdMatObs')./pitchStdMatObs','MissingDataColor',[1 1 1],'ColorLimits',[minColor maxColor]);
h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
h.Colormap = cool;
xlabel('Wave Peak Period (s)')
ylabel('Significant Wave Height (m)')
title('Pitch STD % Difference (WEC-Sim - Observed (Heave AM))')

% figure()
% h = heatmap(periodsVec,heightsVec,heaveStdMatWS'-heaveStdMatObs','MissingDataColor',[1 1 1]);
% h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
% h.Colormap = cool;
% xlabel('Wave Peak Period (s)')
% ylabel('Significant Wave Height (m)')
% title('Heave STD Difference (WEC-Sim - Observed)')

% 
% figure()
% h = heatmap(periodsVec,heightsVec,pitchVelStdMatWS'-pitchVelStdMatObs','MissingDataColor',[1 1 1]);
% h.Colormap = cool;
% xlabel('Significant Wave Height (m)')
% ylabel('Wave Peak Period (s)')
% title('Pitch Velocity STD Difference (WEC-Sim - Observed)')
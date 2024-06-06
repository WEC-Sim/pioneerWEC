close all

processedPitchStd = [];
processedPitchVelStd = [];

for ii = 1:length(processedData)
    processedHeaveStd(ii) = processedData(ii).posStd(3);
    processedPitchStd(ii) = processedData(ii).posStd(5)*180/pi;
    % processedPitchVelStd(ii) = processedData(ii).velStd(5)*180/pi;
end

if exist('mcrOverall')
    mcr = mcrOverall;
end

heights = unique(mcr.cases(:,1));
periods = unique(mcr.cases(:,2));
aboveWaterMass = mcr.cases(:,3);
cdSurge = mcr.cases(:,4);
cdHeave = mcr.cases(:,5);
cdPitch = mcr.cases(:,6);

% make list of non-height and non-period variables
[~, indCases] = unique(mcr.cases(:,3:6),"rows");
indCasesDiff = indCases(2) - indCases(1);

% for all non-height and non-period variables
for ii = 1:length(indCases)
    
    % plot pitch response vs. period
    figure()
    plot(periods, processedPitchStd,'ro')
    hold on
    plot(periods, mcr.posStd(indCases(ii):indCases(ii)+indCasesDiff-1,5)*180/pi,'b*')
    
    xlabel('Peak Period (s)')
    ylabel('Pitch Position STD (deg)')
    legend('Observed Data','WEC-Sim')
    
    % plot pitch response vs. height
    figure()
    plot(heights, processedPitchStd,'ro')
    hold on
    plot(heights, mcr.posStd(indCases(ii):indCases(ii)+indCasesDiff-1,5)*180/pi,'b*')
    
    xlabel('Signicant Wave Height (m)')
    ylabel('Pitch Position STD (deg)')
    legend('Observed Data','WEC-Sim')
    
    % plot pitch response vs. effective RAO
    figure()
    plot(periods, processedPitchStd'./heights,'ro')
    hold on
    plot(periods, mcr.posStd(indCases(ii):indCases(ii)+indCasesDiff-1,5)*(180/pi)./heights,'b*')
    
    xlabel('Peak Period (s)')
    ylabel('Pitch Position STD / Wave Height (deg/m)')
    legend('Observed Data','WEC-Sim')
    
    x = periods;
    y = heights;
    z = processedPitchStd';
    z2 = mcr.posStd(indCases(ii):indCases(ii)+indCasesDiff-1,5)*180/pi;
    
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
    pitchStdMatWS = zeros(length(periodsVec),length(heightsVec));
    heaveStdMatObs = zeros(length(periodsVec),length(heightsVec));
    heaveStdMatWS = zeros(length(periodsVec),length(heightsVec));
    % pitchVelStdMatObs = zeros(length(periodsVec),length(heightsVec));
    % pitchVelStdMatWS = zeros(length(periodsVec),length(heightsVec));
    
    for ii = 1:length(heights)
        [~, indHeights] = min(abs(heights(jj)-heightsVec));
        [~, indPeriods] = min(abs(periods(jj)-periodsVec));
        pitchStdMatObs(indPeriods,indHeights) = processedPitchStd(jj);
        pitchStdMatWS(indPeriods,indHeights) = mcr.posStd(indCases(ii)+jj,5)*180/pi;
        
        heaveStdMatObs(indPeriods,indHeights) = processedHeaveStd(jj);
        heaveStdMatWS(indPeriods,indHeights) = mcr.posStd(jj,3);
        % pitchVelStdMatObs(indPeriods,indHeights) = processedPitchVelStd(ii);
        % pitchVelStdMatWS(indPeriods,indHeights) = mcr.velStd(ii,5)*180/pi;
    end
    
    pitchStdMatObs(pitchStdMatObs==0) = NaN;
    pitchStdMatWS(pitchStdMatWS==0) = NaN;
    heaveStdMatObs(heaveStdMatObs==0) = NaN;
    heaveStdMatWS(heaveStdMatWS==0) = NaN;
    
    figure()
    h = heatmap(periodsVec,heightsVec,pitchStdMatObs','MissingDataColor',[1 1 1]);
    h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
    xlabel('Wave Peak Period (s)')
    ylabel('Significant Wave Height (m)')
    title('Observed Pitch STD (deg)')
    
    figure()
    h = heatmap(periodsVec,heightsVec,pitchStdMatWS','MissingDataColor',[1 1 1]);
    h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
    xlabel('Wave Peak Period (s)')
    ylabel('Significant Wave Height (m)')
    title('WEC-Sim Pitch STD (deg)')
    
    figure()
    h = heatmap(periodsVec,heightsVec,100*(pitchStdMatWS'-pitchStdMatObs')./pitchStdMatObs','MissingDataColor',[1 1 1]);
    h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
    h.Colormap = cool;
    xlabel('Wave Peak Period (s)')
    ylabel('Significant Wave Height (m)')
    title('Pitch STD % Difference (WEC-Sim - Observed)')
    
    figure()
    h = heatmap(periodsVec,heightsVec,heaveStdMatWS'-heaveStdMatObs','MissingDataColor',[1 1 1]);
    h.NodeChildren(3).YDir='normal';                   % turn Y-Axis normal direction
    h.Colormap = cool;
    xlabel('Wave Peak Period (s)')
    ylabel('Significant Wave Height (m)')
    title('Heave STD Difference (WEC-Sim - Observed)')
    
    % 
    % figure()
    % h = heatmap(periodsVec,heightsVec,pitchVelStdMatWS'-pitchVelStdMatObs','MissingDataColor',[1 1 1]);
    % h.Colormap = cool;
    % xlabel('Significant Wave Height (m)')
    % ylabel('Wave Peak Period (s)')
    % title('Pitch Velocity STD Difference (WEC-Sim - Observed)')

end
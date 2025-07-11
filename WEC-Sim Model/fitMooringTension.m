% Dominic D. Forbush
% fits mooring tension model for series of 2 distinct mooring tethers
clear; close all;
% fit tolerance
tol = .001; % error allowance for equivalent tension between polynomial fits (N)
endHappened = 0;
startHappened =0; 
%% first tether 15 m
tpoly1=[21000 0 -12500 7500 0]; %%% UNITS N
strain1 = [0:0.0001:1]; % 1001 points from 0 to 100% strain
tens1= polyval(tpoly1,strain1);
L1= 15; % m

%% second tether 19.8m
tpoly2=[18000 0 -14500 8500 0]; %%% UNITS N
strain2 = strain1; % 1001 points from 0 to 100% strain (match number of points)
tens2= polyval(tpoly2,strain1);
L2=19.8; % m

%% check figures
figure; clf;
plot(strain1,tens1,'b','LineWidth',1.4)
hold on; grid on;
plot(strain2,tens2,'--r','LineWidth',1.4)
xlabel('\epsilon')
ylabel('T (N)')
%% evaluate which polynomial sees larges tension
maxT1 = max(tens1);
maxT2 = max(tens2);

%% loop through strain for largest vector, find strain2 where tens1=tens2
if maxT1 > maxT2
    iter = tens1;
    vec = tens2;
    iterL=15;
    vecL = 19.8;
else
    iter = tens2;
    vec = tens1;
    iterL=19.8;
    vecL = 15;
end

for k=1:length(strain1)
    [res,idx]=min(abs(iter(k)-vec)); % find closest tension value in vec
    if idx == length(strain1)
        break
    end
    if res > tol % if nothing is close enough, interpolate to find strain value that gives equal tension
        warning('Large residual for point %i. Interpolating \n \r',k)
        if k > 1 && k < length(strain1) % midpoint approx wherever possible
            linFit = polyfit([vec(idx-1),vec(idx),vec(idx+1)],[strain1(idx-1), strain1(idx), strain1(idx+1)],1);
        elseif k==length(strain1) % right endpoint approx at right end
            linFit = polyfit([vec(idx-1),vec(idx)],[strain1(idx-1), strain1(idx)],1);
            endHappened =1;
        else % left endpoint approx at start
            linFit = polyfit([vec(idx),vec(idx+1)],[strain1(idx), strain1(idx+1)],1);
            startHappened = 1;
        end
        outStr(k) = polyval(linFit,iter(k));  % interpolate to find strain value giving equal tension
        methodFlag(k)=1;
    else
        outStr(k) = strain1(idx);
        methodFlag(k)=0;
    end
    totStr(k)= ((strain1(k) * iterL) + (outStr(k) * vecL))/(iterL + vecL) ;
    tensOut(k) = iter(k);
end

%% fit polynomial to output tension vs. total strain
outPoly = polyfit(totStr,tensOut,4) % 4th order because the others were?

% add to check plot
plot(totStr,tensOut,'k*')
plot(totStr,polyval(outPoly,totStr),'--k','LineWidth',1.2)
legend('Tether 1','Tether2','Tether series','Tether Series fit')

%% check series plot w/ actual length: series spring should be weaker than both others

origPoly = [15000 0 -15000 9200 0]

figure; clf;
plot(L1*(strain1), polyval(tpoly1,strain1));
hold on; grid on;
plot(L2*(strain1), polyval(tpoly2,strain1));
plot((L1+L2)*(strain1), polyval(outPoly,strain1));
plot(20.5*strain1,polyval(origPoly,strain1));
xlabel('Elongation (m)')
ylabel('Tension')
legend('T1','T2','T1 series with T2', 'Orig Model')




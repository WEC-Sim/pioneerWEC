clear
close all
clc

load ss1_res.mat

dofs = {'surge','sway','heave','roll','pitch','yaw'};

figure()
for ii = 1:6
    subplot(2,3,ii)
    plot(output.bodies(1).time,output.bodies(1).forceRadiationDamping(:,ii))
    hold on
    plot(output.bodies(1).time,output.bodies(1).forceMorisonAndViscous(:,ii),'--')
    xlim([1000, 1050])
    xlabel('Time (s)')
    ylabel('Force (N)')
    title(dofs(ii))
    if ii == 6
        legend('Radiation damping','Quadratic drag')
    end
end

figure()
for ii = 1:6
    subplot(2,3,ii)
    plot(output.bodies(1).time,output.bodies(1).forceRestoring(:,ii))
    hold on
    plot(output.bodies(1).time,output.ptos(1).forceConstraint(:,ii)+output.ptos(1).forceInternalMechanics(:,ii),'--')
    xlim([1000, 1050])
    xlabel('Time (s)')
    ylabel('Force (N)')
    title(dofs(ii))
    if ii == 6
        legend('Restoring force','Force from cable')
    end
end

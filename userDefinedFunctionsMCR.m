%% User Defined Functions for MCR run

% find 100 s
[~,startInd] = min(abs(100-output.bodies(1).time));

mcr.posStd(imcr,:) = std(output.bodies(1).position(startInd:end,:));
mcr.velStd(imcr,:) = std(output.bodies(1).velocity(startInd:end,:));
mcr.forceStd(imcr,:) = std(output.bodies(1).forceTotal(startInd:end,:));

if imcr == length(mcr.cases)
    %save(filename)
    save('mcrResPCT.mat')
end

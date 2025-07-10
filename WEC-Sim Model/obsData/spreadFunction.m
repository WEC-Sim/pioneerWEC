function energyDist = spreadFunction(dirVec, S)

energyDist = (1/(S.*sqrt(2*pi))) .* exp(-(dirVec.^2) ./ (2.*S.^2));

end

close all

output.plotResponse(1,1)
output.plotResponse(1,2)
output.plotResponse(1,3)
output.plotResponse(1,4)
output.plotResponse(1,5)
output.plotResponse(1,6)

figure()
plot(moorDisp)
xlabel('time (s)')
ylabel('mooring displacement (m)')

figure()
plot(moorTens)
xlabel('time (s)')
ylabel('mooring tension (N)')
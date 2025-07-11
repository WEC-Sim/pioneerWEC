%% Simulation Data
simu = simulationClass();                    % Initialize Simulation Class
simu.simMechanicsFile = 'pioneerSNL.slx';    % Specify Simulink Model File
simu.mode      = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
simu.explorer  = 'on';                       % Turn SimMechanics Explorer (on/off)
simu.startTime = 0;                          % Simulation Start Time [s]
simu.endTime   = 1000;                       % Simulation End Time [s]
simu.rampTime  = 0.05*simu.endTime;          % Wave Ramp Time [s]
simu.solver    = 'ode23t';                   % simu.solver = 'ode4' for fixed step & simu.solver = 'ode45' for variable step 
simu.dt        = 0.1; 					  	 % Simulation time-step [s]
simu.cicEndTime = 30;
simu.mcrMatFile = 'mcrCases.mat';

%% Wave Information 

waveNum = 1;

snips = [197 422 141 332];
waveDirs = wrapTo360([-108.3115   52.1207  -74.4436   96.5309]);
waveFiles = ["obsData/dirSpectrum_197.mat" "obsData/dirSpectrum_422.mat" "obsData/dirSpectrum_141.mat" "obsData/dirSpectrum_332.mat"];

waves = waveClass('spectrumImportFullDir');
waves.direction = waveDirs(waveNum); 
waves.spectrumFile = (waveFiles(waveNum));
waves.freqDepDirection.nBins = 10; % for example
waves.freqDepDirection.spreadRange = 2; % for example
waves.waterDepth = 30;
waves.phaseSeed = 1;

waves.current.option = 1;
waves.current.speed = .05;
waves.current.direction = 270;

% % Regular waves - run MCR for RAO
% waves = waveClass('regularCIC');           % Initialize Wave Class and Specify Type
% waves.height = .5;                       % Significant Wave Height [m]
% waves.period = 2:.25:10;                         % Peak Period [s]
% waves.waterDepth = 30;
% waves.direction = 0;

%% initial position (as a result of mooring scope)
L0 = 15+19.8;
surgeDisp = sqrt(L0^2 - 20.5^2);
xLoc = surgeDisp*cosd(waves.direction); 
yLoc = surgeDisp*sind(waves.direction);

%% Body Data
% Float
body(1)              = bodyClass('./hydroData/pioneer.h5');  
body(1).geometryFile = './geometry/pnr_with_box.stl';    
body(1).mass         = 3747;                        % provided mass
body(1).inertia      = [7484 7484 1500];            % provided inertia
body(1).quadDrag.area = [2.5553 2.5553 8.5634 8.5634 8.5634 1.0768]; % projected areas
cdSurge = 6;
cdHeave = 0.5;
cdPitch = 1.5;
cdYaw = 8;
body(1).quadDrag.cd = [cdSurge, cdSurge, cdHeave, cdPitch, cdPitch, cdYaw]; % tuned quadratic drag
body(1).meanDrift = 2;                              % mean drift on
body(1).initial.displacement = [xLoc, yLoc, 0];     % initial location
body(1).yaw.option = 1;                             % passive yaw on
body(1).yaw.threshold = 2;

aboveWaterMass = 0; % kg, above water mass, 1 m above CG (does NOT affect hydrostatics)
aboveWaterMassLoc = [xLoc yLoc 1]; 

% NSIF
body(2)              = bodyClass('');        
body(2).geometryFile = './geometry/NSIF.stl';  
body(2).nonHydro = 2;                               % this is a DRAG body
body(2).mass         = 320 + 1.2416*1000;           % static mass + added from BEM
body(2).volume       = (160 + 1.2416*1000)/1025;    % Calculated from static wet mass + added in heave
body(2).inertia      = [243.3997 + 216.043,  243.3997 + 216.043, 59.7314 + 0.266]; % inertia dry mass assuming uniform cylinder + added mass 
body(2).centerGravity = [0,0,-8];                   % provided from deployment geometry
body(2).centerBuoyancy = [0,0,-7];                  % assumed to make statically stable: note not filled geometry so we don't have good a priori
body(2).quadDrag.area = [3.0192 3.0192 2.3888 3.0192 3.0192 10]; % Uses projected areas of NSIF
body(2).quadDrag.cd = 0.5 .* ones([1,6]);           % values used in a Proteus DS simulation
body(2).hydroStiffness = zeros(6);
body(2).hydroStiffness(3:end,3:end) = [1.0990e-07, 2.4357e-04, -4.6197e-05, 0; 
                                        2.4357e-04, -0.8268, -1.8562e-04, 0;
                                        -4.6197e-05, -1.8562e-04, -0.8270, 0;
                                        0, 0, 0, 0.9950]; % added stiffness manually
body(2).initial.displacement = [xLoc, yLoc, 0];     % initial location

% cable type bodies
body(3) = bodyClass('');
body(3).geometryFile = './geometry/sphere_out.stl';
body(3).nonHydro = 2;                               % drag body
body(3).quadDrag.area = 2 * 0.0254 .* ones([1,6]);  % approximated as 2m cylinder of 1" diameter
body(3).quadDrag.area(6) = 20* 2 * 0.0254;
body(3).quadDrag.cd = ones([1,6]);
body(3).volume = 4*pi*0.0127^2;                     % these are assumed 1" steel cable (density 7850 kg/m^3)
body(3).mass = body(3).volume .*7850;               % these are assumed 1" steel cable, lumped capacitance
body(3).centerGravity = [0,0,-2.686975];            % the top half of the cable
body(3).centerBuoyancy = [0,0,-2.686975];
body(3).inertia = [(1/12)*body(3).mass * (3*0.0127^2 + 2) (1/12)*body(3).mass * (3*0.0127^2 + 2) ...
    (1/2)*body(3).mass * 0.0127^2];
body(3).initial.displacement = [xLoc, yLoc, 0];     % initial location

body(4) = bodyClass('');
body(4).geometryFile = './geometry/sphere_out.stl';
body(4).nonHydro = 2;
body(4).quadDrag.area = 20*2 * 0.0254 .* ones([1,6]);
body(4).quadDrag.cd = ones([1,6]);
body(4).quadDrag.area(6) = 20* 2 * 0.0254;
body(4).volume = 4*pi*0.0127^2;                                 % these are assumed 1" steel cable
body(4).mass = body(4).volume .*7850;                           % these are assumed 1" steeel cable, lumped capacitance 
body(4).centerGravity = [0,0,-5.562325];                               % the bottom half of the cable
body(4).centerBuoyancy = [0,0,-5.562325];
body(4).inertia = [(1/12)*body(4).mass * (3*0.0127^2 + 2) (1/12)*body(4).mass * (3*0.0127^2 + 2) ...
    (1/2)*body(4).mass * 0.0127^2];
body(4).initial.displacement = [xLoc, yLoc, 0];     % initial location

%% PTO and Constraint Parameters
% Floating (6DOF) Joint
constraint(1) = constraintClass('Constraint1'); % Initialize Constraint Class for Constraint1
constraint(1).location = [0 0 -30];               % Constraint Location [m]

% all rotational or spherical elements that accomodate cable displacement
% will have SOME damping and stiffness in reality but will be small (note
% fluid drag is intended to be handled by the cable bodies above. This must
% be NONZERO to avoid the "strumming" mode, aka a snap-through instability
% at zero crossings of PTO displacement.
% don't make this too large though or the cable will support compression!
jointDamping = 10;
jointStiffness = 1;

pto(1) = ptoClass('pto1');
pto(1).damping = jointDamping;
pto(1).stiffness = jointStiffness;
pto(1).location = [0 0 -1.2493]; % bottom of instrumentation cage based on engineering drawing
pto(1).initial.displacement = [xLoc, yLoc, 0];

pto(2) = ptoClass('pto2');
pto(2).damping = jointDamping;
pto(2).stiffness = jointStiffness;
pto(2).location = [0 0 -4.12465]; % somewhere in the middle of the cable, between the two body elements above
pto(2).initial.displacement = [xLoc, yLoc, 0];

pto(3) = ptoClass('pto3');
pto(3).damping = jointDamping;
pto(3).stiffness = jointStiffness;
pto(3).location = [0 0 -7]; % assumed attached to approx top of NSIF
pto(3).initial.displacement = [xLoc, yLoc, 0];

%%
% mooring 
mooring(1)  = mooringClass('mooring');
mooring(1).location = [0.0 0.0 -9.500]; % assumed attached to approx bottom of NSIF
mooring(1).initial.displacement = [xLoc, yLoc, 0];
L0 = 15+19.8; % equilibrium length
polyNom = 1.0e+04*[1.9488   -0.0390   -1.3588    0.8094   -0.0004]; % polynomial definition

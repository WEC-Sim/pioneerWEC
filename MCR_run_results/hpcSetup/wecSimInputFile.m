%% Simulation Data
simu = simulationClass();                    % Initialize Simulation Class
% Specify Simulink Model File
simu.simMechanicsFile = 'pioneerSNL.slx';  
simu.mode      = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
simu.explorer  = 'off';                       % Turn SimMechanics Explorer (on/off)
simu.startTime = 0;                          % Simulation Start Time [s]
simu.endTime   = 1300;                      % Simulation End Time [s]
simu.rampTime  = 0.05*simu.endTime;           % Wave Ramp Time [s]
%%% Note from Dom: ode23t or other mod stiff tends to work better with the inverse trig
%%% functions in custom mooring and the cable approximation. 
simu.solver    = 'ode23t';                    % simu.solver = 'ode4' for fixed step & simu.solver = 'ode45' for variable step 
simu.dt        = 0.05; 					  	 % Simulation time-step [s]
simu.cicEndTime = 30;
simu.mcrMatFile = 'mcrCases.mat';

%% Wave Information 

% % Irregular Waves using JS Spectrum with Equal Energy and Seeded Phase
% waves = waveClass('irregular');           % Initialize Wave Class and Specify Type
% waves.height = 1.5;                       % Significant Wave Height [m]
% waves.period = 7.7;                         % Peak Period [s]
% waves.spectrumType = 'JS';                % Specify Wave Spectrum Type
% waves.bem.option = 'EqualEnergy';         % Uses 'EqualEnergy' bins (default) 
% waves.phaseSeed = 1;                      % Phase is seeded so eta is the same
% waves.waterDepth = 30;
% waves.direction = [320, 0 20];
% waves.spread = [.1, .5, .4];
% waves.current.option = 1;
% waves.current.speed = .05;

addpath('obsData')
waveNum = 1;
waveFiles = {'obsData/spectrumFile197.mat' 'obsData/spectrumFile422.mat' 'obsData/spectrumFile141.mat' 'obsData/spectrumFile332.mat'};
waveDirs = [252.0421   56.5412  285.4639   97.5443];

waves = waveClass('spectrumImport');      % Create the Wave Variable and Specify Type
waves.spectrumFile = string(waveFiles(waveNum));  % Name of User-Defined Spectrum File 202 313 349 419
waves.direction = waveDirs(waveNum); % 240.9309   48.4308  107.6652  108.3043
waves.waterDepth = 30;
waves.phaseSeed = 1;                      % Phase is seeded so eta is the same

excFiles = {'obsData/excitationForceWave1.mat' 'obsData/excitationForceWave2.mat' 'obsData/excitationForceWave3.mat' 'obsData/excitationForceWave4.mat'};
load(string(excFiles(waveNum)));

% Regular waves
% waves = waveClass('regularCIC');           % Initialize Wave Class and Specify Type
% waves.height = 1;                       % Significant Wave Height [m]
% waves.period = 8; %:.25:10;                         % Peak Period [s]
% waves.waterDepth = 30;
% waves.direction = 0;

waves.current.option = 1;
waves.current.speed = .05;
waves.current.direction = 270;

%% Body Data
% Float
body(1)              = bodyClass('./hydrodata_SNL/wamitIRR1L1PCGCubitv2/wec_and_nsif_clean_cb_corrected.h5');  
% this h5 file is cleaned BEM EXCEPT:
% Body 1 CB adjusted based upon buoy diagram because the box modeled in BEM as
% solid geometry
% hydrostatic stiffness = 1000 N*m/rad added for each body in YAW

% calculate the flooded box mass and inertia
boxVol = 1.3557^2*0.7493;
boxMass = boxVol*1025;
cgToBox = 1.016 - .218 + .7493/2;
boxInertia = boxMass*cgToBox;

% body(1).geometryFile = './geometry/float.stl';    
body(1).mass         = 3747; %'equilibrium';   +boxMass            
body(1).inertia      = [7484 7484 1025*7.6135596];  % provided inertia in roll/pitch...unsure about yaw inertia +boxInertia
body(1).quadDrag.area = [2.5553 2.5553 8.5634 8.5634 8.5634 1.0768];
cdSurge = 4;
cdHeave = 0.5;
cdPitch = 1;
body(1).quadDrag.cd = [cdSurge, cdSurge, cdHeave, cdPitch, cdPitch, 0.5];
body(1).meanDrift = 2;

aboveWaterMass = 20; % kg, above water mass, 1 m above CG (does NOT affect hydrostatics)
aboveWaterMassLoc = [0 0 1]; %30*tan(mooringAngle)

% NSIF
body(2)              = bodyClass('');        
% body(2).geometryFile = './geometry/NSIF.stl';  
body(2).nonHydro = 2;                               % this is a DRAG body)
% body(2).mass         = 320;     % static mass + added from BEM
% body(2).volume       = 160/1025; % Calculated from static wet mass + added in heave
body(2).mass         = 320 + 1.2416*1000;     % static mass + added from BEM
body(2).volume       = (160 + 1.2416*1000)/1025; % Calculated from static wet mass + added in heave
%body(2).centerBuoyancy = body(2).centerGravity + [0 0 1];
body(2).inertia      = [243.3997 + 216.043,  243.3997 + 216.043, 59.7314 + 0.266]; % inertia dry mass assuming uniform cylinder + added mass 
body(2).centerGravity = [0,0,-8];                                % provided from deployment geometry
body(2).centerBuoyancy = [0,0,-7];                               % assumed to make statically stable: note not filled geometry so we don't have good a priori
body(2).quadDrag.area = [3.0192 3.0192 2.3888 3.0192 3.0192 10]; % Uses projected areas of NSIF
body(2).quadDrag.cd = 0.5 .* ones([1,6]);                       % values used in a Proteus DS simulation
% body(2).quadDrag.cd(1:3) = 0;                       % values used in a Proteus DS simulation
body(2).hydroStiffness = zeros(6);
body(2).hydroStiffness(3:end,3:end) = [1.0990e-07, 2.4357e-04, -4.6197e-05, 0; 
                                        2.4357e-04, -0.8268, -1.8562e-04, 0;
                                        -4.6197e-05, -1.8562e-04, -0.8270, 0;
                                        0, 0, 0, 0.9950];

% body(2).morisonElement.option = 1;  
% body(2).morisonElement.cd = [0.5; 0.5; 0.5].';
% % body(2).morisonElement.ca = [1.9405 1.9405 1.2416];
% body(2).morisonElement.ca = [0 0 1.2416-1.9405];% 
% body(2).morisonElement.VME = body(2).volume;
% body(2).morisonElement.area = [3.0192 3.0192 2.3888];
% TODO: Add morison element CA/CD for surge and heave to bring in the added
% mass contribution.

% cable type bodies
% NOTE: the mass of the added cable elements DOES affect hydrostatics,but
% this effect is small. 
body(3) = bodyClass('');
% body(3).geometryFile = './geometry/sphere_out.stl';
body(3).nonHydro = 2;
body(3).quadDrag.area = 2 * 0.0254 .* ones([1,6]); % approxd as 2m cylinder of 1" diameter
body(3).quadDrag.area(6) = 20* 2 * 0.0254;
%body(3).quadDrag.area(6) = 0; % no drag in yaw
body(3).quadDrag.cd = ones([1,6]);
body(3).volume = 4*pi*0.0127^2;                                 % these are assumed 1" steel cable (density 7850 kg/m^3)
body(3).mass = body(3).volume .*7850;                           % these are assumed 1" steel cable, lumped capacitance
body(3).centerGravity = [0,0,-2.686975];                               % the top half of the cable
body(3).centerBuoyancy = [0,0,-2.686975];
body(3).inertia = [(1/12)*body(3).mass * (3*0.0127^2 + 2) (1/12)*body(3).mass * (3*0.0127^2 + 2) ...
    (1/2)*body(3).mass * 0.0127^2];

body(4) = bodyClass('');
% body(4).geometryFile = './geometry/sphere_out.stl';
body(4).nonHydro = 2;
body(4).quadDrag.area = 20*2 * 0.0254 .* ones([1,6]);
%body(4).quadDrag.area(6) = 0;
body(4).quadDrag.cd = ones([1,6]);
body(4).quadDrag.area(6) = 20* 2 * 0.0254;
body(4).volume = 4*pi*0.0127^2;                                 % these are assumed 1" steel cable
body(4).mass = body(4).volume .*7850;                           % these are assumed 1" steeel cable, lumped capacitance 
body(4).centerGravity = [0,0,-5.562325];                               % the bottom half of the cable
body(4).centerBuoyancy = [0,0,-5.562325];
body(4).inertia = [(1/12)*body(4).mass * (3*0.0127^2 + 2) (1/12)*body(4).mass * (3*0.0127^2 + 2) ...
    (1/2)*body(4).mass * 0.0127^2];

%% PTO and Constraint Parameters
% Floating (6DOF) Joint
constraint(1) = constraintClass('Constraint1'); % Initialize Constraint Class for Constraint1
constraint(1).location = [0 0 -30];               % Constraint Location [m]

% cable element ptos

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

pto(2) = ptoClass('pto2');
pto(2).damping = jointDamping;
pto(2).stiffness = jointStiffness;
pto(2).location = [0 0 -4.12465]; % somewhere in the middle of the cable, between the two body elements above

pto(3) = ptoClass('pto3');
pto(3).damping = jointDamping;
pto(3).stiffness = jointStiffness;
pto(3).location = [0 0 -7]; % assumed attached to approx top of NSIF

%%
% pioneersim.moorK    = 2e2;
% pioneersim.moorC    = 1e3;
mooring(1)  = mooringClass('mooring');
mooring(1).location = [0.0 0.0 -9.500]; % assumed attached to approx bottom of NSIF

% mooring 
L0 = 15+19.8; % equilibrium length: make sure this is mooring.location + waves.waterDepth
polyNom = 1.0e+04*[1.9488   -0.0390   -1.3588    0.8094   -0.0004]; % polynomial definition

% initial position (as a result of mooring scope) - this is overridden in initializeWecSim when the mcr is loaded in
surgeDisp = sqrt(L0^2 - 20.5^2);
xLoc = surgeDisp*cosd(waveDirs(waveNum));
yLoc = surgeDisp*sind(waveDirs(waveNum));

% set initial displacement for bodies, ptos, and moorings
body(1).initial.displacement = [xLoc, yLoc, 0];
body(2).initial.displacement = [xLoc, yLoc, 0];
body(3).initial.displacement = [xLoc, yLoc, 0];
body(4).initial.displacement = [xLoc, yLoc, 0];
pto(1).initial.displacement = [xLoc, yLoc, 0];
pto(2).initial.displacement = [xLoc, yLoc, 0];
pto(3).initial.displacement = [xLoc, yLoc, 0];
mooring(1).initial.displacement = [xLoc, yLoc, 0];
aboveWaterMassLoc = [xLoc yLoc 1];

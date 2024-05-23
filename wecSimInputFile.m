%% Simulation Data
simu = simulationClass();                    % Initialize Simulation Class
% Specify Simulink Model File
simu.simMechanicsFile = 'pioneerSNL.slx';  
simu.mode      = 'normal';                   % Specify Simulation Mode ('normal','accelerator','rapid-accelerator')
simu.explorer  = 'on';                       % Turn SimMechanics Explorer (on/off)
simu.startTime = 0;                          % Simulation Start Time [s]
simu.endTime   = 300;                      % Simulation End Time [s]
simu.rampTime  = 0.05*simu.endTime;           % Wave Ramp Time [s]
%%% Note from Dom: ode23t or other mod stiff tends to work better with the inverse trig
%%% functions in custom mooring and the cable approximation. 
simu.solver    = 'ode23t';                    % simu.solver = 'ode4' for fixed step & simu.solver = 'ode45' for variable step 
simu.dt        = 0.05; 					  	 % Simulation time-step [s]
simu.cicEndTime = 30;

%% Wave Information 

% % Irregular Waves using JS Spectrum with Equal Energy and Seeded Phase
waves = waveClass('irregular');           % Initialize Wave Class and Specify Type
waves.height = 2;                       % Significant Wave Height [m]
waves.period = 8;                         % Peak Period [s]
waves.spectrumType = 'JS';                % Specify Wave Spectrum Type
waves.bem.option = 'EqualEnergy';         % Uses 'EqualEnergy' bins (default) 
waves.phaseSeed = 1;                      % Phase is seeded so eta is the same
waves.waterDepth = 30;


%% Body Data
% Float
body(1)              = bodyClass('../hydrodata_SNL/wamitIRR1L1PCGCubit/wec_and_nsif_cubit_clean.h5');  
% this h5 file is cleaned BEM EXCEPT:
% Body 1 CB adjusted based upon buoy diagram because the box modeled in BEM as
% solid geometry
% hydrostatic stiffness = 1000 N*m/rad added for each body in YAW
body(1).geometryFile = '../geometry/float.stl';    
body(1).mass         = 'equilibrium';                   
body(1).inertia      = [7484 7484 1025*7.6135596];  % provided inertia in roll/pitch...unsure about yaw inertia
%body(1).centerBuoyancy = [0 0 -0.5301];
aboveWaterMass = 100; % kg, above water mass, 1 m above CG (does NOT affect hydrostatics)
body(1).quadDrag.area = ones([1,6]);
body(1).quadDrag.cd = 0.5 * ones([1,6]);

% NSIF
body(2)              = bodyClass('');        
body(2).geometryFile = '../geometry/NSIF.stl';  
body(2).nonHydro = 2;                               % this is a DRAG body)
body(2).mass         = 320 + (1000*1.24162);     % static mass + added from BEM
body(2).volume       = (1000*1.24162 + 160)/1025; % Calculated from static wet mass + added in heave
%body(2).centerBuoyancy = body(2).centerGravity + [0 0 1];
body(2).inertia      = [243.3997 + 216.043,  243.3997 + 216.043, 59.7314]; % inertia dry mass assuming uniform cylinder + added mass 
body(2).centerGravity = [0,0,-8];                                % provided from deployment geometry
body(2).centerBuoyancy = [0,0,-7];                               % assumed to make statically stable: note not filled geometry so we don't have good a priori
body(2).quadDrag.area = [3.0192 3.0192 2.3888 3.0192 3.0192 10]; % Uses projected areas of NSIF
body(2).quadDrag.cd = 0.5 .* ones([1,6]);                       % values used in a Proteus DS simulation

% cable type bodies
% NOTE: the mass of the added cable elements DOES affect hydrostatics,but
% this effect is small. 
body(3) = bodyClass('');
body(3).geometryFile = '../geometry/sphere_out.stl';
body(3).nonHydro = 2;
body(3).quadDrag.area = 2 * 0.0254 .* ones([1,6]); % approxd as 2m cylinder of 1" diameter
body(3).quadDrag.area(6) = 20* 2 * 0.0254;
%body(3).quadDrag.area(6) = 0; % no drag in yaw
body(3).quadDrag.cd = ones([1,6]);
body(3).volume = 4*pi*0.0127^2;                                 % these are assumed 1" steel cable (density 7850 kg/m^3)
body(3).mass = body(3).volume .*7850;                           % these are assumed 1" steel cable, lumped capacitance
body(3).centerGravity = [0,0,-4];                               % the top half of the cable
body(3).centerBuoyancy = [0,0,-4];
body(3).inertia = [(1/12)*body(3).mass * (3*0.0127^2 + 2) (1/12)*body(3).mass * (3*0.0127^2 + 2) ...
    (1/2)*body(3).mass * 0.0127^2];

body(4) = bodyClass('');
body(4).geometryFile = '../geometry/sphere_out.stl';
body(4).nonHydro = 2;
body(4).quadDrag.area = 20*2 * 0.0254 .* ones([1,6]);
%body(4).quadDrag.area(6) = 0;
body(4).quadDrag.cd = ones([1,6]);
body(4).quadDrag.area(6) = 20* 2 * 0.0254;
body(4).volume = 4*pi*0.0127^2;                                 % these are assumed 1" steel cable
body(4).mass = body(4).volume .*7850;                           % these are assumed 1" steeel cable, lumped capacitance 
body(4).centerGravity = [0,0,-6];                               % the bottom half of the cable
body(4).centerBuoyancy = [0,0,-6];
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
pto(1) = ptoClass('pto1');
pto(1).damping = 10;
pto(1).stiffness = 1;
pto(1).location = [0 0 -3]; % assumed attached to approx bottom of float (can be refined based on geometry, this is global (e.g. 3.298 m below float CG)

pto(2) = ptoClass('pto2');
pto(2).damping = 10;
pto(2).stiffness = 1;
pto(2).location = [0 0 -5]; % somewhere in the middle of the cable, between the two body elements above

pto(3) = ptoClass('pto3');
pto(3).damping = 10;
pto(3).stiffness = 1;
pto(3).location = [0 0 -7]; % assumed attached to approx top of NSIF

%%
% pioneersim.moorK    = 2e2;
% pioneersim.moorC    = 1e3;
mooring(1)  = mooringClass('mooring');
mooring(1).location = [0.0 0.0 -9.500]; % assumed attached to approx bottom of NSIF

% mooring 
L0 = 20.5; % equilibrium length: make sure this is mooring.location + waves.waterDepth
polyNom = fliplr([0, 9.2e3, -15e3, 0, 15e3]); % polynomial definition






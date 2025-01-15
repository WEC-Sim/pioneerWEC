clc, clear all
%initialize the crest and trough vectors

for DampingIndex = 7:11
VelocityCrests  = 0;
VelocityTroughs = 0;
GeneratorTorqueTimeSeries = 0;
RelativeVelTimeSeries = 0;
RelativePositionTimeSeries = 0;
SurgePosTimeSeries = 0;
HeavePosTimeSeries = 0;
PitchPosTimeSeries = 0;
for qq = 1:750

    load(sprintf('IMU_Parsing/InverseDynamics/DataSnip%i.mat',qq))

    Hm0(qq) = InverseDynamics.Hm0;
    Tp(qq) = InverseDynamics.Tp;

%     Year(qq) = InverseDynamics.DateAndTime.Year;
%     Month(qq) = InverseDynamics.DateAndTime.Month;
%     Day(qq) = InverseDynamics.DateAndTime.Day;
%     Hour(qq) = InverseDynamics.DateAndTime.Hour;

    Time = InverseDynamics.Time;
    G = 9.80665;
    dt = 0.01;

    % Define the sampling frequency
%     Fs = 100; % Sampling frequency in Hz
% 
%     % Define the frequency range for the bandpass filter
%     Fpass1 = [0.1125 1.0]; % Passband frequencies in Hz
% 
%     % Design the bandpass filter using a Butterworth filter
%     % You can also choose other filter types like 'cheby1', 'cheby2', etc.
%     bpFilt1 = designfilt('bandpassiir', ...
%         'FilterOrder', 4, ... % Order of the filter
%         'HalfPowerFrequency1', Fpass1(1), ...
%         'HalfPowerFrequency2', Fpass1(2), ...
%         'SampleRate', Fs);
% 
%     Fpass2 = [0.1 1.5]; % Passband frequencies in Hz

    % Design the bandpass filter using a Butterworth filter
    % You can also choose other filter types like 'cheby1', 'cheby2', etc.
%     bpFilt2 = designfilt('bandpassiir', ...
%         'FilterOrder', 4, ... % Order of the filter
%         'HalfPowerFrequency1', Fpass2(1), ...
%         'HalfPowerFrequency2', Fpass2(2), ...
%         'SampleRate', Fs);

    %External Forcing
    Gain = 1.0;
    SecondOrderCoefGain = 1.0;
    Surge.time = Time;
%     Surge.signals.values = Gain*filtfilt(bpFilt1,InverseDynamics.SurgeForce);
    Surge.signals.values = Gain*InverseDynamics.SurgeForce;

    Sway.time = Time;
%     Sway.signals.values = Gain*filtfilt(bpFilt1,InverseDynamics.SwayForce);
    Sway.signals.values = Gain*InverseDynamics.SwayForce;

    Heave.time = Time;
%     Heave.signals.values = Gain*filtfilt(bpFilt2,InverseDynamics.HeaveForce);
    Heave.signals.values = Gain*InverseDynamics.HeaveForce;

    Roll.time = Time;
    Roll.signals.values = SecondOrderCoefGain*Gain*InverseDynamics.RollTorque;

    Pitch.time = Time;
    Pitch.signals.values = SecondOrderCoefGain*Gain*InverseDynamics.PitchTorque;

    % Motion for checking
    Surge_Pos.time = Time;
    Surge_Pos.signals.values = InverseDynamics.Position(:,1);

    Sway_Pos.time = Time;
    Sway_Pos.signals.values  = InverseDynamics.Position(:,2);

    Heave_Pos.time = Time;
    Heave_Pos.signals.values = InverseDynamics.Position(:,3);

    Roll_Pos.time = Time;
    Roll_Pos.signals.values  = InverseDynamics.Position(:,4);

    Pitch_Pos.time = Time;
    Pitch_Pos.signals.values = InverseDynamics.Position(:,5);

    %% ~~~~~~~~~~~ Buoy Characteristics ~~~~~~~~~~~~~~~~
    % Inertia Characteristics
    Buoy.Mass = 3750;
    Buoy.X_add = 1500;
    Buoy.Z_add = 7250;
    Buoy.J1 = 8822;
    % Buoy Stiffness Characteristics
    Buoy.Kx = 500;
    Buoy.Kz = 80000;
    Buoy.Kt = 38188;
    % Buoy Damping Characteristics
    Buoy.Bx = 1019;
    Buoy.Bz = 8000;
    Buoy.Bt = 112;
    % Quadratic Damping Terms
    Buoy.Qx = (1000*2.55*4)/2;
    Buoy.Qz = (1000*8.563*0.5)/2;
    Buoy.Qt = (1000*8.563*1.0)/2;

    Buoy.Wn = sqrt(Buoy.Kt/Buoy.J1);
    % ======== PTO characteristics ==============
    PTO.PinJoint  = -1.18;%-1.18; % up
    PTO.StandHeight = 0.5; % meters
    PTO.B_fric = .25; % Viscous Friction
    % Losses in a single main shaft bearing
    SingleBearing = 0.37*3;
    % Friction in both bearings
    PTO.Bear_C_Fric  = SingleBearing*2;
    PTO.Maxon_C_Fric = 0.6125/7;
    Color = [.15, DampingIndex/11, DampingIndex/22+0.4];

    % Mag spring is fixed by FluxMagic TM
    PTO.Stiffness = 360; %PSU spring is 360
    PTO.Weakening = 57;  %PSU spring is 57
    % if we want to do the idealized sinusoidal spring
    Tuning.Stiffness = 35;
    Tuning.Percent = 1;

    %Via CAD
    PTO.Mass =  244;
    PTO.r = 0.1248;
    PTO.FlywheelJ = 7.605;


    % modify the buoy inertia
    Buoy.J1 = Buoy.J1 - PTO.Mass*(abs(PTO.PinJoint)-PTO.r)^2 - PTO.FlywheelJ + 11;

    PTO.J = PTO.Mass*PTO.r^2 + PTO.FlywheelJ;
    motorkm = 0.58;
    transmission = 6.6*112/34;
    PTO.Km = motorkm*transmission;

    MotorKt = 0.186;
    MotorR = 0.101;
    AddR = 2.5;
    PeakMotorB = MotorKt^2/(MotorR+AddR);
    PeakB = PeakMotorB*transmission^2;

    % PTO damping optimization
    DampingSearchSteps = 1;
    OptimizationVector = zeros(DampingSearchSteps,1);
    DampingValue       = zeros(DampingSearchSteps,1);
    MinDamping = 7;
    MaxDamping = 12;
    DeltaDamping = MaxDamping - MinDamping;
    GR = (sqrt(5)-1)/2;
    InitialDampingGuesses = [MinDamping, MaxDamping-DeltaDamping*GR, MinDamping+DeltaDamping*GR,MaxDamping];

    for qj = 1:DampingSearchSteps
        % Golden Search stepping
        if qj <= length(InitialDampingGuesses)
            % In the first four damping steps
            DampingValue(qj) = InitialDampingGuesses(qj);
            GS_Index = [1 2 3 4];
        else
            if (max(OptimizationVector) == OptimizationVector(GS_Index(3))) || (max(OptimizationVector) == OptimizationVector(GS_Index(4)))
                GS_Index(1) = GS_Index(2); GS_Index(2) = GS_Index(3); GS_Index(3) = qj;
                DeltaDamping = DampingValue(GS_Index(4)) - DampingValue(GS_Index(1));
                DampingValue(qj) = DampingValue(GS_Index(1)) + DeltaDamping*GR;
            else
                GS_Index(4) = GS_Index(3); GS_Index(3) = GS_Index(2); GS_Index(2) = qj;
                DeltaDamping = DampingValue(GS_Index(4)) - DampingValue(GS_Index(1));
                DampingValue(qj) = DampingValue(GS_Index(4)) - DeltaDamping*GR;
            end
        end
        PTO.BPTO = DampingValue(qj); % Nms/rad, on rel motion
        PTO.BPTO = 2*(DampingIndex-1);
        PTO.TorqueLimit = 50; % Nm, max allowable, at the pendulum
        PTO.Misalignment = 0; % currently simulating a Roll List
        PTO.Dead = 0.005; % Dead Band on damping, velocity (rad/s) needed to turn on

        % ================ Run Sim =====================
        Trial = sim('Step3_Resonator_6DOF.slx');
        RelativeVel = squeeze(Trial.RelativeVelocity.signals.values);
        GeneratorT  = squeeze(Trial.GenTorque.signals.values);
        OutTime  = 0.01*(1:length(RelativeVel));
        % Mechanical power at the motor shaft
        MechPower = RelativeVel.*GeneratorT;
        % Remove winding losses
        ElecPower = MechPower - (GeneratorT./PTO.Km).^2;
        AvgMech = mean(MechPower);
        AvgElec = mean(ElecPower);

        OptimizationVector(qj) = AvgElec;

        if OptimizationVector(qj) == max(OptimizationVector)
            % Calculate power terms for ideal trial
            RelativeAngle = squeeze(Trial.RelativeAngle.signals.values);
            Stiffness = squeeze(Trial.SpringConstant.signals.values);
            SpringTorque = squeeze(Trial.SpringTorque.signals.values);
            HeavePos = squeeze(Trial.HeavePos.signals.values);
            SurgePos = squeeze(Trial.SurgePos.signals.values);
            PitchPos = squeeze(Trial.PitchPos.signals.values);
            MeanMechanical(qq) = AvgMech;
            MeanElectrical(qq) = AvgElec;
            FrictionLoss = PTO.B_fric*RelativeVel.*RelativeVel;
            MeanFrictionLoss(qq) = mean(FrictionLoss);
            MeanWindingLoss(qq) = MeanMechanical(qq) - MeanElectrical(qq);
            IdealDamping(qq) = PTO.BPTO;

            MaxMotorTorque(qq) = max(RelativeVel*PTO.BPTO);
            RMS_BuoyVel(qq) = rms(squeeze(Trial.PitchVel.signals.values));
            RMS_RelativeAngle(qq) = rms(squeeze(Trial.RelativeAngle.signals.values));
            Max_RelativeAngle(qq) = max(abs(squeeze(Trial.RelativeAngle.signals.values)));
            Max_RelativeVel(qq) = max(abs(RelativeVel));
    
            % TODO ADD THE BELOW BACK IN
            [~, VelUpC, VelUpT, ~, ~] = fUpcrossing(OutTime, RelativeVel);

        end
    end %End of damping optimization loop
    % same here
    DataPoints = length(RelativeAngle);

    CrestStart  = length(VelocityCrests);
    TroughStart = length(VelocityTroughs);
    VelocityCrests(CrestStart:CrestStart+length(VelUpC)-1) = VelUpC;
    VelocityTroughs(TroughStart:TroughStart+length(VelUpT)-1) = VelUpT;

    StartingLength = length(GeneratorTorqueTimeSeries);
    SaveVector = StartingLength:(StartingLength+DataPoints-1);
    GeneratorTorqueTimeSeries(SaveVector) = GeneratorT;
    RelativeVelTimeSeries(SaveVector) = RelativeVel;
    RelativePositionTimeSeries(SaveVector) = RelativeAngle;
    SurgePosTimeSeries(SaveVector) = SurgePos;
    HeavePosTimeSeries(SaveVector) = HeavePos;
    PitchPosTimeSeries(SaveVector) = PitchPos;

    disp(qq)
    figure(3)
    hold on
    plot(qq,MeanElectrical(qq),'ko','MarkerFaceColor',Color)
%     clear('Trial')

end

save(sprintf('Quadratic_Damping_BPTO_equals%i',PTO.BPTO))
clearvars -except DampingIndex
end

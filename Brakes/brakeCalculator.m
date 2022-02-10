clear all; close all; clc;
%% Vehicle Parameters, updated with 220c values

g = 9.81; % m/s^2

m = convmass(545,'lbm','kg');%720*convert('lb', 'kg'); % kg w/ driver, estimated
wb = 1.6; % m, wheelbase
CGz = 0.25; % m, cg height
swd = 0.51; % static weight dist, rear fraction

v = convvel(50,'mph','m/s');%50*convert('mph','m/s'); % m/s, speed during brake test
cL = 3; % coefficent of lift
cD = 1.5; % coefficient of drag
cP = 0.5; % center of pressure, rear fraction
Af = 1.1; %m^2, frontal area
rho = 1.2; %kg/m^2, air density

Ax = 1.8; % g, deceleration during brake test, conservative

rTire = 0.203; %m, tire radius

%% 222C Brake System Parameters
 
biasF = 0.54; %brake bias, front fraction

pedalForce = convforce(135,'lbf','N');%150*convert('lbf','N'); % N
pedalRatio = 5; % mechanical pedal ratio
masterDiaF = convlength(0.7,'in','m');%0.7*convert('in','m'); % master cylinder diameter
masterDiaR = convlength(0.7,'in','m');%0.7*convert('in','m');
pistonDiaF = convlength(1,'in','m');%1*convert('in','m'); % caliper piston diameter
pistonDiaR = convlength(1,'in','m');%1*convert('in','m');
rotorRadiusF = convlength(3.4,'in','m');%3.5*convert('in','m'); %rotor radius
rotorRadiusR = convlength(3.4,'in','m');%3.5*convert('in','m');
muPadsF = 0.45; % coefficient of friction of brake pads
muPadsR = 0.45;
numPistonsF = 1; %number of piston sets
numPistonsR = 1; %number of piston sets

%% 220C Brake System Parameters
% 
 %biasF = 0.54; %brake bias, front fraction
 
 %pedalForce = convforce(135,'lbf','N');%150*convert('lbf','N'); % N
 %pedalRatio = 5; % mechanical pedal ratio
 %masterDiaF = convlength(0.625,'in','m');%0.7*convert('in','m'); % master cylinder diameter
 %masterDiaR = convlength(0.7,'in','m');%0.7*convert('in','m');
 %pistonDiaF = convlength(1.12,'in','m');%1*convert('in','m'); % caliper piston diameter
 %pistonDiaR = convlength(1,'in','m');%1*convert('in','m');
 %rotorRadiusF = convlength(3.6,'in','m');%3.5*convert('in','m'); %rotor radius
 %rotorRadiusR = convlength(3.4,'in','m');%3.5*convert('in','m');
 %muPadsF = 0.54; % coefficient of friction of brake pads
 %muPadsR = 0.45;
 %numPistonsF = 1; %number of piston sets
 %numPistonsR = 1; %number of piston sets

%% E Brake System Parameters
% 
%biasF = 0.54; %brake bias, front fraction
 
 %pedalForce = convforce(135,'lbf','N');%150*convert('lbf','N'); % N
 %pedalRatio = 5; % mechanical pedal ratio
 %masterDiaF = convlength(0.7,'in','m');%0.7*convert('in','m'); % master cylinder diameter
 %masterDiaR = convlength(0.7,'in','m');%0.7*convert('in','m');
 %pistonDiaF = convlength(1,'in','m');%1*convert('in','m'); % caliper piston diameter
 %pistonDiaR = convlength(1,'in','m');%1*convert('in','m');
 %rotorRadiusF = convlength(3.5,'in','m');%3.5*convert('in','m'); %rotor radius
 %rotorRadiusR = convlength(3.5,'in','m');%3.5*convert('in','m');
 %muPadsF = 0.45; % coefficient of friction of brake pads
 %muPadsR = 0.45;
 %numPistonsF = 2; %number of piston sets
 %numPistonsR = 1; %number of piston sets


%% Determine Lockup Torque

longWT = m*Ax*g*CGz/wb;

FzStaticF = m*g*(1-swd);
FzStaticR = m*g*swd;

FzAeroF = (1/2)*rho*cL*(1-cP)*Af*v^2;
FzAeroR = (1/2)*rho*cL*cP*Af*v^2;

FxDrag = (1/2)*rho*cD*Af*v^2;
FxTotal = m*Ax*g;

FxTires = FxTotal - FxDrag;

FzF = FzStaticF + FzAeroF + longWT;
FzR = FzStaticR + FzAeroR - longWT;
FzTotal = FzF + FzR;

FxF = (FzF/FzTotal)*FxTires;
FxR = (FzR/FzTotal)*FxTires;

mu = FxTires/FzTotal;

fracF = FzF/FzTotal;

torqueLockF = (FxF/2)*rTire;
torqueLockR = (FxR/2)*rTire;

%% Determine Brake Capability

masterAreaF = (pi/4)*masterDiaF^2;
masterAreaR = (pi/4)*masterDiaR^2;
pistonAreaF = 2*(pi/4)*pistonDiaF^2
pistonAreaR = (pi/4)*pistonDiaR^2;

linePressureF = pedalForce*pedalRatio*biasF/masterAreaF
linePressureR = pedalForce*pedalRatio*(1-biasF)/masterAreaR;

torqueBrakeF = 2*numPistonsF*linePressureF*pistonAreaF*muPadsF*rotorRadiusF
torqueBrakeR = 2*numPistonsR*linePressureR*pistonAreaR*muPadsR*rotorRadiusR

%% Lockup Ratio (want > 1)

lockupRatioF = torqueBrakeF/torqueLockF
lockupRatioR = torqueBrakeR/torqueLockR

%% Line Pressure (in psi)

linePressurePsiF = convpres(linePressureF,'Pa','psi')  %*convert('Pa','psi')
linePressurePsiR = convpres(linePressureR,'Pa','psi')   %*convert('Pa','psi')

desiredpressuretoLockF = torqueLockF / (2*numPistonsF*pistonAreaF*muPadsF*rotorRadiusF);
desiredpressuretoLockR = torqueLockR / (2*numPistonsR*pistonAreaR*muPadsR*rotorRadiusR);

newmasterAreaF = (pedalForce*pedalRatio*biasF / desiredpressuretoLockF)*1550;
newmasterAreaR = (pedalForce*pedalRatio*(1-biasF) / desiredpressuretoLockR)*1550;

newmasterboreF = sqrt(newmasterAreaF*4 / pi);    %FOS of 1 MC bore dia to lock tires
newmasterboreR = sqrt(newmasterAreaR*4 / pi);    %FOS of 1 MC bore dia to lock tires

%more braking force -> increase the pressure -> decrease the area of MC


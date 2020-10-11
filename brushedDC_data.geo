// Brushed DC machine
// 4th year project BEAMS-ULB (2012-13): Finite Element and Experimental Analysis of DC machines
// Author: Olivier Candeur; Supervisors: J. Gyselinck, Y. Mollet
// GetDP-Gmsh model: R. Sabariego - August 2013

deg2rad = Pi/180 ;

pp = "Input/Constructive parameters/";

NbrPoles = 4 ; // The FE model is complete, no symmetries considered

DefineConstant[
  InitialRotorAngle_deg = { 0., Range{0,90},
    Name "Input/21Start rotor angle [deg]", Highlight "AliceBlue"}
  MD = { 1., Range{0.1,10},
    Name "Input/22mesh density", Highlight "AliceBlue"}
] ;

InitialRotorAngle = InitialRotorAngle_deg*deg2rad ; // initial rotor angle, 0 if aligned


//--------------------------------------------------------------------------
// Stator
//--------------------------------------------------------------------------
NbrPolesTot = 4; // number of poles in complete cross-section
NbrSectStatorTot = 4 ; // number of stator poles
NbrSectStator = NbrSectStatorTot*NbrPoles/NbrPolesTot; // number of stator poles in FE model

StatorAngleS = -Pi/2 ;

//--------------------------------------------------------------------------
// Rotor
//--------------------------------------------------------------------------
NbrSectTot = 48; // number of "rotor slots"
NbrSect = NbrSectTot*NbrPoles/NbrPolesTot; // number of "rotor slots" in FE model
NbrSectPole = NbrSectTot/NbrPolesTot;

//--------------------------------------------------------------------------
//--------------------------------------------------------------------------
u = 1e-3 ; // dimension unit = mm
AxialLength = 160*u ;

// rotor geometry
Rro = 230/2*u; // outer rotor radius
Rri =  60/2*u; // inner rotor radius (shaft)

h_rt = 29.3*u; // rotor tooth height
w_rt = 6.2*u; // rotor tooth width

// stator geometry
Rso  = 530/2*u; // outer stator radius
Rsop = 470/2*u; // inner stator yoke radius
Rsi  = 117*u;   // inner stator radius at airgap
h_sp = (115-9)*u ; // stator pole height
w_sp = 72*u ; // stator pole width
psuw = 102*u ; // stator pole shoe upper width
pss = 2*32*deg2rad ; // stator pole shoe total span
psr = 3*u ; // stator pole shoe smooth end radius
Rsi2shoe = 9*u;

ag = Rsi-Rro; // airgap width

kk = 1/3;
Rag0 = Rro + kk*ag;
Rag1 = Rsi - kk*ag;

Rag_pos = Rro + ag/2;


DefineConstant[
  mur_fe = {1000, Name StrCat[pp,"Relative permeability (linear)"], Closed 1}
];

IIa = 90 ;
IIe = 1.7 ;

//--------------------------------------------------------------------------
// Physical numbers
//--------------------------------------------------------------------------
ROTOR_CORE     = 20000;
ROTOR_AIRGAP = 23000;

ROTOR_ONE_SLOT = 30000 ; // Just the first rotor conductor
ROTOR_SLOTS_P = 31000; // All rotor conductors with positive current
ROTOR_SLOTS_N = 31001; // All rotor conductors with negative current

SURF_INT = 25000;
ROTOR_BND_MOVING_BAND = 26000;
MB_R1 = ROTOR_BND_MOVING_BAND+0;
MB_R2 = ROTOR_BND_MOVING_BAND+1;
MB_R3 = ROTOR_BND_MOVING_BAND+2;
MB_R4 = ROTOR_BND_MOVING_BAND+3;

//--------------------------------------------------------------------------

STATOR_CORE         = 10000;
STATOR_SLOT_OPENING = 11000;
STATOR_AIRGAP       = 12000;

STATOR_ONE_COILSIDE = 13000;
STATOR_COILSIDES_P  = 13100;
STATOR_COILSIDES_N  = 13200;

SURF_EXT = 15000;

STATOR_BND_MOVING_BAND = 16000;
MB_S1 = STATOR_BND_MOVING_BAND+0;
MB_S2 = STATOR_BND_MOVING_BAND+1;
MB_S3 = STATOR_BND_MOVING_BAND+2;
MB_S4 = STATOR_BND_MOVING_BAND+3;

MOVING_BAND = 999999 ; // Not in the geo file
NICEPOS = 111111 ;

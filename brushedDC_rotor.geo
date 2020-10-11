Geometry.AutoCoherence = 0 ; // Should all duplicate entities be automatically removed?

phia = Asin(w_rt/2/Rro);
xa =  Rro*Sin(phia) ;
ya =  Rro*Cos(phia) ;

phic = 2*Pi/NbrSectTot;
xc = Rro*Sin(phic/2) ;
yc = Rro*Cos(phic/2) ;
xd = Rri*Sin(phic/2) ;
yd = Rri*Cos(phic/2) ;

xmb = Rag0 *Sin(phic/2) ;
ymb = Rag0 *Cos(phic/2) ;

ptR[]+=newp; Point(newp) = {0, Rro, 0, clr0*1.25};
ptR[]+=newp; Point(newp) = {xa, ya, 0, clr0/1.8};
ptR[]+=newp; Point(newp) = {xa, ya-h_rt, 0, clr1};
ptR[]+=newp; Point(newp) = {0, Rro-h_rt, 0, clr1};

ptR[]+=newp; Point(newp) = {xc, yc, 0, clr0*1.25};

// Shaft
ptR[]+=newp; Point(newp) = {0, Rri, 0, clr2};
ptR[]+=newp; Point(newp) = {xd, yd, 0, clr2};

// Moving band
ptR[]+=newp; Point(newp) = {xmb, ymb, 0, clr0_/2};


// Rotate the model... (easier if we do it for the points)
RotorAngleS = InitialRotorAngle-Pi/2+Pi/NbrSectTot ;
Rotate {{0, 0, 1}, {0, 0, 0},  RotorAngleS} { Point{ptR[]}; }

lrC[]+=newl; Circle(newl) = {ptR[0],cen,ptR[1]};
lrL[]+=newl; Line(newl)   = {ptR[1],ptR[2]};
lrC[]+=newl; Circle(newl) = {ptR[2],cen,ptR[3]};
lrL[]+=newl; Line(newl)   = {ptR[3],ptR[0]};

Line Loop(newll) = {lrC[0],lrL[0],lrC[1],lrL[1]};
surfRotorBars[]+=news;Plane Surface(news) = newll-1; // Half bar

lrC[]+=newl; Circle(newl) = {ptR[1],cen,ptR[4]};
lrL[]+=newl; Line(newl)   = {ptR[4],ptR[6]};
lrC[]+=newl; Circle(newl) = {ptR[5],cen,ptR[6]};
lrL[]+=newl; Line(newl)   = {ptR[3],ptR[5]};


// Moving band
lrL[]+=newl; Line(newl)   = {ptR[4],ptR[#ptR[]-1]};

Line Loop(newll) = {lrC[2], lrL[2], -lrC[3], -lrL[3], -lrC[1], -lrL[0]};
surfRotorIron[]+=news; Plane Surface(news) = {newll-1};

bndRotorOut[] = lrC[{0,2}];
bndRotorIn[]  = lrC[{3}];

RotorPeriod_Ref[] = lrL[{2,#lrL[]-1}] ;
RotorPeriod_Dep[] = Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*NbrPoles/NbrPolesTot} { Duplicata{ Line{RotorPeriod_Ref[]};} };


// Always 1/4 max for the moving band
ptR[]  += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi/NbrPolesTot} { Duplicata{ Point{ptR[#ptR[]-1]};} };
If(NbrPoles==1)
  cutMB[] = RotorPeriod_Dep[1];
EndIf
If(NbrPoles>1)
  cutMB[] = Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi/NbrPolesTot} { Duplicata{ Line{RotorPeriod_Ref[1]};} };
EndIf

lnMB[] = newl; Circle(newl) = {ptR[#ptR[]-1],cen,ptR[#ptR[]-2]};


// Symmetry with regard to the axis at initial position
AngSymR = RotorAngleS ;
linaux= Symmetry {Cos(AngSymR),Sin(AngSymR),0,0} { Duplicata{ Line{bndRotorOut[{0,1}]};} };

bndRotorOut[]  += {-linaux[{1,0}]};
bndRotorIn[]    += Symmetry {Cos(AngSymR),Sin(AngSymR),0,0} { Duplicata{ Line{bndRotorIn[{0}]};} };
surfRotorIron[] += Symmetry {Cos(AngSymR),Sin(AngSymR),0,0} { Duplicata{ Surface{surfRotorIron[{0}]};} };
surfRotorBars[] += Symmetry {Cos(AngSymR),Sin(AngSymR),0,0} { Duplicata{ Surface{surfRotorBars[{0}]};} };

// First just one pole
For k In {1:NbrSectPole-1}
  bndRotorOut[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrSectTot} { Duplicata{ Line{bndRotorOut[{0:3}]};} };
  bndRotorIn[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrSectTot} { Duplicata{ Line{bndRotorIn[{0,1}]};} };
  surfRotorIron[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrSectTot} { Duplicata{ Surface{surfRotorIron[{0,1}]};} };
  surfRotorBars[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrSectTot} { Duplicata{ Surface{surfRotorBars[{0,1}]};} };
EndFor

// If we are considering more than one pole in our model
nn = #surfRotorIron[]-1 ;
n0 = #bndRotorOut[]-1 ;
n1 = #bndRotorIn[]-1 ;
For k In {1:NbrPoles-1}
  bndRotorOut[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrPolesTot} { Duplicata{ Line{bndRotorOut[{0:n0}]};} };
  bndRotorIn[]  += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrPolesTot} { Duplicata{ Line{bndRotorIn[{0:n1}]};} };
  surfRotorIron[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrPolesTot} { Duplicata{ Surface{surfRotorIron[{0:nn}]};} };
  surfRotorBars[] += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*k/NbrPolesTot} { Duplicata{ Surface{surfRotorBars[{0:nn}]};} };
EndFor


// Creating the moving band...
Geometry.AutoCoherence = 1;
Coherence ;

Line Loop(newll) = {-bndRotorOut[{0:(#bndRotorOut[]/NbrPoles-1)}], cutMB[0], lnMB[0], -RotorPeriod_Ref[1]};
surfRotorMB[]+=news; Plane Surface(news) = {newll-1};

//Completing the moving band
For k In {1:NbrPolesTot-1}
  lnMB[] += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/NbrPolesTot} { Duplicata{ Line{lnMB[{0}]};} };
EndFor
For k In {1:NbrPoles-1}
  surfRotorMB[]+= Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/NbrPolesTot} { Duplicata{ Surface{surfRotorMB[{0}]};} };
EndFor


// Inverting the normals of the mesh
Reverse Surface {surfRotorIron[{0:#surfRotorIron[]-1:2}]};
Reverse Surface {surfRotorBars[{0:#surfRotorBars[]-1:2}]};

//---------------------------------------------------------
// Physical Regions
//---------------------------------------------------------

Physical Surface("rotor core", ROTOR_CORE) = {surfRotorIron[]};
Physical Surface("rotor airgap", ROTOR_AIRGAP) = {surfRotorMB[]};

Physical Surface("rotor slot", ROTOR_ONE_SLOT) = surfRotorBars[{0,1}] ; // First rotor conductor

Physical Line("inner rotor boundary", SURF_INT) = {bndRotorIn[]};
Physical Line("boundary rotor moving band", ROTOR_BND_MOVING_BAND) = lnMB[];


// For visu
Color SteelBlue {Surface{surfRotorIron[]};}
Color SkyBlue {Surface{surfRotorMB[]};}

nnnn[] = {0:NbrSectPole-1};
pppp[] = {NbrSectPole:2*NbrSectPole-1};
If(NbrPoles>1) //2
  nnnn[] += {3*NbrSectPole:4*NbrSectPole-1};
  pppp[] += {2*NbrSectPole:3*NbrSectPole-1};
EndIf
If(NbrPoles>2) // 3, 4
  nnnn[] += {4*NbrSectPole:5*NbrSectPole-1, 7*NbrSectPole:8*NbrSectPole-1};
  pppp[] += {5*NbrSectPole:6*NbrSectPole-1, 6*NbrSectPole:7*NbrSectPole-1};
EndIf
Physical Surface("rotor slots P", ROTOR_SLOTS_P) = surfRotorBars[{pppp[]}];
Physical Surface("rotor slots N", ROTOR_SLOTS_N) = surfRotorBars[{nnnn[]}];
Color Orchid  {Surface{surfRotorBars[{pppp[]}]};}
Color Purple  {Surface{surfRotorBars[{nnnn[]}]};}

nicepos_rotor[] = {CombinedBoundary{ Surface{surfRotorIron[]};},
                   CombinedBoundary{ Surface{surfRotorBars[]};},
                   CombinedBoundary{ Surface{surfRotorMB[]};} } ;

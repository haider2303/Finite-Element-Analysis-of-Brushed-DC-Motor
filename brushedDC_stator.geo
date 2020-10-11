Geometry.AutoCoherence = 0;

phie = Asin(w_sp/2/Rsop);
xe = -Rsop*Sin(phie) ;
ye =  Rsop*Cos(phie) ;

phik = Asin(psuw/2/Rsop);
xk = -Rsop*Sin(phik) ;
yk =  Rsop*Cos(phik) ;

ptS[]+=newp; Point(newp) = {0, Rso, 0, cls0};
ptS[]+=newp; Point(newp) = {-Rso*Sin(Pi/4), Rso*Cos(Pi/4), 0, cls0};

ptS[]+=newp; Point(newp) = {xe, ye, 0, cls1/2};
ptS[]+=newp; Point(newp) = {xk, yk, 0, cls1};
ptS[]+=newp; Point(newp) = {-Rsop*Sin(Pi/4), Rsop*Cos(Pi/4), 0, cls1};

ptS[]+=newp; Point(newp) = {xe, Rsi+Rsi2shoe, 0, cls2};
ptS[]+=newp; Point(newp) = {xk, Rsi+Rsi2shoe, 0, cls2};

ptS[]+=newp; Point(newp) = {0, Rsi, 0, cls2_};
ptS[]+=newp; Point(newp) = {-Rsi*Sin(pss/2), Rsi*Cos(pss/2), 0, cls2_};

cent = newp; Point(newp) = {-(Rsi+psr)*Sin(pss/2), (Rsi+psr)*Cos(pss/2), 0, cls2_};
ptS[]+=newp; Point(newp) = {-(Rsi+psr)*Sin(pss/2)-psr*Sin(Pi/4), (Rsi+psr)*Cos(pss/2)-psr*Cos(Pi/4), 0, cls2_*1.5};
ptS[]+=newp; Point(newp) = {-(Rsi+psr)*Sin(pss/2)-psr*Sin(Pi/4), (Rsi+psr)*Cos(pss/2)+psr*Cos(Pi/4), 0, cls2_*1.5};

ptS[]+=newp; Point(newp) = {-Rsi*Sin(Pi/4), Rsi*Cos(Pi/4), 0, cls2_};

// Moving band
ptS[]+=newp; Point(newp) = {0, Rag1, 0, cls2_};

// Rotate the model for having it alined with x-axes... (easier if we do it for the points)
StatorAngleS = -Pi/2 ;
Rotate {{0, 0, 1}, {0, 0, 0},  StatorAngleS} { Point{ptS[]}; }
Rotate {{0, 0, 1}, {0, 0, 0},  StatorAngleS} { Point{cent}; }

lsC[]+=newl; Circle(newl) = {ptS[0],cen,ptS[1]};
lsC[]+=newl; Circle(newl) = {ptS[2],cen,ptS[3]};
lsC[]+=newl; Circle(newl) = {ptS[3],cen,ptS[4]};

lsL[]+=newl; Line(newl) = {ptS[2],ptS[5]};
lsL[]+=newl; Line(newl) = {ptS[5],ptS[6]};
lsL[]+=newl; Line(newl) = {ptS[6],ptS[3]};

lsC[]+=newl; Circle(newl) = {ptS[7],cen,ptS[8]};
lsC[]+=newl; Circle(newl) = {ptS[8],cent,ptS[9]};
lsC[]+=newl; Circle(newl) = {ptS[9],cent,ptS[10]};

lsL[]+=newl; Line(newl) = {ptS[6],ptS[10]};

lsL[]+=newl; Line(newl) = {ptS[7],ptS[0]}; // axis
lsL[]+=newl; Line(newl) = {ptS[4],ptS[1]}; // symmetry
lsL[]+=newl; Line(newl) = {ptS[4],ptS[11]}; //symmetry

lsC[]+=newl; Circle(newl) = {ptS[8],cen,ptS[11]};


// Moving band
lsL[]+=newl; Line(newl)   = {ptS[7],ptS[#ptS[]-1]};

Line Loop(newll) = {lsL[5], -lsC[0], -lsL[4], lsC[{5,4,3}], -lsL[{3,1,0}], lsC[{1,2}] };
surfStatorIron[] += news; Plane Surface(news) = newll-1;
Line Loop(newll) = {lsC[1], -lsL[{2,1,0}]};
surfStatorCoil[]+=news; Plane Surface(news) = {newll-1};
Line Loop(newll) = {lsC[6], -lsL[6], -lsC[2], -lsL[2], lsL[3], -lsC[{5,4}]};
surfStatorOpening[]+=news; Plane Surface(news) = {newll-1};


bndStatorOut[] += lsC[0];
bndStatorIn[]  += lsC[{3,6}] ;
StatorPeriod_Ref[] = lsL[{4,#lsL[]-1}] ;
StatorPeriod_Dep[] = Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi*NbrPoles/NbrPolesTot} { Duplicata{ Line{StatorPeriod_Ref[]};} };

// Always 1/4 max for the moving band
ptS[]   += Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi/NbrPolesTot} { Duplicata{ Point{ptS[#ptS[]-1]};} };
If(NbrPoles==1)
  cutSMB[] = StatorPeriod_Dep[1];
EndIf
If(NbrPoles>1)
  cutSMB[] = Rotate {{0, 0, 1}, {0, 0, 0}, 2*Pi/NbrPolesTot} { Duplicata{ Line{StatorPeriod_Ref[1]};} };
EndIf
lnSMB[] = newl; Circle(newl) = {ptS[#ptS[]-1],cen,ptS[#ptS[]-2]};



// Complete stator pole
xsa = Cos(-Pi/4); ysa = Sin(-Pi/4);
bndStatorOut[] += Symmetry {xsa,ysa,0,0} { Duplicata{ Line{bndStatorOut[{0}]};} };
lin[] = Symmetry {xsa,ysa,0,0} { Duplicata{ Line{bndStatorIn[{0,1}]};} };
bndStatorIn[] += {-lin[{1,0}]};

surfStatorIron[] += Symmetry {xsa,ysa,0,0} { Duplicata{ Surface{surfStatorIron[{0}]};} };
surfStatorCoil[] += Symmetry {xsa,ysa,0,0} { Duplicata{ Surface{surfStatorCoil[{0}]};} };

surfStatorOpening[] += Symmetry {xsa,ysa,0,0} { Duplicata{ Surface{surfStatorOpening[{0}]};} };

For k In {1:NbrSectStator-1}
  bndStatorOut[]   += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/4} { Duplicata{ Line{bndStatorOut[{0,1}]};} };
  bndStatorIn[]   += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/4} { Duplicata{ Line{bndStatorIn[{0:3}]};} };
  surfStatorIron[] += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/4} { Duplicata{ Surface{surfStatorIron[{0,1}]};} };
  surfStatorCoil[] += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/4} { Duplicata{ Surface{surfStatorCoil[{0,1}]};} };
  surfStatorOpening[] += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/4} { Duplicata{ Surface{surfStatorOpening[{0,1}]};} };
EndFor

Geometry.AutoCoherence = 1;
Coherence ;
Line Loop(newll) = {bndStatorIn[{0:(#bndStatorIn[]/NbrPoles-1)}], cutSMB[0], lnSMB[0], -StatorPeriod_Ref[1]};
surfStatorMB[]+=news; Plane Surface(news) = {newll-1};


//Completing the moving band
For k In {1:NbrPolesTot-1}
  lnSMB[] += Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/NbrPolesTot} { Duplicata{ Line{lnSMB[{0}]};} };
EndFor
For k In {1:NbrPoles-1}
  surfStatorMB[]+= Rotate {{0, 0, 1}, {0, 0, 0}, k*2*Pi/NbrPolesTot} { Duplicata{ Surface{surfStatorMB[{0}]};} };
EndFor

// Changing the normals of the mesh
Reverse Surface {surfStatorIron[{0:#surfStatorIron[]-1:2}]};
Reverse Surface {surfStatorOpening[{0:#surfStatorOpening[]-1:2}]};
Reverse Surface {surfStatorCoil[{1:#surfStatorCoil[]-1:2}]};

//---------------------------------------------------------
// Physical Regions
//---------------------------------------------------------

Physical Surface("stator core", STATOR_CORE) = {surfStatorIron[]};
Physical Surface("stator slot opening", STATOR_SLOT_OPENING) = {surfStatorOpening[]};
Physical Surface("stator airgap", STATOR_AIRGAP) = {surfStatorMB[]};

Physical Surface("stator one coilside", STATOR_ONE_COILSIDE) = {surfStatorCoil[0]};
Physical Surface("stator coil sides P", STATOR_COILSIDES_P) = {surfStatorCoil[{0:#surfStatorCoil[]-1:4}],surfStatorCoil[{1:#surfStatorCoil[]-1:4}]};
Physical Surface("stator coil sides N", STATOR_COILSIDES_N) = {surfStatorCoil[{2:#surfStatorCoil[]-1:4}],surfStatorCoil[{3:#surfStatorCoil[]-1:4}]};

Physical Line("outer boundary stator", SURF_EXT) = {bndStatorOut[]};


Physical Line("boundary stator moving band", STATOR_BND_MOVING_BAND) = lnSMB[];

Color SteelBlue {Surface{surfStatorIron[]};}
Color Red {Surface{surfStatorCoil[{0:#surfStatorCoil[]-1:2}]};}
Color Yellow {Surface{surfStatorCoil[{1:#surfStatorCoil[]-1:2}]};}
Color SkyBlue {Surface{surfStatorOpening[]};}
Color SkyBlue {Surface{surfStatorMB[]};}

nicepos_stator[] = {CombinedBoundary{Surface{surfStatorIron[]};},
                    Boundary{Surface{surfStatorCoil[]};},
                    CombinedBoundary{Surface{surfStatorOpening[], surfStatorMB[]};} };

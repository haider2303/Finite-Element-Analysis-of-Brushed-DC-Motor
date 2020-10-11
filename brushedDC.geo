Include "brushedDC_data.geo";

Mesh.Algorithm = 1;
Geometry.CopyMeshingMethod = 1;

// characteristic lengths
// stator (out to in)
cls0  = (Rso*Pi/40/MD) ;
cls1  = (Rsop*Pi/40/MD) ;
cls2  = (Rsi*Pi/80/MD) ;
cls2_ = (Rsi*Pi/160/MD) ; //MB

//rotor (out to in)
clr0 = (w_rt/4/MD);
clr0_ =(cls2_/MD); //MB
clr1 = (w_rt/MD);
clr2 = (Rri*Pi/20/MD) ;

// center common to stator and rotor
cen = newp; Point(cen)  = {0.,0.,0., clr2};

Include "brushedDC_stator.geo";
Include "brushedDC_rotor.geo";

Coherence ;


//----------------------------------------
//For nice visualisation- just aesthetics
//----------------------------------------
//Physical Line(NICEPOS) = { nicepos_rotor[], nicepos_stator[] };

Hide { Point{ Point '*' }; Line{ Line '*' };}
Show { Line{ nicepos_rotor[], nicepos_stator[] }; }

//For post-processing...
//View[0].Light = 0;
View[0].NbIso = 25; // Number of intervals
View[0].IntervalsType = 1;




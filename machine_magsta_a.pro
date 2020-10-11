Group {
  DefineGroup[ // Domains appearing in the formulation that may be used or not...
    DomainL, DomainNL,
    Surf_Inf, Surf_bn0
  ];
}

Function{
  DefineConstant[ // With some default values
    Flag_NL,
    AxialLength        = 1,
    Nb_max_iter        = 50,
    relaxation_factor  = 1,
    stop_criterion     = 1e-5,
    reltol             = 1e-7,
    abstol             = 1e-5,
    po       = "Output/",
    po_mec   = "Output/Mechanical data/"
  ];

  DefineFunction[
    dhdb_NL
  ];
}

Include "BH_steelM19.pro"; // nonlinear BH caracteristic of magnetic material

Function {
  mu0 = 4.e-7 * Pi ;

  nu [#{Air, Stator_Winding, Rotor_Winding}]  = 1./mu0 ;

  If(!Flag_NL)
    nu [#{Stator_Core, Rotor_Core }]  = 1/(mur_fe * mu0) ;
  EndIf
  If(Flag_NL)
    // Interpolated data (you could change this law)
    nu [ DomainNL ] = nu_steelM19[$1] ;
    dhdb_NL [ DomainNL ] = dhdb_steelM19_NL[$1];
  EndIf

  // Maxwell stress tensor - for torque computation
  // $1 is an argument specified when calling the post-processing, namely the induction b == {d a} == {Curl a}
  T_max[] = (SquDyadicProduct[$1] - SquNorm[$1] * TensorDiag[0.5, 0.5, 0.5])/mu0 ;

  RotatePZ[] = Rotate[ Vector[$X,$Y,$Z], 0, 0, $1 ] ; // Watch out: Do not use XYZ[]!
  AngularPosition[] = (Atan2[$Y,$X]#7 >= 0.)? #7 : #7+2*Pi ;
}

//-------------------------------------------------------------------------------------

Jacobian {
  { Name Vol; Case { { Region All ; Jacobian Vol; } } }
}

Integration {
  { Name I1 ; Case {
      { Type Gauss ;
        Case {
          { GeoElement Triangle   ; NumberOfPoints  6 ; }
	  { GeoElement Quadrangle ; NumberOfPoints  4 ; }
	  { GeoElement Line       ; NumberOfPoints  13 ; }
        }
      }
    }
  }
}

//-------------------------------------------------------------------------------------

Constraint {

  { Name MVP_2D ;
    Case {
      { Region Surf_Inf ; Type Assign; Value 0. ; }
      { Region Surf_bn0 ; Type Assign; Value 0. ; }
    }
  }

}

//-----------------------------------------------------------------------------------------------

FunctionSpace {
  // Magnetic Vector Potential
  { Name Hcurl_a_2D ; Type Form1P ;
    BasisFunction {
      { Name se1 ; NameOfCoef ae1 ; Function BF_PerpendicularEdge ;
        Support Region[{ Domain}] ; Entity NodesOf [ All ] ; }
   }
    Constraint {
      { NameOfCoef ae1 ; EntityType NodesOf ; NameOfConstraint MVP_2D ; }
    }
  }

}

//-----------------------------------------------------------------------------------------------

Formulation {

  { Name MagSta_a_2D ; Type FemEquation ;
    Quantity {
      { Name a  ; Type Local  ; NameOfSpace Hcurl_a_2D ; }
    }
    Equation {
      Galerkin { [ nu[{d a}] * Dof{d a}  , {d a} ] ;
        In Domain ; Jacobian Vol ; Integration I1 ; }

      Galerkin { [ -js[]  , {a} ] ;
        In Windings ; Jacobian Vol ; Integration I1 ; }

      Galerkin { JacNL [ dhdb_NL[{d a}] * Dof{d a} , {d a} ] ;
        In DomainNL ; Jacobian Vol ; Integration I1 ; }
    }
  }

}

//-----------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------

Resolution {

  { Name Analysis ;
    System {
      { Name A ; NameOfFormulation MagSta_a_2D ; }
    }
    Operation {
      InitMovingBand2D[MB] ;  MeshMovingBand2D[MB] ;

      InitSolution[A]           ;

      If(Flag_NL==0)
        Generate[A] ; Solve[A] ;
      EndIf
      If(Flag_NL==1)
        IterativeLoop[Nb_max_iter, stop_criterion, relaxation_factor]{
          GenerateJac[A] ; SolveJac[A] ; }
      EndIf
      SaveSolution[A] ;

      PostOperation[Get_LocalFields] ;
      PostOperation[Get_GlobalQuantities] ;
      PostOperation[Get_Torque];
    }
  }

}

//-----------------------------------------------------------------------------------------------

PostProcessing {
  { Name MagSta_a_2D ; NameOfFormulation MagSta_a_2D ;
   PostQuantity {
     { Name a  ; Value { Term { [ {a} ] ; In Domain ; Jacobian Vol ; } } }
     { Name az ; Value { Term { [ CompZ[{a}] ] ; In Domain ; Jacobian Vol ; } } }
     { Name jz ; Value { Term { [ CompZ[js[]] ] ; In Windings ; Jacobian Vol ; } } }


     // The pole flux can be directly obtain from the value of magnetic vector potential at a point in the airgap and on the neutral axis
     // It is: AxialLength*(a_{at neutral axis}-a_{at neutral axis+90}) = AxialLength*2*a_{at neutral axis}

     { Name PoleFlux ; Value { Term { [ AxialLength*2*CompZ[{a}] ] ; In Domain ; Jacobian Vol ; } } }

     { Name b  ; Value { Term { [ {d a} ] ; In Domain ; Jacobian Vol ; } } }
     { Name b_radial  ; Value { Term { [ {d a}* Vector[  Cos[AngularPosition[]#4], Sin[#4], 0.] ] ; In Domain ; Jacobian Vol ; } } }
     { Name b_tangent ; Value { Term { [ {d a}* Vector[ -Sin[AngularPosition[]#4], Cos[#4], 0.] ] ; In Domain ; Jacobian Vol ; } } }

     { Name Force_vw ; // Force computation by Virtual Works
       Value {
         Integral {
           Type Global ; [ 0.5 * nu[] * VirtualWork [{d a}] * AxialLength ];
           In ElementsOf[Rotor_Airgap, OnOneSideOf Rotor_Bnd_MB]; Jacobian Vol ; Integration I1 ; }
       }
     }

     { Name Torque_vw ; Value { // Torque computation via Virtual Works
         Integral { Type Global ;
           [ CompZ[ 0.5 * nu[] * XYZ[] /\ VirtualWork[{d a}] ] * AxialLength ];
           In ElementsOf[Rotor_Airgap, OnOneSideOf Rotor_Bnd_MB]; Jacobian Vol ; Integration I1 ; }
       }
     }

     { Name Torque_Maxwell ; // Torque computation via Maxwell stress tensor
       Value {
         Integral {
           [ CompZ [ XYZ[] /\ (T_max[{d a}] * XYZ[]) ] * 2*Pi*AxialLength/SurfaceArea[] ] ;
           In Domain ; Jacobian Vol  ; Integration I1; }
       }
     }

 } }
}

//-----------------------------------------------------------------------------------------------
//-----------------------------------------------------------------------------------------------

PostOperation Get_LocalFields UsingPost MagSta_a_2D {
  Print[ jz, OnElementsOf Windings, File "jz.pos" ] ;
  Print[ b,  OnElementsOf Domain, File "b.pos" ];
  Print[ b_radial, OnElementsOf Domain, File "bradial.pos" ];
  Print[ b_radial, OnGrid {Rag_pos*Cos[$A], Rag_pos*Sin[$A], 0} {0:2*Pi:Pi/180, 0, 0} , Format Table,
    File "bradial.dat" ] ;
  Print[ az, OnElementsOf Domain, File "az.pos" ] ;
}

// SentToServer is only of interest in the GUI
PostOperation Get_GlobalQuantities UsingPost MagSta_a_2D {
  Print[ PoleFlux, OnPoint {Rro*Cos[Pi/4], Rro*Sin[Pi/4], 0}, Format Table,
    File > "PoleFlux.dat", SendToServer StrCat[po,"13PoleFlux"], Color "Pink" ] ;

  For k In {0:NbrPoles-1} //Checking anti-symmetry
    Print[ az, OnPoint {Rro*Cos[Pi/4+k*Pi/2], Rro*Sin[Pi/4+k*Pi/2],0}, Format Table,
      File > "aPnt.dat", SendToServer StrCat[po, Sprintf["70aPoint%g",k]], Color "Pink" ] ; // Value of a at the neutral axis
  EndFor
}

PostOperation Get_Torque UsingPost MagSta_a_2D {
  Print[ Torque_Maxwell[Rotor_Airgap], OnGlobal, Format TimeTable,
    File > "Tr.dat", Store 54, SendToServer StrCat[po_mec, "10T_rotor"], Color "Orange1" ];
  Print[ Torque_Maxwell[Stator_Airgap], OnGlobal, Format TimeTable,
    File > "Ts.dat", Store 55, SendToServer StrCat[po_mec, "11T_stator"], Color "Orange1" ];
  Print[ Torque_Maxwell[MovingBand_PhysicalNb], OnGlobal, Format TimeTable,
    File > "Tmb.dat", Store 56, SendToServer StrCat[po_mec, "12T_mb"], Color "Orange1" ];
}

DefineConstant[
  // Only of interest in the GUI
  R_ = {"Analysis", Name "GetDP/1ResolutionChoices", Visible 0},
  C_ = {"-solve -v2", Name "GetDP/9ComputeCommand", Visible 0},
  P_ = {"", Name "GetDP/2PostOperationChoices", Visible 0}
];

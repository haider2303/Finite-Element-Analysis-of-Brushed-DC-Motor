Function {

// values from measurements
Mat_steelM19_h = {
0.0000e+00,1.5121e+01,2.2718e+01,2.7843e+01,3.1871e+01,3.5365e+01,
3.8601e+01,4.1736e+01,4.4874e+01,4.8088e+01,5.1437e+01,5.4975e+01,
5.8753e+01,6.2824e+01,6.7245e+01,7.2084e+01,7.7420e+01,8.3350e+01,
9.0000e+01,9.7537e+01,1.0620e+02,1.1635e+02,1.2855e+02,1.4377e+02,
1.6375e+02,1.9187e+02,2.3483e+02,3.0651e+02,4.3526e+02,6.7491e+02,
1.1083e+03,1.8131e+03,2.8012e+03,4.0537e+03,5.5911e+03,7.4483e+03,
9.7088e+03,1.2487e+04,1.6041e+04,2.1249e+04,3.1313e+04,5.3589e+04,8.8477e+04,1.2433e+05,1.5997e+05,1.9775e+05,2.3402e+05} ;

Mat_steelM19_b = {
0.0000e+00,5.0000e-02,1.0000e-01,1.5000e-01,2.0000e-01,2.5000e-01,
3.0000e-01,3.5000e-01,4.0000e-01,4.5000e-01,5.0000e-01,5.5000e-01,
6.0000e-01,6.5000e-01,7.0000e-01,7.5000e-01,8.0000e-01,8.5000e-01,
9.0000e-01,9.5000e-01,1.0000e+00,1.0500e+00,1.1000e+00,1.1500e+00,
1.2000e+00,1.2500e+00,1.3000e+00,1.3500e+00,1.4000e+00,1.4500e+00,
1.5000e+00,1.5500e+00,1.6000e+00,1.6500e+00,1.7000e+00,1.7500e+00,
1.8000e+00,1.8500e+00,1.9000e+00,1.9500e+00,2.0000e+00,2.0500e+00,2.1000e+00,2.1500e+00,2.2000e+00,2.2500e+00,2.3000e+00} ;

Mat_steelM19_b2 = List[Mat_steelM19_b]^2 ;
Mat_steelM19_nu = List[Mat_steelM19_h]/List[Mat_steelM19_b] ;
Mat_steelM19_nu(0) = Mat_steelM19_nu(1);
Mat_steelM19_nu_b2  = ListAlt[Mat_steelM19_b2, Mat_steelM19_nu] ;
nu_steelM19[] = InterpolationLinear[SquNorm[$1]]{List[Mat_steelM19_nu_b2]} ;
dnudb2_steelM19[] = dInterpolationLinear[SquNorm[$1]]{List[Mat_steelM19_nu_b2]} ;
h_steelM19[] = nu_steelM19[$1] * $1 ;
dhdb_steelM19[] = TensorDiag[1,1,1]*nu_steelM19[$1#1] + 2*dnudb2_steelM19[#1] * SquDyadicProduct[#1] ;
dhdb_steelM19_NL[] = 2*dnudb2_steelM19[$1] * SquDyadicProduct[$1] ;


//analytical - obtained from fitting
k1 = 102.5 ; k2 = 0.1256; k3 = 3.791;
k1 = -46.3 ; k2 = 45.5 ; k3 = 1.65 ; // best choice - final fitted coefficients
nu_steelM19a[] = k1 + k2 * Exp[k3*SquNorm[$1]] ;
dnudb2_steelM19a[] = k2 * k3 * Exp[k3*SquNorm[$1]] ;
h_steelM19a[] = nu_steelM19a[$1] * $1 ;
dhdb_steelM19a[] = TensorDiag[1,1,1]*nu_steelM19a[$1#1] + 2*dnudb2_steelM19a[#1] * SquDyadicProduct[#1] ;
dhdb_steelM19a_NL[] = 2*dnudb2_steelM19a[$1] * SquDyadicProduct[$1] ;
}

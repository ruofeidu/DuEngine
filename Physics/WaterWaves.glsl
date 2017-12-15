// 
// https://en.wikipedia.org/wiki/Dispersion_(water_waves)

#define rnd(v)   fract( 43758.5453 * sin( (v) * 78.233 ) )
#define gauss(v) exp(  -.5*(v)*(v) )
#define tanh(x)  ( abs(x) > 8. ? sign(x) : tanh(x) ) // to allow values larger than 87

void mainImage( out vec4 O, vec2 U )
{
	vec2 R = iResolution.xy;
    U = 20.* ( U+U - R ) / R.y;                      // window radius (m)
    O -= O;
    float h = 100.,                                  // water depth (m) 
          t = iTime -9.*step(R.y,200.),              // splash sync for icon and window
          l = length(U),
          s = 0.;
    t = mod( t, 30.) * 2.;
    
    for (float k = 6.28/1.; k < 6.28/.01; k++ ) {    // for all wavelengthes
        float w = sqrt( (9.81*k + 74E-6*k*k*k) * tanh(k*h) ), // w(k) = dispertion relation
           // w² = ( gk + s/r k³ ) tanh(kh) , g=9.81, s=0.074, r=10³
              phi = k*l - w*t ;                      // opt: + rnd(k)*6.28 
        O += gauss( phi/10. ) * cos (phi ) / k;      // wave equation  * emission spectrum     
        s += 1./k;
    }
    O = .5 + 5.*O/s;              
}
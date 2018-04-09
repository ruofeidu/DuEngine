// https://www.shadertoy.com/view/XlcGWl
// attention: change flags accordingly in Image.

#define NB_CARS (16.*S)
#define  S   1.             // scale. 1: 1 pixel = 1m (for window height=300), 

#define RANDOM 1            // 1: each car has different A, VMAX and initPos

void mainImage( out vec4 O, vec2 U )
{

float 
  //DT = 1./60.,            // 1 frame = 1/60s
    DT = iTimeDelta,
    D0 = 5.,                // minimum distance
    VMAX = 130./3.6,        // maximum speed ( 130 km/h -> 130/3.6 )
    A = 100./3.6/9.,        // acceleration ( 0 to 100 km/h in 9" -> 100/3.6/9 )
    K3 = 1.66,              // safe space factor ( 10m at VMAX -> 10/sqrt(VMAX) )
    mR = 50.;               // Mouse influence radius   
#define sR vec2(2,1)        // road shape (via scaling). If circle, lR can simplifies.
#define lR length( sin(O.x+vec2(1.57,0)) / sR )
//#define lR 1.             // road shape (via scaling)

#define T(i) texture(iChannel0,vec2(mod(U.x+i,NB_CARS),U.y)/R)
#define PI 3.1415927

    vec2 R = iResolution.xy;

    if (iFrame==0) { // --- initialization of vehicles
#if RANDOM
        O = fract(4567.*sin(vec4(1234,-13.17,112, 1e5)*dot(U,vec2(1,.01754))));
        O.x *= 6.283;       // O.x = angle; O.y = speed. U.y*R = radius. 
        O.y = 0.;
        O.z = 1. + .1*(2.*O.z-1.); // O.z = acceleration fluctuation
        O.a = 1. + .1*(2.*O.z-1.); // O.a = VMAX fluctuation
#else
        O.x = U.x/NB_CARS * 6.283;
        O.y = 0.;
        O.z = O.a = 1.;
#endif
        return; 
      }
     
    O = T(0.); // current car data
    
    // --- calc distance to closest obstacle
    float d = 1e9, a;
    for (float i=1.; i<NB_CARS; i++) { 
        a = T(i).x-O.x; if ( a < -PI ) a += 2.*PI; // ( accounts for angle wrapping
        if ( a > 0. ) d = min(d,a);      
    }
    d *= U.y*lR*S; // convert angle to length
    
    // --- adjust speed to free space (different models)
  // d -=  D0 + K1*O.y*O.y;  // compare to safe distance func(speed)
  // d -=  D0 + K2*O.y; 
     d -=  D0 + K3*sqrt(O.y); 
    if ( d > 0. ) {    // enough space to accelerate
        if (O.y < VMAX*O.a) O.y += DT * A*O.z;
    }
    else if ( d < 0. ) // too close: breaks (different models)
         O.y *= pow(.9,DT*60.); // *= .9, adapted to other DT than 1/60
      // O.y = max(0., O.y-A*DT);
      // O.y = sqrt(-d/K); 

    // --- Mouse creates traffic jam
    vec2 P = U.y * sin( O.x + vec2(1.57,0)) *sR,
         M = (iMouse.xy-R/2.) * 300./R.y;
	if ( iMouse.z>0. && length(P-M) < 50. ) O.y *= .9;
        
    // --- moves     
    O.x = mod (O.x + DT* O.y/(U.y*lR*S), 2.*PI);   // convert to angle and wrap
}
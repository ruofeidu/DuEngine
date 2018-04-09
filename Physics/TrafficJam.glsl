// https://www.shadertoy.com/view/XlcGWl
// attention: change flags accordingly in BufA.

#define NB_CARS (16.*S)       // number of cars per driving line
#define  S   1.               // scale.    1: 1 pixel = 1m (for window height = 300), 

#define LINE0 30.             // first and last driving lines to display (every 10)
#define LINE1 100.

float VMAX = 130./3.6;        // maximum speed ( 130 km/h -> 130/3.6 )
//#define sR 1.               // road shape (via scaling)
#define sR vec2(2,1)

#define T(x,y) texture(iChannel0,(.5+vec2(x,y))/R)              // car data


void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy,
    M = (iMouse.xy-R/2.) * 300./R.y;
    U = (U-R/2.)         * 300./R.y;
    O -= O;
  //O += smoothstep(1.,0.,abs(length(U/sR)-LINE0+5.));
  
    if ( iMouse.z>0. && length(U-M) < 50. ) O.x = .5;             // Mouse influence area

    // --- splat vehicles
    
    float y = length(U/sR)+5.;                                    // driving line at U
    if ( y<LINE0-1. || y > LINE1+1. ) return;
    y = 10.*floor(y/10.);
    {
  //for (float y=LINE0; y<LINE1; y+=10.)  {                       // foreach line
        for (float x=0.; x<NB_CARS; x++) {                        // foreach car on the line
            vec2 C = T(x,y).xy,
                 P = y * sin( C.x + vec2(1.57,0)) *sR;            // car position
            float l = length(P-U)*S;
            if (l<4.5) O +=  smoothstep(4.4,4., l)                // car sprite
                      //   * (.5+.5*cos(x+y+vec4(0,2.1,-2.1,0))); // car color: random
                           * vec4(1,vec3(C.y/VMAX));              // car color: speed
        }
        O += .5*smoothstep(1.,0.,abs(length(U/sR)-y-5.));         // borders of driving lines
        O += .5*smoothstep(1.,0.,abs(length(U/sR)-y+5.));
    }
}
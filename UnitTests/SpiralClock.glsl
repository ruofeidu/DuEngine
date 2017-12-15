// 
// animated version of https://www.shadertoy.com/view/ltyXzw

// --- access to the image of ascii code c - from https://www.shadertoy.com/view/MtyXRW
#define C(c) T+= U.x<.0||U.x>1.||U.y<0.||U.y>1. ?vec4(0): texture( iChannel3, U/16. + fract( floor(vec2(c, 15.999-float((c)/16))) / 16.)); U.x-=.3; 

// --- display int2
float pInt(vec2 U, int n) {
    vec4 T = vec4(0); U += .5; 
    if (n>9) { U.x+=.15; C(48+ n/10); n -= n/10*10; } // tens
    C(48+n);                                          // units
    return  T.x; // length(T.yz)==0. ? -1 : T.x;      // -1 for out of BBox.
}

#define sqr(x) ((x)*(x))

void mainImage( out vec4 O,  vec2 U )
{
	O.xyz = iResolution;
    U = ((U+U-O.xy) / O.y + vec2(0,.07) )*.75;

    float z = iTime,
        tau = 6.2832,
          d = length(U), a = atan(U.x,U.y),
          s = a - tau*4.*sqrt(d) +z,       // spiral coordinate
          t = iDate.w/60.;
    
    O += -O
    // --- spiral
	  +  smoothstep(.95,.8, sin(s))
	// --- ticks
      -  smoothstep(.8, .95, sin(s-.5)) 
         * ( 4.*max(0.,cos(60.*a)-.75) + 20.*max(0.,cos(12.*a)-.9) )
	// --- hands
#define h(D,e,l) smoothstep(.001/d,.0,abs(fract(.5+a/tau-t/D )-.5)-e*.001/d) * smoothstep(-.95,-.8, cos(s)-l)
       - h(1.  ,0.,1.4)   // seconds
       - h(60. ,1., .5)   // minutes
       - h(720.,2., .8);  // hours

    // --- digits - explicit way
    for (float i=0.; i<79.; i++)
        d = .055*sqr((i-6.)/12.+ fract(z/tau)),
        O -= .7 * pInt( (U-d*sin(i*tau/12.+vec2(0,1.57))) *2./d,    // pos
                        int(1.+mod(i-1.,12.)) );                    // number

    // --- digits - procedural way : cf https://www.shadertoy.com/view/ltyXzw
}
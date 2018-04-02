// https://www.shadertoy.com/view/MdGcWW
// ref: https://upload.wikimedia.org/wikipedia/commons/7/79/Eiffel_Tower_plans_07.jpg

#define S(v) smoothstep(1.,0.,abs(v)/e) // antialiased curve/line

// --- a piece of nx*ny units of framework of type i, 
//     placed at dx0,dy0 and scaled/deformed with dx1,s0,s1,sy
float strip(vec2 U, float dx0,float s0, float dx1,float s1, float y0, float sy, float nx, float ny, int i){
    float y = (U.y-y0)/sy, v,
          x = U.x / mix(s0,s1,y) - mix(dx0,dx1,y),// scaling/offset/shear/disto
          e = min(fwidth(y*ny),fwidth(x*nx));     // pixel size (for AA)
       // e = max(ny/sy,nx/s1)/iResolution.y;
    if (y < -e/ny || y > 1.+e/ny || x < -e/nx || x > 1.+e/nx) return 0.;
    x = fract(x*nx);                   // one module
    y = fract(y*ny);
    v = S(x)+S(x-1.)+S(x+y-1.)+S(x-y); // vertical sides + simple X
    if (i>0) v += S(y)+S(y-1.);        // horizontal separators
    if (i>1) v += S(x-.5);             // vertical mid-separator
    if (i>2) v += S(y-.5);             // horizontal mid-separator
    return v;
}

void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy;
         U = abs(U-.2-vec2(.5*R.x,0))/R.y;
    float e = 1./R.y; 
    O -= O;
    O += S(U.x)*step(.96,U.y);                           // antenna
    O += S(length(U-vec2(0,.96))-1./70.);                // head
             //   dx0 s0  dx1 s1    y0  s    nx ny type
    O += strip(U, .0,.015,.0,.015, .93,.03,  3.,6.,0);   // jaw
    O += strip(U, .0,.02, .0,.03,  .90,.03,  2.,3.,1);   // deck 3
    O += strip(U, .0,.03, .0,.02,  .60,.30,  1.,11.,1);  // neck 2
    O += strip(U, .5,.04, .0,.03,  .40,.20,  1.,6.,1);   // neck 1
    O += strip(U, .0,.07, .0,.06,  .37,.03,  3.,2.,2);   // deck 2
    O += strip(U, 1.,.07, .5,.04,  .20,.20,  1.,5.,2);   // legs 2
    O += strip(U, .0,.163, .0,.14, .158,.042,5.,2.,2);   // deck 1
    O += strip(U, 2.6,.07, 1.,.07, .00,.20,  1.,4.,3);   // legs 1
    O += S(length(U)-1./6.3);                            // arch
    O = 1.-O;
                 
}
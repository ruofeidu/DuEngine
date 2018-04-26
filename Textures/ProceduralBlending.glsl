// Xd3XDr
// NB: trick published in https://hal.inria.fr/inria-00537472
// for the simple blend normalization, see https://www.shadertoy.com/view/4dcSDr
 // blending procedurals sprites or patches (yes, this can exist :-) ) creates ghosting. To avoid it, blend only base  noise and deferred the non-linear transform. left to right: naive blend, normalized blend,base noise blend + deferred
// procedural texture: N(U, base noise)  T(U): base noise.
//      for fractal noise, we should store each band.

#define T(U) texture(iChannel0,2.*U/4.)      // *1.3 to 2 if dark texture
#define N(U,T) smoothstep(.1,.0,abs(sin(U.x+(T).x+.03*vec4(0,1,2,0))-.5))
//#define N(U,T) smoothstep(.5,.0,abs(sin(30.*U.y+T.x+.3*vec4(0,1,2,0))-.5))
//#define N(U,T) smoothstep(.5,.0,abs(sin(30.*U.y+cos(10.*U.x)+T.x+.3*vec4(0,1,2,0))-.5))

//#define mean texture(iChannel0,2.*U,10.)*1.3
#define mean .1 // estimation of mean texture after transformation


#define K(U) smoothstep(.2, .0, length(U))      // smooth kernel
//#define K(U) smoothstep(.13, .12, length(U))  // disk kernel
#define rnd(i) fract(1e4*sin(i+vec2(0,73.17)))  // texture offset


void mainImage( out vec4 O,  vec2 U )
{
    O-=O;
    vec4 Od = O;
    vec2 R = iResolution.xy, r=R/R.y;
    if (abs(U.x-R.x*.33)<2. || abs(U.x-R.x*.67)<2.) { O++; return; }
    U /= R.y;
    float s=0., s2=0., v;
    for (int i=0; i<15; i++)
    {
        vec2 V = U-rnd(vec2(i))*r + .1*cos(vec2(i)+iTime+vec2(0,1.6)); // sprite position
        v = K(.3*V); s += v; s2 += v*v;                          // kernel and momentums
        O  += v* N(V,T(V)); // regular evaluation of complete procedural noise before blend
        Od += v*T(V);       // deferred: only the base noise is blended
    }
   
    if     (U.x>r.x*.67) O = Od; // regular or deferred.
    
    if     (U.x<r.x*.33)  // normalization
            O /= s;                          // linear blend
    else    O = mean + (O-s*mean)/sqrt(s2);  // variance preserving blend
 
    if     (U.x>r.x*.67) O = N(U,O); // for deferred.
}

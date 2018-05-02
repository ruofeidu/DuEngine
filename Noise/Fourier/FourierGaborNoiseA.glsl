// 4dGGz1
// do your operation in spectral domain here. 
// Or tune #PROF #PHASE line 35-36

#define SIZE (iResolution.x/2.-30.) //Size must be changed in each tab.

bool keyPress(int ascii) { return (texture(iChannel2,vec2((.5+float(ascii))/256.,0.25)).x > 0.); }
float rand(vec2 uv) { return fract(1e5*sin(dot(uv,vec2(17.4,123.7)))); }     // point -> rnd [0,1[
#define srnd(x) (2.*rand(x)-1.)
float gauss(float x) { return exp(-.5*x*x); }
#define ang(a)  vec2(cos(a), sin(a))                         // used to set the complex exp(i.a)
vec2 cmul (vec2 a,float b) { return mat2(a,-a.y,a.x) * vec2(cos(b),sin(b)); } // complex a*exp(i.b)


void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy;
    if ( U==vec2(.5)) {
        if (iFrame==0) O.zw = vec2(0,0);
        else           O.zw = texture(iChannel1, U/R).zw;  
        if ( keyPress(32) ) 
            if (iMouse.x/R.x<.5) O.z = mod(O.z+.1, 5.) ; // persistant key flag for left window
            else                 O.w = mod(O.w+.1, 5.) ; // persistant key flag for right window
        return;
    }
    
    U -= .5;  // freq 0 must exist
    
    U = 2.*U-SIZE;
    vec2 X = U/SIZE, T,
         M = 2.*iMouse.xy/R-1.;
    float I=1., l = length(X), F, s = sign(-X.x); // s to help making a symmetric spectrum (phases included !)
    
    
    // --- your custom Fourier-space function here ------------
#define PROF  32 // (32) spectrum profile ( = Fourier modulus)
#define PHASE 30 // (30) spectrum phases
    
#if 0 // 0:  scale shape at zoom    1: scale fourier at zoom
    X *= SIZE/256.;  l *= SIZE/256., I *= SIZE/256.; 
#endif    
    
                                     // --- modulus profile here
#if PROF==0
    F = 1.;                                     // flat
#elif PROF==1
    F = gauss(l/.05)*10.;                       // gauss
#elif PROF==101
    F = gauss(l/.01*M.x)*10.;                   // tunable gauss
#elif PROF==11
    F = exp(-l/.05)*10.;                        // exp
#elif PROF==111
    F = exp(-l/.02*(1.+M.x))*10.;               // tunable exp
#elif PROF==2
    float l1 = length(X-vec2(.07,0)),
          l2 = length(X+vec2(.07,0));  
    F = ( gauss(l1/.02)+gauss(l2/.02) )*10.;    // bi-lobe
  //l1 = length(X-vec2(.1,.05)),
  //l2 = length(X+vec2(.1,.05)); 
  //F += ( gauss(l1/.015)+gauss(l2/.015) )*5.;  // additionnal bi-lobe
#elif PROF==3
    F = gauss(abs(l-.12)/.005)*10.;             // --- ring (blue noise)
#elif PROF==31
 // F = gauss(abs(l-.22)/.002)*10.;             // variant
 // F = gauss(abs(l-.5)/.05)*2.;                // variant: 1/2 thinnest blue noise
    F = gauss(abs(l-.95)/.01)*4.;               // variant: thinnest blue noise
#elif PROF==32
    F = gauss(abs(l-.32-.1*cos(.1*iTime))/.002)*10.;             // variant
#elif PROF==4
    F = gauss(abs(l-.12)/.007)*10.*gauss(length(X*vec2(.1,1))/.03)*3.;  
#elif PROF==5
    F = fract(sin(dot(U, vec2(12.9898, 78.233)))* 43758.5453) *2.-1.; // random
  //F = fract(sin(dot(U, vec2(13, 79)))* 4e5) *2.-1.; 
#elif PROF==6                                   // --- let generate aliasing ! :-p
  //F = gauss(abs(l-.95)/.002)*10.; // for qualibration.
    l = length(X-.8); l *= SIZE/256.;
    F += gauss(l/.05)*10.;             
    l = length(X+.8); l *= SIZE/256.;
    F += gauss(l/.05)*10.;             
#elif PROF==61                                  // variant
    F = smoothstep(1.,1.02,l-.0)*100.;    // try -.1, -.35 
#elif PROF==70                                  // structure phases
    F = smoothstep(.01,0.,abs(abs(X.x)-.3)) * gauss(X.y/.1) * 3.;
#endif
 
                                     // --- phases here ( 0 for direct Fourier transform)
  //vec2 P = ang(6.2832*rand(U));               // default: random phases
    vec2 P = ang(6.2832*rand(X*s)*s);           // with phase symmetry
#if PHASE==0
    T = vec2(1,0);                              // no phases ( all 0 )
#elif PHASE==1
    T = P;                                      // random phases
#elif PHASE==20
    T = ang(6.2832*length(30.*X));              // correlated phase: linear 
#elif PHASE==21
    T = ang(6.2832*length(sin(30.*X)));         // correlated phase
#elif PHASE==212
    T = ang(6.2832*length(sin(100.*M*X)));      // variant with mouse gain
#elif PHASE==22
    T = normalize( vec2(abs(X.x),X.y)-vec2(.07,0))*.5; // rotating around (.07,0) - use with PROF=2
#elif PHASE==3
    T = cmul(P,2.*iTime*s);                     // phase shift with time (X biased)   
#elif PHASE==30
    float t = .32*iTime, a = fract(t);          // phase shift with time (morph)
    T = ang(6.2832*mix(srnd(X*s+floor(t)),
                       srnd(X*s+ceil (t)),
                       a)  *s / sqrt(a*a+(1.-a)*(1.-a))); // preserve variance along time
#elif PHASE==31
    T = cmul(P,2.*iTime*s*sqrt(30.*abs(X.x))); // dispersive phase shift 
  //T = cmul(P,2.*iTime*s*sqrt(1./(1e-5+abs(X.x)))); 
#endif
    
    
    O = vec4(T*F,0,0)*sqrt(I); //  *SIZE;  
}
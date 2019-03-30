// https://www.shadertoy.com/view/MslfDf
// Poisson disk : repealing particles.

#define rnd(U)  ( 2. * fract(4567.89*sin(4567.89*U*mat2(1,-13.17,377.1,-78.73))) - 1. )
 
#define T(i,j)  texture(iChannel0, fract( ( U + vec2(i,j) ) / iResolution.xy ) ).xy

void mainImage( out vec4 O, vec2 U )
{
    if (iFrame==0) {
        O.xy = .2*rnd(U);                   // particles location = vec2(i,j) + stored perturb
        return;                             // start with jittered grid (rough approx of Poisson disc)
    }
    
    vec2 U0 = T(0,0), D, F = vec2(0);
    
    for (int j=-4; j<=4; j++)               // look in the neighborhood
        for (int i=-4; i<=4; i++)           // with [-3,3]^2, a leak occurs at ~100"+resize
            if ( vec2(i,j) != vec2(0) ) {
                D = vec2(i,j)+T(i,j) - U0;  // distance vector to particle (i,j)
                float l = length(D);
                F += D / l * max(2.-l,0.);  // simulates a spring (only repealing, otherwise clamped)
            }
    
    O.xy = U0 - .1* F;                      // displace particle proportionaly to force
}

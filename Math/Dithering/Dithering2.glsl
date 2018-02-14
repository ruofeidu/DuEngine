// https://www.shadertoy.com/view/ltlfzX
#define SCALE 4.

void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy,
         A = sin(3.14*u/SCALE);
    vec4 S =  texture(iChannel0, u/R ); 
    
    int t = int(iTime/2.);    

    float d = (t/2)%2 < 1 
        ? .5+.5*A.x*A.y                                     // sin(x)*sin(y)
        : texture(iChannel1, (.5+floor(u*2./SCALE))/8. ).r; // Bayer matrix
    
    if (t%2<1) S = S.rrrr;                                  // B&W or color

    O = smoothstep(-.25, .25, S - d );                      // apply dither
}
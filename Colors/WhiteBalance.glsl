// https://www.shadertoy.com/view/XlSyRG
#define T(l) texture( iChannel0, U , l) 

void mainImage( out vec4 O, vec2 U )
{
    U /= iResolution.xy;
    O = U.x<.5 
        ? T(0.) - T(100.) +.5
        : T(0.);
}

// https://www.shadertoy.com/view/ltsBzr
#define rnd(U)   fract(sin(dot(U, vec2(12.9898, 78.233))) * 43758.5453)
#define T(U,d)   texelFetch( iChannel0, ivec2(U) - d, 0 )

void mainImage( out vec4 O, vec2 U )
{
    int i = iFrame%300;
    
    O = i == 0 
        ? float( rnd(U) < .01 ) * vec4(1,1,0,0) // .r = data, scattered 1 among zeros.
        : T(U,0);                               // .g = index count
    
    if ( i <= int(log2(iResolution.x))+1 )        
        O.g += T(U,ivec2(1<<(i-1),0)).g;        // the hearth of the algorithm
}
/*
void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy, U = u/R;
    
    O = step( U.x < .5 ? texelFetch(iChannel2,ivec2(u)%1024,0)    // bluenoise dithering
                       : texelFetch(iChannel1,ivec2(u)%8,0).xxxx, // Bayer dithering
              texture(iChannel0,U)                       // source
            );
    if (iMouse.z>0.) O = O.rrrr;
    if (u.x-.5==R.x/2.) O.x++;
}
*/
void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy, U = u/R;
    
    O = step( U.x < .5 ? texelFetch(iChannel2,ivec2(u)%1024,0)    // bluenoise dithering
                       : texelFetch(iChannel1,ivec2(u)%8,0).xxxx, // Bayer dithering
              texture(iChannel0,U)                       // source
            );
    if (iMouse.z>0.) O = O.rrrr;
    if (u.x-.5==R.x/2.) O.x++;
}

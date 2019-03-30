void mainImage( out vec4 O, vec2 U )
{
    vec2 R =  iResolution.xy,
         M = length(iMouse.xy)>10. ? iMouse.xy : R*vec2(.5+.5*cos(.5*iTime));
    
    float z =  9.*M.y/R.y;  int iz = int(z);
    O = U.x < R.x/2.
        ? texelFetch( iChannel0, ivec2(2.*U)>>iz , iz )
        : textureLod( iChannel0, 2.*U/R, floor(z));
    O += smoothstep( .035, .03, length((U-.45*vec2(R.x,0))/R.y-vec2(0,floor(z)/9.)));
}

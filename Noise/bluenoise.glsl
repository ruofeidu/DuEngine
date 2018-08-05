// see also https://www.shadertoy.com/view/lldcD7

void mainImage( out vec4 O,  vec2 U )
{
    vec3 R = iResolution/2.;
    vec2 S = sign(U-.5-R.xy);
    if (S.x*S.y==0.) { O=vec4(1); return; }              // separation
    
    if ( S.y > 0. ) U =  U-R.zy;                         // top = blue noise
    if ( S.x > 0. ) U = (U-R.xz) / 3.;                   // right = zoom
    int z = int(iMouse.y*4./R.y);                        // LOD level
    O = S.y > 0.
            ? texelFetch( iChannel0, ivec2(U)%(1024>>z), z )  // top = blue noise
            : texelFetch( iChannel1, ivec2(U)%( 256>>z), z ); // bottom = white noise
 // O = (O-.5) *sqrt(exp2(2.*float(z))) +.5;             // variance normalization
    O = (O-.5) *exp2(float(z)) +.5;                      // (simplification)
}
// https://www.shadertoy.com/view/ltlfRl
// principle : O.a stores intersection = previous * tested disk.
//             Ultimate MIPmap = 0 => no intersection => state += tested disk.

#define p -0.2                                // radius time-decrease power law
#define shape(P,U,r) max( 0., r-length(P-U) ) // put your favorite shape here

#define rand(p)  fract( 43758.5453123 * sin( p* vec2(12.9898, 78.233)) )
 
void mainImage( out vec4 O, vec2 U )
{
    int i = iFrame;
    if (i == 0 ) { O-=O; return; } 
    vec2 R = iResolution.xy, P;
    
    O = texelFetch(iChannel0, ivec2(U), 0);   // previous state
    float v = textureLod(iChannel0, vec2(.5), 100.).a, // result of .g collision test
         r0 = .2*R.y,
          r = r0 * pow(float(i), p);          // radius time-decrease law
    if (v==0.) O.r += O.g,                    // no collision between .r and .g: accept .g
               O.b += r/r0* min(O.g,1.);      // drawable version (we could antialias there).
            // O.b += (16./r)*float(0.<O.g);  // variant (to use with rainbow in Image)
    O.g = 0.;                                 // erase .g, reset test buffer .a
    O.a = O.r;
    P = rand(vec2(i))*R;                      // try new disk
    O.g += shape(P,U,r);                      // temptative shape stored in .g
    O.a *= float(O.g>0.);                     // intersection in .a. MIPmap cumulates on whole image
}
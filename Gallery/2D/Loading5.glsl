// https://www.shadertoy.com/view/XsVBz3
#define S(v,r)  smoothstep ( 3./R.y, 0., length(v)-r ) // antialiased draw

#define hue(v)  ( .6 + .6 * cos( 6.3*(v) + vec4(0,23,21,0) ) ) // from https://www.shadertoy.com/view/ll2cDc

void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy;
    U = ( U+U - R ) / R.y;                           // normalized coordinates
    
    float r = .5,                                    // circle radius
          n = 1.+30.*(.5+.5*sin(iTime)),             // number of dots
          l = length(U),                             // polar coordinates
          a = atan(U.y,U.x),
    
     u = r * ( fract( a*n/6.283 ) - .5 ) / (n/6.283),// local coordinates in
     v = l - r,                                      // cells along the circle
     i = floor( a*n/6.283 );                         // dot number
    
    U = vec2(u,v);
    O = S( U, .03 ) * hue(i/n);                      // draw blobs
    
    if (iMouse.z>0.) U = abs(U)-.1, O += S(max(U.x,U.y),.0); // click to see Bboxes
}
// https://www.shadertoy.com/view/wdd3DS
// Minimalistic version of tunable https://shadertoy.com/view/Ms3czX .
// Readable version at bottom ;-)


// --- 286 chars  ( -3/4 by Xor, -1 by iapafoto, -7 by Fab )
// attention: in versions where 1.57 is factored in r,
// by turning *1.5/l in P into 1.57, the pattern gets too symmetrical around 20"

#define r(a)   mat2(cos( 1.57*a + vec4(0,33,11,0))) // https://www.shadertoy.com/view/XlsyWX
#define t    ( 1.- abs( 2.* texture(iChannel0, P/=2. ).r -1. ) ) //
                              // colored variant: del .r         //
#define mainImage(O,u)                                            \
    vec2 R = iResolution.xy, P,V; O++;                            \
    for (float l=.1; l < 3.1; l+=.1 )                             \
        V =  r( -(1.+l) ) * (u+u-R)/R.y  * vec2(2.4,4),           \
        P =  r( iTime/l + l/.1 ) * .5*V/l,                        \
        O *= exp( min( abs( length(V)-l )/.3 - 1., 0.)            \
                   * t * t * t * t / l )                         /*




// --- 297 chars

#define r(a)   mat2(cos( a + vec4(0,33,11,0))) // https://www.shadertoy.com/view/XlsyWX
#define t    ( 1.- abs( 2.* texture(iChannel0, P/=2. ) -1. ) ) //
                                                               //
#define mainImage(O,u)                                          \
    vec2 R = iResolution.xy, P,V;                               \
    for (float l=.1, n=1.; l < 3.; l+=.1 )                      \
        V =  r( -1.57*(1.+l) ) * (u+u-R)/R.y  * vec2(2.4,4),    \
        P =  r( iTime * 1.5/l + n++ ) * .5*V/l,                 \
        O +=   max( 1.- abs( length(V)-l )/.3 , 0.)             \
             * t * t * t * t / l;                               \
    O = exp(-O.rrrr)  /* colored variant: del .rrrr  */        /*




// --- 305 chars

#define r(a)   mat2(cos( a + vec4(0,33,11,0))) // https://www.shadertoy.com/view/XlsyWX
#define t    ( 1.- abs( 2.* texture(iChannel0, P/=2. ) -1. ) ) //
                                                               //
#define mainImage(O,u)                                          \
    vec2 R = iResolution.xy, P,                                 \
         U = 1.2* ( u+u - R ) / R.y;                            \
    for (float l=.1, n=1.; l < 3.; l+=.1)                       \
        R = ( r( -1.57*(1.+l) ) * U ) / vec2(.5,.3),            \
        P =   r(  iTime * 1.5/l + n++ ) * .5*R/l,               \
        O +=   max( 1.- abs( length(R)-l )/.3 , 0.)             \
             * t * t * t * t / l;                               \
    O = exp(-O.rrrr)                                           /*




// --- 399 chars

#define rot(a)   mat2(cos(a),-sin(a),sin(a),cos(a))
#define t(U)   ( 1.- abs( 2.* texture(iChannel0,U) -1. ) )
vec4 T(vec2 U) { return  8.* t(U/16.) * t(U/8.) * t(U/4.) * t(U/2.) ; }

void mainImage( out vec4 O, vec2 u )
{
    vec2 R = iResolution.xy, V,
         U = 1.2* (u+u-R)/R.y;
    O -= O;

    for (float l = .1,n=1.; l<3.; l+=.1, n++)
        V = ( rot(-1.57*(1.+l)) * U ) / vec2(.5,.3),
        O +=   smoothstep( .3, 0., abs( length(V)-l ) )
             * T( rot( iTime*(1.5/l)+n ) * .5*V/l ) / l;

    O = exp(-O.rrrr/8.);     // colored variant: del .rrrr
}

/**/

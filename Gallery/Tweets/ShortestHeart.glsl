// https://www.shadertoy.com/view/4tffD8
// variant of  https://shadertoy.com/view/4tXfW8
// inspired from https://www.shadertoy.com/view/XlsfDr


/**/ // -10 by coyote 

#define D(a) ( U -1.2 + .5*dot( vec4(a+13,5,a-2,1), cos( asin( pow( abs(U.x)/8., .33) ) * vec4(1,2,3,4) )) )

#define mainImage(O,u)                   \
    vec2 R =  iResolution.xy,            \
         U = 9.5*( u+u - R ) / R.y;      \
    O.ar = - D( - ) * D( )

             
/**/
             
             
             
             
/** // original: 179 chars    

#define D(a,b)  .5* ( U.y -2.4 + dot( vec4(a 13,5,b 2,1), cos( asin( pow( abs(U.x)/16., .33) ) * vec4(1,2,3,4) )) ) 

#define mainImage(O,u)                   \
    vec2 R =  iResolution.xy,            \
         U = 19.* ( u+u - R.xy ) / R.y;  \
    O.r =  - D( - , ) * D( , - )

/**/
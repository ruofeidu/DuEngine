// 
#define mainImage(O,u)                            \
    vec2 R = iResolution.xy, U = 1.5*(u+u-R)/R.y; \
    float x = abs(U.x), z = abs(U.y-.2)*2.+.1;    \
    O += 1.-1e2*(  max(0.,.1 - x*x/6.-z*z)        \
                 + max(0.,.72*exp(-3.*x)-.02*x - abs( U.y-x+cos(6.*x)/6.) ) )

        

        
/** // 199 chars

#define S(v,e) 1e2*max(0.,e-abs(v))

#define mainImage(O,u)                            \
    vec2 R = iResolution.xy, U = 1.5*(u+u-R)/R.y; \
    float x = abs(U.x), z = abs(U.y-.2)*2.+.1;    \
    O += 1. - S(x*x/6.+z*z,.1)                    \
            - S(U.y-x+cos(6.*x)/6.,.72*exp(-3.*x)-.02*x)
/**/         




/** // 231 chars

#define S(v,e) smoothstep(2./R.y,0.,abs(v)-(e))

void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy;
    U = 1.5*(U+U-R)/R.y; 
    float x = abs(U.x), y=U.y,z=abs(y-.2)+.05;
    O = vec4(1)
         - S(y-x+cos(6.*x)/6.,.72*exp(-3.*x)-.02*x)
         - S(x*x/6.+z*z*4.,.1)
         ;//- S(x*x+y*y/3.,.1);   // try also without this one
}
/**/




/**

#define S(v,e) smoothstep(2./R.y,0.,abs(v)-(e))

void mainImage( out vec4 O, vec2 U )
{
    vec2 R = iResolution.xy;
    U = 1.5*(U+U-R)/R.y; 
    float x = abs(U.x), y=U.y,z;
    O = vec4(1);
    //O -= S(y-x+cos(6.*x)/6.,.24-.2*x);
    //O -= S(y-x+cos(6.*x)/6.,.7*exp(-3.*x));
    O -= S(y-x+cos(6.*x)/6.,.72*exp(-3.*x)-.02*x);
    z=y-.2; O -= S(x*x/6.+z*z*4.,.1);
            O -= S(x*x+y*y/3.,.1);
    //      O -= S(x*x/2.+y*y/3.,.1);
  //z=y+.1; O -= S(x*x*2.+z*z/4.,.1);
}

/**/
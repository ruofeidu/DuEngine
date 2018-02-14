// https://www.shadertoy.com/view/4lSfWV
#define S(v) smoothstep( 2./R.y, -2./R.y, v )
#define B(v) S( abs(v) - .04 )

#define mainImage(O,u)                                  \
	vec2  R = iResolution.xy,                           \
          U = u+u-R;                                    \
    float l = length(U)/R.y *1.2,                       \
          a = mod(atan(U.y,U.x)+.3,.52)-.3;             \
    U  = l * sin(a+vec2(33,0));                         \
    O -=  B(l-1.) + B(l-.4) + B(l-.15) + B(a*l)*S(l-.8) \
        + B(U.x-.8)*S(abs(U.y+.1)-.14) + B(U.y+.2)*S(.8-l)*S(l-1.) \
        - 1.  // S(U.y-.04)*S(-U.y-.22)
        
        
        
        
/** // 302 chars

#define S(v) smoothstep(2./R.y,-2./R.y,v)
#define B(v) S(abs(v)-.04)

#define mainImage(O,u)                                  \
	vec2  R = iResolution.xy,                           \
          U = (u+u-R)/R.y;                              \
    float l = length(U)*1.2,                            \
          a = mod(atan(U.y,U.x)+.3,.52)-.3;             \
    U  = l * vec2(cos(a),sin(a));                       \
    O -=  B(l-1.) + B(l-.4) + B(l-.15) + B(a*l)*S(l-.8) \
        + B(U.x-.8)*S(abs(U.y+.1)-.14) + B(U.y+.2)*S(.8-l)*S(l-1.) \
        - 1.  // S(U.y-.04)*S(-U.y-.22)

/**/
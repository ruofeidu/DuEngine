// https://www.shadertoy.com/view/XtSfDV

#define S(v) smoothstep( 2./R.y, -2./R.y, v )
#define B(v,e) S( abs(v) - e )

#define mainImage(O,u)                            \
	vec2  R = iResolution.xy,                     \
          U = u+u-R;                              \
    float l = length(U)/R.y *1.2,   d=.131,       \
          a = mod( atan(U.y,U.x) +d, d+d ) - d;   \
    O -=   -B(l,.1) -1.4*B(l,.22) + B(l,.26) + B(l-1.,.07)        \
          + B(a*l,.03)*S(l-1.1)+ B((a+d)*l,.03)*S(abs(l-.92)-.02) \
          + B(l-1.12,.02)*S(abs(a)-.05) - 1.
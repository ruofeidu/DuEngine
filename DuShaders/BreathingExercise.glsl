// starea@shadertoy
// link to demo: https://www.shadertoy.com/view/XtXyDX
// advise taken from Dr. Neyret.
/*
#define mainImage( O, U )                                     \
    float l = length( U+U - (O.xy=iResolution.xy) ) / O.y,    \
          t = iTime * .5;                                     \
    O =   l < .1 + .3 * abs(sin(t)) ? vec4(1)                \
        : l < .5 + .1 * abs(cos(t)) ? vec4(.35, .55, .95, 1) \
        :                             vec4(.4, .6, 1, 1)
*/
// the preview does not compile the macros
const vec4 BACKGROUND = vec4(.4, .6, 1, 1),
           INNER      = vec4(1),
           INBETWEEN  = vec4(.35, .55, .95, 1);

void mainImage( out vec4 O, vec2 U )
{
	U = ( U+U -  iResolution.xy ) / iResolution.y;
    float l = length(U),
          t = iTime * .5;
    O =   l < .1 + .3 * abs(sin(t)) ? INNER 
        : l < .5 + .1 * abs(cos(t)) ? INBETWEEN 
        :                             BACKGROUND;
}

/*
const vec3 BACKGROUND = vec3(0.4, 0.6, 1.0);
const vec3 INNER = vec3(1.0);
const vec3 INBETWEEN = vec3(0.35, 0.55, 0.95);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// vec2 uv = (2.0 * fragCoord.xy / iResolution.xy - 1.0) * (iResolution.xy / iResolution.yy);
	vec2 uv = (2. * fragCoord -  iResolution.xy ) / iResolution.y;
    vec3 col = length(uv - vec2(0.0)) < 0.53 + 0.1 * abs(cos(iTime * 0.5)) ? INBETWEEN : BACKGROUND;
    if (length(uv - vec2(0.0)) < 0.1 + 0.4 * abs(sin(iTime * 0.5))) col = INNER; 
    fragColor = vec4(col, 1.0); 
}
*/

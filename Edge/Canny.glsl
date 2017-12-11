
#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
#define B(X,Y) (tap(iChannel1,vec2(X,Y)))
#define C(X,Y) (tap(iChannel2,vec2(X,Y)))
#define D(X,Y) (tap(iChannel3,vec2(X,Y)))
vec3 tap(sampler2D tex,vec2 xy) { return texture(tex,xy).xyz; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = D(uv.x, uv.y); 
    //(min(fwidth(texture(iChannel0, fragCoord.xy / iResolution.xy))*7.0
    if (iMouse.z > 0.0) col = vec3(pow( length(fwidth(texture(iChannel1, uv) * 7.0)), 2.0));
	fragColor = vec4(col, 1.0);
}
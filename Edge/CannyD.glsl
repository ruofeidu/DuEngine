#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
vec3 tap(sampler2D tex,vec2 xy) { return texture(tex,xy).xyz; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 dXdYMag = texture(iChannel0, uv).rgb;
    
    vec3 X = texture(iChannel0, uv + dXdYMag.xy ).rgb;
    vec3 Y = texture(iChannel0, uv - dXdYMag.xy ).rgb;
    
    if (dXdYMag.z > 15.0 / 255.0 && dXdYMag.z > X.z && dXdYMag.z > Y.z) 
        fragColor = vec4(vec3(1.0), 1.0);
    else
	    fragColor = vec4(vec3(0.0), 1.0);
}

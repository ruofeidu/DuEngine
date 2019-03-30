void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.y = 1.0 - uv.y;
    float theta = uv.y * PI;
	float phi   = uv.x * PI * 2.0;
    vec3 dir = vec3(sin(theta) * sin(phi), cos(theta), sin(theta) * cos(phi));
	fragColor = texture(iChannel0, dir);
    
#if DEBUG
    if (uv.x > 0.5) {
        if (uv.y > 0.5) {
            fragColor = vec4(1.0, 0.0, 0.0, 1.0);
        } else {
            fragColor = vec4(0.0, 1.0, 0.0, 1.0);
        }
    } else {
        if (uv.y > 0.5) {
            fragColor = vec4(1.0, 0.0, 1.0, 1.0);
        } else {
            fragColor = vec4(0.0, 0.0, 1.0, 1.0);
        }
    }
#endif
            
}

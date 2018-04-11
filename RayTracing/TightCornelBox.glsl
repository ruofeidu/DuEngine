// https://www.shadertoy.com/view/lsyyW
void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 col = pow(texture(iChannel0, uv), vec4(0.4545));
    
	fragColor = vec4(col);
}
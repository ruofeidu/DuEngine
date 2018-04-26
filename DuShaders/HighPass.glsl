// MdSfWV
/**
 * A simple implementation of a high-pass filter: https://www.shadertoy.com/view/MdSfWV
 * Fwidth Edge: 834144373's https://www.shadertoy.com/view/MdGGRt
 * Fwidth with Bilateral Filter: https://www.shadertoy.com/view/MlG3WG
 */
#define USE_BILATERAL_FILTER
#ifdef USE_BILATERAL_FILTER
#define TEXTURE iChannel1
#else
#define TEXTURE iChannel0
#endif
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float[] kernel = float[] (-1., -1., -1., -1., 8., -1., -1., -1., -1.);
    vec2 delta = 1.0 / iResolution.xy; 
    vec2[] offset = vec2[] 
        (-delta, vec2(0.0, -delta.y), vec2(delta.x, -delta.y), 
         vec2(-delta.x, 0.0), vec2(0.0), vec2(delta.x, 0.0), 
         vec2(-delta.x, delta.y), vec2(0.0, delta.y), delta); 
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = vec3(0.0); 
    for (int i = 0; i < 9; ++i)
    {
        col += texture(TEXTURE, uv + offset[i]).rgb * kernel[i]; 
    }
    
    float simpleEdge = length(fwidth(texture(TEXTURE, uv)));
    if (iMouse.z > 0.5) col = vec3(simpleEdge); 
	fragColor = vec4(col, 1.0); 
}
/** 
 * Canny Edge Detection by Ruofei Du (DuRuofei.com)
 * Step 2: Find the intensity gradients of the image
 * Link to demo: https://www.shadertoy.com/view/Xly3DV
 * starea @ ShaderToy, License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
 *
 * Reference: 
 * [1] Canny, J., A Computational Approach To Edge Detection, IEEE Trans. Pattern Analysis and Machine Intelligence, 8(6):679–698, 1986.
 * [2] Canny edge detector, Wikipedia. https://en.wikipedia.org/wiki/Canny_edge_detector
 *
 * Related & Better Implementation:
 * [1] stduhpf's Canny filter (3pass): https://www.shadertoy.com/view/MsyXzt
 **/
#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
vec3 tap(sampler2D tex,vec2 xy) { return texture(tex,xy).xyz; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float dX = dFdx( texture(iChannel0, uv).r );
    float dY = dFdy( texture(iChannel0, uv).r );
    float magnitude = length(vec2(dX, dY)); 
    vec3 col = vec3(dX / magnitude, dY / magnitude, magnitude); 
	fragColor = vec4(col, 1.0);
}

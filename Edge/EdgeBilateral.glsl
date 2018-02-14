// https://www.shadertoy.com/view/MlG3WG
/**
 * Edge Detection: 834144373's https://www.shadertoy.com/view/MdGGRt
 * Bilateral Filter: https://www.shadertoy.com/view/4dfGDH
 */

#define SIGMA 10.0
#define BSIGMA 0.1
#define MSIZE 15

const mat4 kernel = mat4(
0.031225216, 0.033322271, 0.035206333, 0.036826804, 0.038138565, 
0.039104044, 0.039695028, 0.039894000, 0.039695028, 0.039104044, 
0.038138565, 0.036826804, 0.035206333, 0.033322271, 0.031225216, 0.0);

float sigmoid(float a, float f) {
	return 1.0 / (1.0 + exp(-f * a));
}

void mainImage(out vec4 fragColor, vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
	float edgeStrength = (iMouse.z > -0.5) ? 
        length(fwidth(texture(iChannel1, uv))) : 
    	length(fwidth(texture(iChannel0, uv)));
    edgeStrength = sigmoid(edgeStrength - 0.2, 15.0); 
    fragColor = vec4(vec3(edgeStrength), 1.0); 
}

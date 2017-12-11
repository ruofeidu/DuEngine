
/** 
 * Canny Edge Detection by Ruofei Du (DuRuofei.com)
 * Step 1A: Apply (Horizontal) Gaussian filter to smooth the image in order to remove the noise
 * Link to demo: https://www.shadertoy.com/view/Xly3DV
 * starea @ ShaderToy, License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License. 
 *
 * Reference: 
 * [1] Canny, J., A Computational Approach To Edge Detection, IEEE Trans. Pattern Analysis and Machine Intelligence, 8(6):679–698, 1986.
 * [2] Canny edge detector, Wikipedia. https://en.wikipedia.org/wiki/Canny_edge_detector
 *
 * Related & Better Implementation:
 * [1] https://www.shadertoy.com/view/4ssXDS
 * [2] stduhpf's Canny filter (3pass): https://www.shadertoy.com/view/MsyXzt
http://duruofei.com/Public/course/CMSC733/Du_Ruofei_PS1.pdf
 * 
 **/
const int mSize = 5;
const int kSize = (mSize - 1) / 2;
const float sigma = 2.0;
const float GAMMA = 2.2; 
float kernel[mSize];

float normpdf(in float x, in float sigma) {
	return 0.39894*exp(-0.5*x*x/(sigma*sigma))/sigma;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 col = vec3(0.0);
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j) {
        kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
    }

    for (int j = 0; j < mSize; ++j) {
        Z += kernel[j];
    }

    for (int i = -kSize; i <= kSize; ++i) {
        col += kernel[kSize+i] * pow(
                    texture(iChannel0, (fragCoord.xy+ vec2(float(i),0.0) ) / iResolution.xy).rgb
                  , vec3(GAMMA));
    }
    
    fragColor = vec4(pow(col / Z, vec3(1.0 / GAMMA)), 1.0);
}
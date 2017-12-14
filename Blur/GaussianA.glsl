// https://www.shadertoy.com/view/ltBXRh
const int mSize = 11;
const int kSize = (mSize-1)/2;
const float sigma = 7.0;
float kernel[mSize];

float normpdf(in float x, in float sigma) {
	return 0.39894 * exp(-0.5 * x * x / (sigma * sigma)) / sigma;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec3 res = vec3(0.0);
    
    float Z = 0.0;
    for (int j = 0; j <= kSize; ++j) {
        kernel[kSize+j] = kernel[kSize-j] = normpdf(float(j), sigma);
    }

    for (int j = 0; j < mSize; ++j) {
        Z += kernel[j];
    }

    for (int i=-kSize; i <= kSize; ++i) {
        res += kernel[kSize+i]*texture(iChannel0, (fragCoord.xy+ vec2(float(i),0.0) ) / iResolution.xy).rgb;
    }
    
    fragColor = vec4(res / Z, 1.0);
}
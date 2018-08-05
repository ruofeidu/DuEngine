// https://www.shadertoy.com/view/ll3czH

float line(in vec2 p, in vec2 a, in vec2 b) {
    vec2 pa = -p - a, ba = b - a;
    float h = clamp(dot(pa,ba)/dot(ba, ba), 0.0, 1.0);
    return length(pa - ba*h);
}

vec3 hsv2rgb(in vec3 c) {
    vec3 rgb = clamp( abs(mod(c.x*6.+vec3(0.,4.,2.),6.)-3.)-1., 0., 1.);
	rgb = rgb*rgb*(3.-2.*rgb); // cubic smoothing
	return c.z * mix(vec3(1.), rgb, c.y);
}

const float PI = 3.14159;

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 p = (2.0*fragCoord - iResolution.xy) / iResolution.y;
    
    vec3 col = vec3(0.0);
    
    const int N = 128;
    
    float factor = (iMouse.x/iResolution.x)*32.0+2.0;
    for(int i = 0; i < N; i++) {
        float a = float(i+1)/float(N);
    	float a1 = a*2.0*PI;
        float product = float(i+1)*factor;
        float a2 = (product/float(N))*2.0*PI;
        vec2 p1 = vec2(sin(a1), cos(a1)),
             p2 = vec2(sin(a2), cos(a2));
        float d = line(p, p1, p2);
        col += hsv2rgb(vec3(a, 0.5, 0.75))*smoothstep(3.0/iResolution.y, 0.0, d);
    }
    
    fragColor = vec4(col, 1.0);
}
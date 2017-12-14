// https://www.shadertoy.com/view/MsyXRW
// Visualization of the system in Buffer A

// uncomment to just render the normals
//#define NORMAL

// light source rotation
#define TIME iDate.w * 0.6

// displacement
#define DISP 0.06

// contrast
#define SIGMOID_CONTRAST 8.0

// mip level
#define MIP 1.0

vec4 contrast(vec4 x) {
	return 1.0 / (1.0 + exp(-SIGMOID_CONTRAST * (x - 0.5)));    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 texel = 1. / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy;

    #ifdef NORMAL
    	vec2 d = texture(iChannel1, uv).xy;
   		vec3 nr = normalize(vec3(d.x,d.y,sqrt(clamp(1.0-length(d.xy),0.0,1.0))));
    	fragColor = vec4(nr, 1.0);
    #else
        vec2 n  = vec2(0.0, texel.y);
        vec2 e  = vec2(texel.x, 0.0);
        vec2 s  = vec2(0.0, -texel.y);
        vec2 w  = vec2(-texel.x, 0.0);

        vec2 d   = texture(iChannel1, uv).xy;
        vec2 d_n = texture(iChannel1, fract(uv+n)).xy;
        vec2 d_e = texture(iChannel1, fract(uv+e)).xy;
        vec2 d_s = texture(iChannel1, fract(uv+s)).xy;
        vec2 d_w = texture(iChannel1, fract(uv+w)).xy;    

        vec3 i   = texture(iChannel0, fract(uv + DISP * d  ), MIP).xyz;
        vec3 i_n = texture(iChannel0, fract(uv + DISP * d_n), MIP).xyz;
        vec3 i_e = texture(iChannel0, fract(uv + DISP * d_e), MIP).xyz;
        vec3 i_s = texture(iChannel0, fract(uv + DISP * d_s), MIP).xyz;
        vec3 i_w = texture(iChannel0, fract(uv + DISP * d_w), MIP).xyz;

        vec3 ib = 0.4 * i + 0.15 * (i_n+i_e+i_s+i_w);

        vec3 nr = normalize(vec3(d.x,d.y,sqrt(clamp(1.0-length(d.xy),0.0,1.0))));
        vec3 l = normalize(vec3(cos(TIME), sin(TIME), 0.1)); 
        vec3 sh = pow(vec3(clamp(dot(nr,l),0.0,1.0)), vec3(5.0));

        fragColor = contrast(vec4(0.9*ib+0.6*sh,1.0));
    #endif
}
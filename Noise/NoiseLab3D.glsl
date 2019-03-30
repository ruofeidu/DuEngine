// https://www.shadertoy.com/view/4sc3z2

//#define Use_Perlin
//#define Use_Value
#define Use_Simplex

// ========= Hash ===========

vec3 hashOld33(vec3 p)
{   
	p = vec3( dot(p,vec3(127.1,311.7, 74.7)),
			  dot(p,vec3(269.5,183.3,246.1)),
			  dot(p,vec3(113.5,271.9,124.6)));
    
    return -1.0 + 2.0 * fract(sin(p)*43758.5453123);
}

float hashOld31(vec3 p)
{
    float h = dot(p,vec3(127.1,311.7, 74.7));
    
    return -1.0 + 2.0 * fract(sin(h)*43758.5453123);
}

// Grab from https://www.shadertoy.com/view/4djSRW
#define MOD3 vec3(.1031,.11369,.13787)
//#define MOD3 vec3(443.8975,397.2973, 491.1871)
float hash31(vec3 p3)
{
	p3  = fract(p3 * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return -1.0 + 2.0 * fract((p3.x + p3.y) * p3.z);
}

vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yxz+19.19);
    return -1.0 + 2.0 * fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

// ========= Noise ===========

float value_noise(vec3 p)
{
    vec3 pi = floor(p);
    vec3 pf = p - pi;
    
    vec3 w = pf * pf * (3.0 - 2.0 * pf);
    
    return 	mix(
        		mix(
        			mix(hash31(pi + vec3(0, 0, 0)), hash31(pi + vec3(1, 0, 0)), w.x),
        			mix(hash31(pi + vec3(0, 0, 1)), hash31(pi + vec3(1, 0, 1)), w.x), 
                    w.z),
        		mix(
                    mix(hash31(pi + vec3(0, 1, 0)), hash31(pi + vec3(1, 1, 0)), w.x),
        			mix(hash31(pi + vec3(0, 1, 1)), hash31(pi + vec3(1, 1, 1)), w.x), 
                    w.z),
        		w.y);
}

float perlin_noise(vec3 p)
{
    vec3 pi = floor(p);
    vec3 pf = p - pi;
    
    vec3 w = pf * pf * (3.0 - 2.0 * pf);
    
    return 	mix(
        		mix(
                	mix(dot(pf - vec3(0, 0, 0), hash33(pi + vec3(0, 0, 0))), 
                        dot(pf - vec3(1, 0, 0), hash33(pi + vec3(1, 0, 0))),
                       	w.x),
                	mix(dot(pf - vec3(0, 0, 1), hash33(pi + vec3(0, 0, 1))), 
                        dot(pf - vec3(1, 0, 1), hash33(pi + vec3(1, 0, 1))),
                       	w.x),
                	w.z),
        		mix(
                    mix(dot(pf - vec3(0, 1, 0), hash33(pi + vec3(0, 1, 0))), 
                        dot(pf - vec3(1, 1, 0), hash33(pi + vec3(1, 1, 0))),
                       	w.x),
                   	mix(dot(pf - vec3(0, 1, 1), hash33(pi + vec3(0, 1, 1))), 
                        dot(pf - vec3(1, 1, 1), hash33(pi + vec3(1, 1, 1))),
                       	w.x),
                	w.z),
    			w.y);
}

float simplex_noise(vec3 p)
{
    const float K1 = 0.333333333;
    const float K2 = 0.166666667;
    
    vec3 i = floor(p + (p.x + p.y + p.z) * K1);
    vec3 d0 = p - (i - (i.x + i.y + i.z) * K2);
    
    // thx nikita: https://www.shadertoy.com/view/XsX3zB
    vec3 e = step(vec3(0.0), d0 - d0.yzx);
	vec3 i1 = e * (1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy * (1.0 - e);
    
    vec3 d1 = d0 - (i1 - 1.0 * K2);
    vec3 d2 = d0 - (i2 - 2.0 * K2);
    vec3 d3 = d0 - (1.0 - 3.0 * K2);
    
    vec4 h = max(0.6 - vec4(dot(d0, d0), dot(d1, d1), dot(d2, d2), dot(d3, d3)), 0.0);
    vec4 n = h * h * h * h * vec4(dot(d0, hash33(i)), dot(d1, hash33(i + i1)), dot(d2, hash33(i + i2)), dot(d3, hash33(i + 1.0)));
    
    return dot(vec4(31.316), n);
}

float noise(vec3 p) {
#ifdef Use_Perlin
    return perlin_noise(p * 2.0);
#elif defined Use_Value
    return value_noise(p * 2.0);
#elif defined Use_Simplex
    return simplex_noise(p);
#endif
    
    return 0.0;
}

// ========== Different function ==========

float noise_itself(vec3 p)
{
    return noise(p * 8.0);
}

float noise_sum(vec3 p)
{
    float f = 0.0;
    p = p * 4.0;
    f += 1.0000 * noise(p); p = 2.0 * p;
    f += 0.5000 * noise(p); p = 2.0 * p;
	f += 0.2500 * noise(p); p = 2.0 * p;
	f += 0.1250 * noise(p); p = 2.0 * p;
	f += 0.0625 * noise(p); p = 2.0 * p;
    
    return f;
}

float noise_sum_abs(vec3 p)
{
    float f = 0.0;
    p = p * 3.0;
    f += 1.0000 * abs(noise(p)); p = 2.0 * p;
    f += 0.5000 * abs(noise(p)); p = 2.0 * p;
	f += 0.2500 * abs(noise(p)); p = 2.0 * p;
	f += 0.1250 * abs(noise(p)); p = 2.0 * p;
	f += 0.0625 * abs(noise(p)); p = 2.0 * p;
    
    return f;
}

float noise_sum_abs_sin(vec3 p)
{
    float f = noise_sum_abs(p);
    f = sin(f * 2.5 + p.x * 5.0 - 1.5);
    
    return f ;
}


// ========== Draw ==========

vec3 draw_simple(float f)
{
    f = f * 0.5 + 0.5;
    return f * vec3(25.0/255.0, 161.0/255.0, 245.0/255.0);
}

vec3 draw_cloud(float f)
{
    f = f * 0.5 + 0.5;
    return mix(	vec3(8.0/255.0, 65.0/255.0, 82.0/255.0),
              	vec3(178.0/255.0, 161.0/255.0, 205.0/255.0),
               	f*f);
}

vec3 draw_fire(float f)
{
    f = f * 0.5 + 0.5;
    return mix(	vec3(131.0/255.0, 8.0/255.0, 0.0/255.0),
              	vec3(204.0/255.0, 194.0/255.0, 56.0/255.0),
               	pow(f, 3.));
}

vec3 draw_marble(float f)
{
    f = f * 0.5 + 0.5;
    return mix(	vec3(31.0/255.0, 14.0/255.0, 4.0/255.0),
              	vec3(172.0/255.0, 153.0/255.0, 138.0/255.0),
               	1.0 - pow(f, 3.));
}

vec3 draw_circle_outline(vec2 p, float radius, vec3 col)
{
    p = 2.0 * p - vec2(iResolution.x/iResolution.y, 1.0);
    return 	mix(vec3(0.0), col, smoothstep(0.0, 0.02, abs(length(p) - radius)));
        	
}

// ========= Marching ===========
#define FAR 30.0
#define PRECISE 0.001
#define SPEED 0.05

float map(vec3 pos)
{
    return length(pos - (vec3(0.0, 0.0, 1.5) + iTime * vec3(0.0, 0.0, SPEED))) - 1.0;
}

vec3 normal(vec3 pos) {
    vec2 eps = vec2(0.001, 0.0);
    return normalize(vec3(	map(pos + eps.xyy) - map(pos - eps.xyy),
                    		map(pos + eps.yxy) - map(pos - eps.yxy),
                         	map(pos + eps.yyx) - map(pos - eps.yyx)));
}

vec3 getBackground(vec2 uv, vec2 split)
{
    vec3 pos = vec3(uv * vec2(iResolution.x/iResolution.y, 1.0), iTime * SPEED);
    float f;
    if (uv.x < split.x && uv.y > split.y) {
        f = noise_itself(pos);
    } else if (uv.x < split.x && uv.y <= split.y) {
        f = noise_sum(pos);
    } else if (uv.x >= split.x && uv.y < split.y) {
        f = noise_sum_abs(pos);
    } else {
        f = noise_sum_abs_sin(pos);
    }
    
    return vec3(f * 0.5 + 0.5);
}

vec3 getColor(vec2 uv, vec3 pos, vec3 rd, vec2 split)
{
    vec3 nor = normal(pos);
    vec3 light = normalize(vec3(0.5, 1.0, -0.2));
        
    float diff = dot(light, nor);
    diff = diff * 0.5 + 0.5;
    
    vec3 col;
    float f;
    if (uv.x < split.x && uv.y > split.y) {
        f = noise_itself(pos);
        col = draw_simple(f);
    } else if (uv.x < split.x && uv.y <= split.y) {
        f = noise_sum(pos);
        col = draw_cloud(f);
    } else if (uv.x >= split.x && uv.y < split.y) {
        f = noise_sum_abs(pos);
        col = draw_fire(f);
    } else {
        f = noise_sum_abs_sin(pos);
        col = draw_marble(f);
    }
    
    vec3 edge = col * pow((1.0 - clamp(dot(nor, -rd), 0.0, 1.0)), 5.0);
    
    return col + edge;
}

vec3 marching(vec3 ro, vec3 rd, vec2 uv, vec2 split)
{
    float t = 0.0;
    float d = 1.0;
    vec3 pos;
    for (int i = 0; i < 50; i++) {
        pos = ro + rd * t;
        d = map(pos);
        t += d;
        if (d < PRECISE || t > FAR) break;
    }
 
    vec3 col = getBackground(uv, split);
    
    if (t < FAR) {
        pos = ro + rd * t;
        col = getColor(uv, pos, rd, split);
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    vec2 split = vec2(0.5, 0.5);
    if (iMouse.z > 0.0) {
        split += 2.0 * iMouse.xy/iResolution.xy - 1.0;
    }
    
    vec3 col = vec3(0.0, 0.0, 0.0);
    
    vec3 ro = vec3(0.0, 0.0, 0.0) + iTime * vec3(0.0, 0.0, SPEED);
    vec3 rd = vec3((p * 2.0 - 1.0) * vec2(iResolution.x/iResolution.y, 1.0), 1.0);
    col = marching(ro, rd, p, split);
	
    col = draw_circle_outline(p * vec2(iResolution.x/iResolution.y, 1.0), 0.9, col);
    col = mix(vec3(0.3, 0.0, 0.0), col, smoothstep(0.0, 0.005, abs(p.x - split.x)));
    col = mix(vec3(0.3, 0.0, 0.0), col, smoothstep(0.0, 0.005*iResolution.x/iResolution.y, abs(p.y - split.y)));
    
    fragColor = vec4(col, 1.0);
}

// https://www.shadertoy.com/view/XddXRj
/*
	Thin-Film Interference Bubble

	This shader simulates thin-film interference patterns with a reasonable degree of accuracy.
	Chromatic dispersion is also simulated, and both effects use more than 3 wavelengths of light
	to increase accuracy. An arbitrary number of wavelengths can be simulated, which are then
    downsampled to RGB, in a similar fashion to the human eye.

*/

/* 
	BUG NOTICE!
	On some platforms (lower-end Nvidia graphics seem to be the common factor)
	the reflectance is much brighter than it's supposed to be. If the bubble
	looks mostly white on your platform, uncomment this next line:
*/
#define ITS_TOO_BRIGHT

// To see just the reflection (no refraction/transmission) uncomment this next line:
//#define REFLECTANCE_ONLY

// performance and raymarching options
#define WAVELENGTHS 5				 // number of rays of different wavelengths to simulate, should be >= 3
#define INTERSECTION_PRECISION 0.01  // raymarcher intersection precision
#define MIN_INCREMENT 0.02			 // distance stepped when entering the surface of the distance field
#define ITERATIONS 50				 // max number of iterations
#define MAX_BOUNCES 2				 // max number of reflection/refraction bounces
#define AA_SAMPLES 1				 // anti aliasing samples
#define BOUND 6.0					 // cube bounds check
#define DIST_SCALE 0.9   			 // scaling factor for raymarching position update

// optical properties
#define DISPERSION 0.05				 // dispersion amount
#define IOR 0.9     				 // base IOR value specified as a ratio
#define THICKNESS_SCALE 64.0		 // film thickness scaling factor
#define THICKNESS_CUBEMAP_SCALE 0.07 // film thickness cubemap scaling factor
#define REFLECTANCE_SCALE 5.0        // reflectance scaling factor

#define TWO_PI 6.28318530718
#define PI 3.14159265359

// visualize the average number of bounces for each of the rays
//#define VISUALIZE_BOUNCES

// iq's cubemap function
vec3 fancyCube( sampler2D sam, in vec3 d, in float s, in float b )
{
    vec3 colx = textureLod( sam, 0.5 + s*d.yz/d.x, b ).xyz;
    vec3 coly = textureLod( sam, 0.5 + s*d.zx/d.y, b ).xyz;
    vec3 colz = textureLod( sam, 0.5 + s*d.xy/d.z, b ).xyz;
    
    vec3 n = d*d;
    
    return (colx*n.x + coly*n.y + colz*n.z)/(n.x+n.y+n.z);
}

// iq's 3D noise function
float hash( float n ){
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x ) {
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
}

vec3 noise3(vec3 x) {
	return vec3( noise(x+vec3(123.456,.567,.37)),
				noise(x+vec3(.11,47.43,19.17)),
				noise(x) );
}

// a sphere with a little bit of warp
float sdf( vec3 p ) {
	vec3 n = pow(vec3(sin(iDate.w * 0.5), sin(iDate.w * 0.3), cos(iDate.w * 0.2)), vec3(2.0));
	vec3 q = 0.1 * noise3(p + n);
  
	return length(q + p)-3.5;
}

// Fresnel factor from TambakoJaguar Diamond Test shader here: https://www.shadertoy.com/view/XdtGDj
// see also: https://en.wikipedia.org/wiki/Schlick's_approximation
float fresnel( vec3 ray, vec3 norm, float n2 )
{
   float n1 = 1.0;
   float angle = clamp(acos(-dot(ray, norm)), -3.14/2.15, 3.14/2.15);
   float r0 = pow((n1-n2)/(n1+n2), 2.);
   float r = r0 + (1. - r0)*pow(1. - cos(angle), 5.);
   return clamp(0., 1.0, r);
}

vec3 calcNormal( in vec3 pos ) {
    const float eps = INTERSECTION_PRECISION;

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*sdf( pos + v1*eps ) + 
					  v2*sdf( pos + v2*eps ) + 
					  v3*sdf( pos + v3*eps ) + 
					  v4*sdf( pos + v4*eps ) );
}

struct Bounce
{
    vec3 position;
    vec3 ray_direction;
    float attenuation;
    float reflectance;
    float ior;
    float bounces;
    float wavelength;
};
    
float sigmoid(float t, float t0, float k) {
    return 1.0 / (1.0 + exp(-k*(t - t0)));  
}

#define GAMMA_CURVE 50.0
#define GAMMA_SCALE 4.5

vec3 filmic_gamma(vec3 x) {
	return log(GAMMA_CURVE * x + 1.0) / GAMMA_SCALE;    
}

float filmic_gamma_inverse(float y) {
	return (1.0/GAMMA_CURVE) * (-1.0 + exp(GAMMA_SCALE * y)); 
}

// sample weights for the cubemap given a wavelength i
// room for improvement in this function
vec3 texCubeSampleWeights(float i) {
	vec3 w = vec3((1.0 - i) * (1.0 - i), 2.0 * i * (1.0 - i), i * i);
    return w / dot(w, vec3(1.0));
}

float sampleCubeMap(float i, vec3 rd) {
	vec3 col = textureLod(iChannel0, rd * vec3(1.0,-1.0,1.0), 0.0).xyz; 
    return dot(texCubeSampleWeights(i), col);
}

void doCamera( out vec3 camPos, out vec3 camTar, in float time, in vec4 m ) {
    camTar = vec3(0.0,0.0,0.0); 
    if (max(m.z, m.w) <= 0.0) {
    	float an = 1.5 + sin(time * 0.05) * 4.0;
		camPos = vec3(6.5*sin(an), 0.0 ,6.5*cos(an));   
    } else {
    	float an = 10.0 * m.x - 5.0;
		camPos = vec3(6.5*sin(an),10.0 * m.y - 5.0,6.5*cos(an)); 
    }
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

// MATLAB Jet color scheme
vec3 jet(float x) {

   x = clamp(x, 0.0, 1.0);

   if (x < 0.25) {
       return(vec3(0.0, 4.0 * x, 1.0));
   } else if (x < 0.5) {
       return(vec3(0.0, 1.0, 1.0 + 4.0 * (0.25 - x)));
   } else if (x < 0.75) {
       return(vec3(4.0 * (x - 0.5), 1.0, 0.0));
   } else {
       return(vec3(1.0, 1.0 + 4.0 * (0.75 - x), 0.0));
   }
   
}

// 4PL curve fit to experimentally-determined values
float greenWeight() {
    float a = 4569547.0;
    float b = 2.899324;
    float c = 0.008024607;
    float d = 0.07336188;

    return d + (a - d) / (1.0 + pow(log(float(WAVELENGTHS))/c, b)) + 2.0;    
}

// sample weights for downsampling to RGB. Ideally this would be close to the 
// RGB response curves for the human eye, instead I use a simple ad hoc solution here.
// Could definitely be improved upon.
vec3 sampleWeights(float i) {
	return vec3((1.0 - i) * (1.0 - i), greenWeight() * i * (1.0 - i), i * i);
}

// downsample to RGB
vec3 resampleColor(Bounce[WAVELENGTHS] bounces) {
    vec3 col = vec3(0.0);
    
    for (int i = 0; i < WAVELENGTHS; i++) {        
        float reflectance = bounces[i].reflectance;
        float index = float(i) / float(WAVELENGTHS - 1);
        float texCubeIntensity = filmic_gamma_inverse(
            clamp(bounces[i].attenuation * sampleCubeMap(index, bounces[i].ray_direction), 0.0, 0.99)
        );
    	float intensity = texCubeIntensity + reflectance;
        col += sampleWeights(index) * intensity;
    }

    return 1.3 * filmic_gamma(2.0 * col / float(WAVELENGTHS));
}

// compute average number of bounces for the VISUALIZE_BOUNCES render mode
float avgBounces(Bounce[WAVELENGTHS] bounces) {
    float avg = 0.0;
    
    for (int i = 0; i < WAVELENGTHS; i++) {        
         avg += bounces[i].bounces;;
    }

    return avg / float(WAVELENGTHS);
}

// compute the wavelength/IOR curve values.
float iorCurve(float x) {
	return x;
}

Bounce initialize(vec3 ro, vec3 rd, float i) {
    i = i / float(WAVELENGTHS - 1);
    float ior = IOR + iorCurve(1.0 - i) * DISPERSION;
    return Bounce(ro, rd, 1.0, 0.0, ior, 1.0, i); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec4 m = vec4(iMouse.xy/iResolution.xy, iMouse.zw);

    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iTime, m );
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );
    
    float dh = (0.5 / iResolution.y);
    const float rads = TWO_PI / float(AA_SAMPLES);
    
    Bounce bounces[WAVELENGTHS];
    
    vec3 col = vec3(0.0);
    
    for (int samp = 0; samp < AA_SAMPLES; samp++) {
        vec2 dxy = dh * vec2(cos(float(samp) * rads), sin(float(samp) * rads));
        vec3 rd = normalize(camMat * vec3(p.xy + dxy, 1.5)); // 1.5 is the lens length

        for (int i = 0; i < WAVELENGTHS; i++) {
            bounces[i] = initialize(ro, rd, float(i));    
        }

        for (int i = 0; i < WAVELENGTHS; i++) {
            for (int j = 0; j < ITERATIONS; j++) {
                float td = DIST_SCALE * sdf(bounces[i].position);
                float t = abs(td);
                float sig = sign(td);    
                
                vec3 pos = bounces[i].position + t * bounces[i].ray_direction;
                if ( (sig > 0.0 && bounces[i].bounces > 1.0) 
                    || int(bounces[i].bounces) >= MAX_BOUNCES 
                    || clamp(pos, -BOUND, BOUND) != pos) {
                	break;    
                } else if ( t < INTERSECTION_PRECISION ) {
                    vec3 normal = calcNormal(pos);
                    
                    #ifdef REFLECTANCE_ONLY
                    	bounces[i].attenuation = 0.0;
                    #endif
                    
                    float filmThickness = fancyCube( iChannel1, normal, THICKNESS_CUBEMAP_SCALE, 0.0 ).x + 0.1;
                    
                    float attenuation = 0.5 + 0.5 * cos(((THICKNESS_SCALE * filmThickness)/(bounces[i].wavelength + 1.0)) * dot(normal, bounces[i].ray_direction));
                    float ior = sig < 0.0 ? 1.0 / bounces[i].ior : bounces[i].ior;

                    // cubemap reflection
                    float f = fresnel(bounces[i].ray_direction, normal, 0.5 / ior);
                    float texCubeSample = attenuation * sampleCubeMap(bounces[i].wavelength, reflect(bounces[i].ray_direction, normal));
                    
                    #ifdef ITS_TOO_BRIGHT
                    	bounces[i].reflectance += REFLECTANCE_SCALE * filmic_gamma_inverse(mix(0.0, 0.8 * texCubeSample - 0.1, f));
                    #else
                    	bounces[i].reflectance += REFLECTANCE_SCALE * filmic_gamma_inverse(mix(0.0, 4.0 * texCubeSample - 0.5, f));
                    #endif

                    bounces[i].ray_direction = normalize(refract(bounces[i].ray_direction, normal, ior));
                    bounces[i].position = pos + MIN_INCREMENT * bounces[i].ray_direction;
                    bounces[i].bounces += 1.0;
                } else {
                    bounces[i].position = pos;
                }
            }
        }

        #ifdef VISUALIZE_BOUNCES
        	col += jet(avgBounces(bounces) / float(MAX_BOUNCES));
        #else
        	col += resampleColor(bounces);
        #endif
    }
    
    col /= float(AA_SAMPLES);
	   
    fragColor = vec4( col, 1.0 );
}
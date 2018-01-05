// 
//#define COMPARE_PAPER
#define DEBUG_LEVEL 4
#define a00 3.141593
#define a01 2.094395
#define a02 0.785398
#define a03 0.0
#define a04 0.1
#define a05 0.0
#define a06 0.049087
        
// These constants have been calculated with a light probe from this website:
// http://www.pauldebevec.com/Probes/
// The light probe image used is St. Peter's Basilica.
struct SHCoefficientsL2 {
    vec3 l00, l1m1, l10, l11, l2m2, l2m1, l20, l21, l22;
};
const SHCoefficientsL2 stpeter2 = SHCoefficientsL2(
    vec3( 0.3623915,  0.2624130,  0.2326261 ),
    vec3( 0.1759131,  0.1436266,  0.1260569 ),
    vec3(-0.0247311, -0.0101254, -0.0010745 ),
    vec3( 0.0346500,  0.0223184,  0.0101350 ),
    vec3( 0.0198140,  0.0144073,  0.0043987 ),
    vec3(-0.0469596, -0.0254485, -0.0117786 ),
    vec3(-0.0898667, -0.0760911, -0.0740964 ),
    vec3( 0.0050194,  0.0038841,  0.0001374 ),
    vec3(-0.0818750, -0.0321501,  0.0033399 )
);

struct SHCoefficientsL3 {
    vec3 l00, 
         l1m1, l10, l11, 
         l2m2, l2m1, l20, l21, l22,
         l3m3, l3m2, l3m1, l30, l31, l32, l33;
};
const SHCoefficientsL3 stpeter = SHCoefficientsL3(
	vec3(  0.343717,  0.213979,  0.177832 ), 
	vec3(  0.221323,  0.130874,  0.106280 ), 
	vec3(  0.022908,  0.013530,  0.009426 ), 
	vec3( -0.004431, -0.003124, -0.002162 ), 
	vec3( -0.003836, -0.001355, -0.000436 ), 
	vec3(  0.054364,  0.024950,  0.013652 ), 
	vec3( -0.104768, -0.067931, -0.058275 ), 
	vec3( -0.001351, -0.001645, -0.001814 ), 
	vec3( -0.140437, -0.087918, -0.074401 ), 
	vec3( -1.187490, -0.753631, -0.648360 ), 
	vec3(  0.002903,  0.002255, -0.006468 ), 
	vec3(  2.010808,  1.217353,  1.004765 ), 
	vec3( -0.282066, -0.174958, -0.141419 ), 
	vec3(  0.083092,  0.038836,  0.003124 ), 
	vec3( -0.307840, -0.142879, -0.064180 ), 
	vec3(  0.028176,  0.011962,  0.003800 )  
); 

struct SHCoefficientsL4 {
    vec3 l00, 
         l1m1, l10, l11, 
         l2m2, l2m1, l20, l21, l22,
         l3m3, l3m2, l3m1, l30, l31, l32, l33,
         l4m4, l4m3, l4m2, l4m1, l40, l41, l42, l43, l44;
};
    
const SHCoefficientsL4 stpeter4 = SHCoefficientsL4(
	vec3(  1.832940,  1.174918,  0.991465 ),

	vec3(  0.029393,  0.023738,  0.018848 ),
	vec3( -0.292132, -0.130373, -0.074867 ),
	vec3( -0.017030,  0.025532,  0.030895 ),

	vec3( -0.041533, -0.022267, -0.021711 ),
	vec3( -0.008100, -0.009603, -0.009201 ),
	vec3(  0.086924,  0.047386,  0.019906 ),
	vec3(  0.042234,  0.045668,  0.038792 ),
	vec3( -0.036672, -0.056992, -0.073074 ),

	vec3( -0.060115, -0.041182, -0.030487 ),
	vec3(  0.007782, -0.000659, -0.001448 ),
	vec3( -0.045908, -0.040196, -0.031344 ),
	vec3(  0.253094,  0.153117,  0.117610 ),
	vec3( -0.238526, -0.051816,  0.007003 ),
	vec3(  0.030113,  0.041435,  0.035848 ),
	vec3( -0.199477, -0.188422, -0.194569 ),

	vec3( -0.074083, -0.066662, -0.056188 ),
	vec3(  0.012926,  0.009741,  0.010889 ),
	vec3( -0.005381, -0.005234, -0.003589 ),
	vec3(  0.002703, -0.003868, -0.000729 ),
	vec3( -0.016413,  0.006298,  0.012759 ),
	vec3(  0.115660,  0.115143,  0.104764 ),
	vec3(  0.065664,  0.067169,  0.068058 ),
	vec3( -0.041530, -0.027543, -0.024679 ),
	vec3( -0.083113, -0.019013,  0.004458 )

); 

#define PI 3.14159265358979323846264338328
// Constants, see here: http://en.wikipedia.org/wiki/Table_of_spherical_harmonics
#define k01 0.2820947918 // sqrt(  1/PI)/2
#define k02 0.4886025119 // sqrt(  3/PI)/2
#define k03 1.0925484306 // sqrt( 15/PI)/2
#define k04 0.3153915652 // sqrt(  5/PI)/4
#define k05 0.5462742153 // sqrt( 15/PI)/4
#define k06 0.5900435860 // sqrt( 70/PI)/8
#define k07 2.8906114210 // sqrt(105/PI)/2
#define k08 0.4570214810 // sqrt( 42/PI)/8
#define k09 0.3731763300 // sqrt(  7/PI)/4
#define k10 1.4453057110 // sqrt(105/PI)/4
#define k11 2.5033429418 // Math.sqrt(35/Math.PI) * 3 / 4
#define k12 1.7701307698 // Math.sqrt(70/Math.PI) * 3 / 8
#define k13 0.9461746958 // Math.sqrt(5/Math.PI) * 3 / 4
#define k14 0.6690465436 // Math.sqrt(10/Math.PI) * 3 / 8
#define k15 0.1057855469 // Math.sqrt(1/Math.PI) * 3 / 16
#define k16 0.4730873479 // Math.sqrt(5/Math.PI) * 3 / 8
#define k17 0.6258357354 // Math.sqrt(35/Math.PI) * 3 / 16

vec3 calcIrradiance(vec3 nor) {
    const SHCoefficientsL4 c = stpeter4;
    const float c1 = 0.429043;
    const float c2 = 0.511664;
    const float c3 = 0.743125;
    const float c4 = 0.886227;
    const float c5 = 0.247708;
    
    float x = nor.x; 
    float y = nor.y; 
    float z = nor.z; 
    
    x = nor.z;
    y = nor.x; 
    z = nor.y; 
    
    float x2 = x * x; 
    float y2 = y * y; 
    float z2 = z * z; 
    float xy = x * y; 
    float xz = x * z; 
    float yz = y * z; 
    float r2 = dot(nor, nor); 
    
    vec3 old = (
        c4 * c.l00 
    );
    
#if DEBUG_LEVEL > 0
    old = (
        c4 * c.l00  +
        2.0 * c2 * (c.l11  * nor.x + c.l1m1 * nor.y + c.l10  * nor.z)
    );
#endif
    
#if DEBUG_LEVEL > 1
    old = (
        c4 * c.l00 +
        2.0 * c2 * (c.l11  * x + c.l1m1 * y + c.l10  * z)
        -
        c5 * c.l20 +
        c1 * c.l22 * (x2 - y2) +
        c3 * c.l20 * z2 +
        2.0 * c1 * (c.l2m2 * xy + c.l21  * xz + c.l2m1 * yz) 
    );
#endif
    
    float sh_c[5];
	sh_c[0] = a00;
	sh_c[1] = a01;
	sh_c[2] = a02;
	sh_c[3] = a03;
	sh_c[4] = a04;
    
	sh_c[0] = 1.0;
	sh_c[1] = 1.0;
	sh_c[2] = 1.0;
	sh_c[3] = 1.0;
	sh_c[4] = 1.0;
    // order 0
    vec3 ans = sh_c[0] * k01 * c.l00;
    
#if DEBUG_LEVEL > 0
    // order 1
    ans +=  sh_c[1] * k02 * (
            c.l1m1 * y +    
            c.l10 * z +
            c.l11 * x 
           );
#endif
    
#if DEBUG_LEVEL > 1
    // order 2
    ans += sh_c[2] * (
        k03 * c.l2m2 * xy +
        k03 * c.l2m1 * yz +
        k04 * c.l20  * (3.0 * z2 - 1.0) +
        k03 * c.l21 * xz +
        k05 * c.l22 * (x2 - y2)
        );
#endif
    
#if DEBUG_LEVEL > 2
    // order 3
    ans += sh_c[3] * (
        k06 * c.l3m3 * y*(3.0*x2 - y2) + 
        k07 * c.l3m2 * z*xy +             
        k08 * c.l3m1 * y*(5.0*z2 - 1.0) +     
        k09 * c.l30 * z*(5.0*z2 - 3.0) +    
        k08 * c.l31 * x*(5.0*z2 - 1.0) +     
        k10 * c.l32 * z*(x2 - y2) +     
        k06 * c.l33 * x*(x2 - 3.0 * y2)
        );
#endif

#if DEBUG_LEVEL > 3
    // order 4
    ans += sh_c[4] * (
        k11 * c.l4m4 * (xy * (x2 - y2)) +             
        k12 * c.l4m3 * (3.0*x2 - y2) * yz +          
        k13 * c.l4m2 * (xy * (7.0*z2 - r2) ) +          
        k14 * c.l4m1 * (yz * (7.0*z2-3.0*r2) ) +      
        k15 * c.l40  * (35.0 * z2*z2 - 30.0 * z2*r2 + 3.0 * r2*r2) +  
        k14 * c.l41  * (xz * (7.0*z2-3.0*r2) ) +      
        k16 * c.l42  * ( (x2-y2)*(7.0*z2-r2) ) + 
        k12 * c.l43  * xz*(x2-3.0*y2) +                
        k17 * c.l44  * (x2 * (x2-3.0*y2) - y2*(3.0*x2 - y2))       
        );
#endif
    
#ifdef COMPARE_PAPER
    return old;
#else
    return ans;
#endif
    
    return iMouse.z > 0.5 ? old : ans; 
}

vec3 spherePos = vec3(0.0, 1.0, 1.5);
float sphereRadius = 2.5;

float raytraceSphere(in vec3 ro, in vec3 rd, float tmin, float tmax, float r) {
    vec3 ce = ro - spherePos;
    float b = dot(rd, ce);
    float c = dot(ce, ce) - r * r;
    float t = b * b - c;
    if (t > tmin) {
        t = -b - sqrt(t);
        if (t < tmax)
            return t;
        }
    return -1.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 P = fragCoord.xy / iResolution.xy;
	float theta = P.y * PI;             //[0, PI]
	float phi   = P.x * PI * 2.0;       //[0, 2PI]
	vec3 dir = vec3(sin(theta) * sin(phi), cos(theta), sin(theta) * cos(phi));
	vec3 col = texture(iChannel0, dir).rgb;

    if (iMouse.z < 0.5) 
        col = calcIrradiance(dir);

    
	fragColor = vec4(col, 1.0);
}
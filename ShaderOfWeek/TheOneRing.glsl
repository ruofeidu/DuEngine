// 4tfBRf
// ----------------------------------------------------
//  "The One Ring" by Krzysztof Kondrak @k_kondrak
// ----------------------------------------------------

// enable/disable AA
#define ANTIALIASING 1
#define AA_SAMPLES 2
#define AA_WIDTH .8

#define FOV 5.5
#define RING_RADIUS 1.5

// raymarching constants
#define MIN_DIST  .001
#define MAX_DIST  30.
#define NUM_STEPS 100
#define BACKGROUND_ID 0
#define RING_ID       1

// Gold color: https://www.shadertoy.com/view/XdVSRV
const vec3 GOLD1 = vec3(1.1,  0.91, 0.52);
const vec3 GOLD2 = vec3(1.1,  1.07, 0.88);
const vec3 GOLD3 = vec3(1.02, 0.82, 0.55);

// initial eye/camera position
vec3 EYE = vec3(7.5, 0., 0.);

// helper struct to collect raymarching data
struct RMInfo
{
  	vec3 pos;
  	vec3 normal;
  	int  objId;
};

// ------------------
//  1D hash function
// ------------------
float hash(float n)
{
    return fract(sin(n)*753.5453123);
}

// ----------------------------------------------
//  noise: https://www.shadertoy.com/view/4sfGzS
// ----------------------------------------------
float noise(vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
	
    float n = p.x + p.y * 157.0 + 113.0 * p.z;
    return mix(mix(mix(hash(n +   0.0), hash(n +   1.0), f.x),
                   mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
               mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                   mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

// -----------------
//  vector rotation
// -----------------
vec2 rotate(vec2 v, float a)
{
    return vec2(v.x * cos(a) - v.y * sin(a), v.x * sin(a) + v.y * cos(a));
}

// --------------------
//  "noisy" gold color
// --------------------
vec3 Gold(vec3 p)
{
    p += .4 * noise(p * 24.);
    float t = noise(p * 30.);
    float fade = max(0., sin(iTime * .3));

    vec3 gold = mix(GOLD1, GOLD2, smoothstep(.55, .95, t));
    gold = mix(gold, GOLD3, smoothstep(.45, .25, t));

	// Glowing "black speech" inscription on the ring.
    // Flicker depends on the current audio value.
    if(p.y > .18 && p.y < .23)
    {
    	gold +=  8. * fade * vec3(1., .3, 0.) * (1. + 10. * texture(iChannel1, vec2(50., 0.)).r);
    }

    // darker gold tint if the inscription is visible
    gold *= (1. - 0.666 * fade);

    return gold;
}

// ----------------------------------------
//  calculate ray direction for eye/camera
// ----------------------------------------
vec3 EyeRay(vec2 fragCoord, vec3 eyeDir)
{
  	vec2 uv = fragCoord.xy / iResolution.xy; 
  	uv = uv * 2.0 - 1.0;
  	uv.x *= iResolution.x / iResolution.y;

    vec3 forward = normalize(eyeDir);
	vec3 right   = normalize(cross(vec3(.0, 1., .0), forward));
	vec3 up      = normalize(cross(forward, right));    

	return normalize(uv.x * right + uv.y * up + forward * FOV);
}

// ----------------------------------------------
//  SDF for the ring - a slightly deformed torus
// ----------------------------------------------
float Ring(vec3 pos)
{
    vec2 t = vec2(RING_RADIUS, RING_RADIUS * .2);
    vec2 q = vec2(clamp(2. * (length(pos.xz) - t.x), -5., 5.),pos.y);

    return length(q) - t.y;
}

// -------------------------------
//  flickering hellish background
// -------------------------------
vec3 Background(vec3 ray)
{ 
    return texture(iChannel2, ray).rgb * vec3(.7, .15, .0);
}

// ----------------
//  surface normal
// ----------------
vec3 SurfaceNormal(in vec3 pos)
{
    vec3 eps = vec3( MIN_DIST, 0., 0. );
    return normalize(-vec3(Ring(pos + eps.xyy) - Ring(pos - eps.xyy),
                           Ring(pos + eps.yxy) - Ring(pos - eps.yxy),
                           Ring(pos + eps.yyx) - Ring(pos - eps.yyx)));
}

// ------------------
//  scene raymarcher
// ------------------
RMInfo Raymarch(vec3 from, vec3 to)
{
    float t = 0.;
    int objId = BACKGROUND_ID;
    vec3 pos;
    vec3 normal;
    float dist;
    
  	for (int i = 0; i < NUM_STEPS; ++i)
    {
    	pos = from + to * t;
        dist = Ring(pos);

        if (dist > MAX_DIST || abs(dist) < MIN_DIST)
            break;

        t += dist * 0.43;
        objId = RING_ID;
  	}
    
    if (t < MAX_DIST)
    {
        normal = SurfaceNormal(pos);
    }
    else
    {
        objId = BACKGROUND_ID;
    }

    return RMInfo(pos, normal, objId);
}


// -------------------------
//  here be scene rendering
// -------------------------
vec4 Draw(vec2 fragCoord)
{   
    vec3   col = vec3(0.);
  	vec3   ray = EyeRay(fragCoord, -EYE);
  	RMInfo rmi = Raymarch(EYE, ray);

    if (rmi.objId == RING_ID)
    {
        col = mix(col, Gold(rmi.pos) * texture(iChannel0, reflect(ray, rmi.normal)).rgb, .99);            
        rmi = Raymarch(rmi.pos, reflect(ray, rmi.normal));
    }
    else if(rmi.objId == BACKGROUND_ID)
    {
        col += Background(ray);
    }

  	return vec4(col, 1.0);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    EYE.xy = rotate(EYE.xy, iTime * .03 + .015);
    EYE.yz = rotate(EYE.yz, iTime * .03 + .015);

    // Antialiasing: https://www.shadertoy.com/view/XdVSRV
#if ANTIALIASING
    vec4 vs = vec4(0.);
    for (int j = 0; j < AA_SAMPLES ;j++)
    {
        float oy = float(j) * AA_WIDTH / max(float(AA_SAMPLES - 1), 1.);
        for (int i = 0; i < AA_SAMPLES; i++)
        {
            float ox = float(i) * AA_WIDTH / max(float(AA_SAMPLES - 1), 1.);
            vs += Draw(fragCoord + vec2(ox, oy));
        }
    }

    fragColor = vs/vec4(AA_SAMPLES * AA_SAMPLES);
#else
    fragColor = Draw(fragCoord);
#endif
}
// 
/**
 * Created by Kamil Kolaczynski (revers) - 2015
 * Licensed under Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 *
 * This shader uses code written by: 
 * - iq (hash, noise, intersection routines, raymarching, and probably something else I forgot about :) )
 * - reinder (part of path tracing routines, https://www.shadertoy.com/view/4tl3z4)
 * - Syntopia (other part of path tracing routines, http://blog.hvidtfeldts.net/index.php/2015/01/path-tracing-3d-fractals/)
 * - Dave_Hoskins (hash without sine, https://www.shadertoy.com/view/4djSRW)
 * Thanks for sharing it guys!
 * 
 * The shader was created and exported from Synthclipse (http://synthclipse.sourceforge.net/)
 */

//#define QUALITY_LOW
//#define QUALITY_MEDIUM
#define QUALITY_HIGH
//#define QUALITY_VERY_HIGH

//#define AA_CHECKERBOARD_TEXTURE

#ifdef QUALITY_VERY_HIGH
const int SamplesPerPixel = 10;
const int RayDepth = 8;
#elif defined(QUALITY_HIGH)
const int SamplesPerPixel = 15;
const int RayDepth = 4;
#elif defined(QUALITY_MEDIUM)
const int SamplesPerPixel = 6;
const int RayDepth = 4;
#else /* if defined(QUALITY_LOW) */
const int SamplesPerPixel = 2;
const int RayDepth = 4;
#endif

const float MarchDumping = 0.84999996;
const float Far = 60.0;
const int MaxSteps = 64;
const float IceCubeGlossiness = 0.0;
const float IceCubeFresnel = 1.45;
const float CubeLength = 3.0;
const float ScaleFactor = 0.2873;
const vec3 IceCubeColor = vec3(1.0, 1.0, 1.0);
const bool DirectLight = true;
const bool EnableCaustics = false;
const bool CosWeighted = true;
const float CosWeightedExp = 1.0;
const float FOV = 0.228;

const bool ShowLight = false;
const float LightRadius = 2.5574498;
const float LightIntensity = 5.218;
const vec3 LightPosition = vec3(-14.599998, 18.400002, 13.199997);
const vec3 LightColor = vec3(1.0, 1.0, 1.0);

const mat3 Rotation = mat3(-0.5036228, -0.86392355, -2.0861626E-7, -0.22534683, 0.1313659, -0.9653816, 0.83401597, -0.4861882, -0.26084125);

#define PI 3.14159265359
#define PI_INV 0.31830988618
#define TWO_PI 6.28318530718

#define MAT_NONE -1.0
#define MAT_CHECKER_PLANE 1.0
#define MAT_ICE_CUBE 2.0
#define MAT_MIRROR 3.0
#define MAT_MAIN_LIGHT 4.0

#define DISTANCE(v) v.x
#define MATERIAL(v) v.y

// Schlick approximation gives poor quality of refraction.
//#define USE_SCHLICK_APPROX

#define AIR_INDEX_OF_REFRACTION 1.0

const float EPS = 0.0001;
const float MAX_DIST = 1e10;

// Random variable seed.
float seed = 0.0;

struct Material {
	bool isReflective;
	bool isTransmissive;
	float fresnel;
	float glossiness;
};

/*************************************************************************
 * Intersection routines
 *************************************************************************/

float iPlane(vec3 ro, vec3 rd, vec4 pla) {
	return (-pla.w - dot(pla.xyz, ro)) / dot(pla.xyz, rd);
}

vec3 nPlane(vec3 ro, vec4 obj) {
	return obj.xyz;
}

vec3 nSphere(vec3 pos, vec3 sphPos, float sphRadius) {
	return (pos - sphPos) / sphRadius;
}

float iSphere(vec3 ro, vec3 rd, vec3 sphPos, float sphRadius) {
	vec3 oc = ro - sphPos;
	float b = dot(oc, rd);
	float c = dot(oc, oc) - sphRadius * sphRadius;
	float h = b * b - c;

	if (h < 0.0) {
		return -1.0;
	}
	return -b - sqrt(h);
}

/*************************************************************************
 * Raymarching
 *************************************************************************/

vec2 minx(vec2 a, vec2 b) {
	// return a.x < b.x ? a : b;
	return mix(a, b, step(b.x, a.x));
}

float hash(float n) {
	return fract(sin(n) * 43758.5453123);
}

float noise(vec3 x) {
	vec3 p = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);

	float n = p.x + p.y * 157.0 + 113.0 * p.z;
	return mix(
			mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
					mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y),
			mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
					mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

float udRoundBox(vec3 p, vec3 b, float r) {
	p += ScaleFactor * noise(p);
	return length(max(abs(p) - b, 0.0)) - r;
}

vec2 map(vec3 p) {
	p.y -= 6.5;
	p = Rotation * p;

	return vec2(udRoundBox(p, vec3(CubeLength), 0.5), MAT_ICE_CUBE);
}

vec2 raymarch(vec3 ro, vec3 rd) {
	float tmin = 0.0;
	float tmax = Far;

	float precis = 0.0002;
	float t = tmin;
	float m = MAT_NONE;

	for (int i = 0; i < MaxSteps; i++) {
		vec2 res = abs(map(ro + rd * t));

		if (res.x < precis || t > tmax) {
			break;
		}
		t += res.x * MarchDumping;
		m = res.y;
	}

	if (t > tmax) {
		m = MAT_NONE;
	}
	return vec2(t, m);
}

vec3 getNormal(vec3 p) {
	vec2 q = vec2(0.0, 0.002);

	float x = map(p + q.yxx).x - map(p - q.yxx).x;
	float y = map(p + q.xyx).x - map(p - q.xyx).x;
	float z = map(p + q.xxy).x - map(p - q.xxy).x;

	return normalize(vec3(x, y, z));
}

/*************************************************************************
 * Scene
 *************************************************************************/

bool intersect(vec3 ro, vec3 rd, out vec3 hitPoint, out vec3 hitNormal,
		out float materialId) {
	float dist = MAX_DIST;
	materialId = MAT_NONE;
	float t;

	t = iPlane(ro, rd, vec4(0.0, 1.0, 0.0, 0.0));
	if (t > EPS && t < dist) {
		dist = t;
		materialId = MAT_CHECKER_PLANE;
		hitNormal = vec3(0.0, 1.0, 0.0);
		hitPoint = ro + dist * rd;
	}

	vec2 res = raymarch(ro, rd);
	if (MATERIAL(res) != MAT_NONE && DISTANCE(res) > EPS
			&& DISTANCE(res) < dist) {
		dist = DISTANCE(res);
		materialId = MATERIAL(res);
		hitPoint = ro + DISTANCE(res) * rd;
		hitNormal = getNormal(hitPoint);
	}

	if (dist < MAX_DIST) {
		return true;
	}
	return false;
}

/*************************************************************************
 * Materials and background
 *************************************************************************/

vec3 getBackground(vec3 ro, vec3 rd) {
	rd.y -= 0.03;
	rd = normalize(rd);
	return texture(iChannel0, rd).xyz;
}

#ifdef AA_CHECKERBOARD_TEXTURE

/**
 * Anti-aliased checkerboard pattern
 * http://www.yaldex.com/open-gl/ch17lev1sec5.html
 */
vec3 getCheckerboardTexture(vec2 uv) {
	vec3 color;
	vec3 color1 = vec3(0.118, 0.525, 0.729);
	vec3 color2 = vec3(1.0);
	vec3 avgColor = (color1 + color2) * 0.5;

	const float frequency = 0.2;

	vec2 fw = fwidth(uv);
	vec2 fuzz = fw * frequency * 2.0;
	float fuzzMax = max(fuzz.s, fuzz.t);

	vec2 checkPos = fract(uv * frequency);

	if (fuzzMax < 0.5) {
		vec2 p = smoothstep(vec2(0.5), fuzz + vec2(0.5), checkPos)
				+ (1.0 - smoothstep(vec2(0.0), fuzz, checkPos));

		color = mix(color1, color2, p.x * p.y + (1.0 - p.x) * (1.0 - p.y));
		color = mix(color, avgColor, smoothstep(0.125, 0.5, fuzzMax));
	} else {
		color = avgColor;
	}
	return color;
}

#else

vec3 getCheckerboardTexture(vec2 uv) {
	vec3 color1 = vec3(0.118, 0.525, 0.729);
	vec3 color2 = vec3(1.0);

	const float freq = 0.5;
	const float phase = 300.0;
	int x = int(uv.x * freq + phase);
	int y = int(uv.y * freq + phase);

	return mix(color1, color2, mod(float(x + y), 2.0));
}

#endif

Material getMaterial(float materialID) {
	Material material;
	material.isReflective = false;
	material.isTransmissive = false;

	if (materialID == MAT_MIRROR) {
		material.isReflective = true;
		material.glossiness = IceCubeGlossiness;
		material.fresnel = IceCubeFresnel;
	} else if (materialID == MAT_ICE_CUBE) {
		material.isTransmissive = true;
		material.glossiness = IceCubeGlossiness;
		material.fresnel = IceCubeFresnel;
	}
	return material;
}

/*************************************************************************
 * BRDF
 *************************************************************************/

vec3 getBRDF(vec3 viewDir, vec3 lightDir, vec3 hitNormal, vec3 hitPoint, float materialID) {
	if (materialID == MAT_MIRROR) {
		// http://www.codinglabs.net/article_physically_based_rendering.aspx
		// "For a perfectly specular reflection, like a mirror, the BRDF function is 0 for every
		// incoming ray apart for the one that has the same angle of the outgoing ray, in which
		// case the function returns 1 (the angle is measured between the rays and the surface normal)."
		return vec3(1.0);
	}
	if (materialID == MAT_ICE_CUBE) {
		// Should be vec3(1.0), as refraction is also perfect specular phenomenon,
		// but setting it to some color gives nice variation.
		return IceCubeColor;
	}
	//	if (materialID == MAT_PHONG) {
	//		return phongShading(viewDir, ligthDir, hitNormal, hitPoint, materialID);
	//	}
	// Simple lambertian BRDF: albedo / PI
	return getCheckerboardTexture(hitPoint.xz) * PI_INV;
}

/*************************************************************************
 * Path tracing
 *************************************************************************/

float hash11(float p) {
	vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
	p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
	return fract(p2.x * p2.y * 95.4337);
}

vec2 hash21(float p) {
	vec2 p2 = fract(p * vec2(5.3983, 5.4427));
	p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
	return fract(vec2(p2.x * p2.y * 95.4337, p2.x * p2.y * 97.597));
}

float hash1() {
	return hash11(seed += 1.03751);
}

vec2 hash2() {
	return hash21(seed += 1.03751);
}

vec3 ortho(vec3 v) {
	// See : http://lolengine.net/blog/2013/09/21/picking-orthogonal-vector-combing-coconuts
	return mix(vec3(-v.y, v.x, 0.0), vec3(0.0, -v.z, v.y), step(abs(v.x), abs(v.z)));
}

vec3 getSampleBiased(vec3 dir, float power) {
	dir = normalize(dir);
	// create orthogonal vector
	vec3 o1 = normalize(ortho(dir));
	vec3 o2 = normalize(cross(dir, o1));

	// Convert to spherical coords aligned to dir;
	vec2 r = hash2();
	r.x = r.x * 2. * PI;

	// This is  cosine^n weighted.
	// See, e.g. http://people.cs.kuleuven.be/~philip.dutre/GI/TotalCompendium.pdf
	// Item 36
	r.y = pow(r.y, 1.0 / (power + 1.0));

	float oneminus = sqrt(1.0 - r.y * r.y);
	return normalize(cos(r.x) * oneminus * o1 + sin(r.x) * oneminus * o2 + r.y * dir);
}

vec3 getConeSample(vec3 dir, float extent) {
	// Create orthogonal vector (fails for z,y = 0)
	dir = normalize(dir);
	vec3 o1 = normalize(ortho(dir));
	vec3 o2 = normalize(cross(dir, o1));

	// Convert to spherical coords aligned to dir
	vec2 r = hash2();

	r.x = r.x * 2. * PI;
	r.y = 1.0 - r.y * extent;

	float oneminus = sqrt(1.0 - r.y * r.y);
	return normalize(cos(r.x) * oneminus * o1 + sin(r.x) * oneminus * o2 + r.y * dir);
}

vec3 getCosWeightedSample(vec3 dir) {
	return getSampleBiased(dir, CosWeightedExp);
}

vec3 getHemisphereUniformSample(vec3 dir) {
	return getConeSample(dir, 1.0);
}

vec3 getHemisphereDirection(vec3 n) {
	if (CosWeighted) {
		// Biased sampling (cosine weighted):
		// PDF = CosAngle / PI, BRDF = Albedo / PI
		return getCosWeightedSample(n);
	} else {
		// Unbiased sampling:
		// PDF = 1 / (2 * PI), BRDF = Albedo / PI
		return getHemisphereUniformSample(n);
	}
}

vec3 getOutgoingDirection(vec3 n, vec3 rd, float materialID, out bool specularBounce) {
	Material material = getMaterial(materialID);

	if (!material.isReflective && !material.isTransmissive) {
		specularBounce = false;
		return getHemisphereDirection(n);
	}
	specularBounce = true;

	float NdotR = dot(rd, n);
	float n1;
	float n2;

	if (NdotR > 0.0) {
		n = -n;
		n1 = AIR_INDEX_OF_REFRACTION;
		n2 = material.fresnel;
	} else {
		n1 = material.fresnel;
		n2 = AIR_INDEX_OF_REFRACTION;
	}
	vec3 refr = refract(rd, n, n2 / n1);

#ifdef USE_SCHLICK_APPROX
	float r0 = (n1 - n2) / (n1 + n2);
	r0 *= r0;
	float fresnel = r0 + (1.0 - r0) * pow(1.0 - abs(NdotR), 5.0);
#else
	// full Fresnel equation:
	// https://en.wikipedia.org/?title=Fresnel_equations#Power_or_intensity_equations
	float cosI = dot(rd, n);
	float costT = dot(n, refr);

	float Rs = (n1 * cosI - n2 * costT) / (n1 * cosI + n2 * costT);
	Rs = Rs * Rs;
	float Rp = (n1 * costT - n2 * cosI) / (n1 * costT + n2 * cosI);
	Rp = Rp * Rp;
	float fresnel = (Rs + Rp) * 0.5;
#endif
	vec3 dir;

	if (material.isReflective || hash1() < fresnel) {
		dir = reflect(rd, n);
		return normalize(dir + material.glossiness * getHemisphereDirection(n));
	} else {
		dir = refr;
	}
	return dir;
}

vec3 randomSphereDirection() {
	vec2 r = hash2() * TWO_PI;
	return vec3(sin(r.x) * vec2(sin(r.y), cos(r.y)), cos(r.x));
}

vec3 getLightColor() {
	return LightColor * 21.61 * 1.3 * LightIntensity;
}

vec3 sampleLight() {
	vec3 n = randomSphereDirection() * LightRadius;
	return LightPosition + n;
}

float distanceSqr(vec3 a, vec3 b) {
	vec3 k = a - b;
	return dot(k, k);
}

bool intersectIncludingLight(vec3 ro, vec3 rd, out vec3 hitPoint, out vec3 hitNormal,
		out float materialID) {
	bool result = intersect(ro, rd, hitPoint, hitNormal, materialID);

	if (!ShowLight) {
		return result;
	}
	float t = iSphere(ro, rd, LightPosition, LightRadius);
	if (t < 0.0) {
		return result;
	}

	if (result && distanceSqr(hitPoint, ro) <= t * t) {
		return result;
	}
	vec3 pos = ro + t * rd;
	hitPoint = pos;
	hitNormal = nSphere(pos, LightPosition, LightRadius);
	materialID = MAT_MAIN_LIGHT;

	return true;
}

bool isShadowed(vec3 ro, vec3 rd, vec3 point) {
	vec3 pos;
	vec3 nor;
	float m;

	if (!intersect(ro, rd, pos, nor, m)) {
		return false;
	}
	return distanceSqr(point, ro) > distanceSqr(pos, ro);
}

vec3 color(vec3 ro, vec3 rd) {
	vec3 hitPoint = vec3(0.0);
	vec3 hitNormal = vec3(0.0);
	float materialID = 0.0;

	vec3 totalColor = vec3(0.0);
	vec3 luminance = vec3(1.0);

	bool specularBounce = true;
	const float eps = EPS * 8.0;

	for (int i = 0; i < RayDepth; i++) {

		if (!intersectIncludingLight(ro, rd, hitPoint, hitNormal, materialID)) {
			return totalColor + luminance * getBackground(ro, rd);
		}

		if (materialID == MAT_MAIN_LIGHT) {
			if (DirectLight) {
				if (i == 0 || (EnableCaustics && specularBounce)) {
					totalColor += luminance * getLightColor();
				}
			} else {
				totalColor += luminance * getLightColor();
			}
			return totalColor;
		}
		ro = hitPoint;
		vec3 viewDir = -rd;
		rd = getOutgoingDirection(hitNormal, rd, materialID, specularBounce);

		luminance *= getBRDF(viewDir, rd, hitNormal, hitPoint, materialID);

		if (!CosWeighted && !specularBounce) {
			// modulate color with: BRDF * CosAngle / PDF
			luminance *= 2.0 * max(0.0, dot(rd, hitNormal));
		}

		 // Direct lighting
		if (DirectLight && !specularBounce) {
			vec3 lightPoint = sampleLight();
			vec3 ld = normalize(lightPoint - ro);

			if (!isShadowed(hitPoint + rd * eps, ld, lightPoint)) {
				vec3 lo = LightPosition - ro;
				float weight = LightRadius * LightRadius / dot(lo, lo);

				totalColor += (luminance * getLightColor()) * weight
						* max(dot(ld, hitNormal), 0.0);
			}
		}
		ro = hitPoint + rd * eps;
	}
	return totalColor;
}

mat3 rotateX(float a) {
	float sa = sin(a);
	float ca = cos(a);
	return mat3(1.0, 0.0, 0.0, 0.0, ca, sa, 0.0, -sa, ca);
}

mat3 rotateY(float a) {
	float sa = sin(a);
	float ca = cos(a);
	return mat3(ca, 0.0, sa, 0.0, 1.0, 0.0, -sa, 0.0, ca);
}

mat3 getCameraRotation() {
    vec2 mouse = iMouse.xy / iResolution.xy;
    if (mouse.x != 0.0 && mouse.y != 0.0) {
        mouse -= vec2(0.5, 0.6);
    }
    mouse.y = clamp(mouse.y, -1.0, 0.0);
    mouse *= vec2(4.0, 3.0);
    
	return rotateX(mouse.y) * rotateY(mouse.x);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 q = fragCoord.xy / iResolution.xy;

	mat3 rot = getCameraRotation();
	vec3 dir = rot * vec3(0.0, 0.0, -1.0);
	vec3 up = rot * vec3(0.0, 1.0, 0.0);
	vec3 upOrtho = normalize(up - dot(dir, up) * dir);
	vec3 right = normalize(cross(dir, upOrtho));

	vec3 totalColor = vec3(0.0);
	for (int a = 0; a < SamplesPerPixel; a++) {
		vec4 rr = texture(iChannel1,
				(fragCoord.xy + floor(256.0 * hash2())) / iChannelResolution[1].xy);
		vec2 p = -1.0 + 2.0 * (fragCoord.xy + rr.xz) / iResolution.xy;
		p.x *= iResolution.x / iResolution.y;
		p *= FOV;

		vec3 ro = rot * vec3(0.0, 6.0, 29.0);
		vec3 rd = normalize(dir + p.x * right + p.y * upOrtho);

		totalColor += color(ro, rd);
	}
	totalColor /= float(SamplesPerPixel);

	// Gamma correction
	totalColor = pow(clamp(totalColor, 0.0, 1.0), vec3(0.4545));
    
	fragColor = vec4(totalColor, 1.0);
}
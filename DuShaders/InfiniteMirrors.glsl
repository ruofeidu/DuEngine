/** 
 * Forked and remixed from DiLemming's demo of Mirror Room[url]https://www.shadertoy.com/view/4sS3zc[/url]
 * @remix author: starea @ ShaderToy
 * @demo url: https://www.shadertoy.com/view/4dBcDz
 */
#define PI 3.14159265359
#define PI2 (PI*2.0)

#define REFLECTIONS 32

#define FOG_STRENGTH 0.9
#define REFLECTION_STRENGTH 100000.0
#define COLOR_STRENGTH 1.0
#define BRIGHTNESS 5.0


vec2 GetWindowCoord( const in vec2 vUV ) {
	vec2 vWindow = vUV * 2.0 - 1.0;
	vWindow.x *= iResolution.x / iResolution.y;
	return vWindow;	
}

vec3 GetCameraRayDir( const in vec2 vWindow, const in vec3 vCameraPos, const in vec3 vCameraTarget ) {
	vec3 vForward = normalize(vCameraTarget - vCameraPos);
	vec3 vRight = normalize(cross(vec3(0.0, 1.0, 0.0), vForward));
	vec3 vUp = normalize(cross(vForward, vRight));					  
	vec3 vDir = normalize(vWindow.x * vRight + vWindow.y * vUp + vForward * 1.5);
	return vDir;
}

struct ray {
	vec3 p;
	vec3 d;
};

struct material {
	vec3 color;
	vec3 emmision;
	float diffusion;
};

struct hit {
	vec3 p;
	vec3 n;
	float t;
	material m;
};

void plane (vec3 v, float f, ray r, material m, inout hit h) {
	float t = (f - dot (v, r.p)) / dot (v, r.d);
	
	if (t < 0.0) return;
	
	if (t < h.t) {
		h.t = t;
		h.p = r.p + r.d * t;
		h.n = /*normalize*/ (faceforward (v, v, r.d));
		
		h.m = m;
	}
}

void sphere (vec3 v, float f, ray r, material m, inout hit h) {
	vec3 d = r.p - v;
	
	float a = dot (r.d, r.d);
	float b = dot (r.d, d);
	float c = dot (d, d) - f * f;
	
	float g = b*b - a*c;
	
	if (g < 0.0)
		return;
	
	float t = (-sqrt (g) - b) / a;
	
	if (t < 0.0) return;
	
	if (t < h.t) {
		h.t = t;
		h.p = r.p + r.d * t;
		h.n = (h.p - v) / f;
		
		h.m = m;
	}
}

hit scene (ray r) {
	hit h;
	h.t = 1e20;
	
	material m0 = material (vec3 (1.0), vec3 (0), 0.1);
	
	plane	(vec3 ( 1.0, 1.0, 0.0), 5.0, r, m0, h);
	plane	(vec3 ( 1.0, 0.0, 0.0),-5.0, r, m0, h);
	plane	(vec3 ( 0.0, 1.0, 0.0), 5.0, r, m0, h);
	plane	(vec3 ( 0.0, 1.0, 0.0),-5.0, r, m0, h);
	plane	(vec3 ( 0.0, 0.0, 1.0), 5.0, r, m0, h);
    plane	(vec3 ( 0.0, 0.0, 1.0),-5.0, r, m0, h);
    
	//sphere	(vec3 (-1.0, sin (iTime) + 1.0,0), 1.0, r, m0, h);
   
    float radius = 1.0;
    vec3 pos = vec3(0.0);
	sphere	( pos, radius, r, m0, h);
    
	h.m.color *= h.n * h.n;
	return h;
}

ray getRay (in vec3 origin, in vec3 forward, in vec3 up, in vec2 uv) {
	ray r;
	
	r.p = origin;
	vec3 right = cross (up, forward);
	up = cross (forward, right);
	r.d = normalize (right * uv.x + up * uv.y + forward);
	
	return r;
}

vec3 surface (ray r) {
	vec3 color = vec3 (0.0);
	float depth = 0.0;
	float l = 0.0;
	
	for (int i = 0; i < REFLECTIONS; i++) {
		hit h = scene (r);
		
		float c = dot (h.n, r.d);
		depth += (1.0 / REFLECTION_STRENGTH) + h.t * FOG_STRENGTH;
		
		r = ray (h.p + h.n * 0.0001, reflect (normalize (r.d), h.n));
		
		float d = 1.0 / (depth * depth);
		color = (color + c * c * d) * (1.0 - h.m.color * d * COLOR_STRENGTH);
	}
	
	return color * BRIGHTNESS;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    // forked from https://www.shadertoy.com/view/MdBXR3
	vec2 vUV = fragCoord.xy / iResolution.xy;
    vec2 vMouse = iMouse.xy / iResolution.xy;
    float fAngle = vMouse.x * PI2;
    float fDist = 5.0;
    float fHeight = (vMouse.y - 0.5) * 2.0 * 5.0;
    
    vec3 vCameraPos = vec3(sin(fAngle) * fDist, fHeight, cos(fAngle) * fDist);
    
    vec3 vCameraTarget = vec3(0.0, 0.0, 0.0);
    
	vec3 vRayOrigin = vCameraPos;
	vec3 vRayDir = GetCameraRayDir( GetWindowCoord(vUV), vCameraPos, vCameraTarget );
	
        
	//vec3 camera = vec3 (0.5, 3, -4.0);
	vec3 forward = vec3 (0.0, 0.0, 1.0);
	
	vec2 uv = (fragCoord.xy * 2.0 - iResolution.xy) / iResolution.xx;
	//ray r = getRay (camera, forward, vec3 (0,1,0), uv);
	ray r = getRay (vRayOrigin, vRayDir, vec3 (0,1,0), uv);
	
	vec3 c = vec3 (surface (r) * (1.3 - max (abs (uv.x), abs (uv.y * 1.5))));
	c = pow(c, vec3(0.7)); 
    fragColor = vec4(c, 1.0); 
}

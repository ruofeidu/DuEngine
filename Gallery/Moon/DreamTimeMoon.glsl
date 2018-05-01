// MscBD4
// Dream Time Moon
//
// https://www.shadertoy.com/view/MscBD4

// Dreamy clouds over the fbm Full Moon.

// Little New Year's --
// and the moon has deigned
// to rise!
//
// (Issa)

vec3 g_camera_pos   = vec3(0.0, 0.0, -25.0);
vec3 g_camera_front = vec3(0.0, 0.0, 1.0);
vec3 world_up       = vec3(0.0, 1.0, 0.0);
vec3 g_light_pos    = vec3(20.0, 9.0, -30.0);

vec2 castRay(vec3 ro, vec3 rd);
vec3 calcNormal(vec3 pos);
vec3 materialColor(vec3 ro, vec3 rd, float mat_id, vec3 pos);
vec2 map(vec3 p);

float noise(vec2 x);
float noise(vec3 x);
float fbm(vec2 x);
float fbm(vec3 x);

#define INFINITY 100.0

vec2 map(vec3 p) {
  vec2 res = vec2(INFINITY, 0.0);

  res.x = length(vec3(0.0) - p) - 2.0;
  res.y = 1.0;

  return res;
}

vec3 materialColor(vec3 ro, vec3 rd, float mat_id, vec3 pos) {
  vec3 final_col = vec3(0.0);
  vec3 nor = vec3(0.0);

  if (mat_id > -1.0) {
    nor = calcNormal(pos);
  }

  // sunrise gradient background
  vec3 bg_bottom = vec3(0.631, 0.580, 0.517) * vec3(1.3, 1., 1.); // rgb(161, 148, 132)
  vec3 bg_top = vec3(0.439, 0.521, 0.596); // rgb(112, 133, 152)
  vec3 bg_base = mix(bg_bottom, bg_top, rd.y + 0.5);

  if (mat_id == 1.0) {
    // moon
    vec3 view_dir = normalize(ro - pos);
    vec3 light_dir = normalize(pos - g_light_pos);

    // NOTE cheap world-space pos texturing but nah. moon stays in place.

    vec3 base = vec3(1.0, 0.85, 0.82) * vec3(0.52);
    vec3 crater = mix(base, vec3(1.0), smoothstep(0.45, 0.6, fbm(pos)));

    vec3 white_dust = pow(noise(pos*50.0) * vec3(0.9), vec3(2.0));
    vec3 black_dust = pow(noise(pos*40.0) * vec3(0.9), vec3(4.0));
    vec3 col = 0.9*base + 1.0*crater + 0.3*white_dust - 0.5*black_dust;

    float diff = max(dot(nor, -light_dir), 0.0);

    //col = mix(bg_base, col, diff);
    col = mix(mix(bg_base, col+vec3(.3), diff), bg_base, 0.5);

    final_col = clamp(col, 0., 1.);
  } else if (mat_id == 2.0) {
    // black silhouette
    final_col = vec3(0.);
  } else {
    // background
    vec3 col = bg_base;
    final_col = clamp(col, 0., 1.);
  }

  return final_col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  float time = iTime;
  vec3 col = vec3(0.0);

  // normalized image plane, (0,0) is the center, (0.5,0.5) is top right
  vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
  // scale to fit width
  p.x *= iResolution.x / iResolution.y;

  // === Camera ===

  // ray origin is camera position
  vec3 ro = g_camera_pos;

  // camera vectors
  vec3 cam_front = normalize(g_camera_front);
  vec3 cam_right = normalize(cross(cam_front, world_up));
  vec3 cam_up    = normalize(cross(cam_right, cam_front));

  // ray direction toward camera front vector, shifted with screen pos xy
  vec3 rd = normalize(p.x*cam_right + p.y*cam_up + 2.0*cam_front);

  // === Render ===

  vec2 res = castRay(ro, rd);
  col = materialColor(ro, rd, res.y, ro+rd*res.x);

  // add clouds
  vec3 cloud_col = vec3(1.0);
  float t1 = iTime*0.2;
  float t2 = iTime*0.2 + sin(iTime*0.2 + 2.0)*2.0+2.0;

  float cloud_fbm1 = smoothstep(0.4, 0.91, fbm(rd.xy*7.0 + vec2(t1, 0.0)));
  float cloud_fbm2 = smoothstep(0.4, 0.91, fbm(rd.xy*7.0 + vec2(t2, 0.0)));

  col = mix(mix(col, cloud_col, cloud_fbm1),
            mix(col, cloud_col, cloud_fbm2), sin(iTime*0.2) + 1.0);

  // gamma correction, 1.0 / 2.2 = 0.4545
  col = pow(col, vec3(0.4545));

  fragColor = vec4(col, 1.0);
}

// === Raymarch Helpers ========================================================

vec2 castRay(vec3 ro, vec3 rd) {
  float tmax = INFINITY; // far clip
  float precis = 2e-3; // hit precision
  float sm = 0.9; // smaller steps

  float t = 0.1; // first step size
  float m = -1.0; // material id

  for (int i=0; i<150; i++) {
    vec2 res = map(ro + rd * t);
    if (res.x < precis || t > tmax) break;
    t += res.x * sm;
    m = res.y;
  }

  if (t > tmax) m = -1.0;

  return vec2(t,m);
}

vec3 calcNormal(vec3 pos, float eps) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * map( pos + v1*eps ).x +
                    v2 * map( pos + v2*eps ).x +
                    v3 * map( pos + v3*eps ).x +
                    v4 * map( pos + v4*eps ).x );
}

vec3 calcNormal(vec3 pos) {
  return calcNormal(pos, 2e-3);
}

// === Noise ===================================================================

// 1D, 2D & 3D Value Noise by morgan3d
// https://www.shadertoy.com/view/4dS3Wd

#define NUM_NOISE_OCTAVES 6

float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(vec2 x) {
  vec2 i = floor(x);
  vec2 f = fract(x);

  // Four corners in 2D of a tile
  float a = hash(i);
  float b = hash(i + vec2(1.0, 0.0));
  float c = hash(i + vec2(0.0, 1.0));
  float d = hash(i + vec2(1.0, 1.0));

  // Simple 2D lerp using smoothstep envelope between the values.
  // return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
  //			mix(c, d, smoothstep(0.0, 1.0, f.x)),
  //			smoothstep(0.0, 1.0, f.y)));

  // Same code, with the clamps in smoothstep and common subexpressions
  // optimized away.
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}


float noise(vec3 x) {
  const vec3 step = vec3(110, 241, 171);

  vec3 i = floor(x);
  vec3 f = fract(x);

  // For performance, compute the base input to a 1D hash from the integer part of the argument and the
  // incremental change to the 1D based on the 3D -> 1D wrapping
  float n = dot(i, step);

  vec3 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(mix( hash(n + dot(step, vec3(0, 0, 0))), hash(n + dot(step, vec3(1, 0, 0))), u.x),
                 mix( hash(n + dot(step, vec3(0, 1, 0))), hash(n + dot(step, vec3(1, 1, 0))), u.x), u.y),
             mix(mix( hash(n + dot(step, vec3(0, 0, 1))), hash(n + dot(step, vec3(1, 0, 1))), u.x),
                 mix( hash(n + dot(step, vec3(0, 1, 1))), hash(n + dot(step, vec3(1, 1, 1))), u.x), u.y), u.z);
}

float fbm(vec2 x) {
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
  mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
	for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
		v += a * noise(x);
		x = rot * x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < NUM_NOISE_OCTAVES; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

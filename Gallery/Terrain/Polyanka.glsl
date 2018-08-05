// MdsGzS
const int c_terramarch_steps = 64;
const int c_grassmarch_steps = 32;
const float c_maxdist = 200.;
const float c_grassmaxdist = 3.;
const float c_scale = .05;
const float c_height = 6.;
const float c_rslope = 1. / (c_scale * c_height);
const float c_gscale =  15.;
const float c_gheight = 1.5;
const float c_rgslope = 1. / (c_gscale * c_gheight);
const vec3 c_skycolor = vec3(.59, .79, 1.);

float ambient = .8;

float hash(in float p) { return fract(sin(p) * 43758.2317); }
float hash(in vec2 p) { return hash(dot(p, vec2(87.1, 313.7))); }
vec2 hash2(in float p) {
	float x = hash(p);
	return vec2(x, hash(p+x));
}
vec2 hash2(in vec2 p) { return hash2(dot(p, vec2(87.1, 313.7))); }

float noise(in vec2 p) {
	vec2 F = floor(p), f = fract(p);
	f = f * f * (3. - 2. * f);
	return mix(
		mix(hash(F), 			 hash(F+vec2(1.,0.)), f.x),
		mix(hash(F+vec2(0.,1.)), hash(F+vec2(1.)),	  f.x), f.y);
}

vec2 noise2(in vec2 p) {
	vec2 F = floor(p), f = fract(p);
	f = f * f * (3. - 2. * f);
	return mix(
		mix(hash2(F), 			  hash2(F+vec2(1.,0.)), f.x),
		mix(hash2(F+vec2(0.,1.)), hash2(F+vec2(1.)),	f.x), f.y);
}

float fnoise(in vec2 p) {
	return .5 * noise(p) + .25 * noise(p*2.03) + .125 * noise(p*3.99);
}

struct ray_t {
	vec3 o, d;
};
	
struct xs_t {
	float l;
	vec3 pos, nor;
	float occlusion;
};
	
struct tree_t {
	vec2 pos;
	float r;
};

xs_t empty_xs(float maxdist) {
	return xs_t(maxdist, vec3(0.), vec3(0.), 0.);
}

xs_t ray_xs(in ray_t ray, float dist) {
	return xs_t(dist, ray.o + ray.d * dist, vec3(0.), 0.);
}
	
float height(in vec2 p) {
	float n = fnoise(p * c_scale); 
	return (n - .5) * c_height;
}

vec2 wind_displacement(in vec2 p) {
	return noise2(p*.1+iTime) - .5;
}

float grass_height(in vec3 p) {
	float base_h = height(p.xz);
	float depth = 1. - (base_h - p.y) / c_gheight;
	vec2 gpos = (p.xz + depth * wind_displacement(p.xz));
	return base_h - noise(gpos * c_gscale) * c_gheight;
}

vec3 grass_normal(in vec3 p) {
	return vec3(0.,1.,0.);
}

xs_t trace_terrain(in ray_t ray, float Lmax) {
	float L = 0.;
	for (int i = 0; i < c_terramarch_steps; ++i) {
		vec3 pos = ray.o + ray.d * L;
		float h = height(pos.xz);
		float dh = pos.y - h;
		if (dh < .005*L) break;
		L += dh;// * c_rslope;
		if (L > Lmax) break;
	}
	return ray_xs(ray, L);
}

xs_t trace_grass(in ray_t ray, float Lmin, float Lmax) {
	float L = Lmin;
	for (int i = 0; i < c_grassmarch_steps; ++i) {
		vec3 pos = ray.o + ray.d * L;
		float h = grass_height(pos);
		float dh = pos.y - h;
		if (dh < .005*L) break;
		L += dh * c_rgslope;
		if (L > Lmax) break;
	}
	vec3 pos = ray.o + ray.d * L;
	float occlusion = 1. - 2.*(height(pos.xz) - pos.y) / c_gheight;
	return xs_t(L, pos, grass_normal(pos), (L>Lmax)?1.:min(1.,occlusion));
}

vec3 shade_grass(in xs_t xs) {
	vec2 typepos = xs.pos.xz + wind_displacement(xs.pos.xz);
	float typemask1 = fnoise(2.5*typepos);
	float typemask2 = pow(fnoise(.4*typepos), 3.);
	float typemask3 = step(.71,fnoise(.8*typepos));
	vec3 col1 = vec3(.6, .87, .5);
	vec3 col2 = vec3(.7, .73, .4)*.3;
	vec3 col3 = vec3(1., 1., .1);
	vec3 col4 = vec3(1., .4, .7);
	vec3 color = mix(mix(mix(col1, col2, typemask1),
			col3, typemask2), col4, typemask3) * ambient;
	color *= xs.occlusion;
	return color;
}

ray_t lookAtDir(in vec3 uv_dir, in vec3 pos, in vec3 at) {
	vec3 f = normalize(at - pos);
	vec3 r = cross(f, vec3(0.,1.,0.));
	vec3 u = cross(r, f);
	return ray_t(pos, normalize(uv_dir.x * r + uv_dir.y * u + uv_dir.z * f));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
	uv.x *= iResolution.x / iResolution.y;
	
	vec3 pos = vec3(uv, 0.);
	pos += vec3(sin(.3*sin(iTime*.18)), 0., sin(.2*cos(iTime*.18)))*20.;
	pos += vec3(30., 5.+height(pos.xz), 10.);

	ray_t ray = lookAtDir(normalize(vec3(uv, 3.)), pos, vec3(0.));
	
	vec3 color = vec3(0.);

	xs_t xs = empty_xs(c_maxdist);
	xs_t terr = trace_terrain(ray, xs.l);
	if (terr.l < xs.l) {
		xs = trace_grass(ray, terr.l, terr.l+c_grassmaxdist);
	}
	
	if (xs.l < c_maxdist) {
		color = shade_grass(xs);
		color = mix(color, c_skycolor, smoothstep(c_maxdist*.35, c_maxdist, xs.l));
	} else {
		color = c_skycolor;
	}
	
	// gamma correction is for those who understand it
	//fragColor = vec4(pow(color, vec3(2.2)), 1.);
	fragColor = vec4(color, 1.);
}
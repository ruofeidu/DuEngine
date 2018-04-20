// 

#define MAX_REFLECTIONS 24
#define MULTISAMPLES 2 // Max 4

// Refraction index
const float N = 2.55; // Diamond
//const float N = 1.5; // Glass
//const float N = 1.33; // Water

// Shape of diamond, tiny changes affects total internal reflection patterns alot
float toph = -1.075;
float bottomh = 0.8;
float ring1r = 0.7;
float ring2h = -0.33;
float ring2r = 1.4;

const float pi = 3.1415926536;

vec3 ring1[9];

struct Triangle
{
    vec3 p;
    vec3 e1;
    vec3 e2;
    vec3 n;
};
const int num_tris = 24;
Triangle tris[num_tris];
mat3 rotation;

float sq(float x) { return x * x; }
float sq(vec3 x) { return dot(x, x); }

void setup_diamond()
{
	vec3 ring2[9];
    for (int i = 0; i < 8; ++i)
    {
        float a2 = float(i) * pi / 4.0;
        float a1 = a2 + pi / 8.0;
        vec4 cs = cos(vec4(a1, a2, a1 - 0.5 * pi, a2 - 0.5 * pi));
        ring1[i] = vec3(cs.x * ring1r, toph, cs.z * ring1r);
        ring2[i] = vec3(cs.y * ring2r, ring2h, cs.w * ring2r);
	}
    ring1[8] = ring1[0];
    ring2[8] = ring2[0];
    for (int i = 0; i < 8; ++i)
    {
        tris[i].p = vec3(0.0, bottomh, 0.0);
        tris[i].e1 = ring2[i + 1] - tris[i].p;
        tris[i].e2 = ring2[i] - tris[i].p;
        tris[i + 8].p = ring1[i];
        tris[i + 8].e1 = ring2[i] - ring1[i];
        tris[i + 8].e2 = ring2[i + 1] - ring1[i];
        tris[i + 16].p = ring2[i + 1];
        tris[i + 16].e1 = ring1[i + 1] - ring2[i + 1];
        tris[i + 16].e2 = ring1[i] - ring2[i + 1];
    }    
    for (int i = 0; i < num_tris; ++i)
        tris[i].n = normalize(cross(tris[i].e1, tris[i].e2));           
}

float intersect_octagon(vec3 p, vec3 d, float nf, out vec3 rn)
{
    vec3 n = vec3(0.0, -nf, 0.0);
    float dd = dot(-d, n);
    if (dd <= 0.0)
        return -1.0;
    float t = dot(p - ring1[0], n) / dd;
    vec3 pp = p + d * t;
    for (int i = 0; i < 8; ++i)
    	if (dot(cross(pp - ring1[i], ring1[i + 1] - ring1[i]), n) * nf > 0.0)
        	return -1.0;
    rn = n;
	return t;
}

float intersect_diamond(vec3 p, vec3 d, float nf, out vec3 n)
{
    float t = intersect_octagon(p, d, nf, n);
    if (t > 0.0)
        return t;
    for (int i = 0; i < num_tris; ++i)
    {
        vec3 P = cross(d, tris[i].e2);
        float det = dot(tris[i].e1, P) * nf;
        if (det <= 0.0) continue;
        vec3 T = p - tris[i].p;
        float u = dot(T, P) * nf;
        if (u < 0.0 || u > det) continue;
        vec3 Q = cross(T, tris[i].e1);
        float v = dot(d, Q) * nf;
        if (v < 0.0 || u + v > det) continue;
        float t = dot(tris[i].e2, Q) * nf;
        if (t > 0.0)
        {
			n = tris[i].n * nf;
            return t / det;
        }
    }
    return -1.0;
}

float fresnel(float n1, float n2, float cos_theta)
{
    float r = sq((n1 - n2) / (n1 + n2));
    return r + (1.0 - r) * pow(1.0 - cos_theta, 5.0);
}

vec4 background(vec3 d)
{
    return textureLod(iChannel0, rotation * d, 0.0);
}

vec4 ray(vec3 p, vec3 d)
{    
    vec3 n;
    float t = intersect_diamond(p, d, 1.0, n);
    if (t <= 0.0)
		return background(d);

    float f = fresnel(1.0, N, dot(-d, n));
    vec4 c = background(reflect(d, n)) * f;
    float cr = 1.0 - f;

    p += d * t;
    d = refract(d, n, 1.0 / N);

    for (int i = 0; i < MAX_REFLECTIONS; ++i)
    {
        if (cr < 0.05)
            break;
        t = intersect_diamond(p, d, -1.0, n);
        if (t > 0.0)
        {
            vec3 r = refract(d, n, N);
            if (r != vec3(0.0))
            {
                f = fresnel(N, 1.0, dot(-d, n));
                c += background(r) * (1.0 - f) * cr;
                cr *= f;
            }
            p += d * t;
            d = reflect(d, n);
        }
    }
    return c + background(d) * cr;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float r = iTime;
    float ry = iMouse.x * 6.28 / iResolution.x + r;
    float rx = (iMouse.y / iResolution.y - 0.5) * 3.0;

    vec4 cs = cos(vec4(ry, rx, ry - pi * 0.5, rx - pi * 0.5));
    vec3 forward = -vec3(cs.x * cs.y, cs.w, cs.z * cs.y);
	vec3 up = vec3(cs.x * cs.w, -cs.y, cs.z * cs.w);
	vec3 left = cross(up, forward);
    vec3 eye = -forward * 5.0;

    float zoom = 2.0;
    vec2 uv = zoom * (fragCoord.xy - iResolution.xy * 0.5) / iResolution.x;
    vec3 dir = normalize(vec3(forward + uv.y * up + uv.x * left));

    vec2 rcs = cos(vec2(r, r - 0.5 * pi));
 	rotation = mat3(
        rcs.x, 0.0, -rcs.y,
        0.0, 1.0, 0.0,
        rcs.y, 0.0, rcs.x);

    // early reject, bit hacky
    if (sq(dot(dir, -eye) * dir) < sq(4.75))
    {
		fragColor = background(dir);
        return;
    }

    setup_diamond();

    vec4 color = ray(eye, dir);
#if MULTISAMPLES > 1
    vec2 uvh = zoom * vec2(0.5) / iResolution.x;
    color += ray(eye, normalize(forward + (uv.y + uvh.y) * up + (uv.x + uvh.x) * left));
#if MULTISAMPLES > 2
    color += ray(eye, normalize(forward + (uv.y + uvh.y) * up  + uv.x * left));
#if MULTISAMPLES > 3
    color += ray(eye, normalize(forward + uv.y * up + (uv.x + uvh.x) * left));
#endif
#endif
    color /= float(MULTISAMPLES);
#endif
    fragColor = color;
}

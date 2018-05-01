mat2 rot(float x) {
    return mat2(cos(x), sin(x), -sin(x), cos(x));
}

vec2 random2( vec2 p ) {
    /* https://thebookofshaders.com/12/ */
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec4 voronoi(vec3 p) {
    p.x += sin(p.z);
    p.y += cos(p.z);
    p = vec3(atan(p.y, abs(p.x)) / 3.141592 * 3.0, 1.0 - length(p.xy), p.z);
    
    float k = 6.0;
    vec3 ip = floor(p * k);
    vec3 fp = fract(p * k);
    ip.y = 0.0;
    fp.y = p.y;
    
    vec4 da = vec4(vec3(0.0), 1000.0);
    vec4 db = da;
    vec3 dc = vec3(0.0);
    
    for (int i = 0; i < 9; ++i) {
        float fi = float(i);
        vec3 o = vec3(mod(fi, 3.0), 1.0, floor(fi / 3.0)) - 1.0;
        vec3 lp = o;
        lp.xz = o.xz + random2(ip.xz + o.xz);
        vec3 diff = lp - fp;
        float dist = dot(diff,diff);
        if (dist < da.w) {
            db = da;
            da = vec4(diff, dist);
            dc = ip + diff;
        } else if (dist < db.w) {
            db = vec4(diff, dist);
        }
    }
    
    /* from iq */
    float d = dot( 0.5*(da.xyz+db.xyz), normalize(db.xyz-da.xyz) );
    
    return vec4(dc, max(p.y, 0.25 - sqrt(d)));
}

float map(vec3 p) {
    return voronoi(p).w;
}

vec3 normal(vec3 p)
{
	vec3 o = vec3(0.01, 0.0, 0.0);
    return normalize(vec3(map(p+o.xyy) - map(p-o.xyy),
                          map(p+o.yxy) - map(p-o.yxy),
                          map(p+o.yyx) - map(p-o.yyx)));
}

float trace(vec3 o, vec3 r) {
    float t = 0.0;
    for (int i = 0; i < 32; ++i) {
        t += map(o + r * t) * 0.5;
    }
    return t;
}

vec3 tex3d(vec3 p) {
    vec3 ta = texture(iChannel0, p.yz).xyz;
    vec3 tb = texture(iChannel0, p.xz).xyz;
    vec3 tc = texture(iChannel0, p.xy).xyz;
    return (ta * ta + tb * tb + tc * tc) / 3.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 uv = fragCoord/iResolution.xy;
	uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    vec3 o = vec3(0.0, 0.0, iTime);
    o.x += -sin(o.z);
    o.y += -cos(o.z);
    vec3 r = normalize(vec3(uv, 0.7));
    r.xy *= rot(iTime);
    
    float t = trace(o, r);
    vec3 w = o + r * t;
    vec3 sn = normal(w);
    float aoc = map(w + sn * 0.5);
    vec4 vm = voronoi(w);

    float f = max(dot(-r, sn), 0.0) * aoc;
    f /= (1.0 + t * t * 0.1);
    vec3 fc = tex3d(vm.xyz * 0.2) * f;
    
    fragColor = vec4(sqrt(fc), 1.0);
}
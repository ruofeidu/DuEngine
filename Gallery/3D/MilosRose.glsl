// https://www.shadertoy.com/view/XsdyWr
// ray marching
const int max_iterations = 128;
const float stop_threshold = 0.01;
const float grad_step = 0.01;
const float clip_far = 10.0;

// math
const float PI = 3.14159265359;
const float PI2 = 6.28318530718;
const float DEG_TO_RAD = PI / 180.0;

mat3 rotationXY( vec2 angle ) {
	vec2 c = cos( angle );
	vec2 s = sin( angle );
	
	return mat3(
		c.y      ,  0.0, -s.y,
		s.y * s.x,  c.x,  c.y * s.x,
		s.y * c.x, -s.x,  c.y * c.x
	);
}

// distance function

float opI(float d1, float d2) {
    return max(d1, d2);
}

float opU(float d1, float d2) {
    return min(d1, d2);
}

float opS(float d1, float d2) {
    return max(-d1, d2);
}

float sdPetal(vec3 p, float s) {
    p = p * vec3(0.8, 1.5, 0.8) + vec3(0.1, 0.0, 0.0);
    vec2 q = vec2(length(p.xz), p.y);
    
    float lower = length(q) - 1.0;
    lower = opS(length(q) - 0.97, lower);
    lower = opI(lower, q.y);
    
    float upper = length((q - vec2(s, 0)) * vec2(1, 1)) + 1.0 - s;
    upper = opS(upper, length((q - vec2(s, 0)) * vec2(1, 1)) + 0.97 - s);
    upper = opI(upper, -q.y);
    upper = opI(upper, q.x - 2.0);
    
    float region = length(p - vec3(1.0, 0.0, 0.0)) - 1.0;

    return opI(opU(upper, lower), region);
}

float map(vec3 p) {
    float d = 1000.0, s = 2.0;
    mat3 r = rotationXY(vec2(0.1, PI2 * 0.618034));
    r = r * mat3(1.08,0.0,0.0 ,0.0,0.995,0.0, 0.0,0.0,1.08);
    for (int i = 0; i < 21; i++) {
        d = opU(d, sdPetal(p, s));
        p = r * p;
        p += vec3(0.0, -0.02, 0.0);
        s *= 1.05;
    }
    return d;
}

// get gradient in the world
vec3 gradient( vec3 pos ) {
	const vec3 dx = vec3( grad_step, 0.0, 0.0 );
	const vec3 dy = vec3( 0.0, grad_step, 0.0 );
	const vec3 dz = vec3( 0.0, 0.0, grad_step );
	return normalize (
		vec3(
			map( pos + dx ) - map( pos - dx ),
			map( pos + dy ) - map( pos - dy ),
			map( pos + dz ) - map( pos - dz )			
		)
	);
}

// ray marching
float ray_marching( vec3 origin, vec3 dir, float start, float end ) {
	float depth = start;
	for ( int i = 0; i < max_iterations; i++ ) {
		float dist = map( origin + dir * depth );
		if ( dist < stop_threshold ) {
			return depth;
		}
		depth += dist * 0.3;
		if ( depth >= end) {
			return end;
		}
	}
	return end;
}

const vec3 light_pos = vec3( 20.0, 50.0, 20.0 );

vec3 shading(vec3 v, vec3 n, vec3 eye) {
	vec3 ev = normalize(v - eye);
    vec3 mat_color = vec3(0.65,0.0,0.0);
 
    vec3 vl = normalize(light_pos - v);

    float diffuse = dot(vl, n) * 0.5 + 0.5;
    vec3 h = normalize(vl - ev);
    float rim = pow(1.0 - max(dot(n, -ev), 0.0), 2.0) * 0.15;
    float ao = clamp(v.y * 0.5 + 0.5, 0.0, 1.0);
    return (mat_color * diffuse + rim) * ao;
}

// get ray direction
vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
	float z = size.y * 0.5 * cot_half_fov;
	
	return normalize( vec3( xy, -z ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// default ray dir
	vec3 dir = ray_dir(45.0, iResolution.xy, fragCoord.xy);
	
	// default ray origin
	vec3 eye = vec3( 0.0, 0.0, 5.0 );

	// rotate camera
	mat3 rot = rotationXY(vec2(-1.0, 1.0));
    if (iMouse.x > 0.0)
		rot = rotationXY(iMouse.yx / iResolution.yx * vec2(PI, -2.0 * PI) + vec2(PI * -0.5, PI));
    
	dir = rot * dir;
	eye = rot * eye;
	
	// ray marching
	float depth = ray_marching(eye, dir, 0.0, clip_far);
    vec3 pos = eye + dir * depth;
    vec3 c;
    if (depth >= clip_far) {
		c = vec3(0.2, 0.0, 0.1);
    }
    else {
        // shading
        vec3 n = gradient( pos );
        c = shading(pos, n, eye);
    }
    
    float r = 1.2 - length((fragCoord.xy / iResolution.xy) - 0.5) * 1.0;
    fragColor = vec4(c * r, 1.0);
}
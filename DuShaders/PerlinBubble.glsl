// 4lySzt
vec2 L = vec2(.7, .7);                           // Light direction

vec3 mod289(vec3 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 mod289(vec4 x) { return x - floor(x * (1. / 289.)) * 289.; }
vec4 permute(vec4 x) { return mod289(((x*34.)+1.)*x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - .85373472095314 * r; }
vec3 fade(vec3 t) { return t*t*t*(t*(t*6.-15.)+10.); }
float noise(vec3 P) {
	vec3 i0 = mod289(floor(P)), i1 = mod289(i0 + vec3(1.)),
		 f0 = fract(P), f1 = f0 - vec3(1.), f = fade(f0);
	vec4 ix = vec4(i0.x, i1.x, i0.x, i1.x), iy = vec4(i0.yy, i1.yy),
		 iz0 = i0.zzzz, iz1 = i1.zzzz,
		 ixy = permute(permute(ix) + iy), ixy0 = permute(ixy + iz0), ixy1 = permute(ixy + iz1),
		 gx0 = ixy0 * (1. / 7.), gy0 = fract(floor(gx0) * (1. / 7.)) - .5,
		 gx1 = ixy1 * (1. / 7.), gy1 = fract(floor(gx1) * (1. / 7.)) - .5;
	gx0 = fract(gx0); gx1 = fract(gx1);
	vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0), sz0 = step(gz0, vec4(0.)),
		 gz1 = vec4(0.5) - abs(gx1) - abs(gy1), sz1 = step(gz1, vec4(0.));
	gx0 -= sz0 * (step(0., gx0) - .5); gy0 -= sz0 * (step(0., gy0) - .5);
	gx1 -= sz1 * (step(0., gx1) - .5); gy1 -= sz1 * (step(0., gy1) - .5);
	vec3 g0 = vec3(gx0.x,gy0.x,gz0.x), g1 = vec3(gx0.y,gy0.y,gz0.y),
		 g2 = vec3(gx0.z,gy0.z,gz0.z), g3 = vec3(gx0.w,gy0.w,gz0.w),
		 g4 = vec3(gx1.x,gy1.x,gz1.x), g5 = vec3(gx1.y,gy1.y,gz1.y),
		 g6 = vec3(gx1.z,gy1.z,gz1.z), g7 = vec3(gx1.w,gy1.w,gz1.w);
	vec4 norm0 = taylorInvSqrt(vec4(dot(g0,g0), dot(g2,g2), dot(g1,g1), dot(g3,g3))),
		 norm1 = taylorInvSqrt(vec4(dot(g4,g4), dot(g6,g6), dot(g5,g5), dot(g7,g7)));
	g0 *= norm0.x; g2 *= norm0.y; g1 *= norm0.z; g3 *= norm0.w;
	g4 *= norm1.x; g6 *= norm1.y; g5 *= norm1.z; g7 *= norm1.w;
	vec4 nz = mix(vec4(dot(g0, vec3(f0.x, f0.y, f0.z)), dot(g1, vec3(f1.x, f0.y, f0.z)),
					   dot(g2, vec3(f0.x, f1.y, f0.z)), dot(g3, vec3(f1.x, f1.y, f0.z))),
				  vec4(dot(g4, vec3(f0.x, f0.y, f1.z)), dot(g5, vec3(f1.x, f0.y, f1.z)),
					   dot(g6, vec3(f0.x, f1.y, f1.z)), dot(g7, vec3(f1.x, f1.y, f1.z))), f.z);
	return 2.2 * mix(mix(nz.x,nz.z,f.y), mix(nz.y,nz.w,f.y), f.x);
}
float turbulence(vec3 P) {              // Turbulence is a fractal sum of abs(noise).
	float f = 0., s = 1.;                // The domain is rotated after every iteration
	for (int i = 0 ; i < 9 ; i++) {      //    to avoid any visible grid artifacts.
	   f += abs(noise(s * P)) / s;
	   s *= 2.;
	   P = vec3(.866 * P.x + .5 * P.z, P.y + 100., -.5 * P.x + .866 * P.z);
	}
	return f;
}

float D(float x, float y) {                      // Make a disk shape
    float b = 1. - (x * x + y * y) / 10.;
    b = b < 0. ? 0. : b * b * b * b;
    return sqrt(clamp(b - .707, 0.0, 1.0));
}
float H(vec2 v) {                                // Make a highlight
    return max(0., 1. - v.x * v.x - v.y * v.y);
}
vec3 soap(vec3 v) {                              // Make a soap film
    return sin(15. * v + vec3(10.,10.,10.) *
                        turbulence(v + vec3(0., 0., .11 * iTime)));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 vPos = 2.0 * (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
    vec3 c = .3 * mix(vec3(.15,.1,.1),            // Sky color gradient
                      vec3(.2 ,.4,1.),
			     .5 + .4 * vPos.y);
    float d = D(vPos.x, vPos.y);                  // Bubble shape
    if (d > 0.) {
        vec2 v = vec2((D(vPos.x+.01, vPos.y) - d) / .01, // Surface tilt
                      (D(vPos.x, vPos.y+.01) - d) / .01);
        
        float z = sqrt(1. - min(1., .05 * dot(v, v)));   // Depth
        
        c += z * ( c * max(0., .06 * dot(L, v)) +        // Rim light
                   vec3(.3,.3,.3)
		 * pow(H(v + L) + .8 * H(v - L), 8.) );  // Highlights
        
        c *= 1. + .2 * soap(.25 * vec3(v, z));           // Soap film
     }
     fragColor = vec4(sqrt(c), 1.);             // Final pixel color
}

// https://www.shadertoy.com/view/ld2cW1
/*
	Forward rendering for 2D lighting doesn't seem like the best idea to me.
	In particular, alpha blending means you can't reorder draw calls for better batching,
	and combined with a lack of z-testing it makes for a lot of overdraw.

	What if instead you could precalculate all the lighting, and look it up using the normal?
	That's basically the idea here. You can bake a high quality lightprobe texture offline
	or render a realtime one in screen space.

	Applying the probe values should be pretty cheap, requiring only some basic arithmetic.
	However, it will require 6 texture samples per shaded pixel (1x albedo, 1x normal, 4x light).
	Seems like it shouldn't be worse than deferred, though that's not a low bar exactly.
	
	I also have an interactive MathStudio notebook I used to figure out some of the math.
	http://mathstud.io/V9GLZ5
*/

// Fourier series coefficients for a diffuse light probe.
struct Probe {vec3 a0, a1, b1, a2, b2;};

// Double angle identities for cos() and sin()
vec2 DoubleAngle(vec2 n){
	return vec2(n.x*n.x - n.y*n.y, 2.0*n.x*n.y);
}

void FourierAccum(vec3 direction, vec3 color, inout Probe probe){
    // Kinda mostly workable hack to approximate a light not on the xy plane.
    // Should figure out a more accurate curve for this.
    const float C0 = 0.318309886184; // 1/pi
    probe.a0 += mix(C0, 1.0, direction.z)*color;
    
    const float C1 = 0.5;
    vec2 g1 = -C1*direction.xy;
    probe.a1 += g1.x*color;
    probe.b1 += g1.y*color;
    
    const float C2 = 0.212206590789; // 2/(3*pi)
    vec2 g2 = C2*DoubleAngle(-direction.xy);
    probe.a2 += g2.x*color;
    probe.b2 += g2.y*color;
}

vec3 FourierApply(vec3 n, Probe probe){
    vec2 g1 = n.xy;
    vec2 g2 = DoubleAngle(g1);
    return probe.a0 + probe.a1*g1.xxx + probe.b1*g1.yyy + probe.a2*g2.xxx + probe.b2*g2.yyy;
}

vec3 SphereBumps(vec2 uv){
    vec2 uv2 = 2.0*fract(4.0*uv) - 1.0;
    float z = 1.0 - dot(uv2, uv2);
	vec3 n = vec3(uv2, z);
    float mask = step(1.0, length(uv2));
    return mix(n, vec3(0, 0, 1), mask);
}

vec2 TransformGradient(vec2 basis, float h){
    vec2 m1 = dFdx(basis), m2 = dFdy(basis);
    mat2 adjoint = mat2(m2.y, -m2.x, -m1.y, m1.x);

    float eps = 1e-7; // Avoid divide by zero.
    float det = m2.x*m1.y - m1.x*m2.y + eps;
    return vec2(dFdx(h), dFdy(h))*adjoint/det;
}

vec3 BumpMap(vec2 uv, float height){
    float value = height*texture(iChannel0, uv).r;
    vec2 grad = TransformGradient(uv, value);
    return vec3(grad, 1.0 - dot(grad, grad));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = fragCoord.xy/iResolution.xy;
    uv.x *= 2.0;
    
    vec3 ambient = vec3(0.0, 0.0, 0.2);
    Probe probe = Probe(ambient, vec3(0.0), vec3(0.0), vec3(0.0), vec3(0.0));
    
    // Spinning directional light at z=0
    vec3 dir = vec3(cos(iTime), sin(iTime), 0.0);
    FourierAccum(dir, vec3(0.0, 0.4, 0.2), probe);
	
    // Mouse controlled light at z=0.2
    vec2 mouse = iMouse.xy/iResolution.xy;
    mouse.x *= 2.0;
    vec2 delta = uv - mouse;
    vec3 dirMouse = normalize(vec3(delta, 0.2));
    vec3 colorMouse = vec3(0.6, 0.0, 0.5)*max(0.0, 0.7 - length(delta)/2.75);
    FourierAccum(dirMouse, colorMouse, probe);
    
    // Generate some fun normals to use to light stuff up.
//    vec3 n = SphereBumps(uv);
    vec3 n = BumpMap(uv, 0.1);
//    fragColor = vec4(0.5*n + 0.5, 1.0); return;

    // The magic!
    // Calculate the lighting for the current pixel based on the normal
    // and Fourier series approximation.
    fragColor.rgb = FourierApply(n, probe).rgb;
    fragColor.a = 1.0;
}

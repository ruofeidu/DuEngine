// https://www.shadertoy.com/view/ld2yDh
/*
+1 for the http://mathstud.io/dQBNHR.  looks like a nifty app
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
	
	I also made a version that applies the lighting to a bump map:
	https://www.shadertoy.com/view/ld2cW1
*/

vec3 light(float angle, float intensity){
 	return vec3(normalize(vec2(cos(angle), sin(angle))), intensity);   
}

float NdotL(vec2 n, vec3 light){
    return max(0.0, light.z*dot(n, light.xy));
}

// Double angle identities for cos() and sin()
vec2 DoubleAngle(vec2 n){
	return vec2(n.x*n.x - n.y*n.y, 2.0*n.x*n.y);
}

// Fourier series constants.
const float C0 = 0.318309886184; // 1/pi
const float C1 = 0.5;
const float C2 = 0.212206590789; // 2/(3*pi)

void FourierApprox(
    vec3 light,
    inout float a0,
    inout vec4 ab12
){
    vec2 g = light.xy;
    vec2 g2 = DoubleAngle(g);
    
    a0 += C0*light.z;
	ab12 += light.z*vec4(C1*g, C2*g2);
}

float FourierApply(vec2 n, float a0, vec4 ab12){
    vec2 n2 = DoubleAngle(n);
    return max(0.0, a0 + dot(ab12, vec4(n, n2)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
    vec2 uv = fragCoord.xy/iResolution.xy;
    uv.x *= 2.0;
    uv = fract(uv);
    uv.y *= (2.0*iResolution.y)/iResolution.x;
    
    vec2 n = normalize(2.0*uv - 1.0);
    float mask = step(length(2.0*uv - 1.0), 1.0);
    
    // Light Values
    float ambient = 0.0;
    vec3 l0 = light(iMouse.x/50.0, iMouse.y/iResolution.y);
    vec3 l1 = light(iTime/5.0, 0.3);
    
    if(fragCoord.x < 0.5*iResolution.x){
        // Left side works additively like forward rendering.
		float l = ambient;
        l += NdotL(n, l0);
        l += NdotL(n, l1);
        fragColor = mask*vec4(l); return;
    } else {
        // Right side creates a light probe for the pixel then applies that.
        float a0 = ambient;
        vec4 ab12 = vec4(0.0);
        
        FourierApprox(l0, a0, ab12);
        FourierApprox(l1, a0, ab12);
        
        float l = FourierApply(n, a0, ab12);
        fragColor = mask*vec4(l); return;
    }
    
    fragColor = vec4(1, 0, 0, 1); return;
}

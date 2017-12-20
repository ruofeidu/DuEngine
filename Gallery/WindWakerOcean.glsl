// https://www.shadertoy.com/view/ltfGD7
// "Wind Waker Ocean" by @Polyflare (29/1/15)
// License: Creative Commons Attribution 4.0 International

// Source code for the texture generator is available at:
// https://github.com/lmurray/circleator

//-----------------------------------------------------------------------------
// User settings

// 0 = No antialiasing
// 1 = 2x2 supersampling antialiasing
#define ANTIALIAS 1

// 0 = Static camera
// 1 = Animate the camera
#define ANIMATE_CAM 1

// 0 = Do not distort the water texture
// 1 = Apply lateral distortion to the water texture
#define DISTORT_WATER 1

// 0 = Disable parallax effects
// 1 = Change the height of the water with parallax effects
#define PARALLAX_WATER 1

// 0 = Antialias the water texture
// 1 = Do not antialias the water texture
#define FAST_CIRCLES 1

//-----------------------------------------------------------------------------

#define WATER_COL vec3(0.0, 0.4453, 0.7305)
#define WATER2_COL vec3(0.0, 0.4180, 0.6758)
#define FOAM_COL vec3(0.8125, 0.9609, 0.9648)
#define FOG_COL vec3(0.6406, 0.9453, 0.9336)
#define SKY_COL vec3(0.0, 0.8203, 1.0)

#define M_2PI 6.283185307
#define M_6PI 18.84955592

float circ(vec2 pos, vec2 c, float s)
{
    c = abs(pos - c);
    c = min(c, 1.0 - c);
#if FAST_CIRCLES
    return dot(c, c) < s ? -1.0 : 0.0;
#else
    return smoothstep(0.0, 0.002, sqrt(s) - sqrt(dot(c, c))) * -1.0;
#endif
}

// Foam pattern for the water constructed out of a series of circles
float waterlayer(vec2 uv)
{
    uv = mod(uv, 1.0); // Clamp to [0..1]
    float ret = 1.0;
    ret += circ(uv, vec2(0.37378, 0.277169), 0.0268181);
    ret += circ(uv, vec2(0.0317477, 0.540372), 0.0193742);
    ret += circ(uv, vec2(0.430044, 0.882218), 0.0232337);
    ret += circ(uv, vec2(0.641033, 0.695106), 0.0117864);
    ret += circ(uv, vec2(0.0146398, 0.0791346), 0.0299458);
    ret += circ(uv, vec2(0.43871, 0.394445), 0.0289087);
    ret += circ(uv, vec2(0.909446, 0.878141), 0.028466);
    ret += circ(uv, vec2(0.310149, 0.686637), 0.0128496);
    ret += circ(uv, vec2(0.928617, 0.195986), 0.0152041);
    ret += circ(uv, vec2(0.0438506, 0.868153), 0.0268601);
    ret += circ(uv, vec2(0.308619, 0.194937), 0.00806102);
    ret += circ(uv, vec2(0.349922, 0.449714), 0.00928667);
    ret += circ(uv, vec2(0.0449556, 0.953415), 0.023126);
    ret += circ(uv, vec2(0.117761, 0.503309), 0.0151272);
    ret += circ(uv, vec2(0.563517, 0.244991), 0.0292322);
    ret += circ(uv, vec2(0.566936, 0.954457), 0.00981141);
    ret += circ(uv, vec2(0.0489944, 0.200931), 0.0178746);
    ret += circ(uv, vec2(0.569297, 0.624893), 0.0132408);
    ret += circ(uv, vec2(0.298347, 0.710972), 0.0114426);
    ret += circ(uv, vec2(0.878141, 0.771279), 0.00322719);
    ret += circ(uv, vec2(0.150995, 0.376221), 0.00216157);
    ret += circ(uv, vec2(0.119673, 0.541984), 0.0124621);
    ret += circ(uv, vec2(0.629598, 0.295629), 0.0198736);
    ret += circ(uv, vec2(0.334357, 0.266278), 0.0187145);
    ret += circ(uv, vec2(0.918044, 0.968163), 0.0182928);
    ret += circ(uv, vec2(0.965445, 0.505026), 0.006348);
    ret += circ(uv, vec2(0.514847, 0.865444), 0.00623523);
    ret += circ(uv, vec2(0.710575, 0.0415131), 0.00322689);
    ret += circ(uv, vec2(0.71403, 0.576945), 0.0215641);
    ret += circ(uv, vec2(0.748873, 0.413325), 0.0110795);
    ret += circ(uv, vec2(0.0623365, 0.896713), 0.0236203);
    ret += circ(uv, vec2(0.980482, 0.473849), 0.00573439);
    ret += circ(uv, vec2(0.647463, 0.654349), 0.0188713);
    ret += circ(uv, vec2(0.651406, 0.981297), 0.00710875);
    ret += circ(uv, vec2(0.428928, 0.382426), 0.0298806);
    ret += circ(uv, vec2(0.811545, 0.62568), 0.00265539);
    ret += circ(uv, vec2(0.400787, 0.74162), 0.00486609);
    ret += circ(uv, vec2(0.331283, 0.418536), 0.00598028);
    ret += circ(uv, vec2(0.894762, 0.0657997), 0.00760375);
    ret += circ(uv, vec2(0.525104, 0.572233), 0.0141796);
    ret += circ(uv, vec2(0.431526, 0.911372), 0.0213234);
    ret += circ(uv, vec2(0.658212, 0.910553), 0.000741023);
    ret += circ(uv, vec2(0.514523, 0.243263), 0.0270685);
    ret += circ(uv, vec2(0.0249494, 0.252872), 0.00876653);
    ret += circ(uv, vec2(0.502214, 0.47269), 0.0234534);
    ret += circ(uv, vec2(0.693271, 0.431469), 0.0246533);
    ret += circ(uv, vec2(0.415, 0.884418), 0.0271696);
    ret += circ(uv, vec2(0.149073, 0.41204), 0.00497198);
    ret += circ(uv, vec2(0.533816, 0.897634), 0.00650833);
    ret += circ(uv, vec2(0.0409132, 0.83406), 0.0191398);
    ret += circ(uv, vec2(0.638585, 0.646019), 0.0206129);
    ret += circ(uv, vec2(0.660342, 0.966541), 0.0053511);
    ret += circ(uv, vec2(0.513783, 0.142233), 0.00471653);
    ret += circ(uv, vec2(0.124305, 0.644263), 0.00116724);
    ret += circ(uv, vec2(0.99871, 0.583864), 0.0107329);
    ret += circ(uv, vec2(0.894879, 0.233289), 0.00667092);
    ret += circ(uv, vec2(0.246286, 0.682766), 0.00411623);
    ret += circ(uv, vec2(0.0761895, 0.16327), 0.0145935);
    ret += circ(uv, vec2(0.949386, 0.802936), 0.0100873);
    ret += circ(uv, vec2(0.480122, 0.196554), 0.0110185);
    ret += circ(uv, vec2(0.896854, 0.803707), 0.013969);
    ret += circ(uv, vec2(0.292865, 0.762973), 0.00566413);
    ret += circ(uv, vec2(0.0995585, 0.117457), 0.00869407);
    ret += circ(uv, vec2(0.377713, 0.00335442), 0.0063147);
    ret += circ(uv, vec2(0.506365, 0.531118), 0.0144016);
    ret += circ(uv, vec2(0.408806, 0.894771), 0.0243923);
    ret += circ(uv, vec2(0.143579, 0.85138), 0.00418529);
    ret += circ(uv, vec2(0.0902811, 0.181775), 0.0108896);
    ret += circ(uv, vec2(0.780695, 0.394644), 0.00475475);
    ret += circ(uv, vec2(0.298036, 0.625531), 0.00325285);
    ret += circ(uv, vec2(0.218423, 0.714537), 0.00157212);
    ret += circ(uv, vec2(0.658836, 0.159556), 0.00225897);
    ret += circ(uv, vec2(0.987324, 0.146545), 0.0288391);
    ret += circ(uv, vec2(0.222646, 0.251694), 0.00092276);
    ret += circ(uv, vec2(0.159826, 0.528063), 0.00605293);
	return max(ret, 0.0);
}

// Procedural texture generation for the water
vec3 water(vec2 uv, vec3 cdir)
{
    uv *= vec2(0.25);
    
#if PARALLAX_WATER
    // Parallax height distortion with two directional waves at
    // slightly different angles.
    vec2 a = 0.025 * cdir.xz / cdir.y; // Parallax offset
    float h = sin(uv.x + iTime); // Height at UV
    uv += a * h;
    h = sin(0.841471 * uv.x - 0.540302 * uv.y + iTime);
    uv += a * h;
#endif
    
#if DISTORT_WATER
    // Texture distortion
    float d1 = mod(uv.x + uv.y, M_2PI);
    float d2 = mod((uv.x + uv.y + 0.25) * 1.3, M_6PI);
    d1 = iTime * 0.07 + d1;
    d2 = iTime * 0.5 + d2;
    vec2 dist = vec2(
    	sin(d1) * 0.15 + sin(d2) * 0.05,
    	cos(d1) * 0.15 + cos(d2) * 0.05
    );
#else
    const vec2 dist = vec2(0.0);
#endif
    
    vec3 ret = mix(WATER_COL, WATER2_COL, waterlayer(uv + dist.xy));
    ret = mix(ret, FOAM_COL, waterlayer(vec2(1.0) - uv - dist.yx));
    return ret;
}

// Camera perspective based on [0..1] viewport
vec3 pixtoray(vec2 uv)
{
    vec3 pixpos;
    pixpos.xy = uv - 0.5;
    pixpos.y *= iResolution.y / iResolution.x; // Aspect correction
    pixpos.z = -0.6; // Focal length (Controls field of view)
    return normalize(pixpos);
}

// Quaternion-vector multiplication
vec3 quatmul(vec4 q, vec3 v)
{
    vec3 qvec = q.xyz;
    vec3 uv = cross(qvec, v);
    vec3 uuv = cross(qvec, uv);
    uv *= (2.0 * q.w);
    uuv *= 2.0;
    return v + uv + uuv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
#if ANTIALIAS
    for(int y = 0; y < 2; y++) {
        for(int x = 0; x < 2; x++) {
        	vec2 offset = vec2(0.5) * vec2(x, y) - vec2(0.25);
#else
        	vec2 offset = vec2(0.0);
#endif
            // Camera stuff
            vec2 uv = (fragCoord.xy + offset) / iResolution.xy;
            vec3 cpos = vec3(0.0, 4.0, 10.0); // Camera position
            vec3 cdir = pixtoray(uv);
            cdir = quatmul( // Tilt down slightly
                vec4(-0.19867, 0.0, 0.0, 0.980067), cdir);
#if ANIMATE_CAM
            // Rotating camera
            float cost = cos(iTime * -0.05);
            float sint = sin(iTime * -0.05);
            cdir.xz = cost * cdir.xz + sint * vec2(-cdir.z, cdir.x);
            cpos.xz = cost * cpos.xz + sint * vec2(-cpos.z, cpos.x);
#endif

            // Ray-plane intersection
            const vec3 ocean = vec3(0.0, 1.0, 0.0);
            float dist = -dot(cpos, ocean) / dot(cdir, ocean);
            vec3 pos = cpos + dist * cdir;

            vec3 pix;
            if(dist > 0.0 && dist < 100.0) {
                // Ocean
                vec3 wat = water(pos.xz, cdir);
                pix = mix(wat, FOG_COL, min(dist * 0.01, 1.0));
            } else {
                // Sky
                pix = mix(FOG_COL, SKY_COL, min(cdir.y * 4.0, 1.0));
            }
#if ANTIALIAS
        	fragColor.rgb += pix * vec3(0.25);
    	}
    }
#else
    fragColor.rgb = pix;
#endif
}

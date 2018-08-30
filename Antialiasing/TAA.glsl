// https://www.shadertoy.com/view/4dSBDt
// BufA: Main image
// BufB: Bloom
// BufC: TAA
// Image: Post Processing

// Main goal was to model a believable cloud scape and integrate
// the floating Enscape cube in the scene with accurate reflection
// and water interaction.
// There are some compilation issues with Chrome on some machines,
// Firefox seems to work better. The TAA only works well with high FPS.

// Let me know what you think and follow me on Twitter @ThomasSchander
// Regards to everyone around Karlsruhe :)

//#define NO_POST_PRO

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    
#ifdef NO_POST_PRO
    fragColor = textureLod(iChannel0, q, 0.0);
    return;
#endif
    vec2 v = -1.0 + 2.0*q;
    v.x *= iResolution.x/ iResolution.y;
    
    float vign = smoothstep(4.0, 0.6, length(v));
    
    vec2 centerToUv = q-vec2(0.5);
	vec3 aberr;
    aberr.x = textureLod(iChannel0, vec2(0.5)+centerToUv*0.995,0.0).x; 
    aberr.y = textureLod(iChannel0, vec2(0.5)+centerToUv*0.997, 0.0).y;
    aberr.z = textureLod(iChannel0, vec2(0.5)+centerToUv, 0.0).z;
    fragColor = vec4(pow(vign*aberr, vec3(0.2+1.0/2.2)), 1.0);
}

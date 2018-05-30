// MdGfzh
// Himalayas. Created by Reinder Nijhoff 2018
// @reindernijhoff
//
// https://www.shadertoy.com/view/MdGfzh
//
// This is my first attempt to render volumetric clouds in a fragment shader.
//
// Buffer A: The main look-up texture for the cloud shapes. 
// Buffer B: A 3D (32x32x32) look-up texture with Worley Noise used to add small details 
//           to the shapes of the clouds. I have packed this 3D texture into a 2D buffer.
// 
bool resolutionChanged() {
    return floor(texelFetch(iChannel1, ivec2(0), 0).r) != floor(iResolution.x);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) { 
    if (resolutionChanged()) {
        vec2 vUV = fragCoord / iResolution.xy;
        vec3 coord = vec3(vUV + vec2(.2,0.62), .5);
        
        vec4 col = vec4(1);
        
        float mfbm = 0.9;
        float mvor = 0.7;
        
        col.r = mix(1., tilableFbm( coord, 7, 4. ), mfbm) * 
            	mix(1., tilableVoronoi( coord, 8, 9. ), mvor);
        col.g = 0.625 * tilableVoronoi( coord + 0., 3, 15. ) +
        		0.250 * tilableVoronoi(  coord + 0., 3, 19. ) +
        		0.125 * tilableVoronoi( coord + 0., 3, 23. ) 
            	-1.;
        col.b = 1. - tilableVoronoi( coord + 0.5, 6, 9. );
        
	    fragColor = col;
    } else {
        fragColor = texelFetch(iChannel0, ivec2(fragCoord), 0);
    }
}
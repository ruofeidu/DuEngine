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
        // pack 32x32x32 3d texture in 2d texture
        float z = floor(fragCoord.x/32.) + 8.*floor(fragCoord.y/32.);
        vec2 uv = mod(fragCoord.xy, 32.);
        vec3 coord = vec3(uv, z) / 32.;

        float r = tilableVoronoi( coord, 16,  3. );
        float g = tilableVoronoi( coord,  4,  8. );
        float b = tilableVoronoi( coord,  4, 16. );

        float c = max(0., 1.-(r + g * .5 + b * .25) / 1.75);

        fragColor = vec4(c,c,c,c);
    } else {
        fragColor = texelFetch(iChannel0, ivec2(fragCoord), 0);
    }
}

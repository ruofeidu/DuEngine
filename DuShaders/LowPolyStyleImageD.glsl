// A secondary buffer to get clean Voronoi every N-th frame

// this must be in sync with JFA algorithm constant
const float c_maxSteps = 8.0;

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   	vec2 uv = fragCoord.xy / iResolution.xy;
    if (mod(float(iFrame + 2), c_maxSteps) < .5) {
        fragColor = texture(iChannel1, uv); // update to new voronoi cell
    } else {
        fragColor = texture(iChannel0, uv); // no change
    }
}

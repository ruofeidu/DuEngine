// https://www.shadertoy.com/view/XtXBWf
// Define the three points of the triangle (Rule 1)
const int len = 3;
const vec2 points[len] = vec2[len](
    vec2(.5, .9), vec2(.2, .1), vec2(.8, .1)
);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Restore last frame
    vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = texture(iChannel0, uv);
    
    
    // Setup-if-statement:
    // Resets the scene every 3 seconds.
    // (in case this shader runs at 60 fps, which it most likely will)
    if(iFrame % 180 < 2)
    {
        fragColor = vec4(.0);
        float d = 2. / iResolution.y;
        
        // Draws a random starting point. (Rule 2)
        // (starting point is always drawn in the middle,
        // but it does work with every point, on the canvas!)
        uv = (2.*uv-1.) / vec2(1.,iResolution.x/iResolution.y);
        fragColor += 1.-step(d, length(uv));
        //fragColor += 1.-step(d, length(uv));
        
        return;
    }
    
    
    // Checks, whether uv is inbetween one of the endpoints and
    // a point, which has been drawn previously. (Rule 3, but backwards)
    fragColor += texture(iChannel0, 2.*(uv-points[iFrame%len]/2.));
}
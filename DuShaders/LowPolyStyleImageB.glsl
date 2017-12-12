// Modified JFA algorithm to store flattened point offsets instead of coords
// Tom@2016
//https://www.shadertoy.com/view/ldV3Wc#
// Original implementation by demofox:
//    https://www.shadertoy.com/view/Mdy3DK

// how many JFA steps to do.  2^c_maxSteps is max image size on x and y
const float c_maxSteps = 8.0;

//============================================================
vec2 GetCoord( float offset )
{
    float y = floor(offset / iResolution.x);
    return vec2( offset - y * iResolution.x, y ) + .5;
}

//============================================================
vec4 StepJFA (in vec2 fragCoord, in float level)
{
    float stepwidth = floor(exp2(c_maxSteps - 1. - level)+0.5);
    
    float bestDistance = 9999.0;
    float bestCoord;
    
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            vec2 sampleCoord = fragCoord + vec2(x,y) * stepwidth;
            
            float offset = texture( iChannel0, sampleCoord / iChannelResolution[0].xy).x;
            if (offset == 0.) continue;
            float dist = length(GetCoord(offset) - fragCoord);
            if (dist < bestDistance)
            {
                bestDistance = dist;
                bestCoord = offset;
            }
        }
    }
    
    return vec4(bestCoord, 0.0, 0.0, 0.0);
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float fFrame = float(iFrame);
    float level = mod(fFrame,c_maxSteps);
    if (level < .5) {
        if (texture(iChannel1, fragCoord / iResolution.xy).w > .5)
        	fragColor = vec4(floor(fragCoord.y)*iResolution.x + floor(fragCoord.x), 0.0, 0.0, 0.0);
        else 
            fragColor = vec4(0.0);
        return;
    }
    
    fragColor = StepJFA(fragCoord, level);
}


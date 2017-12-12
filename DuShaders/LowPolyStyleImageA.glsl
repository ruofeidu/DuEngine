// A super simple video source with feature detection
const float eps = 1e-2;

float grayScale(vec4 c) { return c.x*.29 + c.y*.58 + c.z*.13; }

//============================================================
vec4 GenerateSeed (in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec3 dataStep = vec3( vec2(1.) / iChannelResolution[0].xy, 0.);
    
    vec4 fragColor = texture( iChannel0, uv );
    
    float d = grayScale(fragColor);
    float dL = grayScale(texture( iChannel0, uv - dataStep.xz ));
    float dR = grayScale(texture( iChannel0, uv + dataStep.xz ));
    float dU = grayScale(texture( iChannel0, uv - dataStep.zy ));
    float dD = grayScale(texture( iChannel0, uv + dataStep.zy ));
    float scale = 1.0;
    float w = float( d*(.99 + scale*.01) > max(max(dL, dR), max(dU, dD)) );
    
    //w = max(w, texture( iChannel1, uv ).w*.9); // get some from previous frame
    if (uv.x < eps || uv.y < eps || (1.0-uv.x) < eps || (1.0-uv.y)<eps) w = 1.0;
    fragColor.w = w;
    
    return fragColor;
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = GenerateSeed(fragCoord);
}


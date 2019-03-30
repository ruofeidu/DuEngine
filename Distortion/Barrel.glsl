// https://www.shadertoy.com/view/lddGDN
vec2 barrelDistortion(vec2 uv)
{   
    float distortion = 0.2;
    float r = uv.x*uv.x + uv.y*uv.y;
    uv *= 1.6 + distortion * r + distortion * r * r;
    return uv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv = barrelDistortion(uv);
    uv = 0.5 * (uv * 0.5 + 1.0);
	fragColor = texture(iChannel0, uv);
}

// void mainImage( out vec4 o, vec2 u )
// {
    // float r =  dot( u = 2.*u / iResolution.xy -1.  ,u);
	// o = texture2D(iChannel0, .5 + u*(.4+ (r+r*r)/20.) );
// }

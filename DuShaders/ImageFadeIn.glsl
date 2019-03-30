// MlcSz2
/** 
 * Image Fade-In Effect by Ruofei Du (DuRuofei.com)
 * starea @ ShaderToy, CC0
 *
 * Reference: 
 * [1] Íñigo Quílez. Trick! https://www.shadertoy.com/view/XljSRK
 *
 **/

// Forked from iq's invisible shader with transparent background: [url]https://www.shadertoy.com/view/XljSRK[/url]
float backgroundPattern( in vec2 p )
{
    vec2 uv = p + 0.1*texture( iChannel2, 0.05*p ).xy;
    return texture( iChannel1, 16.0*uv ).x;
}

vec3 getBackground(in vec2 coord)
{
    float fa = backgroundPattern( (coord + 0.0) / iChannelResolution[0].xy );
    float fb = backgroundPattern( (coord - 0.5) / iChannelResolution[0].xy );
    return vec3( 0.822 + 0.4*(fa-fb) );
}

float getFadeInWeight(vec2 uv)
{
    float edge = 0.5 * abs(sin(0.5));
    // taken FabriceNeyret2's advice
    vec4 v = smoothstep(0., edge, vec4(uv, 1. - uv) );
    return v.x * v.y * v.z * v.w;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 bg = getBackground(fragCoord);
	vec3 col = texture(iChannel0, uv).rgb;
    float alpha = getFadeInWeight(uv);
    
    fragColor = vec4(mix(bg, col, alpha), 1.0);
}

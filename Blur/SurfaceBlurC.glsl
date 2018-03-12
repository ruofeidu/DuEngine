// https://www.shadertoy.com/view/4sVyzR
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;

    vec3 originColor = texture(iChannel0,uv).rgb;
    vec3 bluredColor = fastSurfaceBlur(iChannel2,iChannel1,fragCoord/iResolution.xy,vec2(0.0,1.0/iResolution.y)).rgb;
    
    float edge = texture(iChannel1,uv).r;
    edge = pow(edge,2.0);
    bluredColor = mix(bluredColor,originColor,edge);
    
	vec3 finalColor = fragCoord.x>iMouse.x?originColor:bluredColor;
    fragColor = vec4(finalColor,1.0);
}
// 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float mouse = iMouse.x;
    if(iMouse.x == 0.)
        mouse =500.;
	vec2 uv = fragCoord.xy;
    float scale = 10000./(1.+mouse);
    vec2 bUv = floor(uv/scale)*scale;
    vec2 oUv = step(0., abs(fract(uv/scale)*scale - 0.5)-(0.48-min(0.001*scale, 0.01)));
    bUv /= iResolution.xy; 
	fragColor = texture(iChannel0, bUv);
    fragColor = mix(texture(iChannel1, bUv), fragColor, step(0.0001, fragColor.r+ fragColor.g + fragColor.b));
    fragColor = mix(vec4(1.), fragColor, step(0.001, oUv.x + oUv.y ));

}

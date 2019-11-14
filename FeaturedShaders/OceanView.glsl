// https://www.shadertoy.com/view/4d2cDyvoid mainImage( out vec4 fragColor, in vec2 fragCoord )
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture(iChannel0, uv);

    vec3 rd = texture(iChannel0, vec2(0.5)).rgb;

    float res = .4;
    float steps = 3.14159*2.;
    float focus = 3.;
 	float depth = fragColor.a;

    float dist = smoothstep(0.0, 2., depth-focus)*3.*dFdx(uv.x);
    vec3 tcol = vec3(.0);
    for (float i = 0.; i < steps; i = i + res)
    {
        vec2 _uv = uv+vec2(cos(i), sin(i))*dist;
        tcol += texture(iChannel0, _uv).rgb;
    }

    fragColor.rgb = tcol/(steps/res);
    fragColor.rgb = smoothstep(0.0, 1.0, fragColor.rgb); // contrast
    fragColor.rgb = pow(fragColor.rgb, vec3(1.0 / 2.2));
}

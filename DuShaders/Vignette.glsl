void mainImage( out vec4 O, in vec2 U )
{
	vec2 uv = U.xy / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb;
    float dist = distance(uv, vec2(0.5)),
    falloff = iMouse.y < 0.01 ? 0.1 : iMouse.y / iResolution.y,
    amount = iMouse.x < 0.01 ? 1.0 : iMouse.x / iResolution.x; 
    col *= smoothstep(0.8, falloff * 0.8, dist * (amount + falloff));
	O = vec4(col, 1.0);
}
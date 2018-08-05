void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 r = fragCoord.xy / iResolution.xy;
	float col = sin(r.y + r.x*3. -iTime*9.) * 0.9;
    col = saturate(col * col * col * 0.3);
    vec4 tex = texture(iChannel0, r);
    fragColor = tex + vec4(col);
}

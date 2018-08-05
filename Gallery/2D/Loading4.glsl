// ldG3Ww
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float val = texture(iChannel0, fragCoord/iResolution.xy).b;
    fragColor = vec4(val)*0.16;
}
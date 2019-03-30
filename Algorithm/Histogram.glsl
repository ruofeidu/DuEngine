// https://www.shadertoy.com/view/https://www.shadertoy.com/view/4dd3Wj
void mainImage( out vec4 O, vec2 U )
{
	 O = texture(iChannel0, U/iResolution.xy);
}

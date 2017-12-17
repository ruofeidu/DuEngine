/*

This shader is an attempt to rewrite dbrgn's shader
in a shorter and more efficient way, by utilizing
one of Shadertoys buffers.

He does a great job explaining, what's going on and
I highly suggest you go check out his shader
before you go any further!

https://www.shadertoy.com/view/4tfBWX

All the magic is in Buffer A... This layer is boring...

PS: The shader goes a bit funny if you resize it,
but it should go back to normal after about 3 seconds.

*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = step(.5, texture(iChannel0, uv));
    fragColor *= vec4(1.4*uv, 1.0, 1.0);
}
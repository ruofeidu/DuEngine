// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// The texture() call accepts a mip level offset as an optional parameter, which
// allows one to sample from different LODs of the texture. Besides being handy in
// some special situations, it also allows you to fake (box) blur of textures without
// having to perform a blur youtself. This has been traditionally used in demos and
// games to fake deph ot field and other similar effects in a very cheap way.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float lod = (5.0 + 5.0*sin( iTime ))*step( uv.x, 0.5 );
	
	vec3 col = texture( iChannel0, vec2(uv.x,1.0-uv.y), lod ).xyz;
	
	fragColor = vec4( col, 1.0 );
}
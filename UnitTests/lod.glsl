
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-ShareAlike 3.0 Unported
// https://creativecommons.org/licenses/by-sa/3.0/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.y = 1.0 - uv.y;
	
	float lod = 2.0 + 1.0*cos( 0.25 * 6.2831*iTime );
	vec3 col = 0.5 - 8.0*(texture(iChannel0, uv).xyz - texture(iChannel0, uv, lod).xyz);
	
	fragColor = vec4( col, 1.0 );
}
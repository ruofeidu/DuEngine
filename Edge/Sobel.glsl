// https://www.shadertoy.com/view/4d2BDK
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 vUv = fragCoord.xy / iResolution.xy;
	float x = 1.0 / iResolution.x;
	float y = 1.0 / iResolution.y;
	vec4 horizEdge = vec4( 0.0 );
	horizEdge -= texture( iChannel0, vec2( vUv.x - x, vUv.y - y ) ) * 1.0;
	horizEdge -= texture( iChannel0, vec2( vUv.x - x, vUv.y     ) ) * 2.0;
	horizEdge -= texture( iChannel0, vec2( vUv.x - x, vUv.y + y ) ) * 1.0;
	horizEdge += texture( iChannel0, vec2( vUv.x + x, vUv.y - y ) ) * 1.0;
	horizEdge += texture( iChannel0, vec2( vUv.x + x, vUv.y     ) ) * 2.0;
	horizEdge += texture( iChannel0, vec2( vUv.x + x, vUv.y + y ) ) * 1.0;
	vec4 vertEdge = vec4( 0.0 );
	vertEdge -= texture( iChannel0, vec2( vUv.x - x, vUv.y - y ) ) * 1.0;
	vertEdge -= texture( iChannel0, vec2( vUv.x    , vUv.y - y ) ) * 2.0;
	vertEdge -= texture( iChannel0, vec2( vUv.x + x, vUv.y - y ) ) * 1.0;
	vertEdge += texture( iChannel0, vec2( vUv.x - x, vUv.y + y ) ) * 1.0;
	vertEdge += texture( iChannel0, vec2( vUv.x    , vUv.y + y ) ) * 2.0;
	vertEdge += texture( iChannel0, vec2( vUv.x + x, vUv.y + y ) ) * 1.0;
	vec3 edge = sqrt((horizEdge.rgb * horizEdge.rgb) + (vertEdge.rgb * vertEdge.rgb));
    fragColor = vec4(edge, 1.0);
}

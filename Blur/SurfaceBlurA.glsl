// https://www.shadertoy.com/view/4sVyzR
// Sobel edge detection from https://gist.github.com/Hebali/6ebfc66106459aacee6a9fac029d0115
#define texture2D texture

void make_kernel(inout vec4 n[9], sampler2D tex, vec2 coord)
{
	float w = 1.0 / iResolution.x;
	float h = 1.0 / iResolution.y;

	n[0] = texture2D(tex, coord + vec2( -w, -h));
	n[1] = texture2D(tex, coord + vec2(0.0, -h));
	n[2] = texture2D(tex, coord + vec2(  w, -h));
	n[3] = texture2D(tex, coord + vec2( -w, 0.0));
	n[4] = texture2D(tex, coord);
	n[5] = texture2D(tex, coord + vec2(  w, 0.0));
	n[6] = texture2D(tex, coord + vec2( -w, h));
	n[7] = texture2D(tex, coord + vec2(0.0, h));
	n[8] = texture2D(tex, coord + vec2(  w, h));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec4 n[9];
	make_kernel( n, iChannel0, fragCoord/iResolution.xy );

	vec4 sobel_edge_h = n[2] + (2.0*n[5]) + n[8] - (n[0] + (2.0*n[3]) + n[6]);
  	vec4 sobel_edge_v = n[0] + (2.0*n[1]) + n[2] - (n[6] + (2.0*n[7]) + n[8]);
	vec4 sobel = sqrt((sobel_edge_h * sobel_edge_h) + (sobel_edge_v * sobel_edge_v));
    
    fragColor = vec4(clamp((sobel.rgb),0.0,1.0),1.0);
}
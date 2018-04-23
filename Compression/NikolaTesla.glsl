// Xlffz2
/********************************************
    Tesla(BC4).glsl webgl2.0 Created by 834144373
    2017.12.6
	PS： 834144373 is TNWX or 恬纳微晰 or 祝元洪
*********************************************/
/*
	This texture decompression technology is used by BC4 (Block Compression) 
	And it's 4bpp!
	1. BufA and BufB is fast store full 32bit float into 16bit half-float buffer,
	2. BufC is BC4 Decoder,
	3. Image is Show Texture.

If you want to know more about GPU Texture Compression,
		the below Texture Compression Can help you.:)
------------------------------------------------------------------------
ShaderToyTC I  1bpp : https://www.shadertoy.com/view/MtyGzV by 834144373
PVRTC          4bpp : https://www.shadertoy.com/view/ltV3zD by 834144373
YUV Special    2bpp : https://www.shadertoy.com/view/XlGGzh by 834144373
...more texture compression will be coming soon and GIF!
------------------------------------------------------------------------

Node : BC4 is a very good for learning Texture Compression to learner in the first stage,
		and you will know what happed texture Compression Work and digital coding.
*/

float box(vec2 p,vec2 size,float r){
	return length(max(abs(p)-size,0.)) - r;
}
const vec4 tinyColor = vec4(0.88,0.78,0.5,1.)*1.3;
void mainImage( out vec4 C, in vec2 U )
{
    vec2 UU = U;
    U -= iResolution.xy*vec2(0.24,0.);
    vec2 uv = U/iResolution.xy;
	vec2 scale = iResolution.yy/127.;
    float aspect = iResolution.x/iResolution.y;
	vec4 C1 = texture(iChannel0,uv/scale*1.1)*tinyColor;
    vec4 C2 = texture(iChannel0,uv*fract(sin(uv/40.))/scale)*tinyColor/1.1;
 	float b = 1.-box((UU+UU-iResolution.xy)/iResolution.y+vec2(0.,0.11),vec2(.86,.9),0.);
	b = smoothstep(0.9,1.,b);
	C = mix(C2*1.04,C1,b*1.1);
    C = pow(C,vec4(1.15,1.3,1.1,1.));
}


/*------------------ Shader Story ----------------
	Very thanks for my friend who name is called "孟建科",
	And he provide a big help,why BC4 encode as this.
	Best Wishes
*/
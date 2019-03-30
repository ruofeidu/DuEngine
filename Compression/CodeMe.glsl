// MtBfRR
/********************************************
    Code Me.glsl webgl2.0 Created by 834144373
    2017.12.25
	PS： 834144373 is TNWX or 恬纳微晰 or 祝元洪
*********************************************/
/*
	This texture decompression technology is used by DXT1 (S3TC) 
	And it's 4bpp!
	1. BufA and BufB is fast store full 32bit float into 16bit half-float buffer,
	2. BufC is DXT1 Decoder,
	3. Image is Show Texture.

If you want to know more about GPU Texture Compression,
		the below Texture Compression Can help you.:)
------------------------------------------------------------------------
BC4            4bpp : https://www.shadertoy.com/view/Xlffz2 by 834144373
ShaderToyTC I  1bpp : https://www.shadertoy.com/view/MtyGzV by 834144373
PVRTC          4bpp : https://www.shadertoy.com/view/ltV3zD by 834144373
YUV Special    2bpp : https://www.shadertoy.com/view/XlGGzh by 834144373
...more Confidentiality Texture Compression will be coming soon and GIF!!!
------------------------------------------------------------------------

Node : Yes! You didn't read the wrong words!
       more Confidentiality Texture Compression will be coming soon!!!
	   Crack Crack and Crack!!!
*/

float box(vec2 p,vec2 size,float r){
	return length(max(abs(p)-size,0.)) - r;
}
void mainImage( out vec4 C, in vec2 U )
{
    vec2 UU = U;
    U -= iResolution.xy*vec2(0.24,0.);
    vec2 uv = U/iResolution.xy;
	vec2 scale = iResolution.yy/127.;
    float aspect = iResolution.x/iResolution.y;
	vec4 C1 = texture(iChannel0,uv/scale*1.1);
    vec4 C2 = texture(iChannel0,uv*fract(sin(uv/40.))/scale)*1.1;
 	float b = 1.-box((UU+UU-iResolution.xy)/iResolution.y+vec2(0.,0.11),vec2(.86,.9),0.);
	b = smoothstep(0.9,1.,b);
	C = mix(C2*1.04,C1,b*1.1);
    C = pow(C,vec4(1.15,1.3,1.1,1.));
}





/*---------- Shader Story ------------
	Wooooow！Crazy again!
    Hi guys!Merry Christmas! :-D
    I want to code a work at this meaningful day ,but I think and think again,I have no idea all the day.
    Today some people hang out with girlfriend and some people go to the party or with fimaly at home!
    But I think we should do some special  things!
    In the past,I coded many people with shader on shadertoy,like "Lena"、“Fabrace"、“A little girl”、“Candy Cat”、“Nikola Tesla....etc,
	but I seem that forgot someone!Who is?
    Oh!? My god! It's me!
*/

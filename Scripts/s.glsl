// XsycRW
/********************************************
    Stephen William Hawking.glsl webgl2.0 Created by 834144373
    2018.3.17
	PS：834144373 is TNWX or 恬纳微晰 or 祝元洪
*********************************************/
/*
	This Hawking Cover Texture Compression technology is used by custom S3TC  
	And it's also 4bpp!
	1. BufA,BufB and BufC is fast store full 31bit float into 32bit float buffer,
	2. BufD is S3TC Decoder,
	3. Image is show result.

If you want to know more about GPU Texture Compression,
		the below Texture Compression Can help you.:)
------------------------------------------------------------------------
All About Image Decompresion: https://www.shadertoy.com/playlist/7scBzN
------------------------------------------------------------------------
ATC            4bpp : https://www.shadertoy.com/view/lt2fRz by 834144373
DXT1           4bpp : https://www.shadertoy.com/view/MtBfRR by 834144373
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

//---------------------Function-------------------
float box(vec2 p,vec2 size,float r){
	return length(max(abs(p)-size,0.)) - r;
}

//--------------------------------------------------------
//from https://www.shadertoy.com/view/MslGWN by CBS
float field(in vec3 p,float s) {
	float strength = 7. + .03 * log(1.e-6 + fract(sin(iTime) * 4373.11));
	float accum = s/4.;
	float prev = 0.;
	float tw = 0.;
	for (int i = 0; i < 26; ++i) {
		float mag = dot(p, p);
		p = abs(p) / mag + vec3(-.5, -.4, -1.5);
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
		tw += w;
		prev = mag;
	}
	return max(0., 5. * accum / tw - .7);
}
float field2(in vec3 p, float s) {
	float strength = 7. + .03 * log(1.e-6 + fract(sin(iTime) * 4373.11));
	float accum = s/4.;
	float prev = 0.;
	float tw = 0.;
	for (int i = 0; i < 18; ++i) {
		float mag = dot(p, p);
		p = abs(p) / mag + vec3(-.5, -.4, -1.5);
		float w = exp(-float(i) / 7.);
		accum += w * exp(-strength * pow(abs(mag - prev), 2.2));
		tw += w;
		prev = mag;
	}
	return max(0., 5. * accum / tw - .7);
}
vec3 nrand3( vec2 co ){
	vec3 a = fract( cos( co.x*8.3e-3 + co.y )*vec3(1.3e5, 4.7e5, 2.9e5) );
	vec3 b = fract( sin( co.x*0.3e-3 + co.y )*vec3(8.1e5, 1.0e5, 0.1e5) );
	vec3 c = mix(a, b, 0.5);
	return c;
}
vec4 Universe(vec2 U ) {
    vec2 uv = 2. * U.xy / iResolution.xy - 1.;
	vec2 uvs = uv * iResolution.xy / max(iResolution.x, iResolution.y);
	vec3 p = vec3(uvs / 4., 0) + vec3(1., -1.3, 0.);
	p += .2 * vec3(sin(iTime / 16.), sin(iTime / 12.),  sin(iTime / 128.));
	float freqs[4];
	//Sound
	freqs[0] = texture( iChannel0, vec2( 0.01, 0.25 ) ).x;
	freqs[1] = texture( iChannel0, vec2( 0.07, 0.25 ) ).x;
	freqs[2] = texture( iChannel0, vec2( 0.15, 0.25 ) ).x;
	freqs[3] = texture( iChannel0, vec2( 0.30, 0.25 ) ).x;
	float t = field(p,freqs[2]);
	float v = (1. - exp((abs(uv.x) - 1.) * 6.)) * (1. - exp((abs(uv.y) - 1.) * 6.));
    //Second Layer
	vec3 p2 = vec3(uvs / (4.+sin(iTime*0.11)*0.2+0.2+sin(iTime*0.15)*0.3+0.4), 1.5) + vec3(2., -1.3, -1.);
	p2 += 0.25 * vec3(sin(iTime / 16.), sin(iTime / 12.),  sin(iTime / 128.));
	float t2 = field2(p2,freqs[3]);
	vec4 c2 = mix(.4, 1., v) * vec4(1.3 * t2 * t2 * t2 ,1.8  * t2 * t2 , t2* freqs[0], t2);
	//Let's add some stars
	//Thanks to http://glsl.heroku.com/e#6904.0
	vec2 seed = p.xy * 2.0;	
	seed = floor(seed * iResolution.x);
	vec3 rnd = nrand3( seed );
	vec4 starcolor = vec4(pow(rnd.y,40.0));
	//Second Layer
	vec2 seed2 = p2.xy * 2.0;
	seed2 = floor(seed2 * iResolution.x);
	vec3 rnd2 = nrand3( seed2 );
	starcolor += vec4(pow(rnd2.y,40.0));
	return mix(freqs[3]-.3, 1., v) * vec4(1.5*freqs[2] * t * t* t , 1.2*freqs[1] * t * t, freqs[3]*t, 1.0)+c2+starcolor;
	
}
/*---------------------------------------------------------
		     English Words Decoder Engine
*/									
const uint[] Title = uint[](0x12C73DEDu,0x32205107u,0x26568640u,0x10265u);
const uint[] word0 = uint[](0xF380B7u,0x14ABC41u,0x2404AAFu,0x12C06589u,0x1D504CB6u,0x349C8A4u,0x77248Eu,0x2937B581u,0x128A3DC0u,0x6780EEu,0x1F701514u,0x1192u);
const uint[] word1 = uint[](0x2C9380B7u,0x2944B005u,0x1E8A00ACu,0x1E0A20F5u,0x545006u,0x1C940C2Du,0x11406645u,0x1C538281u,0x265A0645u,0x2602A280u,0x1074B1D5u,0x470414u,0x132AC2Du,0x2002992Cu,0x1824CE6Fu,0x5u);
const uint[] word2 = uint[](0xA8A01F4u,0x1360C8E0u,0x28A0334u,0xB561C14u,0x2809D413u,0x54500Fu,0x8A4825u,0x2E0A0514u,0x1E0232AFu,0x13791514u,0x1C5980B3u,0x2609D404u,0x1C973930u,0x633C07u,0x2607D1C9u,0x28C30u);
const uint[] word3 = uint[](0xFA024Fu,0x28101514u,0x11404DAFu,0x128B8281u,0x5B8103u,0x2D01641u,0x8E080A4u,0x117039E0u,0x2934432Fu,0x28962441u,0xC02DC19u,0xAD091D5u,0x32C6068Eu,0x1C581480u,0x4u);
const uint[] word4 = uint[](0xCF05CA6u,0x21304EA0u,0x2AD011C5u,0x1A9A0103u,0x8E7DC05u,0x772645u,0x2E06517u,0x1202CAB4u,0x545013u,0x28906437u,0x4D20u);
const uint[] word5 = uint[](0x591517u,0x1E301514u,0x609BDB3u,0x246015A1u,0x1AFu);
const uint[] word6 = uint[](0xA8A1517u,0x2E0A2412u,0x2EC08261u,0x11404F21u,0x1645u);
const uint[] word7 = uint[](0x1A9A00C9u,0x18C4DC05u,0x802B9E0u,0x1EC30321u,0x16308817u,0x24837u);
const uint[] word8 = uint[](0xA8B824Fu,0x28091514u,0x202C8A8u,0x28CA80B2u,0x5A05A9u,0x2744B52Cu,0x11703E80u,0x1B540281u,0x2304DC1u,0x2EF72C0Eu);
const uint[] word9 = uint[](0x120A0517u,0x545013u,0xAC605B3u,0xA980293u,0x6780A3u,0x245A502Du);
const uint[] word10 = uint[](0xB706517u,0x1A569640u,0x114048A2u,0x2930C005u,0x1C023820u,0xA8A028Fu,0x255A54C0u,0x5u);
const uint[] word11 = uint[](0x117011C1u,0x24545019u,0x209A405u,0xB64BAA0u,0x1672u);
//-------------------------------
#define ASCII_Tex iChannel2
#define SongTime iChannelTime[0]
float timeLine[] = float[](164.,170.,178.,183.,192.,196.,200.,204.,208.,212.,216.,220.); 
vec2 FontUV;
const int rightBound = 3;
const int leftBound = 28;
const int blankFill = 85;//670;
vec4 FontColor = vec4(0.);
const ivec2 frontSizeRadio = ivec2(5.,1.);
#define R iResolution.xy
vec2 Rect;
vec4 FontTex(uint index,float isFist){
    if(index == 0u)
        return vec4(0.);//texture(ASCII_Tex,FontUV/R*frontSizeRadio+vec2(0,5)/16.);
    vec2 coord = vec2(float(index%16u),(9.+isFist*2.-float(index/16u)))/16.+vec2(16.,0.)/1024.;
	vec4 col = texture(ASCII_Tex,1./vec2(2.,1.)*fract(FontUV/Rect*16.*vec2(frontSizeRadio))/16.+coord);
    return col;
}
//-------------------------------
#define DecodeWords(words) if(_6chsBlock>=0 && _6chsBlock < words.length() ){uint Blockdata = words[_6chsBlock];uint index = (Blockdata >> (_6chsX*5)) & 31u;FontColor = FontTex(index,float(_gridID <= 0));}
float dispayTime(float timeAt,float timeLength,float timePoint){
	float t = SongTime - timeAt;
    if(t > timePoint){
    	t -= timePoint;
        t = timeLength-timePoint - t;
    }
    return t;
}
void Decode(){
    vec2 UU = vec2(FontUV.x/Rect.x,1.-FontUV.y/Rect.y);
    ivec2 fontU = ivec2(UU*16.*vec2(frontSizeRadio));
    if(fontU.x < leftBound || (16*frontSizeRadio.x-fontU.x) <= rightBound)
    	return;
    int _gridID = clamp(fontU.y*(16*frontSizeRadio.x-leftBound-rightBound)+fontU.x - blankFill,-1,2000);
    if(_gridID < 0)
        return;
    int _6chsX = _gridID % 6;
    int _6chsBlock = (_gridID)/6;
    //-----------------Time Line-----------------
    float songTime = SongTime;
	if(songTime < 30.){
    	DecodeWords(Title)
        songTime = dispayTime(0.,20.,10.);
    	FontColor.rgb = FontColor.r * 1.4 * vec3(0.6,.75,0.7) * clamp(songTime,0.,1.);
    }
    else if(songTime < 150.){}
    else if(songTime < 170.){
        DecodeWords(word0)
        songTime = dispayTime(164.,6.,3.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);

    }
	else if(songTime < 178.){
        DecodeWords(word1)
        songTime = dispayTime(170.,8.,4.);
    	FontColor.rgb = FontColor.rrr * 1.4  * clamp(songTime,0.,1.);

    }
    else if(songTime < 183.){
        DecodeWords(word2)
        songTime = dispayTime(178.,5.,2.5);
    	FontColor.rgb = FontColor.rrr * 1.4  * clamp(songTime,0.,1.);
    }
    else if(songTime < 192.){
        DecodeWords(word3)
        songTime = dispayTime(183.,9.,4.5);
    	FontColor.rgb = FontColor.rrr * 1.4  * clamp(songTime,0.,1.);
    }
    else if(songTime < 196.){
        DecodeWords(word4)
        songTime = dispayTime(192.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 200.){
        DecodeWords(word5)
        songTime = dispayTime(196.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 204.){
        DecodeWords(word6)
        songTime = dispayTime(200.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 208.){
        DecodeWords(word7)
        songTime = dispayTime(204.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 212.){
        DecodeWords(word8)
        songTime = dispayTime(208.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 216.){
        DecodeWords(word9)
        songTime = dispayTime(212.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 220.){
        DecodeWords(word10)
        songTime = dispayTime(216.,4.,2.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 250.){
        DecodeWords(word11)
        songTime = dispayTime(220.,30.,15.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    else if(songTime < 270.){}
    else if(songTime < 287.){
        DecodeWords(word11)
        songTime = dispayTime(270.,17.,10.);
    	FontColor.rgb = FontColor.rrr * 1.4 * clamp(songTime,0.,1.);
    }
    
    
}

void SongWords(vec2 U )
{
    Rect = R;
    FontUV = clamp(U,vec2(0.),Rect);
	Decode();
}

//---------------------------------------------------------
void mainImage( out vec4 C, in vec2 U ) {
	
    SongWords(U);
    C = Universe(U);
    vec4 col = texture(iChannel1,U*vec2(800.,450.)/R/R);
    U -= vec2(180.,296.)*R/vec2(800.,450.);
    if(U.x>0.|| U.y >0.)
        col *= 1.-max(U.x/20.,U.y/20.);
    C = max(C,col);
    C = max(C,FontColor);
}



/*---------- Shader Story ------------
	For my best Stephen William Hawking! 

*/

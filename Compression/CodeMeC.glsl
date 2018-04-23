// MtBfRR
/********************************************************
	Here is DXT1 Decoder
DXT1 is also Block Compression,

About knowledge:
wiki!!!
*********************************************************/
//-----------------------------------------------
vec4 data = vec4(0.);

void CombineBinary(ivec2 coord){
    data = texelFetch(iChannel0,coord>>2,0);//x,y,z,w 16,16,16,16
}
//-----------------------------------------------
uvec2 uintData = uvec2(0u);

void GetUintData(){
	uintData.x = packUnorm2x16(data.st);//32bits
	uintData.y = packUnorm2x16(data.pq);//32bits
}
//-----------------------------------------------
struct BlockData{
	vec3 color0;
    vec3 color1;
    uint index;
};
BlockData myBlockData;

void Unpack2BlockData(){
    
    myBlockData.color0.b = float((uintData.x & 31u) << 3);
    uintData.x >>= 5;
    myBlockData.color0.g = float((uintData.x & 63u) << 2);
    uintData.x >>= 6;
    myBlockData.color0.r = float((uintData.x & 31u) << 3);
    uintData.x >>= 5;
    
    myBlockData.color1.b = float((uintData.x & 31u) << 3);
    uintData.x >>= 5;
    myBlockData.color1.g = float((uintData.x & 63u) << 2);
    uintData.x >>= 6;
    myBlockData.color1.r = float((uintData.x & 31u) << 3);
    
    myBlockData.index = uintData.y;
}
//------------------------------------------------
vec3 DeocodeDigit(uint index){
    vec3 tmpCol = vec3(0.);
    if(index == 0u){
    	tmpCol = myBlockData.color0;
    }
    else if(index == 1u){
		tmpCol = myBlockData.color1;
    }
    if(index == 2u)
        tmpCol = mix(myBlockData.color0,myBlockData.color1,1./3.);
    else if(index == 3u)
        tmpCol = mix(myBlockData.color0,myBlockData.color1,2./3.);
    return tmpCol;
}
//------------------------------------------------
vec3 color = vec3(0.);
void DecodeDXT1(ivec2 coord){
	ivec2 chunkCoord = coord & 3;
    int pixelID = chunkCoord.x + (chunkCoord.y<<2);
	color = DeocodeDigit((myBlockData.index >> (pixelID*2)) & 3u);
}

void mainImage( out vec4 C, in vec2 U )
{
	highp ivec2 SV_DispatchThreadID = ivec2(U-0.5);
    
    if(SV_DispatchThreadID.x>=128 || SV_DispatchThreadID.y>=128){
    	C = vec4(sin(iTime*1.5)+1.)/8.;
        return;
    }
    //-----------
    CombineBinary(SV_DispatchThreadID);
	//-----------
    GetUintData();
    //-----------
    Unpack2BlockData();
    //-----------
    DecodeDXT1(SV_DispatchThreadID);
    //-----------
	C = vec4(color/255.,1.); 
}
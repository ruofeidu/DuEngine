// XsycRW
/********************************************************
	Here is S3TC Decoder
S3TC is also Block Compression,

About knowledge:
hum...Wiki!
but here S3TC is customization.
*********************************************************/
//-----------------------------------------------
vec2 data = vec2(0.);
void CombineBinary(ivec2 coord){
    if(((coord.x>>2)&1) == 0)
        data = texelFetch(iChannel0,coord>>2,0).st;
    else
        data = texelFetch(iChannel0,coord>>2,0).pq;
}
//-----------------------------------------------
uvec2 uintData = uvec2(0u);
void GetUintData(){
	uintData = floatBitsToUint(data); //31 bits, 31 bits   
    uintData = ((uintData>>1) & 0x40000000u) | uintData;
    uintData &= 0x7FFFFFFFu;
}
//-----------------------------------------------
struct BlockData{
	vec3 color0;
    vec3 color1;
    uint index;
};
BlockData myBlockData;
void Unpack2BlockData(){
	myBlockData.index = uintData.y << 16 | (uintData.x & 0xFFFFu);

    myBlockData.color0.r = float((uintData.x>>16 & 31u) << 3);
    myBlockData.color0.g = float((uintData.x>>21 & 31u) << 3);
    myBlockData.color0.b = float((uintData.x>>26 & 31u) << 3);
    
    myBlockData.color1.r = float((uintData.y>>16 & 31u) << 3);
    myBlockData.color1.g = float((uintData.y>>21 & 31u) << 3);
    myBlockData.color1.b = float((uintData.y>>26 & 31u) << 3);
}
//------------------------------------------------
vec3 DecodeDigit(uint index){
    vec3 tmpCol = vec3(0.);
	tmpCol = mix(myBlockData.color0,myBlockData.color1,float(index)/3.);
    if(all(lessThanEqual(tmpCol,vec3(0.)))) //index extra decode
    	tmpCol = myBlockData.color1;
    return tmpCol;
}
//------------------------------------------------
vec3 color = vec3(0.);
void DecodeS3TC(ivec2 coord){
	ivec2 chunkCoord = coord & 3;
    int pixelID = chunkCoord.x + (chunkCoord.y<<2);
	color = DecodeDigit((myBlockData.index >> (pixelID<<1)) & 3u);
}
//------------------------------------------------
vec3 GetS3TC_Color(ivec2 coord){
    if(coord.x>=192 || coord.y>=308){
        return vec3(0.);
    }
    CombineBinary(coord);
    GetUintData();
    Unpack2BlockData();
    DecodeS3TC(coord);
	return color/255.;
}

void mainImage( out vec4 C, in vec2 U )
{
	highp ivec2 SV_DispatchThreadID = ivec2(U-0.5);
    //-----------
	C = vec4(GetS3TC_Color(SV_DispatchThreadID),1.); 
}

// Xlffz2
/********************************************************
	Here is BC4 Decoder
BC4 is Block Compression,

About knowledge:
1. https://msdn.microsoft.com/en-us/library/windows/desktop/bb694531(v=vs.85).aspx#BC4
*********************************************************/


//-----------------------------------------------
vec4 data = vec4(0.);

void CombineBinary(ivec2 coord){
    data = texelFetch(iChannel0,coord>>2,0);//x,y,z,w 16,16,16,16
}
//-----------------------------------------------
uvec2 uintData = uvec2(0u);

void GetUintData(){
	uintData.x = packSnorm2x16(data.st);//32bits
	uintData.y = packSnorm2x16(data.pq);//32bits
}
//-----------------------------------------------
struct BlockData{
	float red0;
    float red1;
    uint index0;
    uint index1;
};
BlockData myBlockData;

void Unpack2BlockData(){
	myBlockData.red0 = float(uintData.x & 0xFFu); //8bits
    myBlockData.red1 = float((uintData.x >> 8u) & 0xFFu); //8bits
    myBlockData.index0 = (uintData.x >> 16u) | ((uintData.y & 0x3u)<<16u); //32-16=16bits + 2bits ->18bits
    myBlockData.index1 = uintData.y>>2u;//32bits - 2bits -> 30bits
}
//------------------------------------------------
float DeocodeDigit(uint index){
    float tmp = 0.;
    if(index == 0u){
    	tmp = myBlockData.red0;
    }
    else if(index == 1u){
		tmp = myBlockData.red1;
    }
    
    if(myBlockData.red0 > myBlockData.red1){
    	if(index == 2u)
            tmp = (6. / 7.) * myBlockData.red0 + (1. / 7.) * myBlockData.red1;
        else if(index == 3u)
            tmp = (5. / 7.) * myBlockData.red0 + (2. / 7.) * myBlockData.red1;
        else if(index == 4u)
            tmp = (4. / 7.) * myBlockData.red0 + (3. / 7.) * myBlockData.red1;
        else if(index == 5u)
            tmp = (3. / 7.) * myBlockData.red0 + (4. / 7.) * myBlockData.red1;
        else if(index == 6u)
            tmp = (2. / 7.) * myBlockData.red0 + (5. / 7.) * myBlockData.red1;
        else if(index == 7u)
            tmp = (1. / 7.) * myBlockData.red0 + (6. / 7.) * myBlockData.red1;
    }
    else{
    	if(index == 2u)
            tmp = (4. / 5.) * myBlockData.red0 + (1. / 5.) * myBlockData.red1;
        else if(index == 3u)
            tmp = (3. / 5.) * myBlockData.red0 + (2. / 5.) * myBlockData.red1;
        else if(index == 4u)
            tmp = (2. / 5.) * myBlockData.red0 + (3. / 5.) * myBlockData.red1;
        else if(index == 5u)
            tmp = (1. / 5.) * myBlockData.red0 + (4. / 5.) * myBlockData.red1;
        else if(index == 6u)
            tmp = 0.;
        else if(index == 7u)
            tmp = 1.;
    }
    return tmp;
}
//------------------------------------------------
float luminance = 0.;
void DecodeBC4(ivec2 coord){
	ivec2 chunkCoord = coord & 3;
    int pixelID = chunkCoord.x + (chunkCoord.y<<2);
    if(pixelID < 6){
    	luminance = DeocodeDigit((myBlockData.index0 >> (pixelID*3)) & 7u);
    }
    else{
    	luminance = DeocodeDigit((myBlockData.index1 >> ((pixelID-6)*3)) & 7u);
    }
}


void mainImage( out vec4 C, in vec2 U )
{
	highp ivec2 SV_DispatchThreadID = ivec2(U-0.5);
    
    if(SV_DispatchThreadID.x>=128 || SV_DispatchThreadID.y>=128){
    	C = vec4(0.);
        return;
    }
    //-----------
    CombineBinary(SV_DispatchThreadID);
	//-----------
    GetUintData();
    //-----------
    Unpack2BlockData();
    //-----------
    DecodeBC4(SV_DispatchThreadID);
    //-----------
	C = vec4(luminance/255.); 
}
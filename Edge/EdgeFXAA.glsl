// MdyyRt
//This FreeStyle OutLine Edge by 834144373(恬纳微晰)
/*----------------------
	FXAA
hum...you can also find on wiki
----------------------*/
#define _Strength 10.
#define R iResolution.xy
#define _EdgeTexture iChannel0
float GetLumi(vec3 col){
    return dot(col,vec3(0.299, 0.587, 0.114));
}
vec4 FXAA(sampler2D _Tex,vec2 uv){
    vec3 e = vec3(1./R,0.);

    float reducemul = 0.125;// 1. / 8.;
    float reducemin = 0.0078125;// 1. / 128.;

    vec4 Or = texture(_Tex,uv); //P
    vec4 LD = texture(_Tex,uv - e.xy); //左下
    vec4 RD = texture(_Tex,uv + vec2( e.x,-e.y)); //右下
    vec4 LT = texture(_Tex,uv + vec2(-e.x, e.y)); //左上
    vec4 RT = texture(_Tex,uv + e.xy); // 右上

    float Or_Lum = GetLumi(Or.rgb);
    float LD_Lum = GetLumi(LD.rgb);
    float RD_Lum = GetLumi(RD.rgb);
    float LT_Lum = GetLumi(LT.rgb);
    float RT_Lum = GetLumi(RT.rgb);

    float min_Lum = min(Or_Lum,min(min(LD_Lum,RD_Lum),min(LT_Lum,RT_Lum)));
    float max_Lum = max(Or_Lum,max(max(LD_Lum,RD_Lum),max(LT_Lum,RT_Lum)));

    //x direction,-y direction
    vec2 dir = vec2((LT_Lum+RT_Lum)-(LD_Lum+RD_Lum),(LD_Lum+LT_Lum)-(RD_Lum+RT_Lum));
    float dir_reduce = max((LD_Lum+RD_Lum+LT_Lum+RT_Lum)*reducemul*0.25,reducemin);
    float dir_min = 1./(min(abs(dir.x),abs(dir.y))+dir_reduce);
    dir = min(vec2(_Strength),max(-vec2(_Strength),dir*dir_min)) * e.xy;

    //------
    vec4 resultA = 0.5*(texture(_Tex,uv-0.166667*dir)+texture(_Tex,uv+0.166667*dir));
    vec4 resultB = resultA*0.5+0.25*(texture(_Tex,uv-0.5*dir)+texture(_Tex,uv+0.5*dir));
    float B_Lum = GetLumi(resultB.rgb);

    //return resultA;
    if(B_Lum < min_Lum || B_Lum > max_Lum)
        return resultA;
    else 
        return resultB;
}
void mainImage( out vec4 C, in vec2 U )
{
	C = FXAA(_EdgeTexture,U/R);
    if(iMouse.y>R.y/2.)
		C = texture(_EdgeTexture,U/R);
}
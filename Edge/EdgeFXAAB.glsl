// MdyyRt
/*----------------------
	Edge Detection
----------------------*/
#define _DepthDiffCoeff 5.
#define _NormalDiffCoeff 1.
#define _CameraDepthNormalsTexture iChannel0
#define R iResolution.xy

float CheckDiff(vec4 _centerNormalDepth,vec4 _otherNormalDepth) {
    float depth_diff = abs(_centerNormalDepth.w - _otherNormalDepth.w);
    vec3 normal_diff = abs(_centerNormalDepth.xyz - _otherNormalDepth.xyz);
    return 
        (float(depth_diff > _DepthDiffCoeff))
        +
        float(dot(normal_diff,normal_diff))*_NormalDiffCoeff;
}
float FastEdge(vec2 uv) {
    vec3 e = vec3(1./R, 0.);
    vec4 Center_P = texture(_CameraDepthNormalsTexture,uv);
    vec4 LD = texture(_CameraDepthNormalsTexture, uv + e.xy);
    vec4 RD = texture(_CameraDepthNormalsTexture, uv + vec2(e.x,-e.y));

    float Edge = 0.;
    Edge += CheckDiff(Center_P,LD);
    Edge += CheckDiff(Center_P,RD);
    return float(smoothstep(1., 0., Edge));
}


void mainImage( out vec4 C, in vec2 U )
{
	C = vec4(FastEdge(U/R));
}
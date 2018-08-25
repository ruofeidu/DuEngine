// https://www.shadertoy.com/view/XtyczD
// References:
// https://www.shadertoy.com/view/ls3GWS
// http://www.geeks3d.com/20110405/fxaa-fast-approximate-anti-aliasing-demo-glsl-opengl-test-radeon-geforce/3/
// https://threejs.org/examples/?q=fxaa#webgl_postprocessing_fxaa
// https://github.com/mattdesl/glsl-fxaa
// 
const float FXAA_SPAN_MAX = 8.0;
const float FXAA_REDUCE_MIN = 1.0/128.0;
const float FXAA_SUBPIX_SHIFT = 1.0/4.0;
const float FXAA_REDUCE_MUL = 1.0/8.0;

vec3 FXAA( vec4 uv, sampler2D tex, vec2 rcpFrame) {
    
    vec3 rgbNW = textureLod(tex, uv.zw, 0.0).xyz;
    vec3 rgbNE = textureLod(tex, uv.zw + vec2(1,0)*rcpFrame.xy, 0.0).xyz;
    vec3 rgbSW = textureLod(tex, uv.zw + vec2(0,1)*rcpFrame.xy, 0.0).xyz;
    vec3 rgbSE = textureLod(tex, uv.zw + vec2(1,1)*rcpFrame.xy, 0.0).xyz;
    vec3 rgbM  = textureLod(tex, uv.xy, 0.0).xyz;

    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM,  luma);

    float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
    float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

    vec2 dir;
    dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
    dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

    float dirReduce = max(
        (lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
        FXAA_REDUCE_MIN);
    float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);
    
    dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
          max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
          dir * rcpDirMin)) * rcpFrame.xy;

    vec3 rgbA = (1.0/2.0) * (
        textureLod(tex, uv.xy + dir * (1.0/3.0 - 0.5), 0.0).xyz +
        textureLod(tex, uv.xy + dir * (2.0/3.0 - 0.5), 0.0).xyz);
    vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
        textureLod(tex, uv.xy + dir * (0.0/3.0 - 0.5), 0.0).xyz +
        textureLod(tex, uv.xy + dir * (3.0/3.0 - 0.5), 0.0).xyz);
    
    float lumaB = dot(rgbB, luma);

    if((lumaB < lumaMin) || (lumaB > lumaMax)) return rgbA;
    
    return rgbB; 
}

    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
    float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2. + iResolution.x*cos(iTime*.5) : iMouse.x;
    if ( uv.x < splitCoord/iResolution.x ) {
        vec2 rcpFrame = vec2(1.0/iResolution.x, 1.0/iResolution.y);
        fragColor = vec4(FXAA(vec4(uv, uv - rcpFrame * (0.5 + FXAA_SUBPIX_SHIFT)), iChannel0, rcpFrame), 1.0);
    } else {
        fragColor = texture( iChannel0, uv );
    }
    if (abs(fragCoord.x - splitCoord) < 1.0) {
        fragColor.x = 1.0;
    }
}
/** 
 * Starea Filter by Ruofei Du (DuRuofei.com)
 * Demo: https://www.shadertoy.com/view/MtjyDK
 * starea @ ShaderToy,License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * https://creativecommons.org/licenses/by-nc-sa/3.0/
 * 
 * Reference: 
 * [1] colorBurn function forked from ben's https://www.shadertoy.com/view/XdS3RW
 * [2] starea's Dotted Drawing / Sketch Effect: https://www.shadertoy.com/view/ldSyzV
 * [3] starea's BrightnessContrastSaturationHue: https://www.shadertoy.com/view/MdjBRy
 *
 * Series:
 * [1] Brannan Filter: https://www.shadertoy.com/view/4lSyDK
 * [2] Earlybird Filter: https://www.shadertoy.com/view/XlSyWV
 * [3] Starea Filter: https://www.shadertoy.com/view/MtjyDK
 * 
 * Write-ups:
 * [1] http://blog.ruofeidu.com/implementing-instagram-filters-brannan/
 **/
float greyScale(in vec3 col) 
{
    return dot(col, vec3(0.3, 0.59, 0.11));
}

mat3 saturationMatrix( float saturation ) {
    vec3 luminance = vec3( 0.3086, 0.6094, 0.0820 );
    float oneMinusSat = 1.0 - saturation;
    vec3 red = vec3( luminance.x * oneMinusSat );
    red.r += saturation;
    
    vec3 green = vec3( luminance.y * oneMinusSat );
    green.g += saturation;
    
    vec3 blue = vec3( luminance.z * oneMinusSat );
    blue.b += saturation;
    
    return mat3(red, green, blue);
}

void levels(inout vec3 col, in vec3 inleft, in vec3 inright, in vec3 outleft, in vec3 outright) {
    col = clamp(col, inleft, inright);
    col = (col - inleft) / (inright - inleft);
    col = outleft + col * (outright - outleft);
}

void levelsGamma(inout vec3 col, in vec3 inleft, in vec3 inright, in vec3 outleft, in vec3 outright, 
                 in vec3 gamma1, in vec3 gamma2) {
    col = clamp(col, inleft, inright);
    col = (col - inleft) / (inright - inleft);
    col = pow(col, gamma2); 
    col = outleft + col * (outright - outleft);
    col = pow(col, gamma1);
}


void levelsGamma2(inout vec3 col, in vec3 inleft, in vec3 inright, in vec3 outleft, in vec3 outright, 
                 in vec3 gamma1, in vec3 gamma2, in float ileft, in float iright, in float oleft, in float oright) {
    col = clamp(col, inleft, inright);
    col = (col - inleft) / (inright - inleft);
    col = pow(col, gamma2); 
    col = outleft + col * (outright - outleft);
    
    col = (col - vec3(ileft)) / vec3(iright - ileft); 
    col = pow(col, gamma1);
    col = vec3(oleft) + col * (oright - oleft); 
}

void brightnessAdjust( inout vec3 color, in float b) {
    color += b;
}

void contrastAdjust( inout vec3 color, in float c) {
    float t = 0.5 - c * 0.5; 
    color = color * c + t;
}


vec3 colorBurn(in vec3 s, in vec3 d )
{
	return 1.0 - (1.0 - d) / s;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb; 
    if (iMouse.z > 0.5) {
		fragColor = vec4(col, 1.0);
        return;
    }  
    vec3 tint = vec3(252., 255., 235.) / 255.;
    levelsGamma(col, vec3(28., 0., 0.) / 255., vec3(1.0), 
                     vec3(0., 0., 45.) / 255., vec3(1.0), 
                     vec3(1.2), vec3(0.91, 0.94, 0.85) ); 
	brightnessAdjust(col, 0.05);
    contrastAdjust(col, 1.1);
   
    levelsGamma2(col, vec3(45., 0., 0.) / 255., vec3(255.,255.,255.) / 255., 
                     vec3(11., 0., 56.) / 255., vec3(232.,250.,238.) / 255., 
                     vec3(1.3), vec3(0.45, 0.8, 1.4),
                      15./255., 243./255., 0./255., 238./255.); 
    contrastAdjust(col, 1.2);
    levels(col, vec3(0., 0., 0.) / 255., vec3(240.,255.,255.) / 255.,  
                vec3(0., 0., 14.) / 255., vec3(255.,255.,241.) / 255.);  
    col = col * tint; 
    fragColor = vec4(col, 1.0);
}
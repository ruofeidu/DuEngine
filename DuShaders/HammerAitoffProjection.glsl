/** 
 * Cubemap / Equirectangular to Hammer-Aitoff map projection by Xiaoxu Meng (mengxiaoxu.com)
 * Link to demo: https://www.shadertoy.com/view/Md3fD8
 * xiaoxumeng @ ShaderToy, CC0, free code
 * 
 * The converts a cubemap / panorama to Hammer-Aitoff map projection as in 
 * http://paulbourke.net/geometry/transformationprojection/
 *
 * Related ShaderToy project:
 * [1] starea. Unified Gnomonic & Stereographic https://www.shadertoy.com/view/ldBczm
 * [2] starea. Cubemap to Gnomonic Projection. https://www.shadertoy.com/view/4sjcz1
 *
 *
 * Last updated: 4/27/2018
 *
 **/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    vec2 newuv = uv * 2.0 - 1.0;
    float z2 = 1.0 - newuv.x * newuv.x * 0.5 - newuv.y * newuv.y * 0.5;
    
    float longitude = 2.0 * atan(newuv.x * sqrt(z2) / sqrt(2.0 * z2 - 1.0));
    longitude = longitude / PI2 + 0.5;
    
    float latitude = asin(newuv.y * sqrt(z2));
    latitude = (latitude + PI_2) / PI;
    
    vec2 xy = vec2(longitude, latitude);
    
    vec2 newCoord = (iMouse.z > 0.0) ? uv:xy;
    fragColor = texture(iChannel0, newCoord);
}
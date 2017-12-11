/** 
 * Interactive Poisson Blending by Ruofei Du (DuRuofei.com)
 * Demo: https://www.shadertoy.com/view/4l3Xzl
 * Tech brief: http://blog.ruofeidu.com/interactive-poisson-blending/
 * starea @ ShaderToy,License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * https://creativecommons.org/licenses/by-nc-sa/3.0/
 * 
 * Reference: 
 * [1] P. Pérez, M. Gangnet, A. Blake. Poisson image editing. ACM Transactions on Graphics (SIGGRAPH'03), 22(3):313-318, 2003.
 *
 * Created 12/6/2016
 * Update 4/5/2017:
 * [1] The iteration for each pixel will automatically stop after 100 iterations of Poisson blending.
 * 
 * Bugs remaining:
 * [2] Edge effect, but it's fine leaving the edge glowing
 **/

// Buffer B stores the users' strokes and iteration data
// Buffer A runs the Poisson blending algorithm
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
	fragColor = texture(iChannel1, q);
    fragColor.rgb *= 0.25 + 0.75 * pow( 16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15 );
}
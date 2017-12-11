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
 * [2] Edge effect, but it's kind'of cool right now.
 **/

// the stroke and iterations mask
// r for strokes
// b for iterations
#define BRUSH_SIZE 0.1
#define INITIAL_CIRCLE_SIZE 0.4
const float KEY_1 = 49.5;
const float KEY_2 = 50.5;
const float KEY_SPACE = 32.5;
const float KEY_ALL = 256.0;

bool getKeyDown(float key) {
    return texture(iChannel1, vec2(key / KEY_ALL, 0.5)).x > 0.1;
}

bool getMouseDown() {
    return iMouse.z > 0.0;
}

bool isInitialization() {
	vec2 lastResolution = texture(iChannel0, vec2(0.0) / iResolution.xy).yz; 
    return any(notEqual(lastResolution, iResolution.xy));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = 2.0 * (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;
	float mixingGradients = texture(iChannel0, vec2(1.5) / iResolution.xy).y;    
    float frameReset = texture(iChannel0, vec2(1.5) / iResolution.xy).z;    
    vec2 prevData = texture(iChannel0, uv).xy;
    float mask = prevData.x;
    float iterations = prevData.y + 0.015;
    
    bool resetBlending = (getKeyDown(KEY_1) && mixingGradients > 0.5) || (getKeyDown(KEY_2) && mixingGradients < 0.5); 
    
    if (getKeyDown(KEY_1)) mixingGradients = 0.0;
    if (getKeyDown(KEY_2)) mixingGradients = 1.0;

    if (isInitialization() || getKeyDown(KEY_SPACE)) {    
        // reset canvas
        vec2 q = vec2(-0.7, 0.5); 
        if (distance(p, q) < INITIAL_CIRCLE_SIZE) mask = 1.0;
        if (getKeyDown(KEY_SPACE)) mask = 0.0; 
        iterations = 0.0; 
        resetBlending = true; 
    } else 
    if (getMouseDown()) {
        // draw on canvas
    	vec2 mouse = 2.0 * (iMouse.xy - 0.5 * iResolution.xy) / iResolution.y;
        bool isPainted = (distance(mouse, p) < BRUSH_SIZE);
        
        if (isPainted) {
            mask = 1.0; 
            iterations = 0.0; 
        };
        frameReset = float(iFrame) - 100.0; 
    } 
    
    if (resetBlending) iterations = 0.0; 
    
	if (fragCoord.x < 1.0) { 
        fragColor = vec4(mask, iResolution.xy, 1.0);  
    } else 
    if (fragCoord.x < 2.0) { 
        if (resetBlending) frameReset = float(iFrame); 
  		fragColor = vec4(mask, mixingGradients, frameReset, 1.0);  
    } else {
        fragColor = vec4(mask, iterations, 0.5, 1.0); 
    }
}
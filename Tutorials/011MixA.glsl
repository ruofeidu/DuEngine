// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XsjyDW
//camera IO
// https://www.shadertoy.com/view/4lVXRm
// Created by genis sole - 2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

#define store(P, V) if (all(equal(fragCoord, P + 0.5))) fragColor = V
#define load(P) texture(iChannel1, (P + 0.5) / iChannelResolution[1].xy, -100.0)
#define key(K)  step(0.5, texture( iChannel0, vec2(K, 1.0/6.0) ).x)

const vec2 MEMORY_BOUNDARY = vec2(4.0, 3.0);

const vec2 POSITION = vec2(1.0, 0.0);

const vec2 VMOUSE = vec2(1.0, 1.0);
const vec2 PMOUSE = vec2(2.0, 1.0);

const vec2 TARGET = vec2(0.0, 2.0);

const vec2 RESOLUTION = vec2(3.0, 1.0);

// Keyboard constants definition
const float KEY_BSP   = 8.5/256.0;
const float KEY_SP    = 32.5/256.0;
const float KEY_LEFT  = 37.5/256.0;
const float KEY_UP    = 38.5/256.0;
const float KEY_RIGHT = 39.5/256.0;
const float KEY_DOWN  = 40.5/256.0;
const float KEY_A     = 65.5/256.0;
const float KEY_B     = 66.5/256.0;
const float KEY_C     = 67.5/256.0;
const float KEY_D     = 68.5/256.0;
const float KEY_E     = 69.5/256.0;
const float KEY_F     = 70.5/256.0;
const float KEY_G     = 71.5/256.0;
const float KEY_H     = 72.5/256.0;
const float KEY_I     = 73.5/256.0;
const float KEY_J     = 74.5/256.0;
const float KEY_K     = 75.5/256.0;
const float KEY_L     = 76.5/256.0;
const float KEY_M     = 77.5/256.0;
const float KEY_N     = 78.5/256.0;
const float KEY_O     = 79.5/256.0;
const float KEY_P     = 80.5/256.0;
const float KEY_Q     = 81.5/256.0;
const float KEY_R     = 82.5/256.0;
const float KEY_S     = 83.5/256.0;
const float KEY_T     = 84.5/256.0;
const float KEY_U     = 85.5/256.0;
const float KEY_V     = 86.5/256.0;
const float KEY_W     = 87.5/256.0;
const float KEY_X     = 88.5/256.0;
const float KEY_Y     = 89.5/256.0;
const float KEY_Z     = 90.5/256.0;
const float KEY_COMMA = 188.5/256.0;
const float KEY_PER   = 190.5/256.0;

#define KEY_BINDINGS(FORWARD, BACKWARD, RIGHT, LEFT) const float KEY_BIND_FORWARD = FORWARD; const float KEY_BIND_BACKWARD = BACKWARD; const float KEY_BIND_RIGHT = RIGHT; const float KEY_BIND_LEFT = LEFT;

#define ARROWS  KEY_BINDINGS(KEY_UP, KEY_DOWN, KEY_RIGHT, KEY_LEFT)
#define WASD  KEY_BINDINGS(KEY_W, KEY_S, KEY_D, KEY_A)
#define ESDF  KEY_BINDINGS(KEY_E, KEY_D, KEY_F, KEY_S)

#define INPUT_METHOD  ARROWS
vec2 KeyboardInput() {
    INPUT_METHOD
    
	return vec2(key(KEY_BIND_RIGHT)   - key(KEY_BIND_LEFT), 
                key(KEY_BIND_FORWARD) - key(KEY_BIND_BACKWARD));
}

vec3 CameraDirInput(vec2 vm) {
    vec2 m = vm/iResolution.x;
    m.y = -m.y;
    
    mat3 rotX = mat3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
    mat3 rotY = mat3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));
    
    return (rotY * rotX) * vec3(KeyboardInput(), 0.0).xzy;
}


void Collision(vec3 prev, inout vec3 p) {
    if (p.y < 1.0) p = vec3(prev.xz, max(1.0, prev.y)).xzy;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    if (any(greaterThan(fragCoord, MEMORY_BOUNDARY))) return;
    
    fragColor = load(fragCoord - 0.5);
    
    vec2 resolution = load(RESOLUTION).xy;
    store(RESOLUTION, vec4(iResolution.xy, 0.0, 0.0));
    
    if (iTime == 0.0 || iFrame == 0 || any(notEqual(iResolution.xy, resolution))) {
        store(POSITION, vec4(0.0, 2.0, 0.0, 0.0));
        store(TARGET, vec4(0.0, 2.0, 0.0, 0.0));
        store(VMOUSE, vec4(0.0));
        store(PMOUSE, vec4(0.0));
        
        return;
    }

    vec3 target      = load(TARGET).xyz;   
    vec3 position    = load(POSITION).xyz;
    vec2 pm          = load(PMOUSE).xy;
    vec3 vm          = load(VMOUSE).xyz;
    
    vec3 ptarget = target;
    target += CameraDirInput(vm.xy) * iTimeDelta * 5.0;
    
    Collision(ptarget, target);
    
    store(TARGET, vec4(target, 0.0));
    
    position += (target - position) * iTimeDelta * 5.0; 
    store(POSITION, vec4(position, 0.0));
    
    if (any(greaterThan(iMouse.zw, vec2(0.0)))) {
    	store(VMOUSE, vec4( pm + (iMouse.zw - iMouse.xy), 1.0, 0.0));
    }
    else if (vm.z != 0.0) {
    	store(PMOUSE, vec4(vm.xy, 0.0, 0.0));
    }

}

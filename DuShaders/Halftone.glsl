/** 
 * Yayoi Kusama Sphere
 * starea @ ShaderToy,License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * Demo: https://www.shadertoy.com/view/4sSyD1
 * 
 * Halftone Sphere remixed from Milo Yip's https://www.shadertoy.com/view/4tKSDm
 **/

const float SPHERE_DIAMETER = 0.9; 
const float PI = 3.1415926535897932;
const float PI_2 = PI / 2.0; 

mat3 rotationXY(in vec2 angle);
vec3 render(in vec2 p, in mat3 rot);

vec3 tutorial(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    // step 0: define the screen coordinates p
    vec2 p = (fragCoord.xy / iResolution.xy - 0.5) * 2.0 * vec2(iResolution.x / iResolution.y, 1.0); 
    
    vec3 col = (length(p) <= 0.9) ? vec3(0.0) : vec3(1.0); 
   	
    // step 1: normal vector, assuming the n_z to outwards the screen, n_x = p_x, n_y = p_y, n_z = sqrt(1-p_x^2-p_y^2)
    vec3 n = vec3( p, sqrt(1.0 - dot(p, p)) ); 
    // visualize the normal vector, [-1, 1]
    // col = n; 
    col = vec3(n * 0.5 + 0.5); 
    
    // step 2: define the spherical coordinates, [-1, 1]
    vec2 s = vec2(acos(n.z), atan(n.y, n.x)) / PI; 
    col = vec3(s * 0.5 + 0.5, 0.0); 
    
    // step 3: divide the sphere into many squares
    uv = fract(s * vec2(30.0, 20.0));
    col = vec3(uv, 0.0);
    
    // step 4: texture mapping with circles
    float r = 0.4;
    col = length(uv - 0.5) < r ? vec3(1.0) : vec3(0.0); 
    
  	// step 5: change the radius of the circles
    r = ceil(s.x * 30.0) / 45.0;
    col = length(uv - 0.5) < r ? vec3(1.0) : vec3(0.0); 
    
    // step 6: define the rotation matrix based on the mouse
    mat3 rot = rotationXY( vec2(iMouse.yx / iResolution.yx) * vec2(PI, -2.0 * PI) + vec2(-1.0, 1.0) * 0.5 * PI ); 

    const int KERNEL_RADIUS = 2;
    const int KERNEL_SIZE = (KERNEL_RADIUS * 2) + 1; 
                          
    // step 7: integrate all code into a function named render, and conduct super sampling
    vec3 sum = vec3(0.0); 
    col = vec3(0.0); 
    for (int x = -KERNEL_RADIUS; x <= KERNEL_RADIUS; ++x) {
        for (int y = -KERNEL_RADIUS; y <= KERNEL_RADIUS; ++y) {
            sum += render( p + vec2(x, y) / (2.0 * iResolution.xx), rot); 
        }
    }
    col = sum / 25.0; 
    
    
    return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
	vec3 col = tutorial(fragColor, fragCoord); 
    fragColor = vec4(col, 1.0); 
}

// rotation matrix from step 6, forked from https://www.shadertoy.com/view/4tKSDm
mat3 rotationXY(in vec2 angle) {
	vec2 c = cos(angle);
	vec2 s = sin(angle);
	return mat3(
		c.y, 0.0, -s.y,
		s.y * s.x, c.x, c.y * s.x,
		s.y * c.x, -s.x, c.y * c.x
	);
}

// integration from step 7
vec3 render(in vec2 p, in mat3 rot) {
    if (length(p) > SPHERE_DIAMETER) return vec3(1.0); 
    vec3 n = rot * vec3(p, sqrt(1.0 - dot(p, p)));
    vec2 s = vec2(acos(n.z), atan(n.y, n.x)) / PI;
    vec2 uv = fract(s * vec2(30.0, 30.0));
    float r = ceil( (1.0 - abs(s.x * 2.0 - 1.0)) * 15.0) / 45.0;
    // r = ceil(s.x * 30.0) / 45.0;
    vec3 col = length(uv - 0.5) < r ? vec3(0.0) : vec3(0.86, 0.68, 0.1);
    
    // step 8, add light
    vec3 lightPos = vec3(2.0, 2.5, 4.0);
    col += col * vec3(1.0) * max(dot(n, normalize(lightPos - n)), 0.0);
    
    return col; 
}

// Dr. Neyret has a code-golf version as a step 8:
/*
void mainImage(out vec4 O,  vec2 U) {
    vec2 R = iResolution.xy,
         p = (U+U - R) / R.y,
         m = iMouse.xy / R,
         a = 3.14*vec2(m.y-.5, .5-2.*m.x),
         c = cos(a), s = sin(a);
    vec3 n = mat3( c.y,          0,      -s.y,
		           s.y * s.x,  c.x, c.y * s.x,
		           s.y * c.x, -s.x, c.y * c.x
	            )
             * vec3( p, sqrt(1.-dot(p,p)) );
    O -= O;
    O += n==n ?  s = 9.55* vec2(acos(n.z), atan(n.y, n.x)), // 9.55 = 30/3.14
                 ceil(s.x)/2. - 22.*length(fract(s)-.5)
               : 1. ;   
}
*/

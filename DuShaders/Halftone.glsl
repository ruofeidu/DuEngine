// Ruofei Du
// Dot Screen: https://www.shadertoy.com/view/4sBBDK
// Yet Another Halftone Effect: https://www.shadertoy.com/view/lsSfWV
// Golf version: https://www.shadertoy.com/view/XsjBWK

// refracted by Dr. Neyret (https://www.shadertoy.com/user/FabriceNeyret2)
#define greyScale(col)  dot( col, vec4( .2126, .7152, .0722, 0) )

void mainImage( out vec4 fragColor, vec2 U )
{
	vec2 R = iResolution.xy, 
         M = iMouse.xy / R;
         U /= R;
    
    float eleSize = M.y < 1e-3 ? 6.
                               : 5. + mix(-2., .5, M.x / M.y);
    
    vec2 uniformEleSize = eleSize / R,
         d = mod( U, uniformEleSize) - uniformEleSize * .5; 
    
    float grey = greyScale(texture(iChannel0, U - d)),
          dist = length(d), 
         scale = 1. + .3 * sin(iTime),
           rad = grey * uniformEleSize.x * scale; 
    
    fragColor = vec4(dist < rad);
}

// original
/*
float greyScale(in vec3 col) {
    return dot(col, vec3(0.2126, 0.7152, 0.0722));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float eleSize = iMouse.y < 1e-3 ? 6.0 : 5.0 + mix(-2.0, 0.5, iMouse.x / iMouse.y * iResolution.y / iResolution.x);
    vec2 numEles = iResolution.xy / eleSize; 
    vec2 uniformEleSize = 1.0 / numEles; 
    vec2 d = mod(uv, uniformEleSize) - uniformEleSize * 0.5; 
    vec3 col = texture(iChannel0, uv - d).rgb; 
    float grey = greyScale(col); 
    float dist = length(d); 
    float scale = 1.0 + 0.3 * sin(iTime); 
    float rad = grey * uniformEleSize.x * scale; 
    col = mix(vec3(0.0), vec3(1.0), step(dist, rad));
    fragColor = vec4(col, 1.0);
}
*/
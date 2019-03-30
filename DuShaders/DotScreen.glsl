// 4sBBDK
// Ruofei Du
// Dot Screen / Halftone: https://www.shadertoy.com/view/4sBBDK
// Halftone: https://www.shadertoy.com/view/lsSfWV

float greyScale(in vec3 col) {
    return dot(col, vec3(0.2126, 0.7152, 0.0722));
}

mat2 rotate2d(float angle){
    return mat2(cos(angle), -sin(angle), sin(angle),cos(angle));
}

float dotScreen(in vec2 uv, in float angle, in float scale) {
    float s = sin( angle ), c = cos( angle );
	vec2 p = (uv - vec2(0.5)) * iResolution.xy;
    vec2 q = rotate2d(angle) * p * scale; 
	return ( sin( q.x ) * sin( q.y ) ) * 4.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb; 
    float grey = greyScale(col); 
    float angle = iMouse.y < 1e-3 ? 0.4 : iMouse.x / iMouse.y;
    float scale = 1.0 + 0.3 * sin(iTime); 
    col = vec3( grey * 10.0 - 5.0 + dotScreen(uv, angle, scale ) );
	fragColor = vec4( col, 1.0 );
}

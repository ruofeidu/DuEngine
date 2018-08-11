// https://www.shadertoy.com/view/Xl3yzl
const float PI = 3.1415926535;
const float SC = 400.;
const float Q = 0.1;

mat2 rotate2d(float _angle)
{
	return mat2(cos(_angle), -sin(_angle),
				sin(_angle), cos(_angle));
}

vec3 grid(vec2 uv, vec2 pos)
{
	float v = max(sin(pos.x), cos(pos.y));
	float shade = 0.25*(2.+sin(Q*uv.x))
					*(2.+sin(Q*uv.y));
	return vec3(v*shade, v*(shade-1.), 0.);
}

vec2 warp(vec2 pos)
{
	const float A = 5.;
	float TSC = 0.3 * iTime;
	vec2 T = vec2(-50.*TSC, 20.*sin(TSC));
	vec2 uwave = vec2(sin(Q*pos.y), sin(Q*pos.x));
	return pos + A*uwave + T;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float mx = max(iResolution.x, iResolution.y);
    vec2 uv = gl_FragCoord.xy / mx;
    
    float val = 0.0;
    mat2 m = mat2(1.);
    
    vec3 rgb = grid(SC*uv, warp(SC*uv));
    fragColor = vec4(rgb, 1.0);
}
// https://www.shadertoy.com/view/ltBfzd
vec2 rand2(vec2 uv)
{
    uv += 0.5;
    uv /= 256.0; // texel size
	return vec2(texture(iChannel0, uv).r, texture(iChannel0, uv + 17.0 / 256.0).r) * 2.0 - 1.0;
}

float smix(float a, float b, float t)
{
    return mix(a, b, smoothstep(0.0, 1.0, t));
}

float computeCorner(vec2 corner, vec2 uv)
{
    vec2 gradient = normalize(rand2(corner));
    return dot(gradient, uv - corner);
}

float perlin(vec2 uv)
{
	float c00 = computeCorner(floor(uv) + vec2(0.0, 0.0), uv);
	float c01 = computeCorner(floor(uv) + vec2(0.0, 1.0), uv);
	float c11 = computeCorner(floor(uv) + vec2(1.0, 1.0), uv);
	float c10 = computeCorner(floor(uv) + vec2(1.0, 0.0), uv);
    
    vec2 diff = uv - floor(uv);
    
    return smix(smix(c00, c10, diff.x), smix(c01, c11, diff.x), diff.y);
}

float fbm(vec2 uv)
{
    float value = 0.0;
    float factor = 1.0;
    for (int i = 0; i < 8; i++)
    {
        uv += iTime * 0.04;
        value += perlin(uv * factor) / factor;
        factor *= 2.0;
    }
    return value;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy * 5.0 / iResolution.y;
	fragColor = vec4(vec3(fbm(uv) * 0.5 + 0.5) ,1.0);
}

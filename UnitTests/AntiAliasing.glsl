// https://www.shadertoy.com/view/ldsSRX
vec2 magnify(vec2 uv)
{
    uv *= iChannelResolution[0].xy; 
    return (saturate(fract(uv) / saturate(fwidth(uv))) + floor(uv) - 0.5) / iChannelResolution[0].xy;
}

vec2 quantize(vec2 uv)
{
    return (floor(uv * iChannelResolution[0].xy) + 0.5) / iChannelResolution[0].xy;
}

void mainImage(out vec4 fragColor, vec2 fragCoord)
{
    vec2 sc = fragCoord / iResolution.xy;
    
	vec2 uv = vec2(sc.x * 0.1 - 0.05, 0.1) / (sc.y - 1.0);
	uv *= mat2(sin(iTime * 0.1), cos(iTime * 0.1), -cos(iTime * 0.1), sin(iTime * 0.1));
			
	vec2 uvMod = sc.x < 0.33 ? uv : sc.x < 0.66 ? magnify(uv) : quantize(uv);

	fragColor = textureGrad(iChannel0, uvMod, dFdx(uv), dFdy(uv));
}

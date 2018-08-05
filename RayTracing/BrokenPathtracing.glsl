// XstBzM
// By Roman Smirnov
// License Creative Commons Attribution 4.0 International

vec3 tonemapping(vec3 color, float exposure)
{
	color *= exposure;
    
    float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.10;
	float E = 0.015;
	float F = 0.40;
	float W = 11.2;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
    
    return color;
}

vec3 LinearToSRGB(vec3 color )
{
	vec3 sRGBLo = color * 12.92;
    const float powExp = 1.0/2.4;
	vec3 sRGBHi = ( pow( abs ( color ), vec3(powExp, powExp, powExp)) * 1.055) - 0.055;
	vec3 sRGB;
    sRGB.x = ( color.x <= 0.0031308) ? sRGBLo.x : sRGBHi.x;
    sRGB.y = ( color.y <= 0.0031308) ? sRGBLo.y : sRGBHi.y;
    sRGB.z = ( color.z <= 0.0031308) ? sRGBLo.z : sRGBHi.z;
	return sRGB;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{    
    const float exposure = 2.0;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = tonemapping(texture(iChannel0, uv).xyz, exposure);
    
	fragColor = vec4(LinearToSRGB(color), 1);
}
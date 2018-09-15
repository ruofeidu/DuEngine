/*

This shader experiments the effect of different tone mapping operators.
This is still a work in progress.

Comparing different tone mappings operators.

From top to bottom:
color displayed as is,
linear,
simplified Reinhard operator,
luma based Reinhard op.,
white preserving luma based Reinhard op.,
RomBinDaHouse
filmic tone map.,
Uncharted 2 tone map..

More info:
http://slideshare.net/ozlael/hable-john-uncharted2-hdr-lighting
http://filmicgames.com/archives/75
http://filmicgames.com/archives/183
http://filmicgames.com/archives/190
http://imdoingitwrong.wordpress.com/2010/08/19/why-reinhard-desaturates-my-blacks-3/
http://mynameismjp.wordpress.com/2010/04/30/a-closer-look-at-tone-mapping/
http://renderwonk.com/publications/s2010-color-course/

--
Zavie

*/

float gamma = 2.2;

vec3 getBaseColor(int i)
{
	if (i == 0) return vec3(1.0, 0.4, 0.0);
	if (i == 1) return vec3(0.4, 1.0, 0.0);
	if (i == 2) return vec3(0.0, 1.0, 0.4);
	if (i == 3) return vec3(0.0, 0.4, 1.0);
	if (i == 4) return vec3(0.4, 0.0, 1.0);
	if (i == 5) return vec3(1.0, 0.0, 0.4);

	return vec3(1.);
}

vec3 getBaseColor()
{
	float colorPerSecond = 0.5;
	int i = int(mod(colorPerSecond * iTime, 7.));
	int j = int(mod(float(i) + 1., 7.));

	return mix(getBaseColor(i), getBaseColor(j), fract(colorPerSecond * iTime));
}

vec3 linearToneMapping(vec3 color)
{
	float exposure = 1.;
	color = clamp(exposure * color, 0., 1.);
	color = pow(color, vec3(1. / gamma));
	return color;
}

vec3 simpleReinhardToneMapping(vec3 color)
{
	float exposure = 1.5;
	color *= exposure/(1. + color / exposure);
	color = pow(color, vec3(1. / gamma));
	return color;
}

vec3 lumaBasedReinhardToneMapping(vec3 color)
{
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float toneMappedLuma = luma / (1. + luma);
	color *= toneMappedLuma / luma;
	color = pow(color, vec3(1. / gamma));
	return color;
}

vec3 whitePreservingLumaBasedReinhardToneMapping(vec3 color)
{
	float white = 2.;
	float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
	float toneMappedLuma = luma * (1. + luma / (white*white)) / (1. + luma);
	color *= toneMappedLuma / luma;
	color = pow(color, vec3(1. / gamma));
	return color;
}

vec3 RomBinDaHouseToneMapping(vec3 color)
{
    color = exp( -1.0 / ( 2.72*color + 0.15 ) );
	color = pow(color, vec3(1. / gamma));
	return color;
}

vec3 filmicToneMapping(vec3 color)
{
	color = max(vec3(0.), color - vec3(0.004));
	color = (color * (6.2 * color + .5)) / (color * (6.2 * color + 1.7) + 0.06);
	return color;
}

vec3 Uncharted2ToneMapping(vec3 color)
{
	float A = 0.15;
	float B = 0.50;
	float C = 0.10;
	float D = 0.20;
	float E = 0.02;
	float F = 0.30;
	float W = 11.2;
	float exposure = 2.;
	color *= exposure;
	color = ((color * (A * color + C * B) + D * E) / (color * (A * color + B) + D * F)) - E / F;
	float white = ((W * (A * W + C * B) + D * E) / (W * (A * W + B) + D * F)) - E / F;
	color /= white;
	color = pow(color, vec3(1. / gamma));
	return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 color = getBaseColor();

	float n = 8.;
	if (uv.x > 0.2)
	{
		if (uv.x < 0.6)
			// blacks
			color *= (2.5 * uv.x - 0.5);
		else
			// whites
			color *= 15.*(2.5 * uv.x - 1.5) + 1.;

		int i = int(n * (1. - uv.y));
		if (i == 1) color = linearToneMapping(color);
		if (i == 2) color = simpleReinhardToneMapping(color);
		if (i == 3) color = lumaBasedReinhardToneMapping(color);
		if (i == 4) color = whitePreservingLumaBasedReinhardToneMapping(color);
		if (i == 5) color = RomBinDaHouseToneMapping(color);		
		if (i == 6) color = filmicToneMapping(color);
		if (i == 7) color = Uncharted2ToneMapping(color);
	}

	if (abs(fract(n * uv.y + 0.5) - 0.5) < 0.02)
		color = vec3(0.);

	fragColor = vec4(color, 1.);
}

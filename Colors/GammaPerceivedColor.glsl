/*

This shader demonstrates the effect of gamma on
color hue.

Each left gradient is gamma corrected, while its
right counter part is not.

Note how hue, saturation and intensity are different
between gamma corrected and non gamma corrected
versions.

--
Zavie

*/

float gamma = 2.2;

struct colorPair
{
    vec3 color1;
    vec3 color2;
};

vec3 shade(vec2 uv, colorPair pair)
{
    return clamp(mix(pair.color1, pair.color2, uv.y), 0., 1.);
}

#define numberOfColors 3.

colorPair getColorPair(float x)
{
    int i = int(floor(numberOfColors * x));

    // Demonstrate intensity change
    if (i == 0) return colorPair(vec3(1.0, 0.0, 0.0),
                                 vec3(0.0, 1.0, 1.0));
    
    // Demonstrate saturation change
    if (i == 1) return colorPair(vec3(1.0, 0.5, 0.5),
                                 vec3(0.5, 0.5, 1.0));

    // Demonstrate hue change
    if (i == 2) return colorPair(vec3(1.0, 0.0, 0.0),
                                 vec3(1.0, 1.0, 0.0));

    return colorPair(vec3(0.), vec3(1.));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 color = shade(uv, getColorPair(uv.x));

    float x = clamp(abs(fract(0.2*iTime + 0.5) * 2. - 1.) * 2. - 0.5, 0., 1.);
    float exponent = mix(1.0, 1.0/gamma, max(x, float(fract(numberOfColors * uv.x) < 0.5)));
	color = pow(color, vec3(exponent));

	fragColor = vec4(color, 1.);
}

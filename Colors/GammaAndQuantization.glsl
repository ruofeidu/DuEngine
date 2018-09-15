// 
/*

This demonstrates the effect of quantization in gamma and linear space (watch fullscreen and see the banding).
It's basically a live example of the problem shown in this article:

http://hacksoflife.blogspot.jp/2010/11/value-of-gamma-compression.html

This shader demonstrates the effect of gamma and
quantization.

Each gradient is generated using only a limited
number of bits per channel: you can define this
number here after.

The gradients are then shown in linear space and
in gamma space. Notice how the banding in the
dark colors becomes more visible in gamma space.

The vertical lighter line shows where the
gradients should reach half luminosity (that's
where the contrast with the grainy color
underneath should be minimal).

More info:
http://hacksoflife.blogspot.jp/2010/11/value-of-gamma-compression.html
http://www.poynton.com/notes/colour_and_gamma/GammaFAQ.html

--
Zavie

*/

ivec3 bitsPerChannel = ivec3(5, 6, 5);
float gamma = 2.2;


vec3 checker(vec2 coord, vec3 color)
{
  float intensity = float(mod(coord.x, 2.) == mod(coord.y, 2.));
  return intensity * color;
}

vec3 shade(vec2 uv, vec3 color)
{
  float intensity = uv.x;
  return intensity * color;
}

vec3 quantized(vec3 color, ivec3 bits)
{
  vec3 range = pow(vec3(2.), vec3(bits));
  return floor(color * range) / range;
}


vec3 getColor(float x)
{
  int i = int(floor(13. * x));

  if (i == 0) return vec3(1., 0., 0.);
  if (i == 1) return vec3(1., .5, 0.);
  if (i == 2) return vec3(1., 1., 0.);
  if (i == 3) return vec3(.5, 1., 0.);
  if (i == 4) return vec3(0., 1., 0.);
  if (i == 5) return vec3(0., 1., .5);
  if (i == 6) return vec3(0., 1., 1.);
  if (i == 7) return vec3(0., .5, 1.);
  if (i == 8) return vec3(0., 0., 1.);
  if (i == 9) return vec3(.5, 0., 1.);
  if (i == 10) return vec3(1., 0., 1.);
  if (i == 11) return vec3(1., 0., .5);

  return vec3(1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 color;

	if (fract(13. * uv.y) < 0.2)
		color = checker(fragCoord.xy, getColor(uv.y));
	else
		color = shade(uv, getColor(uv.y));

	float halfLuminosity = 0.5;
	
	if (mod(iDate.w, 8.) > 4.)
	{
		halfLuminosity = pow(halfLuminosity, 1./gamma);
		color = pow(color, vec3(gamma));
	}
	if (mod(iDate.w, 4.) > 2.)
    {
		color = quantized(color, bitsPerChannel);
    }
	color = pow(color, vec3(1./gamma));

	if (abs(uv.x - halfLuminosity) < 0.001)
		color = mix(color, vec3(1.), 0.3);

	fragColor = vec4(color, 1.);
}

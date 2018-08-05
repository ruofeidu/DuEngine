// https://www.shadertoy.com/view/Mtjczz

struct transfer {
	float power;
	float off;
	float slope;
	float cutoffToLinear;
	float cutoffToGamma;
	bool tvRange;
};

struct rgb_space {
	mat3 primaries;
	vec3 whitePoint;
	transfer trc;
};


/*
 * Preprocessor 'functions' that help build colorspaces as constants
 */

// Turns 6 chromaticity coordinates into a 3x3 matrix
#define \
primaries(r1, r2, g1, g2, b1, b2)\
	mat3(\
		r1, r2, 1.0 - r1 - r2,\
		g1, g2, 1.0 - g1 - g2,\
		b1, b2, 1.0 - b1 - b2)

// Creates a whitepoint's xyz chromaticity coordinates from the given xy coordinates
#define \
white(x, y)\
	vec3(x, y, (1.0 - x - y))

// Creates a scaling matrix using a vec3 to set the xyz scalars
#define \
diag(v)\
	mat3(\
		v.x, 0.0, 0.0,\
		0.0, v.y, 0.0,\
		0.0, 0.0, v.z)

// Creates a conversion matrix that turns RGB colors into XYZ colors
#define \
rgbToXyz(space)\
	space.primaries*diag((inverse(space.primaries)*(space.whitePoint/space.whitePoint.y)))

// Creates a conversion matrix that turns XYZ colors into RGB colors
#define \
xyzToRgb(space)\
	inverse(rgbToXyz(space))

// Creates a conversion matrix converts linear RGB colors from one colorspace to another
#define \
conversionMatrix(f, t)\
	xyzToRgb(t)*rgbToXyz(f)


const mat3 primaries709 = mat3(
	0.64, 0.33, 0.03,
	0.3, 0.6, 0.1,
	0.15, 0.06, 0.79
);


const vec3 whiteD65 = vec3(0.312713, 0.329016, 0.358271);

const transfer gamSrgb = transfer(2.4, 0.055, 12.92, 0.04045, 0.0031308, false);

const rgb_space Srgb = rgb_space(primaries709, whiteD65, gamSrgb);


// Radius for the color sampling; keep low for your GPU's sake!
const int r = 1;

// Change this to decide what colorspace the original image uses
const rgb_space from = Srgb;


vec4 toLinear(vec4 color, transfer trc)
{
	if (trc.tvRange) {
		color = color*85.0/73.0 - 16.0/219.0;
	}

	bvec4 cutoff = lessThan(color, vec4(trc.cutoffToLinear));
	bvec4 negCutoff = lessThanEqual(color, vec4(-1.0*trc.cutoffToLinear));
	vec4 higher = pow((color + trc.off)/(1.0 + trc.off), vec4(trc.power));
	vec4 lower = color/trc.slope;
	vec4 neg = -1.0*pow((color - trc.off)/(-1.0 - trc.off), vec4(trc.power));

	color = mix(higher, lower, cutoff);
	color = mix(color, neg, negCutoff);

	return color;
}

vec4 toGamma(vec4 color, transfer trc)
{
	bvec4 cutoff = lessThan(color, vec4(trc.cutoffToGamma));
	bvec4 negCutoff = lessThanEqual(color, vec4(-1.0*trc.cutoffToGamma));
	vec4 higher = (1.0 + trc.off)*pow(color, vec4(1.0/trc.power)) - trc.off;
	vec4 lower = color*trc.slope;
	vec4 neg = (-1.0 - trc.off)*pow(-1.0*color, vec4(1.0/trc.power)) + trc.off;

	color = mix(higher, lower, cutoff);
	color = mix(color, neg, negCutoff);

	if (trc.tvRange) {
		color = color*73.0/85.0 + 16.0/255.0;
	}

	return color;
}

// Scales a color to the closest in-gamut representation of that color
vec4 gamutScale(vec4 color, float luma)
{
	float low = min(color.r, min(color.g, min(color.b, 0.0)));
	float high = max(color.r, max(color.g, max(color.b, 1.0)));

	float lowScale = low/(low - luma);
	float highScale = max((high - 1.0)/(high - luma), 0.0);
	float scale = max(lowScale, highScale);
	color.rgb += scale*(luma - color.rgb);

	return color;
}

// Converts from one RGB colorspace to another
vec4 convert(vec4 color, rgb_space from, rgb_space to)
{
	color = toLinear(color, from.trc);

	color.xyz = rgbToXyz(from)*color.rgb;
	float luma = color.y;

	color.rgb = xyzToRgb(to)*color.rgb;
	color = gamutScale(color, luma);

	return toGamma(color, to.trc);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	rgb_space to = from;

	vec2 texRes = vec2(textureSize(iChannel0, 0));
	vec2 texCoord = fragCoord/texRes;
	texCoord *= texRes.x/iResolution.x;

	vec2 mouseCoord = vec2(0.0);
	vec3 whiteColor = vec3(0.0);

	for (int i = -r; i <= r; ++i) {
		for (int j = -r; j <= r; ++j) {
			mouseCoord = (texCoord*texRes*iMouse.xy/fragCoord + vec2(i, j))/texRes;
			whiteColor += toLinear(texture(iChannel0, mouseCoord), from.trc).rgb;
		}
	}

	whiteColor /= float((r*2+1)*(r*2+1));

	whiteColor = rgbToXyz(to)*whiteColor;
	whiteColor /= dot(whiteColor, vec3(1.0));
	to.whitePoint = whiteColor;

	// Uncomment this portion (remove the '/*' and '*/') for half of the
	// image to remain untouched
	/*bool left = bool(int(texCoord.x*2.0));

	if (!left) {
		from = Srgb;
		to = from;
	}*/

	fragColor = convert(texture(iChannel0, texCoord), from, to);
}
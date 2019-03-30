// FabriceNeyret2's https://www.shadertoy.com/view/llKSDz
// based on SebH's https://www.shadertoy.com/view/MdKSzc
//          h3r2tic's https://www.shadertoy.com/view/4dVSDy

// Spectrum to xyz approx function from Sloan http://jcgt.org/published/0002/02/01/paper.pdf
// Inputs:  Wavelength in nanometers
float xFit_1931( float wave )
{
    float t1 = (wave-442.0)*((wave<442.0)?0.0624:0.0374),
          t2 = (wave-599.8)*((wave<599.8)?0.0264:0.0323),
          t3 = (wave-501.1)*((wave<501.1)?0.0490:0.0382);
    return 0.362*exp(-0.5*t1*t1) + 1.056*exp(-0.5*t2*t2)- 0.065*exp(-0.5*t3*t3);
}
float yFit_1931( float wave )
{
    float t1 = (wave-568.8)*((wave<568.8)?0.0213:0.0247),
          t2 = (wave-530.9)*((wave<530.9)?0.0613:0.0322);
    return 0.821*exp(-0.5*t1*t1) + 0.286*exp(-0.5*t2*t2);
}
float zFit_1931( float wave )
{
    float t1 = (wave-437.0)*((wave<437.0)?0.0845:0.0278),
          t2 = (wave-459.0)*((wave<459.0)?0.0385:0.0725);
    return 1.217*exp(-0.5*t1*t1) + 0.681*exp(-0.5*t2*t2);
}

#define xyzFit_1931(w) vec3( xFit_1931(w), yFit_1931(w), zFit_1931(w) ) 
    
vec3 xyzToRgb(vec3 XYZ)
{
	return XYZ * mat3( 3.240479, -1.537150, -0.498535,
	                  -0.969256 , 1.875991,  0.041556,
	                   0.055648, -0.204043,  1.057311 );
}

#define SPECTRUM_START 360
#define SPECTRUM_BIN   43
#define SPECTRUM_STEP  10

float cross2(vec2 a, vec2 b) { return a.x*b.y - a.y*b.x; } 

// Returns 1 if the lines intersect, otherwise 0. In addition, if the lines 
// intersect the intersection point may be stored in the floats i_x and i_y.

vec2 intersectSegment(vec2 p0, vec2 p1, vec2 p2, vec2 p3)
{
    vec2 s1 = p1-p0, s2 = p3-p2;

    float d = cross2(s1,s2),
          s = cross2(s1, p0-p2) / d,
          t = cross2(s2, p0-p2) / d;

    return s >= 0. && s <= 1. && t >= 0. && t <= 1.
         ? p0 + t*s1    // Collision detected
         : p0;
}

vec3 constrainXYZToSRGBGamut(vec3 col)
{
    vec2 xy = col.xy / (col.x + col.y + col.z);
    
    vec2 red   = vec2(0.64,   0.33  ),
         green = vec2(0.3,    0.6   ),
         blue  = vec2(0.15,   0.06  ),
         white = vec2(0.3127, 0.3290);
    
    const float desaturationAmount = 0.1;
    xy = mix(xy, white, desaturationAmount);
    
    xy = intersectSegment(xy, white, red,   green);
    xy = intersectSegment(xy, white, green, blue );
    xy = intersectSegment(xy, white, blue,  red  );
    
    return col.y * vec3( xy, 1. - xy.x - xy.y ) / xy.y;
}

void mainImage( out vec4 fragColor,  vec2 uv )
{
	uv /= iResolution.xy;
    
    // Draw XYZ curves at the bottom

    float wavelength = float(SPECTRUM_START) + uv.x * float(SPECTRUM_BIN*SPECTRUM_STEP);
    
    
    // Display XYZ spectrum curve

	vec3 outColor = step( uv.y*4., xyzFit_1931(wavelength) );
   

    // Spectrum -> xyz -> rgb absorption gradient

    float spectrum[SPECTRUM_BIN];
    for(int i=0; i<SPECTRUM_BIN; ++i)
    {
      #if 1
        spectrum[i] = 0.014;// uniform band distribution
      #else
        float w = float(SPECTRUM_START + SPECTRUM_STEP*i);
    	      X = xFit_1931(w),
    	      Y = yFit_1931(w),
    	      Z = zFit_1931(w);
        spectrum[i] = (X+Y+Z) * 0.014;// follow xyz distribution
      #endif
    }
    

 
#define sqr(x) ((x)*(x))
#define gauss(x,s) 1.14* exp(-.5*sqr((x)/(s))) / (s)
#define S 1.
//#define S ((2.*uv.y-1.)*10.)
    
    if (uv.y >.9) uv.x = 5./uv.x / float(SPECTRUM_BIN); // org by freqs instead of wavelengths
        
    // Compute spectrum perception along wavelengthes  ( was: Compute spectrum after absorption )
    float spectrum2[SPECTRUM_BIN],
        depth = uv.x * 1000.;
    for(int i=0; i<SPECTRUM_BIN; ++i)
    {
        float w = float(SPECTRUM_START + SPECTRUM_STEP*i);
        // spectrum2[i] = spectrum[i]  * exp(-depth * getAbsorption(w));
        // spectrum2[i] = spectrum[i]*float(int(uv.x*float(SPECTRUM_BIN))==i);
        spectrum2[i] = spectrum[i] * gauss( uv.x*float(SPECTRUM_BIN)-float(i), S);
    }
    
    vec3 colorXYZ = vec3(0),
        color2XYZ = vec3(0);
    for(int i=0; i<SPECTRUM_BIN; ++i)
    {
        float w = float(SPECTRUM_START + SPECTRUM_STEP*i),  
             dw = float(SPECTRUM_STEP);

        vec3 xyzFit = dw * xyzFit_1931(w);        
        colorXYZ  += spectrum [i] * xyzFit;
        color2XYZ += spectrum2[i] * xyzFit;
	}
    
    vec3 color = xyzToRgb(colorXYZ),
        color2 = xyzToRgb(constrainXYZToSRGBGamut(color2XYZ));
    

    // perceived colors at the top

    if(uv.y > .5) {
		outColor =  uv.y > .75 && uv.y < .9
           ? color2                                  // without gamma transform
           : pow(max(vec3(0),color2), vec3(1./2.2)); // with gamma
        if ( uv.y < .55 || uv.y > .97 )           
             outColor = vec3(pow((color2.r+color2.g+color2.b)/3., 1./2.2));
    }

    
	fragColor = vec4(outColor,1.);
}

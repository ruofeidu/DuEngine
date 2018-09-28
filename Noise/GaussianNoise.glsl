// 
// Based on hornet's 'noise distributions' shader (https://www.shadertoy.com/view/4ssXRX)

// An experiment in the viability of generating gaussian noise directly from a single
// uniform noise sample.

// Intuitively it is clear that if we bend or warp the output of a uniform noise then we are
// also changing the distribution of that noise. In general, uniform noise can be shaped into
// a specific distribution by mapping it though its corresponding inverted
// cumulative probability distribution function.

// It is well known that the anti-derivative of the gaussian function is the error function
// which unfortunately doesn't have a closed form expression. To get around this, a variant
// of Sergei Winitzki's highly accurate approximation is used instead.
// In practice, a simpler approximation would probably be satisfactory.

// It is unclear if this has any practical use :)

const int NUM_BUCKETS = 32;
const int ITER_PER_BUCKET = 1024;
const float HIST_SCALE = 8.0;

const float NUM_BUCKETS_F = float(NUM_BUCKETS);
const float ITER_PER_BUCKET_F = float(ITER_PER_BUCKET);
const float PI = 3.1415926535;

//note: uniformly distributed, normalized rand, [0;1[
float nrand( vec2 n )
{
	return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
}
//note: remaps v to [0;1] in interval [a;b]
float remap( float a, float b, float v )
{
	return clamp( (v-a) / (b-a), 0.0, 1.0 );
}
//note: quantizes in l levels
float _trunc( float a, float l )
{
	return floor(a*l)/l;
}

float n8rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );	
	float nrnd2 = nrand( n + 0.13*t );
	float nrnd3 = nrand( n + 0.17*t );
    
    float nrnd4 = nrand( n + 0.19*t );
    float nrnd5 = nrand( n + 0.23*t );
    float nrnd6 = nrand( n + 0.29*t );
    float nrnd7 = nrand( n + 0.31*t );
    
	return (nrnd0+nrnd1+nrnd2+nrnd3 +nrnd4+nrnd5+nrnd6+nrnd7) / 8.0;
}

const float ALPHA = 0.14;
const float INV_ALPHA = 1.0 / ALPHA;
const float K = 2.0 / (PI * ALPHA);

float inv_error_function(float x)
{
	float y = log(1.0 - x*x);
	float z = K + 0.5 * y;
	return sqrt(sqrt(z*z - y * INV_ALPHA) - z) * sign(x);
}

float gaussian_rand( vec2 n )
{
	float t = fract( iTime );
	float x = nrand( n + 0.07*t );
    
	return inv_error_function(x*2.0-1.0)*0.15 + 0.5;
}

float histogram( int iter, vec2 uv, vec2 interval, float height, float scale )
{
	float t = remap( interval.x, interval.y, uv.x );
	vec2 bucket = vec2( _trunc(t,NUM_BUCKETS_F), _trunc(t,NUM_BUCKETS_F)+1.0/NUM_BUCKETS_F);
	float bucketval = 0.0;
	for ( int i=0;i<ITER_PER_BUCKET;++i)
	{
		float seed = float(i)/ITER_PER_BUCKET_F;
		
		float r;
		if ( iter < 2 )
			r = n8rand( vec2(uv.x,0.5) + seed );
		else
			r = gaussian_rand( vec2(uv.x,0.5) + seed );
		
		bucketval += step(bucket.x,r) * step(r,bucket.y);
	}
	bucketval /= ITER_PER_BUCKET_F;
	bucketval *= scale;
    
    float v0 = step( uv.y / height, bucketval );
    float v1 = step( (uv.y-1.0/iResolution.y) / height, bucketval );
    float v2 = step( (uv.y+1.0/iResolution.y) / height, bucketval );
	return 0.5 * v0 + v1-v2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float o;
    int idx;
    vec2 uvrange;
	if ( uv.x < .5 )
	{
		o = n8rand( uv );
        idx = 1;
        uvrange = vec2( 0.0, 0.5 );
	}
	else
	{
		o = gaussian_rand( uv );
        idx = 2;
        uvrange = vec2( 0.5, 1.0 );
	}

    //display histogram
    if ( uv.y < 1.0 / 4.0 )
		o = 0.125 + histogram( idx, uv, uvrange, 1.0/4.0, HIST_SCALE );
    
	//display lines
	if ( abs(uv.x - 0.5) < 0.002 ) o = 0.0;

	
	fragColor = vec4( vec3(o), 1.0 );
}
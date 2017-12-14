/* 
https://www.shadertoy.com/view/4ssXRX

left to right:
- uniform noise
- triangular noise
- gaussianish noise
- moar gaussianish noise 

Used in relation to http://www.loopit.dk/banding_in_games.pdf
*/
const int NUM_BUCKETS = 32;
const int ITER_PER_BUCKET = 1024;
const float HIST_SCALE = 8.0;

const float NUM_BUCKETS_F = float(NUM_BUCKETS);
const float ITER_PER_BUCKET_F = float(ITER_PER_BUCKET);


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
float truncf( float a, float l )
{
	return floor(a*l)/l;
}

float n1rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	return nrnd0;
}
float n2rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );
	return (nrnd0+nrnd1) / 2.0;
}
float n3rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );
	float nrnd2 = nrand( n + 0.13*t );
	return (nrnd0+nrnd1+nrnd2) / 3.0;
}
float n4rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );	
	float nrnd2 = nrand( n + 0.13*t );
	float nrnd3 = nrand( n + 0.17*t );
	return (nrnd0+nrnd1+nrnd2+nrnd3) / 4.0;
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

float n4rand_inv( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	float nrnd1 = nrand( n + 0.11*t );	
	float nrnd2 = nrand( n + 0.13*t );
	float nrnd3 = nrand( n + 0.17*t );
    float nrnd4 = nrand( n + 0.19*t );
	float v1 = (nrnd0+nrnd1+nrnd2+nrnd3) / 4.0;
    float v2 = 0.5 * remap( 0.0, 0.5, v1 ) + 0.5;
    float v3 = 0.5 * remap( 0.5, 1.0, v1 );
    return (nrnd4<0.5) ? v2 : v3;
}

//alternative Gaussian,
//thanks to @self_shadow
//see http://www.dspguide.com/ch2/6.htm
float n4rand_ss( vec2 n )
{
	float nrnd0 = nrand( n + 0.07*fract( iTime ) );
	float nrnd1 = nrand( n + 0.11*fract( iTime + 0.573953 ) );	
	return 0.23*sqrt(-log(nrnd0+0.00001))*cos(2.0*3.141592*nrnd1)+0.5;
}

/*
//Mouse Y give you a curve distribution of ^1 to ^8
//thanks to Trisomie21
float n4rand( vec2 n )
{
	float t = fract( iTime );
	float nrnd0 = nrand( n + 0.07*t );
	
	float p = 1. / (1. + iMouse.y * 8. / iResolution.y);
	nrnd0 -= .5;
	nrnd0 *= 2.;
	if(nrnd0<0.)
		nrnd0 = pow(1.+nrnd0, p)*.5;
	else
		nrnd0 = 1.-pow(nrnd0, p)*.5;
	return nrnd0; 
}
*/

float histogram( int iter, vec2 uv, vec2 interval, float height, float scale )
{
	float t = remap( interval.x, interval.y, uv.x );
	vec2 bucket = vec2( truncf(t,NUM_BUCKETS_F), truncf(t,NUM_BUCKETS_F)+1.0/NUM_BUCKETS_F);
	float bucketval = 0.0;
	for ( int i=0;i<ITER_PER_BUCKET;++i)
	{
		float seed = float(i)/ITER_PER_BUCKET_F;
		
		float r;
		if ( iter < 2 )
			r = n1rand( vec2(uv.x,0.5) + seed );
		else if ( iter<3 )
			r = n2rand( vec2(uv.x,0.5) + seed );
		else if ( iter<4 )
			r = n4rand( vec2(uv.x,0.5) + seed );
		else
			r = n8rand( vec2(uv.x,0.5) + seed );
		
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
	if ( uv.x < 1.0/4.0 )
	{
		o = n1rand( uv );
        idx = 1;
        uvrange = vec2( 0.0/4.0, 1.0/4.0 );
	}
	else if ( uv.x < 2.0 / 4.0 )
	{
		o = n2rand( uv );
        idx = 2;
        uvrange = vec2( 1.0/4.0, 2.0/4.0 );
	}
	else if ( uv.x < 3.0 / 4.0 )
	{
		o = n4rand( uv );
        idx = 3;
        uvrange = vec2( 2.0/4.0, 3.0/4.0 );
	}
	else
	{
		o = n8rand( uv );
        idx = 4;
        uvrange = vec2( 3.0/4.0, 4.0/4.0 );
	}

    //display histogram
    if ( uv.y < 1.0 / 4.0 )
		o = 0.125 + histogram( idx, uv, uvrange, 1.0/4.0, HIST_SCALE );
    
	//display lines
	if ( abs(uv.x - 1.0/4.0) < 0.002 ) o = 0.0;
	if ( abs(uv.x - 2.0/4.0) < 0.002 ) o = 0.0;
	if ( abs(uv.x - 3.0/4.0) < 0.002 ) o = 0.0;
	if ( abs(uv.y - 1.0/4.0) < 0.002 ) o = 0.0;

	
	fragColor = vec4( vec3(o), 1.0 );
}
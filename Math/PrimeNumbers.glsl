// 3 way to display the distribution of primes

// after "discovering numbers structures through images" by Jean-Paul Delahaye
// in "Pour la Science", French edition of Scientific American, Feb 2014
// http://www.lifl.fr/~delahaye/pls/2014/243.pdf

#define PI 3.14159265359

bool keyToggle(int ascii) {
	return (texture(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

int DISPLAY  = 3; // display method :
					// 1: i = length along a squared spiral 
					// 2: i = length along a squared spiral 
					// 3: i = length along an Archimedial spiral 
	

float isPrime( float x );
float prime (int n) {

#define MODE 3

#if MODE == 0 // the simpler the better... but unrolling kills on windows
	int imax = int(sqrt(float(n)));
	for (int i=2; i<1400; i++ ) {
		if (i>imax) return 1.;
		if ( n-i*(n/i) == 0) return 0.;
	}

#elif MODE == 1  // i^2-i+41  gives primes with 50% probability
	float d = sqrt(1.-4.*(41.-float(n)));
	if (d<0.) return 0.;
	if (fract((1.+sqrt(d))/2.)> 1e-5) return 0.;
	return 1.;
	
#elif MODE == 2 // stochastic test, but needs long longs.
	float err = mod(pow(2.,float(n)-1.),float(n)) - 1.; 
	if (abs(err)> 1e-5) return 0.;
	return 1.;
	
#elif MODE == 3 // IQ compact loop
	return isPrime(float(n));
#endif	
}

float truemod(float x,float y) { float v = mod(x,y); return (v==y)? 0. : v; }

// isPrime:  Created by inigo quilez - iq/2013 https://www.shadertoy.com/view/4slGRH
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Info on prime hunting: http://www.iquilezles.org/blog/?p=1558
float isPrime( float x )
{
	if( x==1. ) return 0.;
	if( x==2. ) return 1.;
	if( x==3. ) return 1.;
	if( x==5. ) return 1.;
	if( x==7. ) return 1.;
	
	if( mod(x,2.)==0. ) return 0.;
	if( mod(x,3.)==0. ) return 0.;
	if( mod(x,5.)==0. ) return 0.;

	float y = 7.;
	bool flip =   true; // (mod(iTime*4.,1.)>.5);
	float xmax = (flip) ? sqrt(x)+1. : x;
	//int max =  (flip) ? 2000:200;

	for( int i=0; i<200; i++ ) // count up to 6000
	{ 
	    // if (i>max) {  return 1.; }
		if( truemod(x,y)==0. )  return 0.;
		y += 4.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 2.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 4.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 2.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 4.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 6.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 2.; if( y>=xmax ) return 1.;
		if( truemod(x,y)==0. )  return 0.;
		y += 6.; if( y>=xmax ) return 1.;
	}
	
	return 1.;
}

// ---------------------------------------------------------

#define myInt(x)  (int(x)+(((x)<0.)?0:1) )
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float zoom = (keyToggle(32)) ? 1. : clamp(.5*(1.-cos(iTime)),0.,1.);
	DISPLAY = 1;//+int(mod(iTime/(2.*PI),3.));
	
	vec2 uv;
	uv.x = float(int(fragCoord.x)-int(iResolution.x/2.))*zoom;
	uv.y = float(int(fragCoord.y)-int(iResolution.y/2.))*zoom;
	int i;	
	
	if (DISPLAY == 1) 
	{ 						// i = col + line*WIDTH
		uv += iResolution.xy/2.;
		i = int(uv.x)+int(iResolution.x)*int(uv.y);
	}
	else if (DISPLAY == 2) 
	{ 						 // i = length along a squared spiral 
		int   x = myInt(uv.x),
			  y = myInt(uv.y);
		float ax = abs(float(x)),
			  ay = abs(float(y));
		int   r = int (max(ax,ay));
		int quadran = ( ax > ay ) ? ( (x>0) ? 1 : 3 ) : ( (y>0) ? 2 : 4 );
		
		i = (r-1)*r; 
		if      (quadran==1) i +=                 r+y;     // right
		else if (quadran==2) i += 2*r           + r-x;     // top
		else if (quadran==3) i += 4*(r-1)       + r-y;     // left
		else                 i += 4*(r-1) + 2*r + r+x;     // bottom
		//fragColor = vec4(mod(float(i),2.)); return;	
		//fragColor = vec4(float(i)/40000.); return;	
	}	
	else 
	{ 						//  i = length along an Archimedial spiral 
#       define RAD 1. // 4. // zoom
    	float r = length(uv)/RAD, a = atan(uv.y, uv.x),
	  		  s = r - a/(2.*PI),
	    	  t = floor(s)+a/(2.*PI), // turns
			  l = t*t;// int (a/2PI da)
		//fragColor = vec4(sin(2.*PI*s)); return;
		//fragColor = vec4(sin(l/4.))+vec4(max(0.,sin(s)),0.,0.,0.);return;
 		i = int(l);
	}

		fragColor = vec4(prime(i));
}
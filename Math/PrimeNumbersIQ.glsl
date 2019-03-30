// 4slGRH
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.



// Info on prime hunting:   http://www.iquilezles.org/blog/?p=1558


bool isPrime( int x )
{
	if( x==1 ) return false;
	if( x==2 ) return true;
	if( x==3 ) return true;
	if( x==5 ) return true;
	if( x==7 ) return true;
	if( (x&1)==0 ) return false;
	if( (x%3)==0 ) return false;
	if( (x%5)==0 ) return false;

    int xm = 1 + int(sqrt(float(x)));
    
	int y = 7;
	for( int i=0; i<200; i++ ) // count up to 6000
	{
		         if( (x%y)==0 ) return false;
		y += 4;  if( y>=xm    ) return true;
		         if( (x%y)==0 ) return false;
		y += 2;  if( y>=xm )    return true;
		         if( (x%y)==0 ) return false;
		y += 4;  if( y>=xm )    return true;
		         if( (x%y)==0 ) return false;
		y += 2;  if( y>=xm )    return true;
		         if( (x%y)==0 ) return false;
		y += 4;  if( y>=xm )    return true;
		         if( (x%y)==0 ) return false;
		y += 6;  if( y>=xm )    return true;
		         if( (x%y)==0 ) return false;
		y += 2;  if( y>=xm )    return true;
		         if( (x%y)==0 ) return false;
		y += 6;  if( y>=xm )    return true;
	}
	
	return true;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float s = 0.55 + 0.45*cos(6.2831*iTime/10.0);
    
	vec3 col = vec3(0.0);
    
    int y = int( floor(s* fragCoord.y) );
    int o = int( floor(s*(fragCoord.x - iResolution.x/2.0)) );
    
	if( abs(o)<=y )
	{
        int n = y*y + y + o + 1;
        
	    float f = (isPrime(n)) ? 1.0 : 0.15;
	    col = vec3( f*0.25,f,0.0);
	}
	
	fragColor = vec4( col, 1.0 );
}

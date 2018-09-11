// Du Note: Virdis is preferred for most of the time.
vec3 fromRedToGreen( float interpolant )
{
 	if( interpolant < 0.5 )
    {
       return vec3(1.0, 2.0 * interpolant, 0.0); 
    }
    else
    {
        return vec3(2.0 - 2.0 * interpolant, 1.0, 0.0 );
    }
}


vec3 fromGreenToBlue( float interpolant )
{
   	if( interpolant < 0.5 )
    {
       return vec3(0.0, 1.0, 2.0 * interpolant); 
    }
    else
    {
        return vec3(0.0, 2.0 - 2.0 * interpolant, 1.0 );
    }  
}

vec3 heat5( float interpolant )
{
    float invertedInterpolant = interpolant;
 	if( invertedInterpolant < 0.5 )
    {
        float remappedFirstHalf = 1.0 - 2.0 * invertedInterpolant;
        return fromGreenToBlue( remappedFirstHalf );
    }
    else
    {
     	float remappedSecondHalf = 2.0 - 2.0 * invertedInterpolant; 
        return fromRedToGreen( remappedSecondHalf );
    }
}

vec3 heat7( float interpolant )
{
 	if( interpolant < 1.0 / 6.0 )
    {
        float firstSegmentInterpolant = 6.0 * interpolant;
        return ( 1.0 - firstSegmentInterpolant ) * vec3(0.0, 0.0, 0.0) + firstSegmentInterpolant * vec3(0.0, 0.0, 1.0);
    }
    else if( interpolant < 5.0 / 6.0 )
    {
        float midInterpolant = 0.25 * ( 6.0 * interpolant - 1.0 );
        return heat5( midInterpolant );
    }
    else
    {
    	float lastSegmentInterpolant = 6.0 * interpolant - 5.0; 
        return ( 1.0 - lastSegmentInterpolant ) * vec3(1.0, 0.0, 0.0) + lastSegmentInterpolant * vec3(1.0, 1.0, 1.0);
    }
}
   

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    float interpolant = uv.x;
     
    if( uv.y < 0.33 )
       fragColor = (1.0 - interpolant) * vec4(0.0, 0.0, 1.0, 0.0) + interpolant * vec4(1.0, 0.0, 0.0, 0.0);
    else if( uv.y < 0.66 )
        fragColor = vec4(heat5(interpolant), 0.0);
    else
        fragColor = vec4(heat7(interpolant), 0.0);
            
}
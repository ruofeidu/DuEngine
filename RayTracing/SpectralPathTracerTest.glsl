// Spectral Path Trace Test Scene - @P_Malin
// https://www.shadertoy.com/view/4s3cRr
//
// #define options in Buf B (various scenes)
//
// Naïve Monte Carlo spectral path tracer. Slow to converge but fun
// WASD, mouse & QE to move camera
// Features:
// Absorption
// Scattering
// Fresnel Reflection
// Transparency, refraction & chromatic dispersion
// Bloom
// Depth of field (shaped bokeh & bokeh barrel masking)

vec3 Tonemap( vec3 x )
{
    float a = 0.010;
    float b = 0.132;
    float c = 0.010;
    float d = 0.163;
    float e = 0.101;

    return ( x * ( a * x + b ) ) / ( x * ( c * x + d ) + e );
}

vec3 ApplyGrain( vec2 vPos, vec3 col, float amount )
{
    uint seed = uint( iTime * 213.456 ) * 12345u + uint(vPos.x) * 1256u + uint(vPos.y) * 432u;
    seed = HashWang( seed );    
    
    float h = FRand( seed );
    
    col *= (h * 2.0 - 1.0) * amount + (1.0f -amount);
    
    return col;
}

vec3 ColorGrade( vec3 vColor )
{
    vec3 vHue = vec3(1.0, .7, .2);
    
    vec3 vGamma = 1.0 + vHue * 0.6;
    vec3 vGain = vec3(.9) + vHue * vHue * 8.0;
    
    vColor *= 1.5;
    
    float fMaxLum = 100.0;
    vColor /= fMaxLum;
    vColor = pow( vColor, vGamma );
    vColor *= vGain;
    vColor *= fMaxLum;
    return vColor;
}

vec3 SampleImage( ivec2 vPos )
{
    vec4 vSample = texelFetch( iChannel0, vPos, 0 );
	vec3 vColor = vSample.rgb / vSample.a;
	return vColor;
}

void Sort( inout vec4 a, inout vec4 b )
{
    if ( a.w > b.w )
    {
        vec4 temp = a;
        a = b;
        b = temp;
    }
}

vec4 Median9( vec4 values[9] )
{
    for ( int j=8; j>0; j-- )
    {
        for ( int i=0; i<j; i++ )
        {
		    Sort( values[i], values[i+1] );
        }
    }

    return values[4];
}

vec3 FilterImage( ivec2 vPos )
{
    return SampleImage(vPos);
    
    const int sampleCount = 9;
    
    vec4 vSamples[sampleCount];
    
    for ( int sampleIndex=0; sampleIndex < sampleCount; sampleIndex++)
    {
        int dx = (sampleIndex % 3) -1;
        int dy = (sampleIndex / 3) - 1;
        vec3 vCol = SampleImage(vPos + ivec2(dx,dy) );
        vSamples[sampleIndex] = vec4( vCol, dot( vCol, vec3(0.3) ) );
    }
        
    vec4 vResult = Median9( vSamples );
    
    return vResult.rgb;
}

void mainImage( out vec4 vFragColor, in vec2 vFragCoord )
{
    vec2 vUV = vFragCoord.xy / iResolution.xy;
    vec3 vColor = FilterImage( ivec2(vFragCoord) );
    
    //vFragColor = sqrt( 1.0 - exp2( vFragColor * -0.2 ) );
    
#if 1    
    //if ( vUV.x > sin(iTime)*0.5+0.5 )
    {
    	vColor = ColorGrade( vColor );
    }
    
	//vColor = ApplyGrain( vFragCoord.xy, vColor, 0.15 );          
#endif
    
    vColor = Tonemap( vColor * .5 );
    
    vFragColor = vec4( vColor, 1.0 );
}
// https://www.shadertoy.com/view/XstGRf
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

float hash1( float n )
{
    return fract(sin(n)*138.5453123);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4( texelFetch( iChannel0, ivec2(fragCoord), 0 ).xxx, 1.0 );
	
	//float f = step(0.5, hash1(fragCoord.x*13.0+hash1(fragCoord.y*71.1)));
	//fragColor.r = f; 
}
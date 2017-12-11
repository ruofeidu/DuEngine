
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0


// Conway's Game of Life - http://www.iquilezles.org/www/articles/gameoflife/gameoflife.htm
//
// State based simulation. Buffer A contains the simulated world, and it reads and writes to
// itself to perform the simulation.
//
// I implemented three variants of the algorithm with different interpretations

// VARIANT = 0: traditional
// VARIANT = 1: box fiter
// VARIANT = 2: high pass filter

#define VARIANT 0


int Cell( in ivec2 p )
{
    // do wrapping
    ivec2 r = ivec2(textureSize(iChannel0, 0));
    p = (p+r) % r;
    
    // fetch texel
    return (texelFetch(iChannel0, p, 0 ).x > 0.5 ) ? 1 : 0;
}

float hash1( float n )
{
    return fract(sin(n)*138.5453123);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    ivec2 px = ivec2( fragCoord );
    
#if VARIANT==0
	int k =   Cell(px+ivec2(-1,-1)) + Cell(px+ivec2(0,-1)) + Cell(px+ivec2(1,-1))
            + Cell(px+ivec2(-1, 0))                        + Cell(px+ivec2(1, 0))
            + Cell(px+ivec2(-1, 1)) + Cell(px+ivec2(0, 1)) + Cell(px+ivec2(1, 1));

    int e = Cell(px);

    float f = ( ((k==2)&&(e==1)) || (k==3) ) ? 1.0 : 0.0;
    
#endif
    
#if VARIANT==1
	int k = Cell(px+ivec2(-1,-1)) + Cell(px+ivec2(0,-1)) + Cell(px+ivec2(1,-1))
          + Cell(px+ivec2(-1, 0)) + Cell(px            ) + Cell(px+ivec2(1, 0))
          + Cell(px+ivec2(-1, 1)) + Cell(px+ivec2(0, 1)) + Cell(px+ivec2(1, 1));

    int e = Cell(px);

    float f = ( ((k==4)&&(e==1)) || (k==3) ) ? 1.0 : 0.0;
    
#endif

    
#if VARIANT==2
	int k = -Cell(px+ivec2(-1,-1)) -   Cell(px+ivec2(0,-1)) - Cell(px+ivec2(1,-1))
            -Cell(px+ivec2(-1, 0)) + 8*Cell(px)           - Cell(px+ivec2(1, 0))
            -Cell(px+ivec2(-1, 1)) -   Cell(px+ivec2(0, 1)) - Cell(px+ivec2(1, 1));

    float f = (abs(k+3)*abs(2*k-11)<=9) ? 1.0 : 0.0;
    
    
#endif
    
    if( iFrame < 4 ) f = step(0.5, hash1(fragCoord.x*13.0+hash1(fragCoord.y*71.1)));
	
	fragColor = vec4( f, 0.0, 0.0, 0.0 );
}
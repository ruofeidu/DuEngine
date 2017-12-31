// "[SH17A] Fireworks" by Martijn Steinrucken aka BigWings/Countfrolic - 2017
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Based on https://www.shadertoy.com/view/lscGRl

// Greg Rostami & FabriceNeyret2 version -> 265 chars 
#define N(h) fract(sin(vec4(6,9,1,0)*h) * 9e2) 
#define mainImage(o,U)													\
    vec2 u = U/iResolution.y;											\
    float e, d, i=-2.;													\
    for(vec4 p; i++<9.; d = floor(e = i*9.1+iTime),p = N(d)+.3, e -= d)	\
        for(d=0.; d++<50.;)												\
            o += p*(1.-e) / 1e3 / length(u-(p-e*(N(d*i)-.5)).xy);		\
    u.y<N(ceil(u.x*i+d+e)).x*.4 ? o-=o*u.y : o

/* //Original version, 278 chars
#define N(h) fract(sin(vec4(6,9,1,0)*h) * 9e2) 
void mainImage(out vec4 o,vec2 u )
{
    o-=o; 
    
    u /= iResolution.y;
    
    float e, d, i=-2.; 
    
    for(vec4 p; i++<9.; d = floor(e = i*9.1+iTime),p = N(d)+.3, e -= d)
        for(d=0.; d++<50.;)
            o += p*(1.-e) / 1e3 / length(u-(p-e*(N(d*i)-.5)).xy);  

    if(u.y<N(ceil(u.x*i+d+e)).x*.4) o-=o*u.y;
}
*/

/*
EXPLANATION OF HOW THIS WORKS


// turns 1 float into a pseudo random vec4 in the 0-1 range
#define N(h) fract(sin(vec4(6,9,1,0)*h) * 9e2) 

void mainImage(out vec4 o,vec2 u )
{
    //initialize o to 0,0,0,0 in the shortest way possible
    // o is what will hold the final pixel color
    o-=o; 
    
    // divide the uv pixel coordinates by the height to get aspect corrected 0-1 coords
    u /= iResolution.y;
    
    // loop iterator defined here because it saves characters
    // starts at -2 so it goes through 0, which gives the occasional rocket
    float e, d, i=-2.; 
    
    // outer loop, defines number of simultaneous explosions
    // other var assignments inside of the for statement which 
    // saves chars on brackets around the for loop
    // i++<9 which saves the i++; that usually goes at the end of the for
    for(vec4 p; i++<9.; 
        // e = the time since the shader started + an offset per explosion
        // d = the floored version of that, which stays the same for a second, then jumps
        d = floor(e = i*9.1+iTime),
        // the position of the explosion, as well as the color
        // which is a pseudo random number made by throwing a large number into a sine function
        // +.3 so the explosions are centered horizontally (because aspect ratio of screen)
        p = N(d)+.3, 
        // turn e into the fractional component of time e.g. 10.546 -> 0.546
        e -= d)
        // inner loop, renders the particles in the explosion
        for(d=0.; d++<50.;)
            // add to final pixel col
            // p = the color, 1.-e is a number that starts at 1 and goes to 0 
            // over the duration of the explosion, essentially fading the particle
            o += p*(1.-e) 
            // divide by 1000, otherwise the pixel colors will get too bright
            / 1e3 
            // divide by the distance to the particle, the farther away, the darker
            // note that this never gets to 0, each tiny particle has an effect over the
            // entire screen
            // dist to particle is the length of the vector from the current uv coordinate (u)
            // to the particle pos (p-e*(N(d*i)-.5)).xy
            // particle pos starts at p, when e is 0
            // N(d*i) gives a pseudo random vec4 in 0-1 range
            // d*i to give different vec4 for each particle
            // *i is not really necessary but when i=0 it gives 0 for the whole vec4
            // which makes the appearance of the occasional rocket
            // N(d*i)-.5 to go from 0-1 range to -.5 .5 range
            / length(u-(p-e*(N(d*i)-.5)).xy);  

   // draw skyline
   // uv.x goes from 0 to 1.6  *i to make it larger i=9. (save a char cuz 9. is 2 chars)
   // +d+e   d+e = iTime  -> this will make the skyline scroll
   // ceil to go in steps (stay at one height, then jump to the next)
   // N(..) to make a value 0, 1, 2, 3.. etc into random numbers in 0-1 range
   // .x*4   N returns a vec4, but we only need a float, *.4 so buildings are lower
   // o -= o*u.y   o-=o would make the buildings pitch black, *u.y to fade them towards the 
   // bottom, creating a bit of a fog effect     
   if(u.y<N(ceil(u.x*i+d+e)).x*.4) o-=o*u.y;
}

*/
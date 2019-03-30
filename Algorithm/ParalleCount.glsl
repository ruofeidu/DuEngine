// https://www.shadertoy.com/view/ltsBzr
// https://en.wikipedia.org/wiki/Prefix_sum
// http://www.seas.upenn.edu/~cis565/Lectures2011/Lecture12.pdf

void mainImage( out vec4 O, vec2 U )
{
  //O = texelFetch(iChannel0,ivec2(U.x/1.,0),0);
    O = texelFetch(iChannel0,ivec2(U/1.),0);
    //O.g /= iResolution.x/100.; 
    
    O = O.r==1. 
            ? vec4(1)
            : .3+.3*cos(1.8138*O.g+vec4(0,-2.1,2.1,0));
}

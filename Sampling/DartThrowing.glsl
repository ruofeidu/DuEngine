// https://www.shadertoy.com/view/ltlfRl
void mainImage( out vec4 O, vec2 U )
{
    O = texelFetch(iChannel0, ivec2(U), 0);
  //O = O.g > 0. ? vec4(1) : O.b == 0. ? vec4(0) : .6 + .6 * cos( 6.3*O.b + vec4(0,23,21,0));
}
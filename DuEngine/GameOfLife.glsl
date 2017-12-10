// https://www.shadertoy.com/view/XstGRf
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = vec4( texelFetch( iChannel0, ivec2(fragCoord), 0 ).xxx, 1.0 );
}
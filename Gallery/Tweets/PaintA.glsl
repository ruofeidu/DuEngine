// https://www.shadertoy.com/view/XsBBRw
#define T(u) texelFetch(iChannel0,ivec2(u),0)

void mainImage( out vec4 o, vec2 s )
{
    o = T(s);
    
    o = s.x+s.y > 1. ?
   			s.x < 32. ?
            	step(.5,fract(s.y/vec4(64,128,256,1)))
            :
    			mix(T(0),o,min(1.,length(s-iMouse.xy)/8.))
        :
    		iMouse.x < 32. ?
                T(iMouse.xy)
            :
    			o;
}
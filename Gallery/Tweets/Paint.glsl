// https://www.shadertoy.com/view/XsBBRw
#define mainImage(o,u) o = 1.-texelFetch(iChannel0, ivec2(u) ,0)
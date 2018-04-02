// 
#define mainImage(O,u)               /*  6. / vec2(1.5,1) */                 \
    vec2 U = abs( fract( u/iResolution.y* vec2(4,6) * mat2(1,-1,1,1) ) - .5);\
    O += .3 - cos ( 19.*max(U.x,U.y)  + texture(iChannel0,U).r )
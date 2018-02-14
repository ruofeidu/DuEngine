// https://www.shadertoy.com/view/4tlBWB
vec3 classic_hsv2rgb(vec3 c)
{
    const vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
    // golfed version:
    return c.z*(1.-c.y + c.y*clamp(abs(mod(c.x*6.+vec3(0,4,2),6.) -3.) - 1., 0., 1.));
}

vec3 smooth_hsv2rgb(vec3 c)  // same of above replacing clamp by smoothstep 
{
    return c.z*(1.-c.y*smoothstep(2.,1.,abs(mod(c.x*6.+vec3(0,4,2),6.) -3.)));
}

vec3 cosine_hsv2rgb(vec3 c)  // golfed version: https://www.shadertoy.com/view/ll2cDc
{ 
    // variant 1: exactly saturating 0-1 range; constant luminance; not fully saturated colors
    return  c.z*(1.-c.y*(1. - (.5 + .5 * cos( 6.2832*( c.x  + vec3(0,2./3.,1./3.) ) ) ) ) );
    // variant 2: more vivid colors; 20% more contrast, some overshoot
    return  c.z*(1.-c.y*(1. - (.6 + .6 * cos( 6.2832*( c.x  + vec3(0,2./3.,1./3.) ) ) ) ) );
    // variant 3: 20% more contrast + clamp: luminance not strictly constant
    return  c.z*(1.-c.y*(1. - clamp(.6 + .6 * cos( 6.2832*( c.x  + vec3(0,2./3.,1./3.) ) ), 0., 1. ) ) );
    // golfed variant (hue only) : ( https://www.shadertoy.com/view/ll2cDc )}
    return .6 + .6 * cos( 6.3 *  c.x  + vec3(0,23,21)  ); 
}

void mainImage(out vec4 O, vec2 U) {
    vec2 R = iResolution.xy; 
    float x = U.x/R.x, y = 3.*U.y/R.y;
    vec3 hsv = vec3(x,1,1);
    O.rgb =   y > 2. ? classic_hsv2rgb(hsv)
            : y > 1. ?  smooth_hsv2rgb(hsv)
                     :  cosine_hsv2rgb(hsv);
    y = fract(y);
    O =   y > .4 ? O *=  smoothstep(0., 3./R.y/.6, abs(O-(y-.4)/.6) ) // curves
        : y > .2 ? vec4((O.r+O.g+O.b)/3.)                             // flat luminance
                 : vec4(length(O.rgb)/sqrt(3.));                      // sRGB luminance	
#if 0                                             // check under/overshoot
    if (max(O.r,max(O.g,O.b))>1.) O = vec4(1);  
    if (min(O.r,min(O.g,O.b))<0.) O-=O;
#endif
}

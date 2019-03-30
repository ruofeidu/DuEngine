// https://www.shadertoy.com/view/MlcGD7
// see also full black body spectrum: https://www.shadertoy.com/view/4tdGWM
// deeper in fluids: https://www.shadertoy.com/view/XldGDM

void mainImage( out vec4 O,  vec2 U )
{
    U /= iResolution.xy;
    float y = 2.* U.y; 
    
    O = 
    // secret 1 for natural colors for luminous phenomena:
    // - real-life color spectrum is never zero in any channel
    // - intensities are 0 to infinity
    // - captors (camera,eye) saturates early
	y > 1. ? vec4(1,1./4.,1./16.,1) * exp(4.*U.x - 1.)  // i.e. exp(T) * exp(-z)

    // secret 2 for natural colors for volumetric phenomena:
    // - transparency decrease as the power of distance ( T^l )
    // - T value varies with frequency ( i.e. color channel )
    // - real life transparency is never exactly 1 at any frequency
   : pow(vec4(.1, .7, .8, 1), vec4(4.*U.x));
        
    
}

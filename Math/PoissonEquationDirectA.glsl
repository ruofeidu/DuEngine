// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XstczN
//#define SCALING (iResolution.y*iResolution.y)
//#define SCALING (2.*iResolution.y)
//#define SCALING iResolution.y
#define SCALING 1.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    ivec2 ifragCoord = ivec2(floor(fragCoord));
    
    if(ifragCoord.y != 0)
    {
        fragColor = vec4(0.);
        return;
    }
    
    vec4 val = texelFetch(iChannel0, ifragCoord,0);
    
    
    if(iFrame < 2)
    {
        //val.x = 0.;
        val.x = 0.5+0.2*sin(10.*fragCoord.x/iResolution.x);
        val.x *= SCALING;
    }
    
    //*
    if(iMouse.z>.5 && val.w<.5 && int(iMouse.x) == ifragCoord.x)
    {
        val.x = iMouse.y/iResolution.y;
        val.x *= SCALING;
    }
    //*/
    
    if(iMouse.z>.5 && val.w>.5)
    {
        float t = (fragCoord.x - val.y)/(iMouse.x - val.y);
        if(0.<t && t<1.)
            //val.x = mix(val.z/iResolution.y, iMouse.y/iResolution.y, t);
            val.x = mix(val.z/iResolution.y*SCALING, iMouse.y/iResolution.y*SCALING, t);
    }
    
    fragColor = vec4(val.x , iMouse.xyz);
    
    
    
    
    /*
    float xx = fragCoord.x/iResolution.x;
    float xval = -xx * (xx+3.) * exp(xx);
    
    fragColor = vec4(xval);
	//*/
}
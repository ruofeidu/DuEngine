// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XscczN

float valO(int n)
{
    return texelFetch(iChannel0, ivec2(n, 0),0).r;
}

float valR(int n)
{
    return texelFetch(iChannel1, ivec2(n, 0),0).r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    ivec2 ifragCoord = ivec2(floor(fragCoord));
    
    if(ifragCoord.y != 0)
    {
        fragColor = vec4(0.);
        return;
    }
    
    int x = ifragCoord.x;
    float F = valO(x);
    
    if(ifragCoord.x == 0 || ifragCoord.x == int(iResolution.x)-1)
    {
        float U = valO(x);
        fragColor = vec4(U, 0., 0., 0.);
        return;
    }
    
    float Up = valR(x+1);
    float Um = valR(x-1);
    
    float U = (F+(Up+Um))/2.;
    
    /*
    if(iFrame < 2)
    {
        U = 0.;
    }
	//*/
    
    fragColor = vec4(U, 0., 0., 0.);
    
    
    
    /*
    float xx = fragCoord.x/iResolution.x;
    float xval = xx * (xx-1.) * exp(xx);
    
    fragColor = vec4(xval);
	//*/
}
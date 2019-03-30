// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XscczN
#define BG_COLOR vec3(.9)
#define FG_COLOR_1 vec3(.6, .6, .8)
#define FG_COLOR_2 vec3(.8, .6, .6)
#define FG_COLOR_3 vec3(.6,.8,  .6)
#define ST_COLOR_1 vec3(.1, .1, .2)
#define ST_COLOR_2 vec3(.2, .1, .1)
#define ST_COLOR_3 vec3(.1,.2,  .1)

float PointSegDistance(vec2 p, vec2 a, vec2 b)
{
	vec2 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

float valO(int n)
{
    return texelFetch(iChannel0, ivec2(n, 0),0).r;
}

float valR(int n)
{
    return texelFetch(iChannel1, ivec2(n, 0),0).r;
}

float LvalR(int n)
{    
    return (2.*valR(n) - valR(n+1) - valR(n-1));
}

float val(int n)
{
    //return -valO(n)/12.;
    //return -LvalR(n)/12.;
    //return -valR(n);
    
    
    return valO(n);
    return LvalR(n);
    //return valR(n);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    int x = int(fragCoord.x);
    float dx = 1./iResolution.x;
    float v = valO(x);
    vec2 p  = vec2(uv.x   , v       );
    vec2 pp = vec2(uv.x+dx, valO(x+1));
    vec2 pm = vec2(uv.x-dx, valO(x-1));
    
    //*
    if(x == 0)
        pm = pp;
    
    if(x == int(iResolution.x)-1)
        pp = pm;
	//*/
        
    float dp = min(PointSegDistance(uv,p, pp),PointSegDistance(uv,p, pm));
    
    float stroke_alpha = clamp(mix(1., 0., dp * iResolution.y), 0., 1.);
    float bg_alpha = clamp((v-uv.y)* iResolution.y, -1., 1.)*.5+.5;
    
    
    vec3 c = mix(BG_COLOR, FG_COLOR_1, bg_alpha*.5);
    c = mix(c, ST_COLOR_1, stroke_alpha);
    
    
    
    v = LvalR(x);
    p  = vec2(uv.x   , v       );
    pp = vec2(uv.x+dx, LvalR(x+1));
    pm = vec2(uv.x-dx, LvalR(x-1));
    
    //*
    if(x == 0)
        pm = pp;
    
    if(x == int(iResolution.x)-1)
        pp = pm;
	//*/
        
    dp = min(PointSegDistance(uv,p, pp),PointSegDistance(uv,p, pm));
    
    stroke_alpha = clamp(mix(1., 0., dp * iResolution.y), 0., 1.);
    bg_alpha = clamp((v-uv.y)* iResolution.y, -1., 1.)*.5+.5;
    
    c = mix(c, FG_COLOR_2, bg_alpha*.5);
    c = mix(c, ST_COLOR_2, stroke_alpha);
    
    
    
    
    
    v = abs(LvalR(x) - valO(x));
    p  = vec2(uv.x   , v       );
    pp = vec2(uv.x+dx, abs(LvalR(x+1) - valO(x+1)));
    pm = vec2(uv.x-dx, abs(LvalR(x-1) - valO(x-1)));
    
    //*
    if(x == 0)
        pm = pp;
    
    if(x == int(iResolution.x)-1)
        pp = pm;
	//*/
        
    dp = min(PointSegDistance(uv,p, pp),PointSegDistance(uv,p, pm));
    
    stroke_alpha = clamp(mix(1., 0., dp * iResolution.y), 0., 1.);
    bg_alpha = clamp((v-uv.y)* iResolution.y, -1., 1.)*.5+.5;
    
    c = mix(c, FG_COLOR_3, bg_alpha*.5);
    c = mix(c, ST_COLOR_3, stroke_alpha);
    
    
    fragColor = vec4(c, 1.0);
}

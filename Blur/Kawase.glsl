
void reSample(in int d, in vec2 uv, inout vec4 fragColor)
{
 
    vec2 step1 = (vec2(d) + 0.5) / iResolution.xy;
    
    fragColor += texture(iChannel0, uv + step1) / float(4);
    fragColor += texture(iChannel0,  uv - step1) / float(4);
  	vec2 step2 = step1;
    step2.x = -step2.x;
    fragColor += texture(iChannel0, uv + step2) / float(4);
    fragColor += texture(iChannel0,  uv - step2) / float(4);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 pixelSize = vec2(1.0) / iResolution.xy;
    vec2 halfSize = pixelSize / vec2(2.0);
    
    vec4 color = vec4(0);

    float xvalue = iMouse.x / iResolution.x;
    
    if(uv.x > xvalue)
    {
        reSample(3, uv, color);
    }
    else
    {
        color = texture(iChannel1, uv);
    }
    
    if(abs(uv.x - xvalue) < 0.002)
        color = vec4(0.0);

    
    fragColor = color;
}

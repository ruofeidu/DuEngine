
void reSample(in int d, in vec2 uv, out vec4 fragColor)
{
 
    vec2 step1 = (vec2(d) + 0.5) / iResolution.xy;
    vec4 color = vec4(0);
    color += texture(iChannel0, uv + step1) / float(4);
    color += texture(iChannel0,  uv - step1) / float(4);
  	vec2 step2 = step1;
    step2.x = -step2.x;
    color += texture(iChannel0, uv + step2) / float(4);
    color += texture(iChannel0,  uv - step2) / float(4);
    fragColor = color;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy/ iResolution.xy ;
    reSample(2, uv, fragColor);
}
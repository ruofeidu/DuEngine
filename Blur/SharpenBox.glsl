// https://www.shadertoy.com/view/Mt2GRD
vec3 Filter(vec2 uv, vec3 color, float strength)
{
    vec3 col = vec3(0.0,0.0,0.0);
 
    col += texture(iChannel0, uv + vec2(-1.0 / iResolution.x, -1.0 / iResolution.y)).rgb;
    col += texture(iChannel0, uv + vec2(1.0 / iResolution.x, 1.0 / iResolution.y)).rgb;     
    col += texture(iChannel0, uv + vec2(-1.0 / iResolution.x, 1.0 / iResolution.y)).rgb;      
    col += texture(iChannel0, uv + vec2(1.0 / iResolution.x, -1.0 / iResolution.y)).rgb;     
    col += texture(iChannel0, uv + vec2(0.0 / iResolution.x, 0.0 / iResolution.y)).rgb*strength;
    col += texture(iChannel0, uv + vec2(-1.0 / iResolution.x, 0.0 / iResolution.y)).rgb;
    col += texture(iChannel0, uv + vec2(1.0 / iResolution.x, 0.0 / iResolution.y)).rgb;     
    col += texture(iChannel0, uv + vec2(0.0 / iResolution.x, -1.0 / iResolution.y)).rgb;      
    col += texture(iChannel0, uv + vec2(0.0 / iResolution.x, 1.0 / iResolution.y)).rgb;           
    col /= (8.0+strength);      
      

  	return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    uv.y = 1.-uv.y;
	vec3 color = texture(iChannel0,uv).rgb;
    
    if(uv.x < 0.33)
    {
		color.rgb = Filter(uv, color, -15.0);
    }
    else if(uv.x > 0.33 && uv.x < 0.34 || uv.x > 0.66 && uv.x < 0.67)
    {
        color.rgb = vec3(0.0,0.0,0.0);
    }
    else if(uv.x > 0.67)
    {
        color.rgb = Filter(uv, color, 1.0);
    }
	fragColor = vec4(color.rgb, 1.0);
}

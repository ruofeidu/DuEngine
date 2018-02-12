// 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    
    uv.x = mod( uv.x * 2.0, 1.0 );
    
    uv = uv * (0.6 + 0.4 * sin(iTime * 0.5));
    
	vec2 step = 1.0 / iResolution.xy;
	
	vec3 texA = texture( iChannel0, uv + vec2(-step.x, -step.y) * 1.5 ).rgb;
	vec3 texB = texture( iChannel0, uv + vec2( step.x, -step.y) * 1.5 ).rgb;
	vec3 texC = texture( iChannel0, uv + vec2(-step.x,  step.y) * 1.5 ).rgb;
	vec3 texD = texture( iChannel0, uv + vec2( step.x,  step.y) * 1.5 ).rgb;
   
    vec3 around = 0.25 * (texA + texB + texC + texD);
	vec3 center  = texture( iChannel0, uv ).rgb;
	
	float sharpness = 1.0;
	
    if( fragCoord.x / iResolution.x < 0.5 )
        sharpness = 0.0;
    
	vec3 col = center + (center - around) * sharpness;
	
    fragColor = vec4(col,1.0);
}

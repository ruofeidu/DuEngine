// ltjyDK
float greyScale(in vec3 col) 
{
    return dot(col, vec3(0.3, 0.59, 0.11));
}

void mainImage( out vec4 O, in vec2 U )
{
    // U = fragCoord
    float boost = 1.5; 
    float reduction = 4.0;
    //float boost = iMouse.x < 0.01 ? 1.5 : iMouse.x / iResolution.x * 2.0; 
    //float reduction = iMouse.y < 0.01 ? 2.0 : iMouse.y / iResolution.y * 4.0; 
	vec2 uv = U / iResolution.xy;
    vec3 col = texture(iChannel0, uv).rgb;
    float vignette = distance( iResolution.xy * 0.5, U ) / iResolution.x;
    vec3 grey = vec3(greyScale(col)); 
    col = mix(grey, col, clamp(boost - vignette * reduction, 0.0, 1.0));
	O = vec4(col, 1.0);
}

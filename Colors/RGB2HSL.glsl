// Created by Pol Jeremias - poljere/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

vec3 rgb2hsl( in vec3 c )
{
    const float epsilon = 0.00000001;
    float cmin = min( c.r, min( c.g, c.b ) );
    float cmax = max( c.r, max( c.g, c.b ) );
	float cd   = cmax - cmin;
    vec3 hsl = vec3(0.0);
    hsl.z = (cmax + cmin) / 2.0;
    hsl.y = mix(cd / (cmax + cmin + epsilon), cd / (epsilon + 2.0 - (cmax + cmin)), step(0.5, hsl.z));
    
    // Special handling for the case of 2 components being equal and max at the same time,
    // this can probably be improved but it is a nice proof of concept
    vec3 a = vec3(1.0 - step(epsilon, abs(cmax - c)));
    a = mix(vec3(a.x, 0.0, a.z), a, step(0.5, 2.0 - a.x - a.y));
    a = mix(vec3(a.x, a.y, 0.0), a, step(0.5, 2.0 - a.x - a.z));
    a = mix(vec3(a.x, a.y, 0.0), a, step(0.5, 2.0 - a.y - a.z));
    
    hsl.x = dot( vec3(0.0, 2.0, 4.0) + ((c.gbr - c.brg) / (epsilon + cd)), a );
    hsl.x = (hsl.x + (1.0 - step(0.0, hsl.x) ) * 6.0 ) / 6.0;
    return hsl;
}

vec3 rgb2hsl_branches( in vec3 c )
{
    const float epsilon = 0.00000001;
    vec3 hsl = vec3(0.0);
	float cmin = min( c.r, min( c.g, c.b ) );
	float cmax = max( c.r, max( c.g, c.b ) );
	hsl.z = ( cmax + cmin ) / 2.0;
	if ( cmax > cmin ) 
    {
		float cdelta = cmax - cmin;
        
        hsl.y = hsl.z < 0.5 ? cdelta / ( epsilon + cmax + cmin) : cdelta / ( epsilon + 2.0 - ( cmax + cmin ) );
        
		if ( c.r == cmax ) 
        {
			hsl.x = ( c.g - c.b ) / (epsilon + cmax - cmin);
		} 
        else if ( c.g == cmax ) 
        {
			hsl.x = 2.0 + ( c.b - c.r ) / (epsilon + cmax - cmin);
		} 
        else 
        {
			hsl.x = 4.0 + ( c.r - c.g ) / (epsilon + cmax - cmin);
		}

	    if ( hsl.x < 0.0)
        {
			hsl.x += 6.0;
		}
		hsl.x = hsl.x / 6.0;
	}
    
	return hsl;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    // Generate RGB color
    vec3 rgb = vec3(0.2 * (0.5+0.5*sin(iTime + uv.y)), 0.4, 0.4 * (0.5+0.5*sin(iTime + uv.x)));
    
    // RBG to HSL
    vec3 hsl = rgb2hsl(rgb);
    vec3 hsl_branches = rgb2hsl_branches(rgb);

    //fragColor.xyz = abs(hsl - hsl_branches);
    fragColor.xyz = mix(hsl, hsl_branches, step(0.5, uv.x)) * step(0.001, abs(uv.x - 0.5));
}

// https://www.shadertoy.com/view/4sSBDK
float ASCII_Details = 8.0; 
float PixelSize = 3.5;
float greyScale(in vec3 col) 
{
    //return dot(col, vec3(0.3, 0.59, 0.11));
    return dot(col, vec3(0.2126, 0.7152, 0.0722)); //sRGB
}

float character(float n, vec2 p)
{
	p = floor(p*vec2(4.0, -4.0) + 2.5);
	if (clamp(p.x, 0.0, 4.0) == p.x && clamp(p.y, 0.0, 4.0) == p.y
	 && int(mod(n/exp2(p.x + 5.0*p.y), 2.0)) == 1) return 1.0;
	return 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
	vec3 col = texture(iChannel0, floor(uv / ASCII_Details) * ASCII_Details / iResolution.xy).rgb;	
	float gray = greyScale(col);
    float n = 65536.0 + 
              step(0.2, gray) * 64.0 + 
              step(0.3, gray) * 267172.0 +
        	  step(0.4, gray) * 14922314.0 + 
        	  step(0.5, gray) * 8130078.0 - 
        	  step(0.6, gray) * 8133150.0 - 
        	  step(0.7, gray) * 2052562.0 -
        	  step(0.8, gray) * 1686642.0;
        
	vec2 p = mod(uv / PixelSize, 2.0) - vec2(1.0);
	if (iMouse.z > 0.5)	col = gray * vec3(character(n, p));
	else col = col*character(n, p);
	
	fragColor = vec4(col, 1.0);
}

// 
#define amplitude 0.1
#define BackgroundColor vec4(0.957, 0.925, 0.773, 1.0)
#define EdgeColor vec4(0.2, 0.2, 0.2, 1.0)
#define BlueColor vec4(0.384, 0.667, 0.655, 1.0)
#define PurpleColor vec4(0.761, 0.706, 0.835, 1.0)
#define YellowColor vec4(0.961, 0.753, 0.196, 1.0)
#define GreenColor vec4(0.624, 0.796, 0.361, 1.0)
#define OrangeColor vec4(0.953, 0.482, 0.318, 1.0)
#define RedColor vec4(0.886, 0.557, 0.616, 1.0)

const vec4[] colors = vec4[] (BlueColor, PurpleColor, YellowColor, GreenColor, OrangeColor, RedColor);
float startTime = 0.5;
int colorId = 4;

float noise2d2(vec2 p) {
	return 0.5;
}

float noise2d(vec2 p) {
	float t = texture(iChannel0, p).x;
	//t += 0.5 * texture(iChannel0, p * 2.0).x;
	//t += 0.25 * texture(iChannel0, p * 4.0).x;
	return t / 1.75;
}

#define HASHSCALE1 .1031
float noise2d3(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float line(vec2 p, vec2 p0, vec2 p1, float width) {
    vec2 dir0 = p1 - p0;
    vec2 dir1 = p - p0;
    float h = clamp(dot(dir1, dir0)/dot(dir0, dir0), 0.0, 1.0);
    float d = (length(dir1 - dir0 * h) - width * 0.5);
    return d;
}

vec4 drawline(vec2 p, vec2 p0, vec2 p1, float width) {   		
    float d = line(p, p0, p1, width);
    d += noise2d(p * vec2(0.2)) * 0.005;
    float w = fwidth(d) * 1.0;
    
    return vec4(EdgeColor.rgb, 1.-smoothstep(-w, w, d));
}

float metaball(vec2 p, float r) {
	return r / dot(p, p);
}

vec4 balloon(vec2 pos, vec2 start, vec2 end, float radius, vec4 color) {
    // Draw line
    vec2 linePos = pos;
    linePos.x *= (1.0 + sin(noise2d(pos * 0.005) * pos.y * 8.) * 0.05);
    vec4 line = drawline(linePos, 
                         start * (1.0 + vec2(cos(iTime * 1.4), sin(iTime * 2.4)) * 0.4 * amplitude), 
                         end, 0.015);
	line = vec4(0.0); 
	
    vec2 c0 = start * (1.0 + vec2(cos(iTime * 1.4), sin(iTime * 2.4)) * 0.57 * amplitude);
    vec2 c1 = start * (1.0 + vec2(cos(iTime * 1.4), sin(iTime * 1.9)) * 0.49 * amplitude);
    vec2 c2 = start * (1.0 + vec2(sin(iTime * 1.9), cos(iTime * 2.4)) * 0.46 * amplitude);
			
	float r = metaball(pos - c0, radius*1.1) *
		 		metaball(pos - c1, radius*1.3) *
				metaball(pos - c2, radius*0.9);
    
    vec2 boundary = vec2(0.4, 0.5);
	vec4 c = vec4(0);
			
	vec4 egdeColor = EdgeColor;
	vec4 blobColor = color;
    
	r += noise2d(pos * vec2(0.05)) * 0.15;
    
    if (r < boundary.x) {
		c = egdeColor;
		c.a = 0.0;
	} else if (r < boundary.y) {
		c = egdeColor;
		c.a = 1.0;
    } else {
        //c = blobColor;
        c = mix(blobColor,texture(iChannel1,.5+(pos-c2)),.5+.4*cos(10.*startTime+iTime));
        //c = mix(blobColor,texture(iChannel1,.5+(pos-c2)), 1.0);
		
		c.a = 1.0;
    }
    
    // Blur the edges
    float w = 0.05;
	if (r > boundary.x - w && r < boundary.x) {
		c = mix(line, egdeColor, smoothstep(-w, 0.0, r - boundary.x));
        c.a = mix(0.0, 1.0, smoothstep(-w, 0.0, r - boundary.x));
	}
	if (r > boundary.y - w && r < boundary.y + w) {
		c.rgb = mix(egdeColor.rgb, c.rgb, smoothstep(-w, w, r - boundary.y));
	}
    
    //c.rgb += noise2d(pos * 0.1) * 0.1;
    
    c.rgb = mix(line.rgb, c.rgb, c.a);
    c.a = max(line.a, c.a);
    
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.yy;
    vec2 p = (2.0*fragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x); 

	
    float width = iResolution.x/iResolution.y; 

    fragColor = vec4(0.0);
    
    float end = -0.1;
    
    // First level
    vec4 c = balloon(uv, vec2(width * 0.5, 0.5), vec2(width*0.5, end), 0.13, colors[colorId]);
    fragColor.rgb = mix(fragColor.rgb, c.rgb, c.a);
    
    fragColor.rgb = fragColor.rgb*(1.0-0.15*length(p));
    fragColor.rgb = pow(fragColor.rgb, vec3(1.0/1.8));
}



// https://www.shadertoy.com/view/XtGGzz
float blurRadius = 30.0;

vec2 random(vec2 p){
	p = fract(p * vec2(443.897, 441.423));
    p += dot(p, p.yx+19.19);
    return fract((p.xx+p.yx)*p.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = fragCoord / iResolution.xy;
    vec2 r=random(uv);
    r.x*=6.28305308;
    vec2 cr = vec2(sin(r.x),cos(r.x))*sqrt(r.y);
    
	fragColor = texture(iChannel0,
		uv+cr*(blurRadius/iResolution.xy)
    );
}

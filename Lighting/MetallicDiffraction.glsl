// https://www.shadertoy.com/view/4t23zR
// Created by randy read - rcread/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


//	modified version of https://www.shadertoy.com/view/XsXXDn

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	float t = iTime * .5;
	vec2 r = iResolution.xy;
	vec3 c=vec3(0.);
	float l=0.,z=t;
	for(int i=0;i<3;i++) {
		vec2 uv,p=fragCoord.xy/r;
		uv=p;	//	if we just use p, no uv, it's almost the same, but with dark centered horizontal/vertical lines
		p-=.5;
		p.x*=r.x/r.y;
		z+=.03;
		l=length(p);
		uv+=p/(l*(sin(z)+1.5)*max(.2, abs(sin(l*9.-z*2.))));
        float j = float(i);
        float k = .005*(mix(4.-j, j+1.,(sin(t/1.1e1)+1.)/2.));
		c[i]=(cos(t/2.1)+1.01)*k/length((mod(uv,1.)-.5));
	}
    fragColor = vec4( 5. * c, 1. );
}

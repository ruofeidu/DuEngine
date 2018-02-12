// https://www.shadertoy.com/view/https://www.shadertoy.com/view/MtcSzH
#define GAMMA        (2.2)
#define pow3(x,y)    (pow( max(x,0.) , vec3(y) ))

// https://www.shadertoy.com/view/4djSRW

#define HASHSCALE3 vec3(.1031, .1030, .0973)
vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yxz+19.19);
    return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    fragColor.rgb = pow3(texture(iChannel0,fragCoord/iResolution.xy).rgb,GAMMA);
    // uncomment to add random noise
    //fragColor.rgb += (hash33(vec3(fragCoord.xy,iTime))-.5)*0.2;
    fragColor.a = 1.;
}
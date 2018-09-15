// 
float M=512.0,L=0.01,R=3.0;
vec3 l=vec3(0.577);
vec3 bl=vec3(0.5,0.7,1.0);


// IQ's noise stuff
mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}
#define USE_3DTEXTURE 1

#if USE_3DTEXTURE
float noise( in vec3 x )
{
	x += 0.5;
	vec3 fx = fract( x );
	x = floor( x ) + fx*fx*(3.0-2.0*fx);
    return texture( iChannel0, (x-0.5)/32.0 ).x;
}

#else
float noise( in vec3 x )
{
	x += 0.5;
	vec3 fx = fract( x );
	x = floor( x ) + fx*fx*(3.0-2.0*fx);
    return texture( iChannel0, (x-0.5)/32.0 ).x;
}
#endif

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}

float noise2(vec3 p){
	return noise(p*32.0);
}

vec4 u, v;

vec3 K(vec3 p) {
	float a=atan(p.x,p.y)+p.z*0.5,d=length(p.xy);
	vec3 p2=vec3(a*0.31831+u.z,d*0.2*u.y,p.z*0.2*u.y);
	float xr = noise2(p2);
	float yr = noise2(p*0.02);
	float yg = noise2(p*0.02+vec3(3.63));
	float zr = noise2(p*0.07);
	float zg = noise2(p*0.07+vec3(5.72));
	float nn = yr*yg+zr*zg;
	return vec3(
		v.w*nn*nn*3.0+
		v.z*(6.0-(d+xr*4.0*v.y)+(sin(p.x*1.7+u.w-sin(p.y*2.5+u.w))+sin(p.z*1.5-u.w)*0.7)*0.5),
		clamp(nn*nn*0.25,0.0,1.0),
		xr);
}

vec3 N(vec3 p,float a) {
	return normalize(vec3(a-K(vec3(p.x+0.05,p.y,p.z)).r,a-K(vec3(p.x,p.y+0.05,p.z)).r,a-K(vec3(p.x,p.y,p.z+0.05)).r));
}

vec4 calc_pixel(vec3 ro, vec3 rd) {
	vec3 P,D=rd*L;
	float s=48.0,ks,a=1.0,f2;
	vec3 k=vec3(0.0),f=vec3(0.0),n,h,d,b,c;

	//for (;s<M;) {
	for (int i=0; i<64; i++) {
		P=ro+D*s;
		k=K(P);
		if (k.r>R) break;
		if (s>=M) break;
		ks=clamp(k.g-v.w*0.025,0.0,0.1);
		a=a*(1.0-ks);
		f=f+vec3(1.5-ks*14.0)*a*ks;
		if (a<0.01) break;
		s=s+clamp((R-k.r)*5.0,1.0,20.0);
	}

	if (s<M) for (int i=0;i<9;i++) {
		D=D*0.5;
		if (k.r>R) P=P-D;
		else P=P+D;
		k=K(P);
	}

	D=rd;
	n=N(P,k.r);
	h=vec3(dot(reflect(normalize(D),n),l));
	h=clamp(h*h*h*h*h*h*h*vec3(0.9,0.9,1.0),0.0,1.0);
	b=dot(n,-l)*bl.bgr;
	d=clamp(dot(n,l)*bl+b*b,0.0,1.0);
	f2=clamp(1.0-(M-s)/M,0.0,1.0);
	c=mix((h+d)*abs(sin(k.b))*2.0,bl*v.w*0.5,f2*f2);
	return vec4(u.x*mix(f*f2*f2,c,a),1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {	
    u = vec4(1.0, sin(iTime*0.1)*0.2+0.6, iTime*0.2, -iTime*2.0);
    v = vec4(0.0, 1.0-(cos(iTime*0.1)*0.25+0.5), 1.0, 1.0-(cos(iTime*0.05)*0.5+0.5));

	vec2 p = -1.0 + 2.0 * (fragCoord.xy / iResolution.xy);
	vec3 cp = vec3(sin(iTime*0.2)*5.0, cos(iTime*0.2)*5.0, iTime*0.05);
	vec3 t = vec3(0.0, 0.0, cp.z-5.0);
	vec3 z = normalize(t-cp);
	vec3 x = cross(z, vec3(0.0, 1.0, 0.0));	
	vec3 y = cross(z, x); 
	vec3 ro = cp+p.x*x-p.y*y;
	cp = cp-z*1.0;
	vec3 rd = (normalize(ro - cp));
    fragColor = calc_pixel(ro, rd);
}

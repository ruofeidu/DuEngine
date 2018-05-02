// ldl3z2
#define ANIM true
#define PI 3.1415927
float time;

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}
// --- End of Created by inigo quilez

vec2 noise2_2( vec2 p )     // 2 noise channels from 2D position
{
	vec3 pos = vec3(p,.5);
	if (ANIM) pos.z += time;
	pos *= m;
    float fx = noise(pos);
    float fy = noise(pos+vec3(1345.67,0,45.67));
    return vec2(fx,fy);
}

#define snoise(p)  (2.*noise(p)-1.)
#define snoise2_2(p)  (2.*noise2_2(p)-1.)
#define fbm2(p)  ((noise(p)+.5*noise(m*(p)))/1.5)

vec2 advfbm( vec2 p )
{	
    float l=1.;
	vec2 dp;	
    dp  =   snoise2_2(p+dp); l*=.5;
    dp += l*snoise2_2(p+dp); l*=.5;
    dp += l*snoise2_2(p+dp); l*=.5;
    dp += l*snoise2_2(p+dp); l*=.5;
    dp += l*snoise2_2(p+dp); 

    return dp;
}

float _h, _n,_d;
float scene(vec3 p)
{
	float d1 = length(p.xz);
	float d2 = length(p.xz-vec2(1.,0.));
	float h; 
	
	// main shape
	h =  .4*sin(5.*d1-time       )/(.4+d1*d1)
	   + .4*sin(5.*d2-.71234*time)/(.4+d2*d2);

	// add details
	vec3 pp = 15.*p+4.*time*vec3(.5,.4,.8);
	float n;
	if (p.y-h < .2) n = fbm(pp); // details only if close
	else n = 0.; //.5*noise(pp); // detail approx
	_h = h; _n = n; _d=d1;
	h += .2*n; 
	
	return  .1*max(p.y-h,0.);
		// length(advfbm(10.*p.xy));
}

vec2 rotate(vec2 k,float t)
{   return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	time = iTime;
    float speed = 0.;
	vec2 pos=(fragCoord.xy/iResolution.y-vec2(.8,.5))*2.;
	vec2 mouse = vec2(0.,.16);
	if (iMouse.x > 0.) mouse = (iMouse.xy/iResolution.xy-.5)*2.;
    vec3 col;
	//ec3 sky = vec3(.6,.8,1.);
	vec3 sky = vec3(.1,.2,0.);
	//vec3 light = vec3(.2,.8,-.2);
	vec3 light = vec3(.1,.1,.9);

	// camera, ray-marching & shading  inspired by rez
	// https://www.shadertoy.com/view/MsXGR2
	
	float fov = .5;
	vec3 dir=normalize(vec3(fov*pos,1.0));	// ray dir
	dir.yz=rotate(dir.yz, PI*mouse.y);		// rotation up/down
	dir.zx=rotate(dir.zx,-PI*mouse.x);		// rotation left/right
	//dir.xy=rotate(dir.xy,0.);	       		// twist
	vec3 ray=vec3(0.,2.,-4.);         		// pos along ray
	
	float l=0.,dl;
#define eps 1.e-3
	const int ray_n=128;
	for(int i=0; i<ray_n; i++)
	{
		l += dl = scene(ray+dir*l);
		if (dl<=eps) break;
	}
	if (true) // dl<=eps) 
	{
	vec3 hit = ray+dir*l;
	float H=_h, dH=_n;
		
	// shading ( -> eval normals)
	vec2 h = vec2(.005,-.005); 
	vec3 N = normalize(vec3(scene(hit+h.xyy),
						    scene(hit+h.yxx),
						    scene(hit+h.yyx)));
    //float c = texture(iChannel1,N.xzy).x;
	float c = dot(N,light);

	// fog
	float a = 1.-exp(-.15*l); // optical thickness

	// lava
	col = 1.*c*vec3(1.,.3,0.); // shading
	col += pow(1.-dH,2.)*vec3(1.,.6,.1)*2.5/(.4+.2*_d*_d);

	float gaz = 1.5*fbm2(vec3(5.*(pos.x-PI*mouse.x),2.*pos.y-6.*time,.5));
	col = a*sky*gaz+(1.-a)*col;
	}
	else
		col = sky;
	
#if 0
	vec2 disp = advfbm(15.*+mouse.x*uv);
	vec2 p = uv+mouse.x*disp;
	//col = texture(iChannel0,p).rgb;
	col = vec3(length(disp));
	//col = vec3(.5+.5*disp,.5);
#endif
	
	fragColor = vec4(col,1.0);
}
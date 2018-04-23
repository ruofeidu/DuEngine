// 
/*by mu6k, Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.*/
//2D texture based 4 component 1D, 2D, 3D noise
vec4 noise(float p){return texture(iChannel0,vec2(p*float(1.0/256.0),.0));}
vec4 noise(vec2 p){return texture(iChannel0,p*vec2(1.0/256.0));}
vec4 noise(vec3 p){float m = mod(p.z,1.0);float s = p.z-m; float sprev = s-1.0;if (mod(s,2.0)==1.0) { s--; sprev++; m = 1.0-m; };return mix(texture(iChannel0,p.xy*vec2(1.0/256.0) + noise(sprev).yz*21.421),texture(iChannel0,p.xy*vec2(1.0/256.0) + noise(s).yz*14.751),m);}
vec4 noise(vec4 p){float m = mod(p.w,1.0);float s = p.w-m; float sprev = s-1.0;if (mod(s,2.0)==1.0) { s--; sprev++; m = 1.0-m; };return mix(noise(p.xyz+noise(sprev).wyx*3531.123420),	noise(p.xyz+noise(s).wyx*4521.5314),	m);}

//functions that build rotation matrixes
mat2 rotate_2D(float a){float sa = sin(a); float ca = cos(a); return mat2(ca,sa,-sa,ca);}
mat3 rotate_x(float a){float sa = sin(a); float ca = cos(a); return mat3(1.,.0,.0,    .0,ca,sa,   .0,-sa,ca);}
mat3 rotate_y(float a){float sa = sin(a); float ca = cos(a); return mat3(ca,.0,sa,    .0,1.,.0,   -sa,.0,ca);}
mat3 rotate_z(float a){float sa = sin(a); float ca = cos(a); return mat3(ca,sa,.0,    -sa,ca,.0,  .0,.0,1.);}


float t;

vec3 flare(vec2 uv, vec2 pos, float seed, float size)
{
	vec4 gn = noise(seed-1.0);
	gn.x = size;
	vec3 c = vec3(.0);
	vec2 p = pos;
	vec2 d = uv-p;
	
	
	c += (0.01+gn.x*.2)/(length(d));
	
	c += vec3(noise(atan(d.x,d.y)*256.9+pos.x*2.0).y*.25)*c;
	
	float fltr = length(uv);
	fltr = (fltr*fltr)*.5+.5;
	fltr = min(fltr,1.0);
	
	
	return c;
}

float df(vec3 p)
{
	vec2 m = mod(p.xz,vec2(1.0));
	vec2 i = p.xz-m;
	m=m-vec2(.5); m*=2.0;
	m = m*m;
	vec3 q = p;
	q.y+=t*4.0;
	q.x+=t*.1;
	q.z+=t*.1;
    float wave_amp = sin(t*.1)*.5+.5;
    p.y+=sin(p.x*.3+p.z*.1+t)*.25*wave_amp;
    p.y+=sin(p.z*.1-p.x*.15+t)*.5*wave_amp;
	float amount = sin(t)*.1+.1;
	float pillars = noise(p.xz).y-amount;
	float waves = sin(pillars*8.0-t*2.0+p.x*.5+p.z*.7)*.1/(pillars+.7);
	return min(p.y+3.0+waves,noise(p.xz).y-.1)+noise(q.xyz*vec3(4.0,1.0,4.0)*2.0).x*.1-.05;
}

vec3 nf(vec3 p)
{
	vec2 e = vec2(.1,.0);
	float c = df(p);
	return normalize(vec3(c-df(p+e.xyy),c-df(p+e.yxy),c-df(p+e.yyx)));
}

vec3 background(vec3 d)
{
	return d.y*vec3(.2,.4,.8)*.5+.5;	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    t = (iTime+noise(gl_FragCoord.xy).x*(1.0/24.0));
    
	vec2 uv = fragCoord.xy / iResolution.yy - vec2(.9,.5);
	
	float t=iTime;
	vec3 p = vec3(.0);
	p.z+=t;
	vec3 turb = (noise(t*10.0).xyz*noise(t*22.0).xyz)*((sin(t*.1)+sin(t*3.10)+sin(t*7.10)-3.0)/6.0)*.2;
	turb*=1.0-cos(t*.2);
	turb*=sin(t*.793)*.5+.5;
	mat3 rot = rotate_x(.1+turb.x*.15) * rotate_y(turb.y*.15);
	vec3 d = normalize(vec3(uv,.9-pow(length(uv),4.0)*.2+(sin(t*.5)-sin(t*.52))*.1));
	d*=rot;
	float td = .0;
	for (int i=0; i<100; i++)
	{
		float dd = df(p);
		p += d*dd;
		td+=dd;
		if (dd>100.0||abs(dd)<.01) break;
		
	}
	
	vec3 l = -normalize(vec3(.4,.2,.8));
	vec3 n = nf(p);
	vec3 color = (dot(l,n)*.5+.5)*vec3(.4,.026,.013)*.5;
    float oa = min(abs(df(p-n)),abs(df(p-n*.5)*2.0));
    float od = min(abs(df(p-l)),abs(df(p-l*.5)*2.0));
    color = color*od*oa;
    vec3 r = reflect(d,n);
    float fr = dot(d,r)*.5+.5;
    fr*=fr;
    color += pow(dot(d,-r)*.5+.5,64.0)*oa*od*2.0;
    color += pow(texture(iChannel1,r).xyz,vec3(2.0))*oa*fr*.5;
    
    color = color/(1.0+td*td*.01);
    
   	color += flare(uv*2.0,vec2(.0,1.5),0.010,10.0)*.02;
    color *=1.0-length(uv)*.5;
    
	fragColor = vec4(pow(color,vec3(1.0/2.2)),1.0);
}
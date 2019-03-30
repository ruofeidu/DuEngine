// 
#define time iTime

/* Adjust reflection sample size */
#define RSAMPLES 32

/* Enable softShadow / direct lighting */
#define SHADOWS

float noise3D(vec3 p)
{
	return fract(sin(dot(p ,vec3(12.9898,78.233,126.7378))) * 43758.5453)*2.0-1.0;
}

mat3 rot(vec3 ang)
{
	mat3 x = mat3(1.0,0.0,0.0,0.0,cos(ang.x),-sin(ang.x),0.0,sin(ang.x),cos(ang.x));
	mat3 y = mat3(cos(ang.y),0.0,sin(ang.y),0.0,1.0,0.0,-sin(ang.y),0.0,cos(ang.y));
	mat3 z = mat3(cos(ang.z),-sin(ang.z),0.0,sin(ang.z),cos(ang.z),0.0,0.0,0.0,1.0);
	return x*y*z;
}

float sphere(vec3 rp, vec3 c, float r)
{
	return distance(rp,c)-r;
}

float cube( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

vec4 map(vec3 rp)
{
	vec4 d;
	vec4 sp = vec4( vec3(0.68, 0.9, 0.40), sphere(rp, vec3(1.0,0.0,0.0), 1.0) );
    vec4 sp2 = vec4( vec3(0.68, 0.1, 0.40), sphere(rp, vec3(1.0,2.0,0.0), 1.0) );
    vec4 cb = vec4( vec3(0.17,0.46,1.0), cube(rp+vec3(2.1,-1.0,0.0), vec3(2.0), 0.0) );
	vec4 py = vec4( vec3(0.7,0.35,0.1), rp.y+1.0 );
	d = (sp.a < py.a) ? sp : py;
    d = (d.a < sp2.a) ? d : sp2;
    d = (d.a < cb.a) ? d : cb;
	return d;
}

vec3 normal(vec3 rp)
{
    vec3 eps = vec3( 0.002 ,0.0,0.0);
	return normalize( vec3(
           map(rp+eps.xyy).a - map(rp-eps.xyy).a,
           map(rp+eps.yxy).a - map(rp-eps.yxy).a,   //shamelessly stolen from iq :(
           map(rp+eps.yyx).a - map(rp-eps.yyx).a ) );

}

float softShadow(vec3 ro, vec3 lp)
{
	vec3 rd = normalize(lp-ro);
	float tmax = distance(lp,ro);
	float res = 1.0;
    float t = 0.1;
	for(int i = 0; i<256; i++ )
	{
        if(t>=tmax) break;
		float d = map(ro+rd*t).a;
		if(d < 0.001) return 0.0;
		res = min(res, 8.0*d);
		t += d;
	}
	return res;
}

float ao(vec3 ro, vec3 norm, float k)
{
    float res = 0.0;
    float f = 0.1;
    for(int i = 1; i<6; i++)
    {
        vec3 rp = ro + f*float(i)*norm;
     	res+=(1.0/pow(2.0,float(i)))*(f*float(i)-map(rp).a);    
    }
	return 1.0-k*res;
}


vec3 lp(void){
    return vec3(1.0,5.0,3.0)*rot(vec3(0.0,time*0.5,0.0));
}

vec3 reflection(vec3 rro, vec3 rd, vec3 n, vec3 ro, float x)
{
    float my = iMouse.y > 0.0 ? iMouse.y/iResolution.y : 0.5;
    vec3 ang = vec3(noise3D(rro*1.1*x), noise3D(rro*1.2*x), noise3D(rro*1.3*x))*my;
	rd = normalize(reflect(rd,n)*rot(ang));
	vec3 res = vec3(1.0,1.0,0.8);
	float tmax = 10.0;
    float t = 0.1;
    vec3 rp = rro;
    vec4 d = vec4(res, 1.0);
	for(int i = 0; i<256; i++ )
	{
        if(t>=tmax) break;
		rp = rro+rd*t;
		d = map(rp);
		if(d.a < 0.001) 
		{		
			break;
		}
		t+=d.a;
	}
    if(d.a < 0.001) 
	{		
    	float ks = 0.5;
		float kd = 0.5;		
		float ka = 0.2;
        float a = 3.0;
		float aof = 5.0;
        float ss = 1.0;
			
		vec3 l = normalize(lp()-rp);          
		vec3 n = normal(rp);				
		vec3 v = normalize(ro-rp);
        vec3 h = normalize(l+v);		
			
		float illumination  = ka*ao(rp,n, aof) 				
							+ max(kd*dot(l,n),0.0)
                            + max(ks*pow(dot(n,h),a),0.0);
        
        #ifdef SHADOWS
        	illumination += ss*softShadow(rp, lp());
        #endif
        
		res = d.rgb*illumination;
	}
	return res;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord/iResolution.xy;
	vec2 p = uv*2.0-1.0;
	p.x*=iResolution.x/iResolution.y;	
	float f = -7.0;    
	vec3 col = vec3(0.7,0.35,0.1)*0.55*vec3(1.0,1.0,0.8);
    #ifndef SHADOWS
    	col = vec3(0.7,0.35,0.1)*0.45*vec3(1.0,1.0,0.8);
    #endif
    float mx = iMouse.x > 0.0 ? iMouse.x/iResolution.x : 0.59;
	vec3 ang = vec3(3.14/8.0,mx*3.14*3.0,0.0);
	vec3 ro = vec3(0.0,0.0,f-2.0);
	vec3 rd = normalize(vec3(p,f)-ro);
	ro*=rot(ang);
	rd*=rot(ang);
	vec3 rp;
	float tmax = 60.0;
	float t = 0.0;
    vec4 d = vec4(col, 1.0);
	for(int i = 0; i<256; i++)
	{
        if(t >= tmax) break;
		rp = ro+rd*t;
		d = map(rp);
		if(d.a < 0.0001)
		{
			break;
		}
		t += d.a;
	}
	if(d.a < 0.0001)
    {
   		float ks = 0.5;		//specular reflection constant
		float kd = 0.5;		//diffuse reflection constant
		float ka = 0.4;		//ambient reflection constant
		float a = 5.0;		//shininess constant
		float aof = 5.0;	//ambient occlusion amount
		float rf = 1.0;		//reflection amount
        float ss = 1.0;
			
		vec3 l = normalize(lp()-rp);          //surface to light vector
		vec3 n = normal(rp);				//surface normal vector
		vec3 v = normalize(ro-rp);			//surface to camera vector
        vec3 h = normalize(l+v);			//the "half way vector"
			
		float illumination  = ka*ao(rp,n, aof) 				//add ambient light
							+ max(kd*dot(l,n),0.0) 			//add diffuse light
							+ max(ks*pow(dot(n,h),a),0.0);	//add specular light
        
        #ifdef SHADOWS
        	illumination += ss*softShadow(rp, lp());		//add direct light + shadows
        #endif
						
        vec3 ref = vec3(0.0);
        
        for(int j = 1; j<RSAMPLES+1; j++)
        {
            ref+=reflection(rp,rd,n,ro,float(j));
        }
        ref/=float(RSAMPLES);
		col = d.rgb*(illumination+ref);
    }

	fragColor = vec4(col,1.0);	
}

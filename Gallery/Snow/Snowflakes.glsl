// https://www.shadertoy.com/view/Xsd3zf 
//
/* Panteleymonov Aleksandr Konstantinovich 2015
//
// if i write this string my code will be 0 chars, :) */

#define iterations 15.0
#define depth 0.0125
#define layers 8.0
#define layersblob 20
#define step 1.0
#define far 10000.0

float radius=0.25; // radius of Snowflakes. maximum for this demo 0.25.
float zoom=4.0; // use this to change details. optimal 0.1 - 4.0.

vec3 light=vec3(0.0,0.0,1.0);
vec2 seed=vec2(0.0,0.0);
float iteratorc=iterations;
float powr;
float res;

vec4 NC0=vec4(0.0,157.0,113.0,270.0);
vec4 NC1=vec4(1.0,158.0,114.0,271.0);

lowp vec4 hash4( mediump vec4 n ) { return fract(sin(n)*1399763.5453123); }
lowp float noise2( mediump vec2 x )
{
    vec2 p = floor(x);
    lowp vec2 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0;
    lowp vec4 h = hash4(vec4(n)+vec4(NC0.xy,NC1.xy));
    lowp vec2 s1 = mix(h.xy,h.zw,f.xx);
    return mix(s1.x,s1.y,f.y);
}

lowp float noise222( mediump vec2 x, mediump vec2 y, mediump vec2 z )
{
    mediump vec4 lx = vec4(x*y.x,x*y.y);
    mediump vec4 p = floor(lx);
    lowp vec4 f = fract(lx);
    f = f*f*(3.0-2.0*f);
    mediump vec2 n = p.xz + p.yw*157.0;
    lowp vec4 h = mix(hash4(n.xxyy+NC0.xyxy),hash4(n.xxyy+NC1.xyxy),f.xxzz);
    return dot(mix(h.xz,h.yw,f.yw),z);
}

lowp float noise3( mediump vec3 x )
{
    mediump vec3 p = floor(x);
    lowp vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    mediump float n = p.x + dot(p.yz,vec2(157.0,113.0));
    lowp vec4 s1 = mix(hash4(vec4(n)+NC0),hash4(vec4(n)+NC1),f.xxxx);
    return mix(mix(s1.x,s1.y,f.y),mix(s1.z,s1.w,f.y),f.z);
}
lowp vec2 noise3_2( mediump vec3 x ) { return vec2(noise3(x),noise3(x+100.0)); }

float map(mediump vec2 rad)
{
    float a;
    if (res<0.0015) {
    	//a = noise2(rad.xy*20.6)*0.9+noise2(rad.xy*100.6)*0.1;
        a = noise222(rad.xy,vec2(20.6,100.6),vec2(0.9,0.1));
    } else if (res<0.005) {
        //float a1 = mix(noise2(rad.xy*10.6),1.0,l);
        //a = texture(iChannel0,rad*0.3).x;
        a = noise2(rad.xy*20.6);
        //if (a1<a) a=a1;
    } else a = noise2(rad.xy*10.3);
    return (a-0.5);
}

vec3 distObj(vec3 pos,vec3 ray,float r,vec2 seed)
{   
    mediump float rq = r*r;
    mediump vec3 dist = ray*far;
    
    mediump vec3 norm = vec3(0.0,0.0,1.0);
    mediump float invn = 1.0/dot(norm,ray);
    mediump float depthi = depth;
    if (invn<0.0) depthi =- depthi;
    mediump float ds = 2.0*depthi*invn;
    mediump vec3 r1 = ray*(dot(norm,pos)-depthi)*invn-pos;
    mediump vec3 op1 = r1+norm*depthi;
    mediump float len1 = dot(op1,op1);
    mediump vec3 r2 = r1+ray*ds;
    mediump vec3 op2 = r2-norm*depthi;
    mediump float len2 = dot(op2,op2);
    
    mediump vec3 n = normalize(cross(ray,norm));
    mediump float mind = dot(pos,n);
    mediump vec3 n2 = cross(ray,n);
    mediump float d = dot(n2,pos)/dot(n2,norm);
    mediump float invd = 0.2/depth;
    
    if ((len1<rq || len2<rq) || (abs(mind)<r && d<=depth && d>=-depth))
    {        
        mediump vec3 r3 = r2;
        mediump float len = len1;
        if (len>=rq) {
        	mediump vec3 n3 = cross(norm,n);
        	mediump float a = inversesqrt(rq-mind*mind)*abs(dot(ray,n3));
            mediump vec3 dt = ray/a;
        	r1 =- d*norm-mind*n-dt;
            if (len2>=rq) {
                r2 =- d*norm-mind*n+dt;
            }
            ds = dot(r2-r1,ray);
        }
        ds = (abs(ds)+0.1)/(iterations);
        ds = mix(depth,ds,0.2);
        if (ds>0.01) ds=0.01;
        mediump float ir = 0.35/r;
        r *= zoom;
        ray = ray*ds*5.0;
        for (float m=0.0; m<iterations; m+=1.0) {
            if (m>=iteratorc) break;
           	mediump float l = length(r1.xy); //inversesqrt(dot(r1.xy,r1.xy));
            lowp vec2 c3 = abs(r1.xy/l);
            if (c3.x>0.5) c3=abs(c3*0.5+vec2(-c3.y,c3.x)*0.86602540);
			mediump float g = l+c3.x*c3.x; //*1.047197551;
			l *= zoom;
            mediump float h = l-r-0.1;
            l = pow(l,powr)+0.1;
          	h = max(h,mix(map(c3*l+seed),1.0,abs(r1.z*invd)))+g*ir-0.245; //0.7*0.35=0.245 //*0.911890636
            if ((h<res*20.0) || abs(r1.z)>depth+0.01) break;
            r1 += ray*h;
            ray*=0.99;
        }
        if (abs(r1.z)<depth+0.01) dist=r1+pos;
    }
    return dist;
}

vec3 nray;
vec3 nray1;
vec3 nray2;
float mxc=1.0;

vec4 filterFlake(vec4 color,vec3 pos,vec3 ray,vec3 ray1,vec3 ray2)
{
    vec3 d=distObj(pos,ray,radius,seed);
    vec3 n1=distObj(pos,ray1,radius,seed);
    vec3 n2=distObj(pos,ray2,radius,seed);

    vec3 lq=vec3(dot(d,d),dot(n1,n1),dot(n2,n2));
	if (lq.x<far || lq.y<far || lq.z<far) {
    	vec3 n=normalize(cross(n1-d,n2-d));
        if (lq.x<far && lq.y<far && lq.z<far) {
       		nray = n;//normalize(nray+n);
       		//nray1 = normalize(ray1+n);
       		//nray2 = normalize(ray2+n);
        }
       	float da = pow(abs(dot(n,light)),3.0);
        vec3 cf = mix(vec3(0.0,0.4,1.0),color.xyz*10.0,abs(dot(n,ray)));
       	cf=mix(cf,vec3(2.0),da);
      	color.xyz = mix(color.xyz,cf,mxc*mxc*(0.5+abs(dot(n,ray))*0.5));
    }
    
    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time = iTime*0.2;//*0.1;
    res = 1.0 / iResolution.y;
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) *res;

    vec3 rotate;
    
    mat3 mr;
    
    vec3 ray = normalize(vec3(p,2.0));
    vec3 ray1;
    vec3 ray2;
    vec3 pos = vec3(0.0,0.0,1.0);

    fragColor.w = 0.0;
    
	nray = vec3(0.0);
	nray1 = vec3(0.0);
	nray2 = vec3(0.0);
    
    vec4 refcolor=vec4(0.0);
    iteratorc=iterations-layers;
    
    vec2 addrot = vec2(0.0);
    if (iMouse.z>0.0) addrot=(iMouse.xy-iResolution.xy*0.5)*res;
    
    float mxcl = 1.0;
    vec3 addpos=vec3(0.0);
    pos.z = 1.0;
    mxc=1.0;
    radius = 0.25;
    float mzd=(zoom-0.1)/layers;
    for (int i=0; i<layersblob;i++) {
        vec2 p2 = p-vec2(0.25)+vec2(0.1*float(i));
        ray = vec3(p2,2.0)-nray*2.0;
    	//ray = nray;//*0.6;
    	ray1 = normalize(ray+vec3(0.0,res*2.0,0.0));
    	ray2 = normalize(ray+vec3(res*2.0,0.0,0.0));
        ray = normalize(ray);
    	vec2 sb = ray.xy*length(pos)/dot(normalize(pos),ray)+vec2(0.0,time);
        seed=floor((sb+vec2(0.0,pos.z)))+pos.z;
        vec3 seedn = vec3(seed,pos.z);
        sb = floor(sb);
        if (noise3(seedn)>0.2 && i<int(layers)) {
            powr = noise3(seedn*10.0)*1.9+0.1;
            rotate.xy=sin((0.5-noise3_2(seedn))*time*5.0)*0.3+addrot;
            rotate.z = (0.5-noise3(seedn+vec3(10.0,3.0,1.0)))*time*5.0;
            seedn.z += time*0.5;
            addpos.xy = sb+vec2(0.25,0.25-time)+noise3_2(seedn)*0.5;
            vec3 sins = sin(rotate);
    		vec3 coss = cos(rotate);
    		mr=mat3(vec3(coss.x,0.0,sins.x),vec3(0.0,1.0,0.0),vec3(-sins.x,0.0,coss.x));
		    mr=mat3(vec3(1.0,0.0,0.0),vec3(0.0,coss.y,sins.y),vec3(0.0,-sins.y,coss.y))*mr;
            mr=mat3(vec3(coss.z,sins.z,0.0),vec3(-sins.z,coss.z,0.0),vec3(0.0,0.0,1.0))*mr;

            light = normalize(vec3(1.0,0.0,1.0))*mr;
    		//vec4 cc=filterFlake(fragColor,(pos+addpos)*mr,normalize(ray*mr+nray*0.1),normalize(ray1*mr+nray*0.1),normalize(ray2*mr+nray*0.1));
            vec4 cc = filterFlake(fragColor,(pos+addpos)*mr,ray*mr,ray1*mr,ray2*mr);
            //if (i>0 && dot(nray,nray)!=0.0 && dot(nray1,nray1)!=0.0 && dot(nray2,nray2)!=0.0) refcolor=filterFlake(refcolor,(pos+addpos)*mr,nray,nray1,nray2);
            //cc+=refcolor*0.5;
            fragColor=mix(cc,fragColor,min(1.0,fragColor.w));
        }
        seedn = vec3(sb,pos.z)+vec3(0.5,1000.0,300.0);
        if (noise3(seedn*10.0)>0.4) {
            float raf = 0.3+noise3(seedn*100.0);
            addpos.xy = sb+vec2(0.2,0.2-time)+noise3_2(seedn*100.0)*0.6;
            float l = length(ray*dot(ray,pos+addpos)-pos-addpos);
            l = max(0.0,(1.0-l*10.0*raf));
            fragColor.xyzw += vec4(1.0,1.2,3.0,1.0)*pow(l,5.0)*(pow(0.6+raf,2.0)-0.6)*mxcl;
        }
        mxc -= 1.1/layers;
        pos.z += step;
        iteratorc += 2.0;
        mxcl -= 1.1/float(layersblob);
        zoom-= mzd;
    }
    
    vec3 cr = mix(vec3(0.0),vec3(0.0,0.0,0.4),(-0.55+p.y)*2.0);
    fragColor.xyz += mix((cr.xyz-fragColor.xyz)*0.1,vec3(0.2,0.5,1.0),clamp((-p.y+1.0)*0.5,0.0,1.0));
    
    fragColor = min( vec4(1.0), fragColor );
}
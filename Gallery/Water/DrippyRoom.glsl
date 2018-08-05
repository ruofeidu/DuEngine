// MstGWX
mat3 boxxfrm;
float box1(vec3 ro,vec3 rd)
{
    return min((sign(rd.x)-ro.x)/rd.x,min((sign(rd.y)-ro.y)/rd.y,(sign(rd.z)-ro.z)/rd.z));
}
vec2 box2(vec3 ro,vec3 rd)
{
    return vec2(max((-sign(rd.x)-ro.x)/rd.x,max((-sign(rd.y)-ro.y)/rd.y,(-sign(rd.z)-ro.z)/rd.z)),box1(ro,rd));
}
vec3 textureBox1(vec3 p)
{
    vec3 ap=abs(p),f=step(ap.zxy,ap.xyz)*step(ap.yzx,ap.xyz);
    vec2 uv=f.x>.5?p.yz:f.y>.5?p.xz:p.xy;
    float l=clamp(-normalize(p-vec3(0,1,0)).y,0.,1.);
    vec2 b=box2(boxxfrm*p,boxxfrm*(vec3(0,1,0)-p));
    // Some lighting and a shadow (and approximated AO).
    float s=mix(.2,1.,smoothstep(0.,.8,length(p.xz)));
    vec3 d=.6*(1.-smoothstep(-1.,1.,p.y))*vec3(0.3,0.3,.5)*s+smoothstep(0.9,.97,l)*vec3(1,1,.8)*step(b.y,b.x);
    return texture(iChannel1,uv).rgb*d;
}

vec3 textureBox2(vec3 p,vec3 p2)
{
    vec3 ap=abs(p),f=step(ap.zxy,ap.xyz)*step(ap.yzx,ap.xyz);
    vec2 uv=f.x>.5?p.yz:f.y>.5?p.xz:p.xy;
    vec3 n=normalize(-transpose(boxxfrm)*(f*sign(p)));
    float l=clamp(-normalize(p2-vec3(0,1,0)).y,0.,1.);
    vec3 d=1.*(1.-smoothstep(-1.,2.5,p2.y))*vec3(0.3,0.3,.7)+smoothstep(0.95,.97,l)*clamp(-n.y,0.,1.)*2.*vec3(1,1,.8)+
        	smoothstep(0.9,1.,l)*clamp(-n.y,0.,1.)*vec3(1,1,.8);
    return texture(iChannel3,uv).rgb*d;
}
mat2 rotation2D(float a)
{
    return mat2(cos(a),sin(a),-sin(a),cos(a));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float time=iTime;
    vec3 waterc=vec3(.55,.75,1.)*.9;

    // Set up the primary ray.
    vec3 ro=vec3(0,.7,.8),rd=normalize(vec3((fragCoord-iResolution.xy/2.)/iResolution.y,-1.));
    
    rd.yz*=rotation2D(.7);
    rd.xz*=rotation2D(time*.1);
    ro.xz*=rotation2D(time*.1);
    
    // These are the heights of the planes that the water surface lies within.
    float h0=.1,h1=-.4;
    
    float ba=time;
    boxxfrm=mat3(cos(ba),sin(ba),0,-sin(ba),cos(ba),0,0,0,1)*
        		mat3(cos(ba),0,sin(ba),-sin(ba),0,cos(ba),0,1,0)*4.;
    
    float t0=(h0-ro.y)/rd.y,t1=(h1-ro.y)/rd.y;
    float bt2=box1(ro,rd);
    vec2 bt3=box2(boxxfrm*ro,boxxfrm*rd);
    
    // Raymarch through the water surface.
    float ht=0.,h=0.;
    vec2 uv;
    const int n=256;
    for(int i=0;i<n;++i)
    {
        ht=mix(t0,t1,float(i)/float(n));
        vec3 hp=ro+rd*ht;
        uv=hp.xz/2.+.5;
        h=texture(iChannel0,uv).r;
        if(h<float(i)/float(n))
            break;
    }
    // Check primary ray intersection with the inner box.
    if(bt3.x<bt3.y&&bt3.x<ht)
    {
        fragColor.rgb=textureBox2(boxxfrm*(ro+rd*bt3.x),ro+rd*bt3.x);
        return;
    }
    // Check subsequent intersections after water surface intersection.
    if(ht>0.&&ht<bt2)
    {
        const float e=1e-2;
        float hdx=texture(iChannel0,uv+vec2(e,0.)).r;
        float hdy=texture(iChannel0,uv+vec2(0.,e)).r;
        vec3 norm=normalize(vec3(hdx,e,hdy));
        float fresnel=1.-pow(clamp(1.-dot(-rd,norm),0.,1.),2.);
        vec3 r=refract(rd,norm,1./1.333);
        vec3 r2=reflect(rd,norm);
        ro+=ht*rd;
		bt2=box1(ro,r);
    	bt3=box2(boxxfrm*ro,boxxfrm*r);
        
		float bt4=box1(ro,r2);
    	vec2 bt5=box2(boxxfrm*ro,boxxfrm*r2);
        
        vec3 reflc,refrc;
        
		reflc=textureBox1(ro+r*bt4);
        if(bt5.x<bt5.y&&bt5.x>0.)
        {
            reflc=textureBox2(boxxfrm*(ro+r2*bt5.x),ro+r2*bt5.x);
        }
        
        refrc=textureBox1(ro+r*bt2);
        if(bt3.x<bt3.y&&bt3.x>0.)
        {
            refrc=textureBox2(boxxfrm*(ro+r*bt3.x),ro+r*bt3.x);
        } 

        fragColor.rgb=reflc*(1.-fresnel)+refrc*fresnel*waterc;
    }
    else
		fragColor.rgb=textureBox1(ro+rd*bt2);
    
    // Apply (very simple) tone mapping and gamma.
    fragColor.rgb=sqrt(clamp((fragColor.rgb/(fragColor.rgb+vec3(1.))),0.,1.));
}
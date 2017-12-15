// 
//
// facebook.com/steveoscpu
// 
// greets/thx to iq & XT95 code/ideas!
//
// Arrrrgggg!!! OpenGL ES limitations !!
//
// lots of loop unrolling here it seems!
              
float pn(vec3 p) {
      vec3 i = floor(p); vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
      vec3 f = cos((p-i)*3.141592653589793)*(-.5) + .5;   a = mix(sin(cos(a)*a), sin(cos(1.+a)*(1.+a)), f.x);
      a.xy = mix(a.xz, a.yw, f.y);   return mix(a.x, a.y, f.z);
      }
vec3 co=vec3(1.); vec2 q; float radius=0.18,dp=6.9,pw=1.; float vr1=1.,vr2=1.,vr3=1.,vr4=1.,vr5=1.,vr6=1.,vr7=1.,vr8=1.,vr9=1.,vr10=1.;
float r (vec2 c,vec2 d){vec2 k=abs(q-c)-0.5*d;return max(k.x,k.y);}
float rr(vec2 c,vec2 d){d-=vec2(2.0*radius); return abs(length(max(abs(q-c)-0.5*d,0.0))-radius);}
float cpu(vec2 p){
      q=p;q.x*=3.;float i=floor(q.x);q.x=fract(q.x);q-=0.5; float d=1.;
      if(i==0.)d=max(rr(vec2(0.),vec2(.7)),-r(vec2(0.35,0.),vec2(1.,0.3)));
      else if(i==1.)d=min(max(rr( vec2(-0.2,0.175),vec2(1.1,.35)),-r( vec2(-1.35,0.),vec2(2.))),max(abs(r(vec2(0.),vec2(.7))),-r(vec2(0.15,0.),vec2(1.,2.))));
      else if(i==2.)d=max(rr(vec2(0.,0.2),vec2(.7,1.1)),-r(vec2(0.,1.35),vec2(2.)));
      return pow(clamp(d*dp,0.,1.),pw);
      }
vec3 flx(vec2 p,float ct){
     float t; vec3 q=vec3(p,p.x-p.y+iTime*0.3);
     t=abs(pn(q)); t+=.5*abs(pn(q*2.)); t+=.25*abs(pn(q*4.));t*=0.5;
     vec3 c=clamp(3.*abs(fract(fract(ct)+vec3(0.,2./3.0,1./3.0))*2.-1.)-1.,0.,1.);
     return pow(vec3(1.-t),c+1.5);
     }
float sk(float g){g=abs(g*40.);return cos(g)*pow(1.-clamp(g/11.,0.,1.),2.);}
float scv(float t){t=clamp(t,0.,1.);return t*t*(3.0-2.0*t);}

void main_(void){
     float sc,de,st,t=mod(iTime,55.);
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr8=mix(.024,1. ,st);
        vr10=mix(2.37,1.,st);
        vr2=mix(.02,2.,pow(st,3.));
        co=mix(vec3(1),vec3(4,1,0.1),st);
        vr3=0.;
        vr7=0.;
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=0.;st=scv(t/(sc-de));
        vr8=mix(1.,0.7,st);
        vr10=mix(1.,0.,st);
        vr2=2.;
        co=mix(vec3(4.,1.,0.1),vec3(1.,18.,18.),st);
        st=clamp((t-4.),0.,1.);
        vr7=mix(0.,0.5,st);
        vr3=0.;
        vr5=0.5;
        vr6=3.;
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=0.;st=scv(t/(sc-de));
        vr3=0.;
        vr8=.7;
        vr10=0.;
        vr2=2.;
        co=mix(vec3(1,18,18),vec3(8,20,20),st);
        vr7=mix(0.5,1.,st);
        vr5=mix(0.5,1.,st);
        vr6=mix(3.,1.,st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=0.;st=st=scv(t/(sc-de));
        vr3=0.;
        vr8=mix(0.7,1.,st);
        vr10=mix(0.,1.,st);
        vr2=mix(2.,1.,st);
        co=mix(vec3(8,20,20),vec3(8,2,.4),st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=0.;st=st=scv(t/(sc-de));
        vr3=mix(0.,1.,st);
        co=mix(vec3(8.,2.,.4),vec3(1.),st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr8=1.;
        vr9=mix(1.,1.7,st);
        vr10=mix(1.,1.53,st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr8=mix(1.,3.,st);
        vr9=mix(1.7,1.,st);
        vr10=mix(1.53,1.89,st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr8=mix(3.,2.3,st);
        vr10=mix(1.89,2.4,st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr8=mix(2.3,3.,st);
        vr10=mix(2.4,1.89,st);
        vr1=mix(1.,0.,st);
        vr4=mix(1.,0.,st);
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr8=mix(3.,.5,st);
        vr10=1.89;
        vr1=0.;
        vr4=0.;
        return;}t-=sc;
     sc=5.;if(t<=sc){
        de=2.;st=scv(t/(sc-de));
        vr3=mix(1.,0.,st);
        vr1=mix(0.,1.,st);
        vr7=mix(1.,0.,st);
        vr8=mix(.5,.024 ,st);
        vr10=mix(1.89,2.37,st);
        vr2=mix(1.,.02,pow(st,0.1));
        return;}t-=sc;
        }
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
     float a=iTime*94.24777960;
     vec2 pa=.15*vec2(sin(a),cos(a));
     float asp=iResolution.x/iResolution.y;
     vec2 p=(pa+fragCoord.xy)/iResolution.xy-0.5; main_();
     p*=1./(1.-(vr9-1.)*length(p));
     p*=1.-length(p)*2.*(vr10-1.); p*=vr8; vec2 pp=p*2.; p.y*=3./asp; p*=1.2; float t=iTime*0.4;
     p.x+=0.02*(sk(p.y+cos(t)*3.)-sk(p.y-cos(t*1.1)*2.));
     p+=0.5; float ll=cpu(p); dp=9.3; pw=vr2*6.; float lc=cpu(p);
     vec2 f=vec2(0.001,0); vec3 dl; dl.z=0.06; dl.x=cpu(p-f.xy)-cpu(p+f.xy); dl.y=cpu(p-f.yx)-cpu(p+f.yx);
     vec3 light=normalize(vec3(0.5,-0.5,1.0)); vec3 nd=normalize(dl);
     float s=0.5+0.5*dot(nd,light);  float e=smoothstep(1.,0.4,lc);
     p.x*=3.; p=(0.5*p)+nd.xy*0.6*e; t=iTime*0.04;
     vec3 fx=flx(p,t)*flx(2.1*p+10.,0.333+t*1.1); fx*=vr1*2.;
     fx=pow(fx,vec3(vr3)); fragColor.rgb=pow(s*fx*(0.5+0.5*e),co);
     float lf=ll*vr4-(vr6-1.2);
     vec3 dir=normalize(vec3(pp*vec2(asp*1.6,-1),-1.5)),q,r=vec3(0.,0.,4.);
     float d,ii=1.;e=0.02;
     for(float i=0.;i<64.;i++){d=length(r*vec3(0.1,.5,1.))-1.;q=r; q.y-=2.; d+=(pn(q+vec3(.0,iTime*2.,.0))+pn(q*3.)*.5)*.25*(q.y); d=min(100.-length(q),abs(lf+d))+e; r+=d*dir; if(d<e){ii=i/64.;break;}}
     fragColor.rgb+=vr7*mix(vec3(0.),mix(vec3(1.,.5,.1),vec3(0.1,.5,1),r.y*.02+.4),pow(ii*2.,4.*vr5));
     }


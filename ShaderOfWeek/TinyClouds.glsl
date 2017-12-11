// https://www.shadertoy.com/view/lsBfDz
#define T texture(iChannel0,(s*p.zw+ceil(s*p.x))/2e2).y/(s+=s)*4.
void mainImage(out vec4 O,vec2 x){
    vec4 p,d=vec4(.8,0,x/iResolution.y-.8),c=vec4(.6,.7,d);
    O=c-d.w;
    for(float f,s,t=2e2+sin(dot(x,x));--t>0.;p=.05*t*d)
        p.xz+=iTime,
        s=2.,
        f=p.w+1.-T-T-T-T,
    	f<0.?O+=(O-1.-f*c.zyxw)*f*.4:O;
}
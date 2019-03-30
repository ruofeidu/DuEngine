// https://www.shadertoy.com/view/4t2cRW
float u(vec3 c){return c.y;}
float v(vec3 c,vec2 d){vec2 e=abs(vec2(length(c.xz),c.y))-d;return min(max(e.x,e.y),0.)+length(max(e,0.));}
float w(in vec3 c,in vec3 d){vec2 e=vec2(length(c.xz),c.y);
float f,g;f=-c.y-d.z;g=max(dot(e,d.xy),c.y);return length(max(vec2(f,g),0.))+min(max(f,g),0.);}
vec2 x(vec2 c,vec2 d){return c.x<d.x?c:d;}vec2 y(float c){vec2 d=vec2(c);d=vec2(dot(d,vec2(127.1,311.7)),
                                                                                dot(d,vec2(269.5,183.3)));
                     return -1.+2.*fract(sin(d)*43758.5453123);}
vec2 z(in vec3 c){vec2 d=x(vec2(u(c),1),vec2(v(c-vec3(0),vec2(1,.6)),31.9));for(float e=-.5;e<=.5;e+=.5){
    float f,g;f=e;g=abs(e)<.1?.1:.2;d=x(d,vec2(v(c-vec3(-.5+g,0,f),vec2(.05,.8)),55));d=x(d,
                vec2(w(c-vec3(-.5+g,.9+y(iTime).x/1e2,f),vec3(.5,.08,.1)),30));}
                  for(float e=0.;e<=.5;e+=.25)for(float f=-.25;f<=.25;f+=.25){
                      float g,h;g=abs(f)<.1?-.1:0.;h=0.;d=x(d,vec2(v(c-vec3(e+g,0,f+h),
                                                                     vec2(.02,.8)),50));
                      d=x(d,vec2(w(c-vec3(e+g,.85+y(iTime).x/1e2,f+h),vec3(.4,.03,.06)),30));}
                  return d;}vec2 A(in vec3 c,in vec3 d){float e,f,i,j,k;e=1.;f=20.;i=.002;j=e;k=-1.;
                                                        for(int l=0;l<50;l++){vec2 m=z(c+d*j);if(m.x<i||j>f)break;j+=m.x;k=m.y;}if(j>f)k=-1.;return vec2(j,k);}float B(in vec3 c,in vec3 d,in float e,in float f){float g,h;g=1.;h=e;for(int i=0;i<16;i++){float j=z(c+d*h).x;g=min(g,8.*j/h);h+=clamp(j,.02,.1);if(j<.001||h>f)break;}return clamp(g,0.,1.);}vec3 C(in vec3 c){vec3 d,e;d=vec3(.001,0,0);e=vec3(z(c+d.xyy).x-z(c-d.xyy).x,z(c+d.yxy).x-z(c-d.yxy).x,z(c+d.yyx).x-z(c-d.yyx).x);return normalize(e);}float D(in vec3 c,in vec3 d){float e,f;e=0.;f=1.;for(int g=0;g<5;g++){float h,j;h=.01+.12*float(g)/4.;vec3 i=d*h+c;j=z(i).x;e+=-(j-h)*f;f*=.95;}return clamp(1.-3.*e,0.,1.);}vec3 E(in vec3 c,in vec3 d){vec3 e=vec3(.8,.9,1);vec2 f=A(c,d);float g,h;g=f.x;h=f.y;if(h>-.5){vec3 i,j,k,m,t;i=c+g*d;j=C(i);k=reflect(d,j);e=.45+.3*sin(vec3(.05,.08,.1)*(h-1.));if(h<1.5){float l=mod(floor(5.*i.z)+floor(5.*i.x),2.);e=.4+.1*l*vec3(1);}float l,n,o,p,q,r,s;l=D(i,j);m=normalize(vec3(-.6,.7,-.5));n=clamp(.5+.5*j.y,0.,1.);o=clamp(dot(j,m),0.,1.);p=clamp(dot(j,normalize(vec3(-m.x,0,-m.z))),0.,1.)*clamp(1.-i.y,0.,1.);q=smoothstep(-.1,.1,k.y);r=pow(clamp(1.+dot(j,d),0.,1.),2.);s=pow(clamp(dot(k,m),0.,1.),16.);o*=B(i,m,.02,2.5);q*=B(i,k,.02,2.5);t=vec3(0);t+=1.2*o*vec3(1,.9,.6);t+=1.2*s*vec3(1,.9,.6)*o;t+=.3*n*vec3(.5,.7,1)*l;t+=.4*q*vec3(.5,.7,1)*l;t+=.3*p*vec3(.25)*l;t+=.4*r*vec3(1)*l;t+=.02;e=e*t;e=mix(e,vec3(.8,.9,1),1.-exp(-5e-4*g*g));}return vec3(clamp(e,0.,1.));}mat3 F(in vec3 c,in vec3 d,float e){vec3 f,g,h,i;f=normalize(d-c);g=vec3(sin(e),cos(e),0);h=normalize(cross(f,g));i=normalize(cross(h,f));return mat3(h,i,f);}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    vec2 c,d,e;
    c=fragCoord.xy/iResolution.xy;d=-1.+2.*c;d.x*=iResolution.x/iResolution.y;e=iMouse.xy/iResolution.xy;
    float f=15.+iTime;vec3 g,h,j,k;
    g=vec3(-.5+3.2*cos(.1*f+6.*e.x),1.+2.*e.y,.5+3.2*sin(.1*f+6.*e.x));h=vec3(-.5,-.4,.5);
    mat3 i=F(g,h,0.);j=i*normalize(vec3(d.xy,2.5));k=E(g,j);k=pow(k,vec3(.4545));
    fragColor=vec4(k,1);
}

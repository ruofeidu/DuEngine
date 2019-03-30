// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XsjyDW
// Created by genis sole - 2016
// https://www.shadertoy.com/view/4lVXRm
// License Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International.

//basic ray-marching loop
#define MaxSteps 96
//smallest positive 16 bit float is exp2(-126.)
#define eps exp2(-126.)

//scale of 2d texturing
#define zoom 5.
const float PI = acos(-1.);
const vec2 POSITION = vec2(1.,0.);
const vec2 VMOUSE = vec2(1.);
#define load(P) texture(iChannel1,(P+.5)/iChannelResolution[1].xy,-100.)
#define pi acos(-1.)
#define pih acos(0.)
////phi=golden-Ratio: 1/phi=1-phi
#define phi (sqrt(5.)*.5-.5)
////return 2x2matrix that mirrors a point on a line, that is rotated by r*0.5 radians.
#define r2(r) mat2(sin(r+vec4(pih,0,0,-pih)))
////r2(r) is equal to the matrix of a SINGLE rotation by [r], but (a*r2(r))*r2(r)=a is a double,refletion back and forth.
////see "complex number rotation in 2d", which also uses "half-angles"

    //projecting an iChannel to 3d space.
vec4 project(vec2 p){
 //p*=r2(iTime*.1);
 p/=zoom;    
 p.x*=iResolution.y/iResolution.x;
 p+=vec2(.5);
 p=fract(p); 
 vec4 r=vec4(0);
 r+= texture(iChannel2,p, -100.0);//BufC=float data
 r+= 0.1*texture(iChannel3,p, -100.0);//BufD=3d canvas
 return r;}

vec3 Grid(vec3 ro,vec3 rd){
    ro.z+=sin(length(ro.xy));
 float d =-ro.y/rd.y;
 if(d <=0.)return vec3(.4);    
 vec2 p=(ro.xz + rd.xz*d);
 
 //projecting 2d canvases into 3d traversable plane:
 return project(p).xyz;
    
 p/=zoom;    
 p.x*=iResolution.y/iResolution.x;
 p+=vec2(.5);
 p=fract(p); 
 vec4 r=vec4(0);
 r+= texture(iChannel2,p, -100.0);//BufC=float data
 r+= 0.1*texture(iChannel3,p, -100.0);//BufD=3d canvas
 return r.xyz;
    
 //vec2 e=min(vec2(1.),fwidth(p));
 //vec2 l=smoothstep(vec2(1.),1.-e,fract(p))+smoothstep(vec2(0.),e,fract(p))-(1.-e);  
 //return mix(vec3(.4),vec3(.8)*(l.x+l.y)*.5,exp(-d*.01));
}

//return distance of [p]Point to box [s]size box [r]Roundness
float dfBox(vec3 p,vec3 s,float r){return length(max(abs(p)-s+vec3(r),0.0))-r;}

#define opU(a,b) a=min(a,b);
//offset mod() for repeating space, xplained by "hg_sdf"
#define pMod(x,d) (mod(x+d*.5,d)-d*.5)
float df2(vec3 p){
 float r=p.z-.1*sin(1.5*length(p.xy             )-iTime)
            -.1*sin(1.5*length(p.xy*.61-vec2(55))-iTime);
                 p.z+=.5;
 //p.z=pMod(p.z,100.);
 vec3 q=vec3(pMod(p.xy,vec2(20,10)),p.z);
 opU(r,length(q-vec3(0,0,5))-1.);
 q=vec3(pMod(p.xy,vec2(17,13)),p.z);
 opU(r,dfBox(q-vec3( 3, 1,1.),vec3(2),0.15));
 q=vec3(pMod(p.xy,vec2(61,21)),p.z);
 opU(r,dfBox(p-vec3(-3, 1,1.),vec3(2),1.2));
 opU(r,dfBox(p-vec3( 0,-3,1.),vec3(2),.7));return r;}

//distance field returns distance of p ti defined geometry
float df(vec3 p){
  return df2(p);
  vec3 sphereCenter=vec3(0);
  return length(p-sphereCenter)-1.;
  //return sin(length(p.xy))-p.z;
}

vec3 normal(vec3 p){const vec2 e=vec2(.001,0);return normalize(vec3(
 df(p+e.xyy)-df(p-e.xyy),df(p+e.yxy)-df(p-e.yxy),df(p+e.yyx)-df(p-e.yyx)));}
//below normal has a branch for very small normals

vec3 normal2(vec3 p){const vec2 e=vec2(.01,0);
 vec3 n=vec3(df(p+e.xyy)-df(p-e.xyy),df(p+e.yxy)-df(p-e.yxy),df(p+e.yyx)-df(p-e.yyx));
 if(length(n)<0.01)return vec3(0);//makes is easier to distinguish if the camera is far from any surface.
 return normalize(n);}

//#define dynamicEps

//#define eps 1e-4
//[o]=rayOrigin [d]=rayDirection
vec4 rm2(vec3 o,vec3 d){d=normalize(d);
 float e=0.;//total distance
 for(int i=0;i<MaxSteps;i++){
  if(df(o+d*e)<eps)break;//surface hit at .xyz with distance .w to [in ro]
  e+=df(o+d*e);//increment total distance marched on ray
 }return vec4(o,e);}//surface missed

#ifdef dynamicEps
//this is experimental tweaking
const float verysmallpositive=FPSmultipier*0.0000000000000000000000000000000000000117;//3.5/1e40;//taking 1./1e40 as planck constant for floats in gl.
const float almostone=1.+verysmallpositive*20.;
//i find values like these to cause a scene with a horizon co compile as fast as a scene that looks down at a flat ground.
#endif
float rm(vec3 o,vec3 i){float e,d;for(int j=0;j<MaxSteps;j++){float p=df(o+i*d);if(p<e)return d;d+=p;
#ifdef dynamicEps                                 
 e=e+verysmallpositive+e*almostone;
#endif
 }return d;}

//////Camera functions.start

//camera.rm
vec3 Camera2(in vec2 fragCoord,out vec3 o){
 vec2 m = load(VMOUSE).xy/iResolution.x;
 m.y=-m.y;    
 float a=1./max(iResolution.x, iResolution.y);
 vec3 d=normalize(vec3((fragCoord-iResolution.xy*.5)*a,.5));
 mat3 rotX = mat3(1.0, 0.0, 0.0, 0.0, cos(m.y), sin(m.y), 0.0, -sin(m.y), cos(m.y));
 mat3 rotY = mat3(cos(m.x), 0.0, -sin(m.x), 0.0, 1.0, 0.0, sin(m.x), 0.0, cos(m.x));
 d =rotY*(rotX*d);
 return normalize(d);}

//camera.ollj
void Camera(vec2 q,vec3 e,vec3 t,vec3 u,out vec3 o,out vec3 i,float v){	
 vec3 z=normalize(t-e),x=normalize(cross(z,u)),y=normalize(cross(x,z))*q.y;x*=q.x;//vec3 x,y,z==vec3 u,v,w
 float f=acos(dot(z,normalize(x))),//fow.xy
 s=(10./(2.*tan(abs(f)/2.)));o=e+(x+y)*(.15+.5*v)*s;i=normalize((e+z*2.+(x+y)*s)-o);}


const float lookUp=.3;
//all while lookDown is just fine being >.4, allowing you to look down into the abyss:
const float lookDown=.4;
vec3 Camera(in vec2 uv,out vec3 o){
  float el=0.;
  float az=0.;
  if(iMouse.z>0.){
    az=az + 2.*acos(-1.)*iMouse.x;
    el=clamp (el + 0.8 *pi*iMouse.y,-lookDown*pi, lookUp * pi);
  }
  vec3 potision=vec3(0.);
  vec3 target=vec3(0,-1.,0.);
  vec3 vd=potision - target;
  vec2 ori = vec2 (el, az + ((length (vd.xz) > 0.) ? atan (vd.x, vd.z) : pih));
  vec2 ca = cos (ori),sa=sin (ori);
  mat3 vuMat = mat3 (ca.y, 0., -  sa.y, 0., 1., 0., sa.y, 0., ca.y) *
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  return vuMat*normalize (vec3(uv, 2.5));}
//from   https://www.shadertoy.com/view/MsScDz

//////camera functions.end
#define ccc color=clamp(color,vec3(0),vec3(1));
void mainImage( out vec4 Out, in vec2 fragCoord ){
	vec3 o = load(POSITION).xyz;
    o=vec3(o.x,-o.z,o.y);//simple 90° rotation
    vec3 d = vec3(0.0);
    d=Camera2(fragCoord,o);//i is rotated by camera
    vec3 color=vec3(0);
    o+=vec3(9,6,0);//camera position offset to better fit the distanceField
    d=vec3(d.x,-d.z,d.y);//simple 90° rotation
    vec3 dist=vec3(rm(o,d));
    color=pow(fract(d),floor(d));
   
    vec3 hit=o+d*dist;//3d space were ray hit a surface
    vec3 n=normal(hit);
    color=n*.5+.5;//surface normals, shifted to visible range
    vec2 a=vec3(hit).xy;
    a.y*=-sign(n.z);
    color-=n.z*project(a).xyz;ccc
    a=vec3(hit).xz;
    a.x*=sign(n.y);
    color-=n.y*project(a*9.).xyz;ccc
    a=vec3(hit).yz;
    a.x*=-sign(n.x);
    color-=n.x*project(a*9.).xyz;ccc
     
        
    //color.xyz = Grid(o,d);//optionally add the old raytraced 2d plane grid.
    
    //my way of doing "distance fog"
    color=clamp(color,vec3(0),vec3(1));
    color*=pow(pow(color,vec3(.5e-1)),dist-3.);
    
    color.xyz=pow(color.xyz, vec3(0.4545));
    Out = vec4(color.xyz, 1.0);
}

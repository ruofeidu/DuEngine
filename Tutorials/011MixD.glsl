// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XsjyDW
//better documented: https://www.shadertoy.com/view/XsByDW

//this is a core 2d canvas with core basics.

////A define is identical to an "alias" or "bind", a useful shorthand.
#define zoom 5.

#define pi acos(-1.)
#define pih acos(0.)
////phi=golden-Ratio: 1/phi=1-phi
#define phi (sqrt(5.)*.5-.5)

////return a sinusoid over time with range.y [-1 .. 1] & wavelength of 1 second.
#define hz sin(iTime*pi*2.)
////return a sinusoid over time with range.y [ 0 .. 1] & wavelength of 1 second.
#define hz1 (hz*.5+.5)

////By discarding the whole part (of a line) with x=fract(x), you get a seesaw with range.y [0 .. 1];
#define frac(a) a=fract(a)
////ss2t(a) changes a seesaw waves output (range [0..1]) to a triangle wave.
#define ss2t(a) a=abs(a*2.-1.)

////return 2x2matrix that mirrors a point on a line, that is rotated by r*0.5 radians.
#define r2(r) mat2(sin(r+vec4(pih,0,0,-pih)))
////r2(r) is equal to the matrix of a SINGLE rotation by [r], but (a*r2(r))*r2(r)=a is a double,refletion back and forth.
////see "complex number rotation in 2d", which also uses "half-angles"

//return polar (distamce,angle) coordinates of carthesian (x,y) input.
//vec2 c2p(vec2 p){return vec2(length(p),atan(p.y,p.x));}
//return carthesian (x,y) coordinates of polar (distamce,angle) input.
//vec2 p2c(vec2 p){return p.x*vec2(cos(p.y),sin(p.y));}

vec2 frame(vec2 p){p/=iResolution.xy;
    p-=vec2(.5);//move xy=vec2(0,0) to the center of range [0 .. 1].xy
    p*=zoom;//scale by [zoom]
    p.x*=iResolution.x/iResolution.y;//m.x scales by aspect ratio.
  //p=p*r2(iTime);//rotation transform, clockwise over time
  //p=p*r2(sin(iTime*phi*2.)*.1);//rotation transform, PENDULUM over time
return p;}

//if(a p.dimension is exactly on a cell border && a direction is negative) cubeid.dimension-=1.
//vec3 getRt(vec3 p, vec3 d){return p-step(d,vec3(0));}//likely faster.
vec3 getRt(vec3 p, vec3 d){return p-vec3(lessThan(d,vec3(0)));}//works on older gl versions
//caveat if(on cell border and parallel to it) the lower cell(s) get(s) ignored

float df(vec2 p){
    vec3 pp=vec3(p,0.);
    //p=getRt2(p,p);
    vec2 mouse=frame(iMouse.xy)-p;
    float DitanceToMouse =length(mouse);//distance of p to framed-mouse
    float DitanceToMetaball=DitanceToMouse*length(p);//simple metaball.
    float d=0.;
    d-=hz*.1;//oscillate [d] a little bit over time. (larger oscillations distract too much)
  //d+=DitanceToMouse;
  
  //d+=max(abs(mouse.x),abs(mouse.y));//distance to square
  //d+=min(abs(p.x),abs(p.y));//distance to cross
  //d+=max(abs(p.x),abs(p.y))*(3.-hz1)-min(abs(mouse.x),abs(mouse.y));//distance to (distorting) star.
  
  d+=DitanceToMetaball-2.;
  //d+=min(length(p),DitanceToMouse)*phi*4.-2.;//union of 2 distances to 2 points via min(a,b)
  //d+= min(DitanceToMouse*1.5,DitanceToMetaball)-2.;//union of 2 distances 
////mix(a,b,c) does linear interpolation on a line trough a and b, c=0.0 returns a,c=1.0 returns b:
  //d+= mix(DitanceToMetaball,min(DitanceToMouse*1.5,DitanceToMetaball),hz)-2.;
////max(a,b) returns the UNION of 2 distance fields [a] and [b]
  //d+=max(length(p),  DitanceToMouse     )-1.;//distance to union
////max(a,-b) returns the distance to shpe [a], substracted by distance to shape [b].
////(but that is for distances to volumes, in 2d we need an offset (here -2.)):
  //d+=max(length(p)-2.,-(DitanceToMouse-2.));
  //d+=(DitanceToMouse+length(p))-2.;//(poorly scaled) oval
  //d+= DitanceToMouse/length(p)+length(p)-2.;//hearty
    return d;//return distance to mouse
}////see http://mercury.sexy/hg_sdf/

//[p]=framed screenspace pixel (position of pixel on screen). [d]=
vec3 cam(vec2 p,vec3 d){
 mat3 m=mat3(1,0,0,   0,1,0 ,   0,0,1);
 return vec3(p,1.)*m;
}

void mainImage(out vec4 Out,in vec2 In){vec2 p=frame(In);
                                        
    
                                        
    vec2 p2=p;//we change p soon, and copy a backup of it here.
    float c=length(p);//length(a.xyzw) returns euclidean distance, pythagrean, squareroot of sum of squares.
    frac(p);//.xy grid <- seesaw
    ss2t(p);//.xy grid    seesaw <- triangle
    p*=p*p; //f(p)=p*p*p; simple way to make p more exponential (for p range[0 .. 1])
                               
    frac(c);//distance to point (0,0) <- seesaw
  //ss2t(c);//distance to point (0,0)    seesaw <- triangle
    c*=.5;
    c*=hz1;//multiply [c] by a sinusoid over time see "#define hz..."
    Out=vec4(c,p,1.);//set the "out vec4 Out" value, 

    float di=df(p2);//di stores [distance of [p2] to distance field df()
    frac(di);//display distance fiels just as we display distance to point (0,0)
  //di=step(di+hz1,1.);//display distance field as "inside and outside of distance 1.0"
  //di=1.-di;//optional inversion, with offset
    Out.xyz+=di*.5;//show distance field. Additive visualization is lazy and fast (and bad style)
///end of distance field code
                                        
    vec3 cent=getRt(vec3(0),vec3(0,1,1));
    Out.xyz+=step(length(p2-cent.xy),.1);
            
////post processing:
    Out*=Out;//f(Out)=Out*Out; simple way to increase contrast.
}
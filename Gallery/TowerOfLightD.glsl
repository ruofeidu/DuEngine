// https://www.shadertoy.com/view/lllBRn
//////////////////////////////////////////////////////////////////////////////////////
// TOWER BUFFER  -   RENDERS TOWER ONLY
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Buffer C. Capture rendered data from previous buffer
// Channel 1 = Buffer D. This buffer for use in AA pass.
// Channel 2 = Buffer A. Read data from data-buffer.
// Channel 3 = Organic3 texture. Used to create tower stone look.
#define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
#define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
#define PI 3.14159265359
#pragma optimize(off) 
#define NO_UNROLL(X) (X + min(0,iFrame))

// Delete one or several of below defines to increase performance
//#define PERFORM_AO_PASS
#define PERFORM_AA_PASS
#define SHADOWS
//#define HIGH_QUALITY

// Try enabling below define if shader doesn´t compile
//#define LOWRES_TEXTURES

vec3 sunPos = normalize( vec3(0.50, 1.0, 1.0) );

float winDist=100000.0;
float dekoDist=100000.0;
float steelDist=100000.0;
float lampDist=100000.0;
float doorDist=100000.0;


struct RayHit
{
  bool hit;  
  vec3 hitPos;
  vec3 normal;
  float dist;
  float depth;
  float winDist;
  float dekoDist;
  float steelDist;
  float glassDist;
  float lampDist;
  float doorDist;
};


float noise(vec3 p)
{
  vec3 ip=floor(p);
  p-=ip; 
  vec3 s=vec3(7, 157, 113);
  vec4 h=vec4(0., s.yz, s.y+s.z)+dot(ip, s);
  p=p*p*(3.-2.*p); 
  h=mix(fract(sin(h)*43758.5), fract(sin(h+s.x)*43758.5), p.x);
  h.xy=mix(h.xz, h.yw, p.y);
  return mix(h.x, h.y, p.z);
}


float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x, p.y);
  return length(q)-t.y;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa, ba)/dot(ba, ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz), p.y)) - h;
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}

float sdEllipsoid( vec3 p, vec3 r )
{
  return (length( p/r ) - 1.0) * min(min(r.x, r.y), r.z);
}

float sdConeSection( vec3 p, float h, float r1, float r2 )
{
  float d1 = -p.y - h;
  float q = p.y - h;
  float si = 0.5*(r1-r2)/h;
  float d2 = max( sqrt( dot(p.xz, p.xz)*(1.0-si*si)) + q*si - r2, q );
  return length(max(vec2(d1, d2), 0.0)) + min(max(d1, d2), 0.);
}

float fCylinder(vec3 p, float r, float height) {
  float d = length(p.xy) - r;
  d = max(d, abs(p.z) - height);
  return d;
}

float fCylinderH(vec3 p, float r, float height) {
  float d = length(p.xz) - r;
  d = max(d, abs(p.y) - height);
  return d;
}

float fCylinderV(vec3 p, float r, float height) {
  float d = length(p.yz) - r;
  d = max(d, abs(p.x) - height);
  return d;
}

float fOpPipe(float a, float b, float r) {
  return length(vec2(a, b)) - r;
}

float fOpIntersectionChamfer(float a, float b, float r) {
  return max(max(a, b), (a + r + b)*sqrt(0.5));
}

float fOpUnionChamfer(float a, float b, float r) {
  return min(min(a, b), (a - r + b)*sqrt(0.5));
}

vec2 pModPolar(in vec2 p, float repetitions) {
  float angle = 2.*PI/repetitions;
  float a = atan(p.y, p.x) + angle/2.;
  float r = length(p);
  float c = floor(a/angle);
  a = mod(a, angle) - angle/2.;
  p = vec2(cos(a), sin(a))*r;
  if (abs(c) >= (repetitions/2.)) c = abs(c);
  return p;
}

mat2 r2(float r) {
  float c=cos(r), s=sin(r);
  return mat2(c, s, -s, c);
}
#define pR(p, a) (p)*=r2(a)


  float pModInterval1(inout float p, float size, float start, float stop) {
  float halfsize = size*0.5;
  float c = floor((p + halfsize)/size);
  p = mod(p+halfsize, size) - halfsize;
  if (c > stop) { //yes, this might not be the best thing numerically.
    p += size*(c - stop);
    c = stop;
  }
  if (c <start) {
    p += size*(c - start);
    c = start;
  }
  return c;
}


float SmallWindow( vec3 p)
{
  // AABB
  if ( sdBox(p-vec3(-.65, 1.17, 0.0), vec3(1.))<0.1) 
  {
    // window base
    float d= sdBox(p-vec3(-.65, 1.17, 0.0), vec3(0.08, 0.4, 0.4));       
    // window cutouts
    d= max(d, -sdBox(p-vec3(-.06, 1.17, 0.0), vec3(0.54, 0.36, .36))); 
    d= max(d, -sdBox(p-vec3(-.22, 1.17, 0.0), vec3(0.54, 0.32, .32))); 
    // deco above window  
    d= min(d, sdBox(p-vec3(-0.58, 1.6, 0.), vec3(0.165, 0.04, 0.5)));
    // window steel vertical 
    steelDist= min(steelDist, sdBox(p-vec3(-.62, 1.17, 0.0), vec3(0.02, 0.32, 0.02))); 
    // window steel horizontal 
    vec3 winPos = p-vec3(-.62, 1.03, 0.0);
    pModInterval1(winPos.y, 0.25, 0., 1.0);
    steelDist= min(steelDist, sdBox(winPos, vec3(0.007, 0.018, 0.38))); 
    // deco below window  
    d= min(d, sdBox(p-vec3(-.59, .71, 0.), vec3(0.13, 0.05, 0.45)));
    d= min(d, sdBox(p-vec3(-.59, 0.69, 0.), vec3(0.18, 0.025, 0.50)));
    // deco in the middle below window
    d= min(d, sdBox(p-vec3(-0.70, .49, 0.), vec3(0.25, 0.2, 0.07)));   
    d = fOpIntersectionChamfer(d, -fCylinder(p-vec3(-0.32, .25, 0.), 0.23, 1.63), 0.03);
    return d;
  }
  else
  {
      return 10000.;
  }
}


float Window( vec3 p)
{
  // window base
  float d= sdBox(p-vec3(-0.58, 1.07, 0.), vec3(0.075, 0.6, 0.4));

  if (d<2.0)
  {  
    // window cutouts
    d = max(d, -sdBox(p-vec3(-0.28, 1.07, 0.), vec3(0.25, 0.60, 0.34)));
    d= max(d, -sdBox(p-vec3(-0.21, 1.05, 0.), vec3(1.4, 0.5, 0.25))); 
    d= min(d, sdBox(p-vec3(-0.58, 1.7, 0.), vec3(0.325, 0.06, 0.48)));

    // window steel vertical 
    steelDist= min(steelDist, sdBox(p-vec3(-0.55, 1.17, 0.), vec3(0.01, 0.60, 0.02))); 

    // window steel horizontal 
    vec3 winPos = p-vec3(-0.55, 0.75, 0.);
    pModInterval1(winPos.y, 0.30, 0., 2.0);        
    steelDist= min(steelDist, sdBox(winPos, vec3(0.01, 0.02, 0.4))); 

    d=min(d, max(max(fCylinderV(p-vec3(-0.5, 1.74, 0.), 0.42, 0.13), -sdBox(p-vec3(-0.5, 1.49, 0.), vec3(1., 0.27, 1.5))), -fCylinderV(p-vec3(-0.5, 1.74, 0.), 0.38, 0.53)));

    d= min(d, sdBox(p-vec3(-.52, .42, 0.), vec3(0.13, 0.05, 0.45)));
    d= min(d, sdBox(p-vec3(-.52, 0.40, 0.), vec3(0.18, 0.025, 0.50)));

    // lower decoration 
    d= min(d, sdBox(p-vec3(-0.55, .20, 0.4), vec3(0.15, 0.2, 0.05)));   
    d= min(d, sdBox(p-vec3(-0.55, .20, -0.4), vec3(0.15, 0.2, 0.05)));
    d = fOpIntersectionChamfer(d, -fCylinder(p-vec3(-0.3, .0, 0.), 0.23, 1.63), 0.02);

    // upper decoration 
    dekoDist=min(dekoDist, sdBox(p-vec3(-0.55, 2.63, 0.), vec3(0.3, 0.45, 0.12)));    
    dekoDist = fOpIntersectionChamfer(dekoDist, -fCylinder(p-vec3(-0.22, 2.45, -0.1), 0.21, 0.63), 0.03);
  }
  return d;
}




#define radius 1.6
#define outRad 1.82
#define inRad 1.12

float Map(  vec3 p)
{

  p.y-=21.25;
  float  d=100000.0;
  vec3 checkPos = p;
  winDist=dekoDist=steelDist=lampDist=doorDist = 100000.0;
  d=sdCappedCylinder(p-vec3(0.0, -3.0, 0), vec2(3.20, 12.45));
  if (d>.2) return d;

  float noiseScale=(1.+(0.01*abs(noise(p*22.))));
  float noiseScale2=(1.+(0.03*abs(noise(p*13.))));

  d = sdCappedCylinder(p-vec3(0.0, 3.7, 0), vec2(inRad, .45));

  d=min(d, fCylinderH(p-vec3(0.0, 1.3, 0), radius*noiseScale, 1.80));
  d=min(d, sdConeSection(p-vec3(0.0, -6.0, 0.), 5.3, 2.4*noiseScale, 1.7*noiseScale));
  d=min(d, sdConeSection(p-vec3(0.0, -13.0, 0.), 1.8, 2.8*noiseScale, 2.6*noiseScale));

  // roof /////////////////
  dekoDist=min(dekoDist, sdConeSection(p-vec3(0., 6.7, 0), 0.40, 1.2, 0.8)); 

  checkPos = p;
  checkPos.xz = pModPolar(checkPos.xz, 26.0);   
  checkPos-=vec3(1.2, 6.7, 0);
  pR(checkPos.xy, 0.5);

  dekoDist=fOpUnionChamfer(dekoDist, sdCappedCylinder(checkPos, vec2(0.08, 0.47)), 0.1); // roof

  steelDist=min(steelDist, sdSphere(p-vec3(0., 6.6, 0), 1.05));    
  vec3 pp = p-vec3(0., 8., 0);
  float m = pModInterval1(pp.y, -0.14, 0.0, 2.);         
  steelDist=min(steelDist, sdSphere(pp, 0.20+(0.12*m)));   
  steelDist = fOpUnionChamfer(steelDist, sdCapsule(p-vec3(0., 8., 0), vec3(0, 0., 0), vec3(0, 1.0, 0), 0.013), 0.1);

  checkPos = p;
  // deko and windows steel top
  checkPos.xz = pModPolar(p.xz, 12.0);
  steelDist=min(steelDist, sdCappedCylinder(checkPos-vec3(outRad+0.05, 3.6, 0), vec2(0.03, .42))); // top railing
  steelDist=min(steelDist, sdCappedCylinder(checkPos-vec3(inRad-0.06, 4.4, 0), vec2(0.02, 1.45))); // window grid
  steelDist=min(steelDist, sdBox(checkPos-vec3(inRad-0.19, 6.25, 0), vec3(0.25, .3, 0.25)));
  steelDist=fOpIntersectionChamfer(steelDist, -sdBox(checkPos-vec3(inRad+0.20, 6.25, 0), vec3(0.19, 0.24, 0.19)), 0.12);
  // top window grid
  pp = p-vec3(0.0, 4.4, 0);
  pModInterval1(pp.y, 0.4, 0.0, 2.);          
  steelDist=min(steelDist, sdTorus(pp, vec2(inRad-0.02, .02)));  

  // top railing
  pp = p-vec3(0.0, 3.55, 0);
  m = pModInterval1(pp.y, 0.15, 0.0, 3.);          
  steelDist=min(steelDist, sdTorus(pp, vec2(outRad+0.05, mix(0.02, .035, step(3., m)))));

  #ifdef HIGH_QUALITY  
  d=min(d, sdSphere(p-vec3(0., 4., 0), 0.50));
  // lamp
  lampDist = sdEllipsoid(p-vec3(0., 4.9, 0), vec3(0.5, 0.6, 0.5)*(1.+abs(0.1*cos(p.y*50.))));
  lampDist = min(lampDist, sdCappedCylinder(p-vec3(0.0, 4.5, 0), vec2(0.12, 1.2)));    
  d=min(d, lampDist);
  #endif
    
  // tower "rings"
  pp = p-vec3(0.0, 4., 0);
  m = pModInterval1(pp.y, 1.8, 0.0, 1.);  
  dekoDist=min(dekoDist, sdTorus(pp, vec2(inRad, mix(.11, 0.15, step(1., m)))));                  

  // upper "rings"
  pp = p-vec3(0.0, -0.6, 0);
  m = pModInterval1(pp.y, -1.05, 0.0, 1.);   
  dekoDist=min(dekoDist, sdTorus(pp, vec2(mix(radius+0.15, radius+0.08, step(1., m)), 0.15)));                  


  dekoDist=min(dekoDist, sdTorus(p-vec3(0.0, -.35, 0), vec2(radius-0.05, .15)));
  dekoDist=min(dekoDist, fCylinderH(p-vec3(0.0, -.5, 0), radius+0.02, .15));
  dekoDist=min(dekoDist, fCylinderH(p-vec3(0.0, 3.18, 0), radius+0.35, 0.15));  

  // upper decoration
  pp = p-vec3(0.0, 2.7, 0);     
  dekoDist=min(dekoDist, fCylinderH(pp, radius+0.10, .30)); pp.y-=.15;
  dekoDist=min(dekoDist, fCylinderH(pp, radius+0.28, 0.18)); pp.y-=.15;
  dekoDist=min(dekoDist, fCylinderH(pp, radius+0.46, 0.18));
  checkPos.xz = pModPolar(p.xz, 6.0);
  dekoDist = max(dekoDist, -fCylinderV(checkPos-vec3(0.0, 2.4, 0), 0.6, 2.63));

  // middle and lower "rings"
  pp = p-vec3(0.0, -9., 0);
  m = pModInterval1(pp.y, -2.3, 0.0, 1.);    
  dekoDist=min(dekoDist, sdTorus(pp, vec2( mix( radius+0.6, 2.42, step(1., m)), .25))); 

  #ifdef HIGH_QUALITY
  // windows cutouts   
  checkPos.xz = pModPolar(p.xz, 6.0);   
  d=max(d, -sdBox(checkPos-vec3(2.20, 1.07, 0.), vec3(3.25, 0.6, 0.4))); 
  checkPos.xz = pModPolar(p.xz, 5.0); 
  pp = checkPos-vec3(2.50, -6.83, 0.);
  pModInterval1(pp.y, 3.5, 0.0, 1.);         
  d= max(d, -sdBox(pp, vec3(1.3, 0.35, 0.35)));  
  #endif

  // upper windows   
  checkPos.xz = pModPolar(p.xz, 6.0);   
  winDist = min(winDist, Window(checkPos-vec3(2.20, 0, 0.))); 

  // small windows  (upper deco)
  checkPos.xz = pModPolar(p.xz, 5.0); 

  pp = checkPos-vec3(2.10, -2.44, 0.0);
  m=pModInterval1(pp.y, -3.5, 0., 1.);

  pp-=mix(vec3(0.), vec3(0.28, 0.0, 0.), m);
  dekoDist=min(dekoDist, sdBox(pp, vec3(0.3, 0.4, 0.12)));   
  dekoDist = fOpIntersectionChamfer(dekoDist, -fCylinder(pp+vec3(-.30, -0.4, 0.0), 0.21, 0.63), .03); 
  dekoDist = max(dekoDist, -fCylinder(pp+vec3(-.40, .22, 0.0), 0.51, 0.63));  
  dekoDist=min(dekoDist, sdTorus(p-vec3(0.0, -2.26 - (m*3.55), 0), vec2(radius+0.25, .15)*(1.0+(m*0.14))));

  // small windows  
  pp = checkPos-vec3(2.82, -8.0, 0.);
  m=pModInterval1(pp.y, 3.5, 0., 1.);
  winDist = min(winDist, SmallWindow(pp+mix(vec3(0.), vec3(0.28, 0.0, 0.), m)));   

  #ifdef HIGH_QUALITY
  // make tower hollow
  d=max(d, -sdConeSection(p-vec3(0.0, -6.0, 0.), 5., 2.3, 1.55));
  #endif
    
  dekoDist=min(dekoDist, sdTorus(p-vec3(0., -15.2, 0), vec2(2.5, .75*noiseScale2))); 
  
  dekoDist=min(dekoDist, fCylinder(p-vec3(-0.05, -12.95, 2.25), 0.7, 0.5)); 

  // create door opening    
  float doorOpening = min(sdBox(p-vec3(-0.05, -13.9, 2.5), vec3(1.3, 1.4, 4.6)), fCylinder(p-vec3(-0.05, -12.75, 2.5), 0.6, 4.6));

  dekoDist = min(fOpPipe(dekoDist, doorOpening, 0.13), max(dekoDist, -doorOpening));

  checkPos.xz = pModPolar(p.xz, 8.0);
  d=fOpIntersectionChamfer(d, -fCylinderH(checkPos-vec3(2.95, -15.4, 0), 0.2, 3.6), 0.5);    
  checkPos.xz = pModPolar(p.xz, 16.0);
  d=fOpUnionChamfer(d, fCylinderH(checkPos-vec3(2.2, -10.3, 0), 0.03, 0.8), 0.4);    

  d=max(d, -sdBox(p-vec3(-0., -14., 2.7), vec3(0.6, 1.3, 4.6)));    
  d=max(d, -fCylinder(p-vec3(-0., -12.7, 2.5), 0.6, 4.6));    

  // door   
  doorDist =sdBox(p-vec3(-0., -13.6, 2.0), vec3(0.6, 1.3, 0.4)); 

  // door cutout     
  pp = p-vec3(-0.28, -13., 2.4);
  pModInterval1(pp.x, 0.46, 0., 1.);     
  doorDist=max(doorDist, -sdBox(pp, vec3(0.15, 0.25, 0.08)));   
  pp = p-vec3(-0.28, -13.8, 2.4);   
  doorDist=max(doorDist, -sdBox(pp, vec3(0.15, 0.4, 0.08))); pp.x-=0.46;
  doorDist=max(doorDist, -sdBox(pp, vec3(0.15, 0.4, 0.08))); 

  pp = p-vec3(-0., -15.20, 3.30);
  pp.z+=0.3; pp.y-=0.15;
  dekoDist=min(dekoDist, sdBox(pp, vec3(1.2, .075, 0.4)));  
  pp.z+=0.3; pp.y-=0.15;
  dekoDist=min(dekoDist, sdBox(pp, vec3(1.2, .075, 0.4)));  
      pp.z+=0.3; pp.y-=0.15;
  dekoDist=min(dekoDist, sdBox(pp, vec3(1.2, .075, 0.4)));  
  d=min(d, steelDist);
  d=min(d, dekoDist);
  d=min(d, winDist);
  d=min(d, doorDist);
  return  d;
}




float MapGlass(  vec3 p)
{   

  p.y-=21.25;
  vec3 checkPos = p;
  // tower windows
  float d = sdCappedCylinder(p-vec3(0.0, 5.0, 0), vec2(1.00, .8));
  checkPos.xz = pModPolar(p.xz, 6.0);
  // upper windows
  #ifdef HIGH_QUALITY
  d = min(d, sdBox(checkPos-vec3(1.550, 1.1, 0.), vec3(0.01, .60, 0.3)));   
  #else
  d = min(d, sdBox(checkPos-vec3(1.62, 1.1, 0.), vec3(0.01, .60, 0.3)));   
  #endif  
  checkPos.xz = pModPolar(p.xz, 5.0);
  // middle and lower windows 
  #ifdef HIGH_QUALITY
  checkPos-=vec3(2.03, -6.8, 0.);
  #else
  checkPos-=vec3(2.18, -6.8, 0.);
  #endif
    float m=pModInterval1(checkPos.y, 3.5, 0., 1.);
  return min(d, sdBox(checkPos+mix(vec3(0.), vec3(0.28, 0.0, 0.), m), vec3(0.01, 0.4, .3)));
}


#define calcNormal( pos ) normalize( vec3(Map(pos+vec3(0.02, 0.0, 0.0).xyy) - Map(pos-vec3(0.02, 0.0, 0.0).xyy), 0.5*2.0*0.02, Map(pos+vec3(0.02, 0.0, 0.0).yyx) - Map(pos-vec3(0.02, 0.0, 0.0).yyx) ) )

  float SoftShadow( in vec3 origin, in vec3 direction )
{
  float res = 1.0, t = 0.0, h;
  for ( int i=0; i<NO_UNROLL(16); i++ )
  {
    h = Map(origin+direction*t);
    res = min( res, 7.5*h/t );
    t += clamp( h, 0.02, 0.15);
    if ( h<0.002 ) break;
  }
  return clamp( res, 0.0, 1.0 );
}

RayHit March( vec3 origin, vec3 direction, float maxDist)
{
  RayHit result;
  float t = 0.0, dist = 0.0, glassDist=100000.0;
  vec3 rayPos = vec3(0.);
    float td=0.;
  float precis=.0;
  for ( int i=0; i<NO_UNROLL(120); i++ )
  {
    rayPos =origin+direction*t;
    dist = Map( rayPos);
    #ifdef HIGH_QUALITY
    if(glassDist>0.05)
    { 
      glassDist = min(glassDist, MapGlass(rayPos));
    }
    #else
    glassDist =MapGlass(rayPos);
    dist=min(dist,glassDist); 
    #endif
    precis = 0.001*t;
    if (dist<precis || t>maxDist )
    {
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;                              
      result.hitPos = origin+direction*(t-td);   
      result.winDist = winDist;
      result.dekoDist = dekoDist;
      result.glassDist = glassDist;
      result.steelDist = steelDist;
      result.lampDist = lampDist;
      result.doorDist = doorDist;
      break;
    }
    td= dist*0.65;
      t+=td;
  }    


  return result;
}

mat3 setCamera( vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}

float calcAO( in vec3 pos, in vec3 nor )
{
  float occ = 0.0;
  float sca = 1.0;
  for ( int i=0; i<NO_UNROLL(3); i++ )
  {
    float hr = 0.01 + 0.1*float(i);
    vec3 aopos =  nor * hr + pos;
    float dd = Map( aopos );
    occ += -(dd-hr)*sca;
    sca *= 0.93;
  }
  return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}

// set sky color tone. 
vec3 GetSkyColor(vec3 rayDir)
{ 
  float sun = mix(0., pow( clamp( 0.5 + 0.5*dot(sunPos, rayDir), 0.0, 1.0 ), 3.0 ), smoothstep(.33, .0, rayDir.y));
  float sun2 = clamp( 0.75 + 0.25*dot(sunPos, rayDir), 0.0, 1.0 );

  vec3 col = mix(vec3(156, 140, 164)/255., vec3(166, 134, 150)/255., smoothstep(0.8, 0.00, rayDir.y)*sun2);
  col = mix(col, vec3(239, 181, 169)/255., smoothstep(0.4, .0, rayDir.y)*sun2);
  col = mix(col, vec3(255, 190, 136)/255., smoothstep(.4, 1.0, sun));
  col = mix(col, vec3(255, 135, 103)/255., smoothstep(.8, 1.0, sun));

  col = mix(col, col+vec3(1.0, 0.96, 0.90), pow(max(0., dot(sunPos, rayDir)), 14.0));

  return col;
}



vec3 GetSceneLight(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin, float specSize)
{         
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
  vec3 reflectDir = reflect( rayDir, normal );

  float occ = 1.;
  #ifdef PERFORM_AO_PASS
    occ = calcAO( rayHit.hitPos, normal );
  #endif

    vec3 lightTot = vec3(0.0);
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  float bac = clamp( dot( normal, normalize(vec3(-sunPos.x, 0.0, -sunPos.z)) ), 0.0, 1.0 );

  float fre = clamp(1.0+dot(normal, rayDir), 0.0, 1.0);
  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 2.0);
  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );

  float shadow=1.; 
  #ifdef SHADOWS
    shadow = SoftShadow(rayHit.hitPos+normal*0.001, sunPos);
  #endif
    dif*=shadow;

  lightTot += 1.6*dif*sunColor;

  lightTot += 0.75*amb*vec3(0.35, 0.45, 0.6)*occ;  
  lightTot += 0.270*skylight*GetSkyColor(reflectDir)*occ;
  lightTot += 1.*specLevel*vec3(1., 0.85, 0.75)*dif;  
  fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 2.0)*occ;
  fre = mix(0., mix( .1, 1.0, specLevel*0.5), fre );
  lightTot = mix( lightTot, lightTot+ vec3(3.)*vec3(0.9, 0.6, 0.57), fre );

  return clamp(lightTot, 0., 10.);
}


void ApplyFog(inout vec3 color, vec3 skyColor, vec3 rayOrigin, vec3 rayDir, float depth)   
{
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
  float mixValue = smoothstep(50., 15000., pow(depth, 2.)*0.03);
  float sunVisibility = max(0., dot(sunPos, rayDir));
  // horizontal fog
  vec3 fogColor = mix(sunColor*0.7, skyColor, mixValue);  
  fogColor = mix(fogColor, sunColor, smoothstep(0., 0.5, sunVisibility));   
  color = mix(color, fogColor, mixValue);

  // vertical fog
  const float heightAmount = .008;
  float fogAmount = 0.2 * exp(-rayOrigin.y*heightAmount) * (1.0-exp( -depth*rayDir.y*heightAmount ))/rayDir.y;
  color = mix(color, fogColor, fogAmount);
}

// https://www.shadertoy.com/view/MtsGWH
vec4 BoxMap( sampler2D sam, in vec3 p, in vec3 n, in float k )
{
  vec3 m = pow( abs(n), vec3(k) );
  vec4 x = texture( sam, p.yz );
  vec4 y = texture( sam, p.zx );
  vec4 z = texture( sam, p.xy );
  return (x*m.x + y*m.y + z*m.z)/(m.x+m.y+m.z);
}
vec4 BoxMapFast( sampler2D sam, in vec3 p, in vec3 n, in float k )
{
  vec3 m = pow( abs(n), vec3(k) );
  vec4 x = textureLod( sam, p.yz ,0.4);
  vec4 y = textureLod( sam, p.zx ,0.4);
  vec4 z = textureLod( sam, p.xy ,0.4);
  return (x*m.x + y*m.y + z*m.z)/(m.x+m.y+m.z);
}

vec4 GetMaterial(vec3 rayDir, inout RayHit rayHit, vec2 fragCoord, inout float specSize)
{
  vec2 center;
  float dist;

  float specLevel=1.;
  specSize=12.8;

  #ifdef LOWRES_TEXTURES
  vec3 tex =  BoxMapFast(iChannel3, rayHit.hitPos*0.22, rayHit.normal, 0.5).rgb; 
  vec3 dirtTex =  BoxMapFast(iChannel3, (rayHit.hitPos+vec3(10000.0))*0.13, rayHit.normal, 0.5).rgb;   
  #else
  vec3 tex =  BoxMap(iChannel3, rayHit.hitPos*0.22, rayHit.normal, 0.5).rgb; 
  vec3 dirtTex =  BoxMap(iChannel3, (rayHit.hitPos+vec3(10000.0))*0.13, rayHit.normal, 0.5).rgb;   
  #endif

  float noiseTex = abs(noise(rayHit.hitPos*0.2));

  vec3 scratches = dirtTex*tex;

  vec3 altCol =dirtTex;


  vec3 col = mix(mix(tex, vec3(1.3), 0.6), 0.7*dirtTex, smoothstep(0.196, 0.36, scratches.r));
  altCol = mix(altCol, vec3(1.), smoothstep(0.196, 0.32, scratches.b));


  col = mix(altCol, col, smoothstep(.6, .61, length(12.65-rayHit.hitPos.y)));   
  col = mix(altCol, col, smoothstep(.60, .61, length(15.9-rayHit.hitPos.y))); 
  col = mix(altCol, col, smoothstep(.80, .81, length(19.85-rayHit.hitPos.y)));   
  col = mix(col, altCol, smoothstep(25.15, 25.16, rayHit.hitPos.y));      

  if (length(rayHit.dist-rayHit.winDist)<0.01)
  {
    specSize=10.;
    col = mix(vec3(1.), vec3(0.37), smoothstep(0.156, 0.24, scratches.b))*(1.0+(noiseTex*0.15));
    specLevel=mix(4., 0.45, col.r);
  } else if (length(rayHit.dist-rayHit.dekoDist)<0.01)
  {  
    specLevel=2.; 
    specSize=20.;
    col=altCol;
  } else if (length(rayHit.dist-rayHit.steelDist)<0.01)
  {  
    float fre = clamp(1.0+dot(rayHit.normal, rayDir), 0.0, 1.0);
    vec3 reflectDir = reflect( rayDir, rayHit.normal );
    specLevel=2.2; 
    specSize=6.2;
    col = mix(tex, vec3(1.1), smoothstep(0.14, 0.26, scratches.r));
    col = mix(col, mix(col, GetSkyColor(reflectDir), 0.4), fre);
  } else if (length(rayHit.dist-rayHit.doorDist)<0.01)
  {       
    specLevel=1.2;  
    specSize=10.2;

    col = mix(vec3(0.85), vec3(0.19), smoothstep(0.14, 0.3, scratches.r));
  } 
  else
  {
    vec3 dirtMask = mix(col, min(col, dirtTex), smoothstep(0.13, 0.22, scratches.r));
    col=mix(dirtMask, col, 0.2+(0.8*smoothstep(0., 0.84, rayHit.dekoDist)));
    col=mix(dirtMask, col, 0.2+(0.8*smoothstep(0., 0.42, rayHit.winDist)));
  }

  vec3 moss =  mix(col, tex*vec3(0.356, 0.415, 0.328), 0.7);
  moss = mix(moss, col, smoothstep(4.5, 10., rayHit.hitPos.y));
  col = mix(col, moss, smoothstep(-.75, 0.1, 0.3+abs(noise(rayHit.hitPos*4.))-(0.11*rayHit.hitPos.y)));

  specLevel = mix(2.*specLevel, specLevel*0.3, smoothstep(0.14, 0.26, scratches.b));


  col *= 0.1+(max(0.7, dirtTex.b));   

  // make specs irregular by using texture intensity to scale the values
  specLevel*=tex.r;
  specSize*=tex.r;
        
  #ifdef HIGH_QUALITY   
  // color lamp
  col = mix(vec3(1.0), col, smoothstep(0., 1.1, length(rayHit.dist-rayHit.lampDist)));
  specLevel = mix(3., specLevel, step(0.01, length(rayHit.dist-rayHit.lampDist)));
  specSize = mix(6., specSize, step(0.01, length(rayHit.dist-rayHit.lampDist)));
  #endif
    
  return vec4(col, specLevel);
}


void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  sunPos =  readRGB(ivec2(50, 0));
  vec3 camData  = readRGB(ivec2(52, 0));  

  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;


  vec3 rayOrigin = vec3(camData.z*cos(camRot.x), camData.y, camData.z*sin(camRot.x) );    
  rayOrigin.y = readRGB(ivec2(62, 0)).y;
  mat3 ca = setCamera( rayOrigin, vec3(0., camData.y+(11.*camRot.y), 0. ), 0.0 );
  vec3 rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );

  // vec4 color = vec4(0.2,0.2,0.16,1000000000.);//texture(iChannel0, uv);
  vec4 color = textureLod(iChannel0, uv,0.);

  float bufferDepth = color.a;
  color.a=0.;

  RayHit marchResult = March(rayOrigin, rayDir, min(110.,bufferDepth));

  // only draw if ray hit is closer to camera origin than the same position in the buffer.
    if (marchResult.hit)
    {
      float specSize = 1.0;
      marchResult.normal = calcNormal(marchResult.hitPos);  
        
     #ifdef HIGH_QUALITY   
     vec4 col = GetMaterial(rayDir, marchResult, fragCoord, specSize);

      // get lightning based on material
      vec3 light = GetSceneLight(col.a, marchResult.normal, marchResult, rayDir, rayOrigin, specSize);   
      // apply lightning
      color.rgb = col.rgb*light;

      ApplyFog(color.rgb, GetSkyColor(rayDir), rayOrigin, rayDir, marchResult.depth);

    
     #else
     if (marchResult.dist==marchResult.glassDist)
     {       
     vec3 sky= GetSkyColor(rayDir*=vec3(-1., 1., -1.));
     color.rgb= mix(mix(color.rgb*0.4, sky, length(sky)*0.36), color.rgb, step(0.05, marchResult.glassDist));    
     }
     else
     {
        
      vec4 col = GetMaterial(rayDir, marchResult, fragCoord, specSize);

      // get lightning based on material
      vec3 light = GetSceneLight(col.a, marchResult.normal, marchResult, rayDir, rayOrigin, specSize);   
      // apply lightning
      color.rgb = col.rgb*light;

      ApplyFog(color.rgb, GetSkyColor(rayDir), rayOrigin, rayDir, marchResult.depth);
     }  
     #endif
        
      color.a+=1.;
    }
  

    #ifdef HIGH_QUALITY
    vec3 sky= GetSkyColor(rayDir*=vec3(-1., 1., -1.));
    color.rgb= mix(mix(color.rgb*0.4, sky, length(sky)*0.36), color.rgb, step(0.05, marchResult.glassDist));
    #endif
 
    
 #ifdef PERFORM_AA_PASS
    // Perform AA pass
    if( iFrame>0 && bufferDepth<5000.) 
    {
            // if the camera is kept steady, switch to fine AA pass.
            if(length(readRGB(ivec2(62, 0))-readRGB(ivec2(60, 0)))>0.)           
       {
            // better for moving cameras
            vec3 oldColor = textureLod(iChannel1, uv,1.0).rgb;
            color.rgb = mix(color.rgb,oldColor,max(0.2,0.85*(clamp(bufferDepth,1.,100.)/500.)));
       }      
            else
            {
                  // good for static camera
             vec3 oldColor = texelFetch(iChannel1, ivec2(fragCoord-0.5), 0 ).rgb;
            color.rgb = mix( oldColor, color.rgb, 0.15 );
            }
    }   
  #endif

  fragColor = color;
}

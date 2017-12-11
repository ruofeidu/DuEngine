// https://www.shadertoy.com/view/MlscWX
//////////////////////////////////////////////////////////////////////////////////////
// PLANE BUFFER   -   RENDERS PLANE ONLY
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Buffer B. Get the colors of the terrain buffer render.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = Buffer A. Read data from data-buffer.
// Channel 3 = Forest blurred cube map. Used in reflections in plane window and hull.

  #pragma optimize(off) 
#define PI acos(-1.)
  #define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
  #define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
  #define RAYSTEPS 300
  #define CLOUDLEVEL -70.0
  float turn=0., pitch = 0., roll=0., rudderAngle = 0.;
float speed = 0.5;
vec3 checkPos=vec3(0.);
vec3 sunPos=vec3(0.);
const vec3 sunColor = vec3(1.00, 0.90, 0.85);
vec3 planePos=vec3(0.);
const vec3 eps = vec3(0.02, 0.0, 0.0);

float winDist=10000.0;
float engineDist=10000.0;
float eFlameDist=10000.0;
float blackDist=10000.0;
float bombDist=10000.0;
float bombDist2=10000.0;
float missileDist=10000.0;
float frontWingDist=10000.0;
float rearWingDist=10000.0;
float topWingDist=10000.0;
vec2 missilesLaunched=vec2(0.);

float sgn(float x) 
{   
  return (x<0.)?-1.:1.;
}

struct RayHit
{
  bool hit;  
  vec3 hitPos;
  vec3 normal;
  float dist;
  float depth;

  float winDist;
  float engineDist;
  float eFlameDist;
  float blackDist;
  float bombDist;
  float bombDist2;
  float missileDist;
  float frontWingDist;
  float rearWingDist;
  float topWingDist;
};

float noise2D( in vec2 pos, float lod)
{   
  vec2 f = fract(pos);
  f = f*f*(3.0-2.0*f);
  vec2 rg = textureLod( iChannel1, (((floor(pos).xy+vec2(37.0, 17.0)) + f.xy)+ 0.5)/64.0, lod).yx;  
  return -1.0+2.0*mix( rg.x, rg.y, 0.5 );
}
float noise2D( in vec2 pos )
{
  return noise2D(pos, 0.0);
}

float noise( in vec3 x )
{
  vec3 p = floor(x);
  vec3 f = fract(x);

  float a = textureLod( iChannel1, x.xy/64.0 + (p.z+0.0)*120.7123, 0.1 ).x;
  float b = textureLod( iChannel1, x.xy/64.0 + (p.z+1.0)*120.7123, 0.1 ).x;
  return mix( a, b, f.z );
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

float sdEllipsoid( vec3 p, vec3 r )
{
  return (length( p/r.xyz ) - 1.0) * r.y;
}

float sdConeSection( vec3 p, float h, float r1, float r2 )
{
  float d1 = -p.z - h;
  float q = p.z - h;
  float si = 0.5*(r1-r2)/h;
  float d2 = max( sqrt( dot(p.xy, p.xy)*(1.0-si*si)) + q*si - r2, q );
  return length(max(vec2(d1, d2), 0.0)) + min(max(d1, d2), 0.);
}

float fCylinder(vec3 p, float r, float height) {
  float d = length(p.xy) - r;
  d = max(d, abs(p.z) - height);
  return d;
}
float fSphere(vec3 p, float r) {
  return length(p) - r;
}

float sdHexPrism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.y-h.y, max((q.z*0.866025+q.x*0.5), q.x)-h.x);
}

float fOpPipe(float a, float b, float r) {
  return length(vec2(a, b)) - r;
}

vec2 pModPolar(vec2 p, float repetitions) {
  float angle = 2.*PI/repetitions;
  float a = atan(p.y, p.x) + angle/2.;
  float r = length(p);
  float c = floor(a/angle);
  a = mod(a, angle) - angle/2.;
  p = vec2(cos(a), sin(a))*r;
  if (abs(c) >= (repetitions/2.)) c = abs(c);
  return p;
}

float pModInterval1(inout float p, float size, float start, float stop) {
  float halfsize = size*0.5;
  float c = floor((p + halfsize)/size);
  p = mod(p+halfsize, size) - halfsize;
  if (c > stop) {
    p += size*(c - stop);
    c = stop;
  }
  if (c <start) {
    p += size*(c - start);
    c = start;
  }
  return c;
}

float pMirror (inout float p, float dist) {
  float s = sgn(p);
  p = abs(p)-dist;
  return s;
}

mat2 r2(float r)
{
  float c=cos(r), s=sin(r);
  return mat2(c, s, -s, c);
}

#define r3(r) mat2(sin(vec4(-1, 0, 0, 1)*acos(0.)+r))
  void pR(inout vec2 p, float a) 
{
  p*=r2(a);
}

float fOpUnionRound(float a, float b, float r) {
  vec2 u = max(vec2(r - a, r - b), vec2(0));
  return max(r, min (a, b)) - length(u);
}

float fOpIntersectionRound(float a, float b, float r) {
  vec2 u = max(vec2(r + a, r + b), vec2(0));
  return min(-r, max (a, b)) + length(u);
}

// limited by euler rotation. I wont get a good plane rotation without quaternions! :-(
vec3 TranslatePos(vec3 p, float _pitch, float _roll)
{
  pR(p.xy, _roll-PI);
  p.z+=5.;
  pR(p.zy, _pitch);
  p.z-=5.; 
  return p;
}

float MapEsmPod(vec3 p)
{
  float dist = fCylinder( p, 0.15, 1.0);   
  checkPos =  p- vec3(0, 0, -1.0);
  pModInterval1(checkPos.z, 2.0, .0, 1.0);
  return min(dist, sdEllipsoid(checkPos, vec3(0.15, 0.15, .5)));
}

float MapMissile(vec3 p)
{
  float d= fCylinder( p, 0.70, 1.7);
  if (d<1.0)
  {
    missileDist = min(missileDist, fCylinder( p, 0.12, 1.2));   
    missileDist =min(missileDist, sdEllipsoid( p- vec3(0, 0, 1.10), vec3(0.12, 0.12, 1.0))); 

    checkPos = p;  
    pR(checkPos.xy, 0.785);
    checkPos.xy = pModPolar(checkPos.xy, 4.0);

    missileDist=min(missileDist, sdHexPrism( checkPos-vec3(0., 0., .60), vec2(0.50, 0.01)));
    missileDist=min(missileDist, sdHexPrism( checkPos+vec3(0., 0., 1.03), vec2(0.50, 0.01)));
    missileDist = max(missileDist, -sdBox(p+vec3(0., 0., 3.15), vec3(3.0, 3.0, 2.0)));
    missileDist = max(missileDist, -fCylinder(p+vec3(0., 0., 2.15), 0.09, 1.2));
  }
  return missileDist;
}

float MapFrontWing(vec3 p, float mirrored)
{
  missileDist=10000.0;

  checkPos = p;
  pR(checkPos.xy, -0.02);
  float wing =sdBox( checkPos- vec3(4.50, 0.25, -4.6), vec3(3.75, 0.04, 2.6)); 

  if (wing<5.) //Bounding Box test
  {
    // cutouts
    checkPos = p-vec3(3.0, 0.3, -.30);
    pR(checkPos.xz, -0.5);
    wing=fOpIntersectionRound(wing, -sdBox( checkPos, vec3(6.75, 1.4, 2.0)), 0.1);

    checkPos = p - vec3(8.0, 0.3, -8.80);
    pR(checkPos.xz, -0.05);
    wing=fOpIntersectionRound(wing, -sdBox( checkPos, vec3(10.75, 1.4, 2.0)), 0.1);

    checkPos = p- vec3(9.5, 0.3, -8.50);
    wing=fOpIntersectionRound(wing, -sdBox( checkPos, vec3(2.0, 1.4, 6.75)), 0.6);

    // join wing and engine
    wing=min(wing, sdCapsule(p- vec3(2.20, 0.3, -4.2), vec3(0, 0, -1.20), vec3(0, 0, 0.8), 0.04));
    wing=min(wing, sdCapsule(p- vec3(3., 0.23, -4.2), vec3(0, 0, -1.20), vec3(0, 0, 0.5), 0.04));    

    checkPos = p;
    pR(checkPos.xz, -0.03);
    wing=min(wing, sdConeSection(checkPos- vec3(0.70, -0.1, -4.52), 5.0, 0.25, 0.9));   

    checkPos = p;
    pR(checkPos.yz, 0.75);
    wing=fOpIntersectionRound(wing, -sdBox( checkPos- vec3(3.0, -.5, 1.50), vec3(3.75, 3.4, 2.0)), 0.12); 
    pR(checkPos.yz, -1.95);
    wing=fOpIntersectionRound(wing, -sdBox( checkPos- vec3(2.0, .70, 2.20), vec3(3.75, 3.4, 2.0)), 0.12); 

    checkPos = p- vec3(0.47, 0.0, -4.3);
    pR(checkPos.yz, 1.57);
    wing=min(wing, sdTorus(checkPos-vec3(0.0, -3., .0), vec2(.3, 0.05)));   

    // flaps
    wing =max(wing, -sdBox( p- vec3(3.565, 0.1, -6.4), vec3(1.50, 1.4, .5)));
    wing =max(wing, -max(sdBox( p- vec3(5.065, 0.1, -8.4), vec3(0.90, 1.4, 2.5)), -sdBox( p- vec3(5.065, 0., -8.4), vec3(0.89, 1.4, 2.49))));

    checkPos = p- vec3(3.565, 0.18, -6.20+0.30);
    pR(checkPos.yz, -0.15+(0.8*pitch));
    wing =min(wing, sdBox( checkPos+vec3(0.0, 0.0, 0.30), vec3(1.46, 0.007, 0.3)));

    // missile holder
    float holder = sdBox( p- vec3(3.8, -0.26, -4.70), vec3(0.04, 0.4, 0.8));

    checkPos = p;
    pR(checkPos.yz, 0.85);
    holder=max(holder, -sdBox( checkPos- vec3(2.8, -1.8, -3.0), vec3(1.75, 1.4, 1.0))); 
    holder=max(holder, -sdBox( checkPos- vec3(2.8, -5.8, -3.0), vec3(1.75, 1.4, 1.0))); 
    holder =fOpUnionRound(holder, sdBox( p- vec3(3.8, -0.23, -4.70), vec3(1.0, 0.03, 0.5)), 0.1); 

    // bomb
    bombDist = fCylinder( p- vec3(3.8, -0.8, -4.50), 0.35, 1.);   
    bombDist =min(bombDist, sdEllipsoid( p- vec3(3.8, -0.8, -3.50), vec3(0.35, 0.35, 1.0)));   
    bombDist =min(bombDist, sdEllipsoid( p- vec3(3.8, -0.8, -5.50), vec3(0.35, 0.35, 1.0)));   

    // missiles
    checkPos = p-vec3(2.9, -0.45, -4.50);

    // check if any missile has been fired. If so, do NOT mod missile position  
    float maxMissiles =0.; 
    if (mirrored>0.) maxMissiles =  mix(1.0, 0., step(1., missilesLaunched.x));
    else maxMissiles =  mix(1.0, 0., step(1., missilesLaunched.y)); 

    pModInterval1(checkPos.x, 1.8, .0, maxMissiles);
    holder = min(holder, MapMissile(checkPos));

    // ESM Pod
    holder = min(holder, MapEsmPod(p-vec3(7.2, 0.06, -5.68)));

    // wheelholder
    wing=min(wing, sdBox( p- vec3(0.6, -0.25, -3.8), vec3(0.8, 0.4, .50)));

    wing=min(bombDist, min(wing, holder));
  }

  return wing;
}

float MapRearWing(vec3 p)
{
  float wing2 =sdBox( p- vec3(2.50, 0.1, -8.9), vec3(1.5, 0.017, 1.3)); 
  if (wing2<0.15) //Bounding Box test
  {
    // cutouts
    checkPos = p-vec3(3.0, 0.0, -5.9);
    pR(checkPos.xz, -0.5);
    wing2=fOpIntersectionRound(wing2, -sdBox( checkPos, vec3(6.75, 1.4, 2.0)), 0.2); 

    checkPos = p-vec3(0.0, 0.0, -4.9);
    pR(checkPos.xz, -0.5);
    wing2=fOpIntersectionRound(wing2, -sdBox( checkPos, vec3(3.3, 1.4, 1.70)), 0.2);

    checkPos = p-vec3(3.0, 0.0, -11.70);
    pR(checkPos.xz, -0.05);
    wing2=fOpIntersectionRound(wing2, -sdBox( checkPos, vec3(6.75, 1.4, 2.0)), 0.1); 

    checkPos = p-vec3(4.30, 0.0, -11.80);
    pR(checkPos.xz, 1.15);
    wing2=fOpIntersectionRound(wing2, -sdBox( checkPos, vec3(6.75, 1.4, 2.0)), 0.1);
  }
  return wing2;
} 

float MapTailFlap(vec3 p, float mirrored)
{
  p.z+=0.3;
  pR(p.xz, rudderAngle*(-1.*mirrored)); 
  p.z-=0.3;

  float tailFlap =sdBox(p- vec3(0., -0.04, -.42), vec3(0.025, .45, .30));

  // tailFlap front cutout
  checkPos = p- vec3(0., 0., 1.15);
  pR(checkPos.yz, 1.32);
  tailFlap=max(tailFlap, -sdBox( checkPos, vec3(.75, 1.41, 1.6)));

  // tailFlap rear cutout
  checkPos = p- vec3(0., 0, -2.75);  
  pR(checkPos.yz, -0.15);
  tailFlap=fOpIntersectionRound(tailFlap, -sdBox( checkPos, vec3(.75, 1.4, 2.0)), 0.05);

  checkPos = p- vec3(0., 0., -.65);
  tailFlap = min(tailFlap, sdEllipsoid( checkPos-vec3(0.00, 0.25, 0), vec3(0.06, 0.05, 0.15)));
  tailFlap = min(tailFlap, sdEllipsoid( checkPos-vec3(0.00, 0.10, 0), vec3(0.06, 0.05, 0.15)));

  return tailFlap;
}

float MapTopWing(vec3 p, float mirrored)
{    
  checkPos = p- vec3(1.15, 1.04, -8.5);
  pR(checkPos.xy, -0.15);  
  float topWing = sdBox( checkPos, vec3(0.014, 0.8, 1.2));
  if (topWing<.15) //Bounding Box test
  {
    float flapDist = MapTailFlap(checkPos, mirrored);

    checkPos = p- vec3(1.15, 1.04, -8.5);
    pR(checkPos.xy, -0.15);  
    // top border    
    topWing = min(topWing, sdBox( checkPos-vec3(0, 0.55, 0), vec3(0.04, 0.1, 1.25)));

    float flapCutout = sdBox(checkPos- vec3(0., -0.04, -1.19), vec3(0.02, .45, 1.0));
    // tailFlap front cutout
    checkPos = p- vec3(1.15, 2., -7.65);
    pR(checkPos.yz, 1.32);
    flapCutout=max(flapCutout, -sdBox( checkPos, vec3(.75, 1.41, 1.6)));

    // make hole for tail flap
    topWing=max(topWing, -flapCutout);

    // front cutouts
    checkPos = p- vec3(1.15, 2., -7.);
    pR(checkPos.yz, 1.02);
    topWing=fOpIntersectionRound(topWing, -sdBox( checkPos, vec3(.75, 1.41, 1.6)), 0.05);

    // rear cutout
    checkPos = p- vec3(1.15, 1., -11.25);  
    pR(checkPos.yz, -0.15);
    topWing=fOpIntersectionRound(topWing, -sdBox( checkPos, vec3(.75, 1.4, 2.0)), 0.05);

    // top roll 
    topWing=min(topWing, sdCapsule(p- vec3(1.26, 1.8, -8.84), vec3(0, 0, -.50), vec3(0, 0, 0.3), 0.06)); 

    topWing = min(topWing, flapDist);
  }
  return topWing;
}

float MapPlane( vec3 p)
{
  float  d=100000.0;
  vec3 pOriginal = p;
  // rotate position 
  p=TranslatePos(p, pitch, roll);
  float mirrored=0.;
  // AABB TEST  
  float test = sdBox( p- vec3(0., -0., -3.), vec3(7.5, 4., 10.6));    
  if (test>1.0) return test;

  // mirror position at x=0.0. Both sides of the plane are equal.
  mirrored = pMirror(p.x, 0.0);

  float body= min(d, sdEllipsoid(p-vec3(0., 0.1, -4.40), vec3(0.50, 0.30, 2.)));
  body=fOpUnionRound(body, sdEllipsoid(p-vec3(0., 0., .50), vec3(0.50, 0.40, 3.25)), 1.);
  body=min(body, sdConeSection(p- vec3(0., 0., 3.8), 0.1, 0.15, 0.06));   

  body=min(body, sdConeSection(p- vec3(0., 0., 3.8), 0.7, 0.07, 0.01));   

  // window
  winDist =sdEllipsoid(p-vec3(0., 0.3, -0.10), vec3(0.45, 0.4, 1.45));
  winDist =fOpUnionRound(winDist, sdEllipsoid(p-vec3(0., 0.3, 0.60), vec3(0.3, 0.6, .75)), 0.4);
  winDist = max(winDist, -body);
  body = min(body, winDist);
  body=min(body, fOpPipe(winDist, sdBox(p-vec3(0., 0., 1.0), vec3(3.0, 1., .01)), 0.03));
  body=min(body, fOpPipe(winDist, sdBox(p-vec3(0., 0., .0), vec3(3.0, 1., .01)), 0.03));

  // front (nose)
  body=max(body, -max(fCylinder(p-vec3(0, 0, 2.5), .46, 0.04), -fCylinder(p-vec3(0, 0, 2.5), .35, 0.1)));
  checkPos = p-vec3(0, 0, 2.5);
  pR(checkPos.yz, 1.57);
  body=fOpIntersectionRound(body, -sdTorus(checkPos+vec3(0, 0.80, 0), vec2(.6, 0.05)), 0.015);
  body=fOpIntersectionRound(body, -sdTorus(checkPos+vec3(0, 2.30, 0), vec2(.62, 0.06)), 0.015);

  // wings       
  frontWingDist = MapFrontWing(p, mirrored);
  d=min(d, frontWingDist);   
  rearWingDist = MapRearWing(p);
  d=min(d, rearWingDist);
  topWingDist = MapTopWing(p, mirrored);
  d=min(d, topWingDist);

  // bottom
  checkPos = p-vec3(0., -0.6, -5.0);
  pR(checkPos.yz, 0.07);  
  d=fOpUnionRound(d, sdBox(checkPos, vec3(0.5, 0.2, 3.1)), 0.40);

  float holder = sdBox( p- vec3(0., -1.1, -4.30), vec3(0.08, 0.4, 0.8));  
  checkPos = p;
  pR(checkPos.yz, 0.85);
  holder=max(holder, -sdBox( checkPos- vec3(0., -5.64, -2.8), vec3(1.75, 1.4, 1.0))); 
  d=fOpUnionRound(d, holder, 0.25);

  // large bomb
  bombDist2 = fCylinder( p- vec3(0., -1.6, -4.0), 0.45, 1.);   
  bombDist2 =min(bombDist2, sdEllipsoid( p- vec3(0., -1.6, -3.20), vec3(0.45, 0.45, 2.)));   
  bombDist2 =min(bombDist2, sdEllipsoid( p- vec3(0., -1.6, -4.80), vec3(0.45, 0.45, 2.)));   

  d=min(d, bombDist2);

  d=min(d, sdEllipsoid(p- vec3(1.05, 0.13, -8.4), vec3(0.11, 0.18, 1.0)));    

  checkPos = p- vec3(0, 0.2, -5.0);
  d=fOpUnionRound(d, fOpIntersectionRound(sdBox( checkPos, vec3(1.2, 0.14, 3.7)), -sdBox( checkPos, vec3(1., 1.14, 4.7)), 0.2), 0.25);

  d=fOpUnionRound(d, sdEllipsoid( p- vec3(0, 0., -4.), vec3(1.21, 0.5, 2.50)), 0.75);

  // engine cutout
  blackDist = max(d, fCylinder(p- vec3(.8, -0.15, 0.), 0.5, 2.4)); 
  d=max(d, -fCylinder(p- vec3(.8, -0.15, 0.), 0.45, 2.4)); 

  // engine
  d =max(d, -sdBox(p-vec3(0., 0, -9.5), vec3(1.5, 0.4, 0.7)));

  engineDist=fCylinder(p- vec3(0.40, -0.1, -8.7), .42, 0.2);
  checkPos = p- vec3(0.4, -0.1, -8.3);
  pR(checkPos.yz, 1.57);
  engineDist=min(engineDist, sdTorus(checkPos, vec2(.25, 0.25)));
  engineDist=min(engineDist, sdConeSection(p- vec3(0.40, -0.1, -9.2), 0.3, .22, .36));

  checkPos = p-vec3(0., 0., -9.24);  
  checkPos.xy-=vec2(0.4, -0.1);
  checkPos.xy = pModPolar(checkPos.xy, 22.0);

  float engineCone = fOpPipe(engineDist, sdBox( checkPos, vec3(.6, 0.001, 0.26)), 0.015);
  engineDist=min(engineDist, engineCone);

  d=min(d, engineDist);
  eFlameDist = sdEllipsoid( p- vec3(0.4, -0.1, -9.45-(speed*0.07)+cos(iTime*40.0)*0.014), vec3(.17, 0.17, .10));
  d=min(d, eFlameDist);

  d=min(d, winDist);
  d=min(d, body);

  d=min(d, sdBox( p- vec3(1.1, 0., -6.90), vec3(.33, .12, .17))); 
  checkPos = p-vec3(0.65, 0.55, -1.4);
  pR(checkPos.yz, -0.35);
  d=min(d, sdBox(checkPos, vec3(0.2, 0.1, 0.45)));

  return min(d, eFlameDist);
}

RayHit TracePlane(in vec3 origin, in vec3 direction)
{
  RayHit result;
  float maxDist = 150.0;
  float t = 0.0, dist = 0.0;
  vec3 rayPos;
  eFlameDist=10000.0;
  for ( int i=0; i<RAYSTEPS; i++ )
  {
    rayPos =origin+direction*t;
    dist = MapPlane( rayPos);

    if (abs(dist)<0.003 || t>maxDist )
    {                
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;                              
      result.hitPos = origin+((direction*t));   
      result.winDist = winDist;
      result.engineDist = engineDist;
      result.eFlameDist = eFlameDist;
      result.blackDist = blackDist;
      result.bombDist = bombDist;
      result.bombDist2 = bombDist2;
      result.missileDist = missileDist;
      result.frontWingDist = frontWingDist;
      result.rearWingDist = rearWingDist;
      result.topWingDist = topWingDist;
      break;
    }
    t += dist;
  }

  return result;
}

float MapLights( vec3 p)
{
  vec3 pOriginal = p;
  // rotate position 
  p=TranslatePos(p, pitch, roll);   
  // mirror position at x=0.0. Both sides of the plane are equal.
  pMirror(p.x, 0.0);

  return max(sdEllipsoid( p- vec3(0.4, -0.1, -9.5), vec3(0.03, 0.03, 0.03+max(0., (speed*0.07)))), -sdBox(p- vec3(0.4, -0.1, -9.6+2.0), vec3(2.0, 2.0, 2.0)));
}

float TraceLights(in vec3 origin, in vec3 direction)
{
  float maxDist = 150.0;
  float t = 0.0;
  vec3 rayPos;
  float dist=10000.;

  for ( int i=0; i<10; i++ )
  {
    rayPos =origin+direction*t;
    dist = min(dist, MapLights( rayPos));
    t += dist;
  }

  return dist;
}

vec3 calcNormal( in vec3 pos )
{    
  return normalize( vec3(MapPlane(pos+eps.xyy) - MapPlane(pos-eps.xyy), 0.5*2.0*eps.x, MapPlane(pos+eps.yyx) - MapPlane(pos-eps.yyx) ) );
}

float SoftShadow( in vec3 origin, in vec3 direction )
{
  float res = 2.0, t = 0.02, h;
  for ( int i=0; i<24; i++ )
  {
    h = MapPlane(origin+direction*t);
    res = min( res, 7.5*h/t );
    t += clamp( h, 0.05, 0.2 );
    if ( h<0.001 || t>2.5 ) break;
  }
  return clamp( res, 0.0, 1.0 );
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}


// Advanced lightning pass
vec3 GetSceneLight(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin, float specSize)
{          
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  vec3 reflectDir = reflect( rayDir, normal );
  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 9.0/specSize);
  vec3 reflection = vec3(texture(iChannel3, reflectDir ).r*1.5);

  float fre = pow( 1.0-abs(dot( normal, rayDir )), 2.0 );
  fre = mix( .03, 1.0, fre );   
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );

  vec3 shadowPos = origin+((rayDir*rayHit.depth)*0.998);

  float shadow = SoftShadow(shadowPos, sunPos);
  dif*=shadow;
  float skyLight = smoothstep( -0.1, 0.1, reflectDir.y );
  skyLight *= SoftShadow(shadowPos, reflectDir );

  vec3 lightTot = (vec3(0.2)*amb); 
  lightTot+=vec3(0.85)*dif;
  lightTot= mix(lightTot, reflection*max(0.3, shadow), fre );
  lightTot += 1.00*specLevel*dif;
  lightTot += 0.50*skyLight*vec3(0.40, 0.60, 1.00);
  lightTot= mix(lightTot*.7, lightTot*1.2, fre );

  fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 4.0);
  fre = mix(0., mix( .1, 1.0, specLevel*0.5), fre );
  lightTot = mix( lightTot, lightTot+ vec3(1.6), fre );

  return lightTot*sunColor;
}

float drawRect(vec2 p1, vec2 p2, vec2 uv) 
{
  vec4 rect = vec4(p1, p2);
  vec2 hv = step(rect.xy, uv) * step(uv, rect.zw);
  return hv.x * hv.y;
}

// Thanks IÃ±igo Quilez!
float line(vec2 p, vec2 a, vec2 b, float size)
{
  vec2 pa = -p - a;
  vec2 ba = b - a;
  float h = clamp( dot(pa, ba)/dot(ba, ba), 0.0, 1.0 );
  float d = length( pa - ba*h );

  return clamp((((1.0+size) - d)-0.99)*100.0, 0.0, 1.0);
}

void AddLetters(vec2 hitPos, inout vec3 col, vec2 linePos)
{
  // text
  vec3 textColor = vec3(0.2);
  vec2 absHitPos2 = vec2(hitPos.x-1.05, hitPos.y);

  pModInterval1(absHitPos2.x, 8., linePos.x, linePos.x+10.);

  // E
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(1.45, 0.4), linePos+vec2(1.45, .9), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(1.45, 0.9), linePos+vec2(1.1, .9), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(1.45, 0.65), linePos+vec2(1.25, 0.65), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(1.45, 0.4), linePos+vec2(1.1, .4), 0.06));
  // F            
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(0.9, 0.4), linePos+vec2(0.9, .9), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(0.9, 0.9), linePos+vec2(.65, .9), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(0.9, 0.65), linePos+vec2(.75, 0.65), 0.06));
  // Z
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(0.45, 0.4), linePos+vec2(.1, 0.9), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(0.45, 0.9), linePos+vec2(.1, 0.9), 0.06));
  col =mix(col, textColor, line(absHitPos2, linePos+vec2(0.45, 0.4), linePos+vec2(.1, 0.4), 0.06));
}


vec3 GetReflectionMap(vec3 rayDir, vec3 normal)
{
  return texture(iChannel3, reflect( rayDir, normal )).rgb;
}

vec4 GetMaterial(vec3 rayDir, inout RayHit rayHit, vec2 fragCoord, inout float specSize)
{
  vec3 hitPos =TranslatePos(rayHit.hitPos, pitch, roll);
  vec2 center;
  float dist;

  float specLevel=0.7;
  specSize=0.7;

  float fre = pow( 1.0-abs(dot( rayHit.normal, rayDir )), 3.0 );
  fre = mix( .03, 1.0, fre );   

  // vec3 tint = vec3(0.62,.50,0.40)*1.15;
  vec3 tint = vec3(1.62, 1.50, 1.30)*0.65;
  vec3 brightCamo =1.15*tint;
  vec3 darkCamo = 0.78*tint;


  vec3 baseTexture = mix(brightCamo, darkCamo, smoothstep(0.5, 0.52, noise(hitPos*1.6)));

  // baseTexture = col;
  vec3 col=mix(brightCamo, darkCamo, smoothstep(0.5, 0.52, noise(hitPos*1.6)));
  vec3 reflection = GetReflectionMap(rayDir, rayHit.normal);
  // create base color mixes
  vec3 lightColor = (vec3(1.0));
  vec3 darkColor = (vec3(0.25));
  vec3 missilBaseCol =  lightColor*0.5;
  vec3 missilBaseCol2 =  darkColor;
  vec3 missilCol = lightColor;
  vec3 missilCol2 = lightColor*0.27;

  if (distance(rayHit.dist, rayHit.topWingDist)<.01)
  { 
    // top wing stripes
    col=mix(darkColor, baseTexture, smoothstep(0.55, 0.57, distance(0.85, hitPos.y)));
    col=mix(lightColor, col, smoothstep(.32, 0.34, distance(0.95, hitPos.y)));

    // create star (top wings)    
    center = vec2(-8.73, 0.95)-vec2(hitPos.z, hitPos.y);
    dist = length(center); 
    col=mix(darkColor, col, smoothstep(0.24, 0.26, dist));
    col=mix(lightColor, col, smoothstep(0.24, 0.26, (dist*1.15)+abs(cos( atan(center.y, center.x)*2.5)*0.13)));
  } else if (distance(rayHit.dist, rayHit.winDist)<.01)
  { 
    // windows
    col=vec3(0.2, 0.21, 0.22)*reflection;
    specSize=3.2;
    specLevel=3.5;
    fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 3.0);
    fre = mix( mix( .0, .01, specLevel ), mix( .4, 1.0, specLevel ), fre );
    col = mix(col, vec3(1.5), fre );
  } else if (distance(rayHit.dist, rayHit.missileDist)<.01)
  {  
    specSize=2.;
    specLevel=2.;
    // small missiles
    col=mix(missilBaseCol, missilCol2, smoothstep(-3.35, -3.37, hitPos.z));
    col=mix(col, missilCol, smoothstep(-3.2, -3.22, hitPos.z));
    col=mix(missilCol2, col, smoothstep(.32, 0.34, distance(-4.75, hitPos.z)));
    col=mix(missilBaseCol, col, smoothstep(.25, 0.27, distance(-4.75, hitPos.z)));
  } else if (distance(rayHit.dist, rayHit.bombDist)<.01)
  { 
    specSize=2.;
    specLevel=1.7;
    // small bombs   
    col=mix(missilCol, missilBaseCol, smoothstep(1.18, 1.2, distance(-4.5, hitPos.z)));      
    col=mix(col, missilCol2, smoothstep(1.3, 1.32, distance(-4.5, hitPos.z)));
  } else if (distance(rayHit.dist, rayHit.bombDist2)<.01)
  {   
    specSize=2.;
    specLevel=1.8;
    // large bomb  
    col=mix(missilBaseCol2, missilCol, smoothstep(1.48, 1.5, distance(-4.1, hitPos.z)));      
    col=mix(col, missilBaseCol, smoothstep(1.6, 1.62, distance(-4.1, hitPos.z)));      
    col=mix(missilBaseCol, col, smoothstep(0.45, 0.47, distance(-4.1, hitPos.z)));
  } else
  {
    // remove camo from wing tip
    col =mix(col, brightCamo, line(vec2(abs(hitPos.x), hitPos.z), vec2(-7.25, 5.), vec2(-1.45, 1.7), 0.3));

    // color bottom gray
    col=mix(lightColor*0.7, col, step(0.01, hitPos.y));

    // front
    col = mix(col, lightColor, smoothstep(3.0, 3.02, hitPos.z));  
    col = mix(col, darkColor, smoothstep(3.08, 3.1, hitPos.z));
    col =mix(col*1.4, col, smoothstep(.07, .09, distance(1.8, hitPos.z)));


    // front wing stripes
    col=mix(darkColor, col, smoothstep(1.4, 1.42, distance(-6.90, hitPos.z)));
    col=mix(lightColor, col, smoothstep(1.3, 1.32, distance(-6.90, hitPos.z)));
    col=mix(darkColor, col, smoothstep(.84, 0.86, distance(-6.7, hitPos.z)));
    col=mix(lightColor, col, smoothstep(.22, 0.235, distance(-6.94, hitPos.z)));

    // vertical stripes   
    float xMod = mod(hitPos.x-0.5, 11.0);
    col=mix(darkColor, col, smoothstep(0.5, 0.52, distance(5., xMod)));
    col=mix(lightColor, col, smoothstep(0.4, 0.42, distance(5., xMod)));


    // boxes 
    vec2 absHitPos = abs(hitPos.xz);

    col =mix(col, col*1.40, drawRect(vec2(0.4, 2.0)-0.05, vec2(0.8, 2.0)+0.05+0.25, absHitPos));
    col =mix(col, col*0.2, drawRect(vec2(0.4, 2.0), vec2(0.8, 2.0)+0.2, absHitPos));

    // side 17      
    vec2 linePos = vec2(-0.55, 0.);
    vec3 textColor = vec3(0.2);
    if (hitPos.x<0.)
    {
      col =mix(col, textColor, line(hitPos.zy, linePos+vec2(0., -0.2), linePos+vec2(0., .2), 0.04));
      col =mix(col, textColor, line(hitPos.zy, linePos+vec2(-0.2, -0.2), linePos+vec2(-.4, -.2), 0.04));
      col =mix(col, textColor, line(hitPos.zy, linePos+vec2(-0.4, -0.2), linePos+vec2(-.25, .2), 0.04));
    } else
    {
      col =mix(col, textColor, line(hitPos.zy, linePos+vec2(-0.35, -0.2), linePos+vec2(-0.35, .2), 0.04));
      col =mix(col, textColor, line(hitPos.zy, linePos+vec2(0.1, -0.2), linePos+vec2(-.15, -.2), 0.04));
      col =mix(col, textColor, line(hitPos.zy, linePos+vec2(-0.15, 0.2), linePos+vec2(.10, -.2), 0.04));
    }  

    if (hitPos.y>0.15)
    {
      // letters BoundingBox
      if (drawRect(vec2(3.2, 3.8)-0.05, vec2(4.9, 4.8), absHitPos)>=1.)
      {
        AddLetters(hitPos.xz, col, vec2(-3.70, 3.60));
      }

      // more boxes 
      col =mix(col, col*1.40, drawRect(vec2(0.2, 3.6)-0.05, vec2(1., 3.6)+0.05+0.35, absHitPos)); 
      col =mix(col, col*0.2, drawRect(vec2(0.2, 3.6), vec2(1., 3.6)+0.3, absHitPos));          
      col =mix(col, col*0.2, drawRect(vec2(3.5, 4.8), vec2(4.5, 5.3), absHitPos));

      // create star (front wings)         
      center = vec2(5., -5.1)-vec2(xMod, hitPos.z);
      dist = length(center);
      col=mix(lightColor, col, smoothstep(0.8, 0.82, dist));
      col=mix(darkColor, col, smoothstep(0.7, 0.72, dist));
      col=mix(lightColor, col, smoothstep(0.7, 0.72, (dist*1.15)+abs(cos( atan(center.y, center.x)*2.5)*0.3)));
      col=mix(darkColor, col, smoothstep(0.6, 0.62, (dist*1.50)+abs(cos( atan(center.y, center.x)*2.5)*0.3)));
    } else
    {
      // bottom details
      col =mix(col, darkColor, line(vec2(abs(hitPos.x), hitPos.z), vec2(0., -1.5), vec2(-0.3, -1.5), 0.06));
      col =mix(col, darkColor, line(vec2(abs(hitPos.x), hitPos.z), vec2(-0.3, -1.5), vec2(-0.3, -1.), 0.085));
    }

    // rear wing stripes
    col=mix(darkColor, col, smoothstep(.55, 0.57, distance(-9.6, hitPos.z)));
    col=mix(lightColor, col, smoothstep(.5, 0.52, distance(-9.6, hitPos.z)));
    col=mix(darkColor, col, smoothstep(.4, 0.42, distance(-9.6, hitPos.z)));

    // esm pods
    col = mix(col, lightColor*0.75, smoothstep(7.02, 7.04, abs(hitPos.x)));

    // stabilizer
    col = mix(col, lightColor*0.75, smoothstep(1.72, 1.74, abs(hitPos.y)));

    // engines exhaust
    col=mix(mix(vec3(0.7), reflection, fre), col, step(.05, rayHit.engineDist));
    specSize=mix(4., specSize, step(.05, rayHit.engineDist));
    col=mix(col*0.23, col, step(.02, rayHit.blackDist));
    col=mix(col+0.5, col, smoothstep(.04, 0.10, distance(2.75, hitPos.z)));
  }
  fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 7.0);
  fre = mix( 0., mix( .2, 1.0, specLevel*0.5 ), fre );
  col = mix( col, vec3(1.0, 1.0, 1.1)*1.5, fre );

  return vec4(col, specLevel);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
  vec2 mo = iMouse.xy/iResolution.xy;
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;
  vec2 cloudPos = vec2(-iTime*1.3, -iTime*.95);
  float CAMZOOM = read(ivec2(52, 0));  

  // read missile data
  missilesLaunched = vec2(read(ivec2(100, 0)), read(ivec2(200, 0)));

  // read roll and speed values from buffer
  turn = read(ivec2(1, 10));
  roll = read(ivec2(1, 1));
  speed = read(ivec2(10, 1));
  pitch = read(ivec2(15, 1));
  rudderAngle = read(ivec2(6, 1));
  sunPos = readRGB(ivec2(50, 0));
  planePos = readRGB(ivec2(55, 0));
  pR(sunPos.xz, turn);

  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;

  vec3 rayOrigin = vec3(CAMZOOM*cos(camRot.x), CAMZOOM*sin(camRot.y), -3.+CAMZOOM*sin(camRot.x) );
  mat3 ca = setCamera( rayOrigin, vec3(0., 0., -3. ), 0.0 );
  vec3 rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );

  // load background from buffer A
  vec4 color =  texture(iChannel0, uv);

  // calculate engine flare
  float lightDist = TraceLights(rayOrigin, rayDir);
    
  vec3 lightFlares = vec3(0.);
  lightFlares =  mix((vec3(1., 0.4, 0.2)), vec3(0.), smoothstep(0., .35, lightDist));             
  lightFlares =  mix(lightFlares+(2.*vec3(1., 0.5, 0.2)), lightFlares, smoothstep(0., 0.15, lightDist));
  lightFlares =  mix(lightFlares+vec3(1., 1., 1.), lightFlares, smoothstep(0., 0.08, lightDist));
  RayHit marchResult = TracePlane(rayOrigin, rayDir);

  if (marchResult.hit)
  {
    float specSize=1.0;

    marchResult.normal = calcNormal(marchResult.hitPos); 

    // create texture map and set specular levels
    color = GetMaterial(rayDir, marchResult, fragCoord, specSize);

    if (marchResult.dist != marchResult.eFlameDist)
    {
      // get lightning based on material
      vec3 light = GetSceneLight(color.a, marchResult.normal, marchResult, rayDir, rayOrigin, specSize);   

      // cloud shadows on plane if below cloud level
      if (planePos.y<=-CLOUDLEVEL)
      {  
        // get cloud shadows at rayMarch hitpos
        float clouds =clamp(max(0., -0.15+noise(marchResult.hitPos+planePos+vec3(cloudPos.x, 0., cloudPos.y))), 0., 1.)*.5;

        color.rgb*= 1.0-clouds;
        // sun light  
        color.rgb*= 1.+(clouds);
      }   

      // apply lightning
      color.rgb *=light;

      // balance colors
      color.rgb = pow(color.rgb, vec3(1.0/1.1));
    }

    color.rgb = mix(color.rgb, vec3(0.3, 0.5, 0.7), 0.1);    
    color.a=1.0;  

    lightFlares = mix(lightFlares, lightFlares*0., step(0.1, distance(marchResult.dist, marchResult.eFlameDist)));
  }

  color.rgb+=lightFlares;
  fragColor = color;
}

// https://www.shadertoy.com/view/MlscWX
//////////////////////////////////////////////////////////////////////////////////////
// TERRAIN BUFFER  -   RENDERS TERRAIN AND LAUNCHED MISSILES + EXPLOSIONS 
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Fine noise texture. Used in noise functions.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = Buffer A. Read data from data-buffer.
// Channel 3 = Lichen texture. Used to create landscape height map and textures.

  #define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
  #define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
  #define MAX_HEIGHT 150. 
  #define WATER_LOD 0.4
  #define CLOUDLEVEL -70.0
  #define PI acos(-1.)
  #pragma optimize(off) 
  // remove on or several of below defines, if FPS is too low
  #define SHADOWS
  #define QUALITY_TREE
  #define QUALITY_REFLECTIONS
  #define EXACT_EXPLOSIONS
  // ---------------------------------------------------------

float turn=0.;
vec2 cloudPos=vec2(0.);
float eFlameDist=10000.0;
vec3 checkPos=vec3(0.);
vec3 sunPos=vec3(0.);
const vec3 sunColor = vec3(1.00, 0.90, 0.85);

const vec3 eps = vec3(0.02, 0.0, 0.0);
vec3 planePos=vec3(0.);

struct RayHit
{
  bool hit;  
  vec3 hitPos;
  vec3 normal;
  float dist;
  float depth;
  float eFlameDist;
};

struct Missile
{ 
  vec3 pos;
  float life;
  vec3 orientation;   // roll,pitch,turn amount
  vec3 origin;
};
    
struct Explosion
{ 
  vec3 pos;
  float life;
};

mat2 r2(float r) {
  float c=cos(r), s=sin(r);
  return mat2(c, s, -s, c);
}

#define r3(r) mat2(sin(vec4(-1, 0, 0, 1)*acos(0.)+r))

void pR(inout vec2 p, float a)
{
  p*=r2(a);
}

float sgn(float x)
{   
  return (x<0.)?-1.:1.;
}

float hash(float h) 
{
  return fract(sin(h) * 43758.5453123);
}

float noise(vec3 x) 
{
  vec3 p = floor(x);
  vec3 f = fract(x);
  f = f * f * (3.0 - 2.0 * f);

  float n = p.x + p.y * 157.0 + 113.0 * p.z;
  return -1.0+2.0*mix(
    mix(mix(hash(n + 0.0), hash(n + 1.0), f.x), 
    mix(hash(n + 157.0), hash(n + 158.0), f.x), f.y), 
    mix(mix(hash(n + 113.0), hash(n + 114.0), f.x), 
    mix(hash(n + 270.0), hash(n + 271.0), f.x), f.y), f.z);
}

float fbm(vec3 p) 
{
  float f = 0.5000 * noise(p);
  p *= 2.01;
  f += 0.2500 * noise(p);
  p *= 2.02;
  f += 0.1250 * noise(p);
  return f;
}

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

// 3D noise function (IQ)
float fastFBM(vec3 p)
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
float fastFBMneg(vec3 p)
{
  return -1.0+2.0*fastFBM(p);
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

float fCylinder(vec3 p, float r, float height) {
  float d = length(p.xy) - r;
  d = max(d, abs(p.z) - height);
  return d;
}
float sdEllipsoid( vec3 p, vec3 r )
{
  return (length( p/r.xyz ) - 1.0) * r.y;
}
float sdHexPrism( vec3 p, vec2 h )
{
  vec3 q = abs(p);
  return max(q.y-h.y, max((q.z*0.866025+q.x*0.5), q.x)-h.x);
}
float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}
float fSphere(vec3 p, float r) {
  return length(p) - r;
}

float GetExplosionIntensity(Explosion ex)
{
  return mix(1., .0, smoothstep(0., 5.0, distance(ex.life, 5.)));
}

float NoTreeZone(vec3 p)
{
  float dist = distance(readRGB(ivec2(140, 0)).xz, p.xz);
  dist = min(dist, distance(readRGB(ivec2(142, 0)).xz, p.xz));
  dist = min(dist, distance(readRGB(ivec2(144, 0)).xz, p.xz));
  dist = min(dist, distance(readRGB(ivec2(146, 0)).xz, p.xz));
  dist = min(dist, distance(readRGB(ivec2(148, 0)).xz, p.xz));
  return dist;
}
float GetTerrainHeight( vec3 p)
{
  vec2 p2 = (p.xz+planePos.xz)*0.0005;

  float heightDecrease = mix(1.0, 0., smoothstep(0., 15.0, NoTreeZone(p+planePos)));

  float mainHeight = -2.3+fastFBM((p+vec3(planePos.x, 0., planePos.z))*0.025)*max(11., abs(22.*noise2D(p2))); 
  mainHeight-=heightDecrease;

  float terrainHeight=mainHeight;
  p2*=4.0;
  terrainHeight += textureLod( iChannel3, p2, 2.7 ).x*1.; 
  p2*=2.0;
  terrainHeight -= textureLod( iChannel3, p2, 1.2 ).x*.7;
  p2*=3.0;
  terrainHeight -= textureLod( iChannel3, p2, 0.5 ).x*.1;

  terrainHeight=mix(terrainHeight, mainHeight*1.4, smoothstep(1.5, 3.5, terrainHeight)); 

  return   terrainHeight;
}

float GetTreeHeight( vec3 p, float terrainHeight)
{
  if (NoTreeZone(p+planePos)<25.) return 0.;
  float treeHeight = textureLod(iChannel3, (p.xz+planePos.xz)*0.006, .1).x;
  float tree = mix(0., mix(0., mix(0., 2.0, smoothstep(0.3, 0.86, treeHeight)), smoothstep(1.5, 3.5, terrainHeight)), step(0.3, treeHeight)); 
  tree -= tree*0.75;
  tree*=4.0;

  return  tree;
}

float MapTerrainSimple( vec3 p)
{
  float terrainHeight = GetTerrainHeight(p);   
  return  p.y - max((terrainHeight+GetTreeHeight(p, terrainHeight)), 0.);
}

float GetStoneHeight(vec3 p, float terrainHeight)
{
  return (textureLod(iChannel1, (p.xz+planePos.xz)*0.05, 0.).x*max(0., -0.3+(1.25*terrainHeight)));
}

float MapTerrain( vec3 p)
{   
  float terrainHeight = GetTerrainHeight(p);   
  terrainHeight= mix(terrainHeight+GetStoneHeight(p, terrainHeight), terrainHeight, smoothstep(0., 1.5, terrainHeight));
  terrainHeight= mix(terrainHeight+(textureLod(iChannel1, (p.xz+planePos.xz)*0.0015, 0.).x*max(0., -0.3+(.5*terrainHeight))), terrainHeight, smoothstep(1.2, 12.5, terrainHeight));

  terrainHeight= mix(terrainHeight-0.30, terrainHeight, smoothstep(-0.5, 0.25, terrainHeight));
  float water=0.;
  if (terrainHeight<=0.)
  {   
    water = (-0.5+(0.5*(noise2D((p.xz+planePos.xz+ vec2(-iTime*0.4, iTime*0.25))*2.60, WATER_LOD))));
    water*=(-0.5+(0.5*(noise2D((p.xz+planePos.xz+ vec2(iTime*.3, -iTime*0.25))*2.90), WATER_LOD)));
  }
  return   p.y -  max((terrainHeight+GetTreeHeight(p, terrainHeight)), -water*0.04);
}


float MapTree( vec3 p)
{  
  float terrainHeight = GetTerrainHeight(p);
  float treeHeight =GetTreeHeight(p, terrainHeight);

  // get terrain height at position and tree height onto that
  return  p.y - terrainHeight-treeHeight;
}

vec3 calcTreeNormal( in vec3 pos )
{    
  return normalize( vec3(MapTree(pos+eps.xyy) - MapTree(pos-eps.xyy), 0.5*2.0*eps.x, MapTree(pos+eps.yyx) - MapTree(pos-eps.yyx) ) );
}

vec4 TraceTrees( vec3 origin, vec3 direction, int steps, float terrainHeight)
{
  vec4 treeCol =vec4(0.5, 0.5, 0.5, 0.0);
  float intensity=0.0, t = .0, dist = 0.0;
  vec3 rayPos, nn;
  float precis=.0, dif =0.0, densAdd =.0;
  float treeHeight = 0.0;
  float td =.0;
  for ( int i=0; i<steps; i++ )
  {
    rayPos = origin+direction*t;
    treeHeight = GetTreeHeight(rayPos, terrainHeight);
    dist = rayPos.y - (terrainHeight + treeHeight);  
    precis = 0.015*t;

    if (treeHeight>0.1 && dist<precis)
    {
      nn= calcTreeNormal(rayPos);  
      dif = clamp( dot( nn, sunPos ), 0.0, 1.0 );

      densAdd = (precis-dist)*3.0*td;
      treeCol.rgb+=(0.5*td)*dif;
      treeCol.a+=(1.-treeCol.a)*densAdd;
    } 
    if (treeCol.a > 0.99) 
    {
      break;
    }
    td = max(0.04, dist*0.5);
    t+=td;
  }

  return clamp(treeCol, 0., 1.);
}


RayHit TraceTerrainReflection( vec3 origin, vec3 direction, int steps)
{
  RayHit result;
  float precis = 0.0, maxDist = 100.0, t = 0.0, dist = 0.0;
  vec3 rayPos;

  for ( int i=0; i<steps; i++ )
  {
    rayPos =origin+direction*t; 
    dist = MapTerrainSimple( rayPos);
    precis = 0.01*t;

    if (dist<precis || t>maxDist )
    {             
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;                              
      result.hitPos = origin+((direction*t));     
      break;
    }

    t += dist*0.5;
  }

  return result;
}

RayHit TraceTerrain( vec3 origin, vec3 direction, int steps)
{
  RayHit result;
  float precis = 0.0, maxDist = 400.0, t = 0.0, dist = 0.0;
  vec3 rayPos;

  for ( int i=0; i<steps; i++ )
  {
    rayPos =origin+direction*t; 
    dist = MapTerrain( rayPos);
    precis = 0.001*t;

    if (dist<precis || t>maxDist )
    {             
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;                              
      result.hitPos = origin+((direction*t));     
      break;
    }

    t += dist*0.5;
  }

  return result;
}

float SoftShadow( in vec3 origin, in vec3 direction )
{
  float res = 2.0, t = 0.0, h;
  for ( int i=0; i<16; i++ )
  {
    h = MapTerrain(origin+direction*t);
    res = min( res, 3.5*h/t );
    t += clamp( h, 0.02, 0.8);
    if ( h<0.002 ) break;
  }
  return clamp( res, 0.0, 1.0 );
}


vec3 calcNormal( in vec3 pos )
{    
  return normalize( vec3(MapTerrain(pos+eps.xyy) - MapTerrain(pos-eps.xyy), 0.5*2.0*eps.x, MapTerrain(pos+eps.yyx) - MapTerrain(pos-eps.yyx) ) );
}

float GetCloudHeight(vec3 p)
{    
  vec3 p2 = (p+vec3(planePos.x, 0., planePos.z)+vec3(cloudPos.x, 0., cloudPos.y))*0.03;

  float i  = (-0.3+noise(p2))*4.4; 
  p2*=2.52;
  i +=abs(noise( p2 ))*1.7; 
  p2*=2.53;
  i += noise( p2 )*1.; 
  p2*=2.51;
  i += noise(p2 )*0.5;
  p2*=4.22;
  i += noise( p2)*0.2;
  return i*3.;
}

float GetCloudHeightBelow(vec3 p)
{    
  vec3 p2 = (p+vec3(planePos.x, 0., planePos.z)+vec3(cloudPos.x, 0., cloudPos.y))*0.03;

  float i  = (-0.3+noise(p2))*4.4; 
  p2*=2.52;
  i +=noise( p2 )*1.7; 
  p2*=2.53;
  i += noise( p2 )*1.; 
  p2*=2.51;
  i += noise(p2 )*0.5;
  p2*=3.42;
  i += noise( p2)*0.2;
  i*=0.5;
  i-=0.25*i; 

  return i*5.;
}

float GetHorizon( vec3 p)
{
  return sdEllipsoid(p, vec3(1000., -CLOUDLEVEL, 1000.));
}

float MapCloud( vec3 p)
{
  return GetHorizon(p) - max(-3., (1.3*GetCloudHeight(p)));
}

vec4 TraceClouds( vec3 origin, vec3 direction, vec3 skyColor, int steps)
{
  vec4 cloudCol=vec4(skyColor*vec3(0.65, 0.69, 0.72)*1.3, 0.0);
  cloudCol.rgb=mix(cloudCol.rgb, sunColor, 0.32);

  float density = 0.0, t = .0, dist = 0.0;
  vec3 rayPos;
  float precis; 
  float td =.0;
  float densAdd;
  float sunDensity;
  for ( int i=0; i<steps; i++ )
  {
    rayPos = origin+direction*t;
    density = max(-5., 1.7+(GetCloudHeight(rayPos)*1.3));
    dist = GetHorizon(rayPos)-(density);

    precis = 0.01*t;
    if (dist<precis && density>-5.1)
    {    
      sunDensity = MapCloud(rayPos+sunPos*3.);
      densAdd =  mix(0., 0.5*(1.0-cloudCol.a), smoothstep(-5.1, 4.3, density));
      cloudCol.rgb-=clamp((density-sunDensity), 0., 1.0)*0.06*sunColor*densAdd;
      cloudCol.rgb += 0.003*max(0., sunDensity)*density*densAdd;
      

      cloudCol.a+=(1.-cloudCol.a)*densAdd;
    } 

    if (cloudCol.a > 0.99) break; 

    td = max(0.12, dist*0.45);
    t+=td;
  }

  // mix clouds color with sky color
  float mixValue = smoothstep(100., 620., t);
  cloudCol.rgb = mix(cloudCol.rgb, skyColor, mixValue);

  return cloudCol;
}

vec4 TraceCloudsBelow( vec3 origin, vec3 direction, vec3 skyColor, int steps)
{
  vec4 cloudCol=vec4(vec3(0.95, 0.95, 0.98)*0.7, 0.0);
  cloudCol.rgb=mix(cloudCol.rgb, sunColor, 0.2);

  float density = 0.0, t = .0, dist = 0.0;
  vec3 rayPos;
  float precis; 
  float td =.0;
  float energy=1.0;
  float densAdd=0.;
  float sunDensity;

  for ( int i=0; i<steps; i++ )
  {
    rayPos = origin+direction*t;
    density = clamp(GetCloudHeightBelow(rayPos), 0., 1.)*2.;          
    dist = -GetHorizon(rayPos);

    precis = 0.015*t;
    if (dist<precis && density>0.001)
    {    
      densAdd = 0.14*density/td;
      sunDensity = clamp(GetCloudHeightBelow(rayPos+sunPos*3.), -0.6, 2.)*2.; 
      cloudCol.rgb-=sunDensity*0.02*cloudCol.a*densAdd; 
      cloudCol.a+=(1.-cloudCol.a)*densAdd;

      cloudCol.rgb += 0.03*max(0., density-sunDensity)*densAdd;

      cloudCol.rgb+=mix(vec3(0.), vec3(1.0, 1.0, 0.9)*0.013, energy)*sunColor;
      energy*=0.96;
    } 

    if (cloudCol.a > 0.99) break; 

    td = max(1.4, dist);
    t+=td;
  }
    
  // mix clouds color with sky color
  cloudCol.rgb = mix(cloudCol.rgb, vec3(0.97), smoothstep(100., 960., t)); 
  cloudCol.a = mix(cloudCol.a, 0., smoothstep(0., 960., t));

  return cloudCol;
}

float getTrailDensity( vec3 p)
{
  return noise(p*3.)*1.;
}

void TranslateMissilePos(inout vec3 p, Missile missile)
{  
  p = p-(missile.pos);  
  p+=missile.origin;
  pR(p.xz, missile.orientation.z);
  pR(p.xy, -missile.orientation.x +PI);
  p-=missile.origin;
}

vec2 MapSmokeTrail( vec3 p, Missile missile)
{
  TranslateMissilePos(p, missile);
  float spreadDistance = 1.5;
  p.z+=3.82;

  // map trail by using mod op and ellipsoids
  float s = pModInterval1(p.z, -spreadDistance, .0, min(12., (missile.pos.z-planePos.z)/spreadDistance));     
  float dist = sdEllipsoid(p+vec3(0.0, 0.0, .4), vec3(0.6, 0.6, 3.));   
  dist-= getTrailDensity(p+vec3(10.*s))*0.25;

  return vec2(dist, s);
}


vec4 TraceSmoketrail( vec3 origin, vec3 direction, int steps, Missile missile)
{
  vec4 trailCol =vec4(0.5, 0.5, 0.5, 0.0);
  float height = 0.0, t = .0;
  vec2 dist = vec2(0.0);
  vec3 rayPos;
  float precis; 
  float td =.0;
  for ( int i=0; i<steps; i++ )
  {
    rayPos = origin+direction*t;
    dist = MapSmokeTrail(rayPos, missile);  
    precis = 0.002*t;
    if (dist.x<precis)
    {     
      trailCol.rgb+=(0.5*(getTrailDensity(rayPos+sunPos*.17)))*0.03;

      float densAdd =(precis-dist.x)*0.20;
      trailCol.a+=(1.-trailCol.a)*densAdd/(1.+(pow(dist.y, 2.0)*0.021));
    } 

    if (trailCol.a > 0.99) break; 

    td = max(0.04, dist.x);
    t+=td;
  }

  return clamp(trailCol, 0., 1.);
}


float MapExplosion( vec3 p, Explosion ex)
{ 
  checkPos = (ex.pos)-vec3(planePos.x, 0., planePos.z); 
  checkPos=p-checkPos;

  float testDist = fSphere(checkPos, 20.0);
  if (testDist>10.)  return testDist;

  float intensity =GetExplosionIntensity(ex);
  float d= fSphere(checkPos, intensity*15.);  

  // terrain clipping
  #ifdef EXACT_EXPLOSIONS
    d=max(d, -MapTerrain(p));
  #else
    d = max(d, -sdBox(checkPos+vec3(0., 50., 0.), vec3(50., 50.0, 50.0)));
  #endif

  // add explosion "noise/flames"
  float displace = fbm(((checkPos) + vec3(1, -2, -1)*iTime)*0.5);
  return d + (displace * 1.5*max(0., 4.*intensity));
}


RayHit TraceExplosion(in vec3 origin, in vec3 direction, int steps, Explosion ex)
{
  RayHit result;
  float precis = 0.0, maxDist = 350.0, t = 0.0, dist = 0.0;
  vec3 rayPos;

  for ( int i=0; i<steps; i++ )
  {
    rayPos =origin+direction*t; 
    dist = MapExplosion( rayPos, ex);
    precis = 0.01*t;

    if (dist<precis || t>maxDist )
    {             
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;                              
      result.hitPos = origin+((direction*t));     
      break;
    }

    t += dist*0.5;
  }

  return result;
}

// inspired by https://www.shadertoy.com/view/XdfGz8
vec3 GetExplosionColor(float x)
{
  vec3 col1= vec3(240., 211., 167.)/255.;
  vec3 col2 = vec3(210., 90., 60.)/255.;
  vec3 col3 = vec3(84., 20., 13.)/255.;

  float t = fract(x*3.);
  vec3 c= mix(col2, col3, t);
  c= mix(mix(col1, col2, t), c, step(0.666, x));
  return mix(mix(vec3(4, 4, 4), col1, t), c, step(0.333, x));
}

vec3 GetExplosionLight(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin)
{                
  vec3 reflectDir = reflect( rayDir, normal );

  vec3 lightTot = vec3(0.0);
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  float bac = clamp( dot( normal, normalize(vec3(-sunPos.x, 0.0, -sunPos.z)) ), 0.0, 1.0 ) * clamp(1.0-rayHit.hitPos.y/20.0, 0.0, 1.0);

  float fre = pow( clamp(1.0+dot(normal, rayDir), 0.0, 1.0), 2.0 );
  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 7.0);
  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );

  lightTot += 1.5*dif*vec3(1.00, 0.90, 0.85);
  lightTot += 0.50*skylight*vec3(0.40, 0.60, 0.95);
  lightTot += 1.00*specLevel*vec3(0.9, 0.8, 0.7)*dif;
  lightTot += 0.50*bac*vec3(0.25, 0.25, 0.25);
  lightTot += 0.25*fre*vec3(1.00, 1.00, 1.00);

  return clamp(lightTot, 0., 10.);
}


void DrawExplosion(int id, RayHit marchResult, inout vec3 color, vec3 rayDir, vec3 rayOrigin)
{
  Explosion explosion;
  id *= 100;
  explosion.life = read(ivec2(122+id, 0));

  // check if explosion has been spawned
  if (explosion.life>0.)
  {  
    explosion.pos = readRGB(ivec2(120+id, 0)); 

    vec3 testPoint = explosion.pos-planePos;
    // ensure the explosions starts on ground
    // explosion.pos.y=GetTerrainHeight(testPoint);

    // explosion light flash    
    if (marchResult.hit)
    {
      float intensity = GetExplosionIntensity(explosion);

      vec3 testCol = color.rgb+vec3(1.0, 0.59, 0.28)*2.5;
      color.rgb=mix(color.rgb, mix(testCol, color.rgb, smoothstep(0., 40.0*intensity, distance(testPoint.xz, marchResult.hitPos.xz))), intensity);
    }

    // trace explosion  
    RayHit exploTest = TraceExplosion(rayOrigin, rayDir, 68, explosion);   
    if (exploTest.hit)
    {
      color.rgb = GetExplosionColor(clamp(0.5+((fbm((exploTest.hitPos + vec3(1, -2, -1)*iTime)*0.5))), 0.0, 0.99));
      color.rgb = mix(color.rgb, color.rgb*0.45, smoothstep(0., 12., distance(exploTest.hitPos.y, GetTerrainHeight(testPoint))));
    }

    color.rgb = mix(color.rgb*3.0, color.rgb, smoothstep(0., 12.4, exploTest.dist));
  }
  ////////////////////////////////////////////////////////////
}

float MapFlare( vec3 p, Missile missile)
{
  TranslateMissilePos(p, missile);
  return sdEllipsoid( p+ vec3(0., 0., 2.4), vec3(.05, 0.05, .15));
}

float TraceEngineFlare(in vec3 origin, in vec3 direction, Missile missile)
{
  float t = 0.0;
  vec3 rayPos = vec3(0.0);
  float dist=10000.;

  for ( int i=0; i<10; i++ )
  {
    rayPos =origin+direction*t;
    dist = min(dist, MapFlare( rayPos, missile));
    t += dist;
  }

  return dist;
}

float MapMissile(vec3 p, Missile missile)
{
  float d= fCylinder( p, 0.70, 1.7);
  if (d<1.0)
  {
    d = fCylinder( p, 0.12, 1.2);   
    d =min(d, sdEllipsoid( p- vec3(0, 0, 1.10), vec3(0.12, 0.12, 1.0))); 

    checkPos = p;  
    pR(checkPos.xy, 0.785);
    checkPos.xy = pModPolar(checkPos.xy, 4.0);

    d=min(d, sdHexPrism( checkPos-vec3(0., 0., .60), vec2(0.50, 0.01)));
    d=min(d, sdHexPrism( checkPos+vec3(0., 0., 1.03), vec2(0.50, 0.01)));
    d = max(d, -sdBox(p+vec3(0., 0., 3.15), vec3(3.0, 3.0, 2.0)));
    d = max(d, -fCylinder(p+vec3(0., 0., 2.15), 0.09, 1.2));
  }
  return d;
}

float MapFlyingMissile( vec3 p, Missile missile)
{
  TranslateMissilePos(p, missile);  
  // map missile flame
  eFlameDist = min(eFlameDist, sdEllipsoid( p+ vec3(0., 0., 2.2+cos(iTime*90.0)*0.23), vec3(.17, 0.17, 1.0)));
  // map missile 
  return min(MapMissile(p, missile), eFlameDist);
}

RayHit TraceMissile(in vec3 origin, in vec3 direction, int steps, Missile missile)
{
  RayHit result;
  float maxDist = 450.0;
  float t = 0.0, glassDist = 0.0, dist = 100000.0;
  vec3 rayPos;
  eFlameDist=10000.0;
  for ( int i=0; i<steps; i++ )
  {
    rayPos =origin+direction*t;
    dist = MapFlyingMissile(rayPos, missile);

    if (dist<0.01 || t>maxDist )
    {                
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;                              
      result.hitPos = origin+((direction*t));   

      result.eFlameDist = eFlameDist;
      break;
    }
    t += dist;
  }

  return result;
}

float SoftShadowMissile( in vec3 origin, in vec3 direction, Missile missile )
{
  float res = 2.0, t = 0.02, h;
  for ( int i=0; i<8; i++ )
  {
    h = MapMissile(origin+direction*t, missile);
    res = min( res, 7.5*h/t );
    t += clamp( h, 0.05, 0.2 );
    if ( h<0.001 || t>2.5 ) break;
  }
  return clamp( res, 0.0, 1.0 );
}

vec3 GetMissileLightning(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin, Missile missile)
{       
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  vec3 reflectDir = reflect( rayDir, normal );
  specLevel= 3.5*pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 9.0/3.);

  float fre = pow( 1.0-abs(dot( normal, rayDir )), 2.0 );
  fre = mix( .03, 1.0, fre );   
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );

  float shadow = SoftShadowMissile(origin+((rayDir*rayHit.depth)*0.998), sunPos, missile);
  dif*=shadow;
  float skyLight = smoothstep( -0.1, 0.1, reflectDir.y );

  vec3 lightTot = (vec3(0.7)*amb); 
  lightTot+=vec3(0.85)*dif;
  lightTot += 1.00*specLevel*dif;
  lightTot += 0.80*skyLight*vec3(0.40, 0.60, 1.00);
  lightTot= mix(lightTot*.7, lightTot*1.2, fre );

  return lightTot*sunColor;
}

vec3 calcMissileNormal( in vec3 pos, Missile missile )
{    
  return normalize( vec3(MapFlyingMissile(pos+eps.xyy, missile) - MapFlyingMissile(pos-eps.xyy, missile), 0.5*2.0*eps.x, MapFlyingMissile(pos+eps.yyx, missile) - MapFlyingMissile(pos-eps.yyx, missile) ) );
}

mat3 setCamera(  vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}

// set sky color tone. 2 gradient passes using MIX.
vec3 GetSkyColor(vec3 rayDir)
{ 
  return mix(mix(vec3(0.15, 0.19, 0.24), vec3(220., 230., 240.0)/255., smoothstep(1.0, .30, rayDir.y)), mix(vec3(229.0, 221., 230)/200., sunColor, 0.15), smoothstep(0.15, -0.13, rayDir.y));
}

// scene lightning
vec3 GetSceneLight(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin)
{                
  vec3 reflectDir = reflect( rayDir, normal );

  vec3 lightTot = vec3(0.0);
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  float bac = clamp( dot( normal, normalize(vec3(-sunPos.x, 0.0, -sunPos.z)) ), 0.0, 1.0 ) * clamp(1.0-rayHit.hitPos.y/20.0, 0.0, 1.0);
  ;
  float fre = pow( clamp(1.0+dot(normal, rayDir), 0.0, 1.0), 2.0 );
  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 7.0);
  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );

  float shadow=1.; 
  #ifdef SHADOWS
    shadow = SoftShadow(origin+((rayDir*rayHit.depth)*0.988), sunPos);
  #endif

    lightTot += 1.5*dif*vec3(1.00, 0.90, 0.85)*shadow;
  lightTot += 0.50*skylight*vec3(0.40, 0.60, 0.95);
  lightTot += 1.00*specLevel*vec3(0.9, 0.8, 0.7)*dif;
  lightTot += 0.50*bac*vec3(0.25, 0.25, 0.25);
  lightTot += 0.25*fre*vec3(1.00, 1.00, 1.00)*shadow;

  return clamp(lightTot, 0., 10.)*sunColor;
}

vec3 GetSceneLightWater(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin)
{                
  vec3 reflectDir = reflect( rayDir, normal );
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  float bac = clamp( dot( normal, normalize(vec3(-sunPos.x, 0.0, -sunPos.z)) ), 0.0, 1.0 ) * clamp(1.0-rayHit.hitPos.y/20.0, 0.0, 1.0);

  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 9.0);

  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );
  float fre = pow( 1.0-abs(dot( normal, rayDir )), 4.0 );
  fre = mix( .03, 1.0, fre );   

  vec3 reflection = vec3(1.0);
  vec3 lightTot = vec3(0.0);

  lightTot += 1.15*dif*vec3(1.00, 0.90, 0.85);
  lightTot += 1.00*specLevel*vec3(0.9, 0.8, 0.7)*dif;    
  lightTot= mix(lightTot, reflection, fre );
  lightTot += 0.70*skylight*vec3(0.70, 0.70, 0.85);
  lightTot += 1.30*bac*vec3(0.25, 0.25, 0.25);
  lightTot += 0.25*amb*vec3(0.80, 0.90, 0.95);  
  return clamp(lightTot, 0., 10.);
}


void ApplyFog(inout vec3 color, vec3 skyColor, vec3 rayOrigin, vec3 rayDir, float depth)   
{
  float mixValue = smoothstep(50., 15000., pow(depth, 2.)*0.1);
  float sunVisibility = max(0., dot(sunPos, rayDir));
  // horizontal fog
  vec3 fogColor = mix(sunColor*0.7, skyColor, mixValue);  
  fogColor = mix(fogColor, sunColor, smoothstep(0., 1., sunVisibility));   
  color = mix(color, fogColor, mixValue);

  // vertical fog
  float heightAmount = .01;
  float fogAmount = 0.2 * exp(-rayOrigin.y*heightAmount) * (1.0-exp( -depth*rayDir.y*heightAmount ))/rayDir.y;
  color = mix(color, fogColor, fogAmount);
}



void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 mo = iMouse.xy/iResolution.xy;
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  // read plane data from buffer
  turn = read(ivec2(1, 10));
  float roll = read(ivec2(1, 1));
  float speed = read(ivec2(10, 1));
  float pitch = read(ivec2(15, 1));
  sunPos =  readRGB(ivec2(50, 0));
  planePos = readRGB(ivec2(55, 0));
  float CAMZOOM = read(ivec2(52, 0));  

  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;

  cloudPos = vec2(-iTime*0.3, iTime*0.45);

  vec3 rayOrigin = vec3(CAMZOOM*cos(camRot.x), planePos.y+CAMZOOM*sin(camRot.y), -3.+CAMZOOM*sin(camRot.x) );    
  pR(rayOrigin.xz, -turn);
  mat3 ca = setCamera( rayOrigin, vec3(0., planePos.y, -3. ), 0.0 );
  vec3 rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );

  // create sky color fade
  vec3 skyColor = GetSkyColor(rayDir);
  vec3 color = skyColor;
  float alpha=0.;

  RayHit marchResult = TraceTerrain(rayOrigin, rayDir, 1200);

  // is terrain hit?
  if (marchResult.hit)
  { 

    alpha=1.0;
    marchResult.normal = calcNormal(marchResult.hitPos);  

    float specLevel=0.7;
    color=vec3(0.5);

    // create terrain texture
    vec3 colorRocks= vec3(mix(texture(iChannel3, (marchResult.hitPos.xz+planePos.xz)*.01).rgb, texture(iChannel3, (marchResult.hitPos.xz+vec2(10000.0, 10000.0)+planePos.xz)*.01).rgb, fastFBM(marchResult.hitPos)));
    color =colorRocks;
    color.rgb = mix(color.rgb, color*3., abs(noise2D((marchResult.hitPos.xz+planePos.xz)*0.4, 1.0))); 

    // grass
    color.rgb = mix(color.rgb, ((color+noise2D((marchResult.hitPos.xz+planePos.xz)*24., 1.0))+vec3(0.5, 0.4, .1))*0.3, smoothstep(0.2, 2.0, marchResult.hitPos.y)); 

    float stoneHeight = GetStoneHeight(marchResult.hitPos, (GetTerrainHeight(marchResult.hitPos)));     
    color.rgb = mix(color.rgb, vec3(0.5+(noise(marchResult.hitPos+vec3(planePos.x, 0., planePos.z))*0.3)), smoothstep(1., .0, stoneHeight));
    specLevel = mix(specLevel, specLevel*2.6, smoothstep(1., .0, stoneHeight));

    // beach
    color.rgb = mix((color+vec3(1.2, 1.1, 1.0))*0.5, color.rgb, smoothstep(0.3, 0.7, marchResult.hitPos.y)); 


    float burn = NoTreeZone(marchResult.hitPos+planePos);
    color=mix(color*0.1, color, smoothstep(0., 25., burn));

    // create slight wave difference between water and beach level
    float wave = max(0., cos(abs(noise2D((marchResult.hitPos.xz+planePos.xz)))+(iTime*.5)+(length(marchResult.hitPos.xz)*0.03))*0.09);

    vec3 light;
    // check if terrain is below water level
    if (marchResult.hitPos.y<0.3+wave)
    {
      vec3 terrainHit = rayOrigin+((rayDir*marchResult.depth)*0.998);
      vec3 refDir = reflect(rayDir, marchResult.normal);
      vec4 testClouds = TraceCloudsBelow(terrainHit, refDir, skyColor, 30);

      color = vec3(0.3);

      float sunVisibility = max(0., dot(sunPos, rayDir));

      // calculate water fresnel  
      float dotNormal = dot(rayDir, marchResult.normal);
      float fresnel = pow(1.0-abs(dotNormal), 4.);  
      vec3 rayRef = rayDir-marchResult.normal*dotNormal;

      //color.rgb  = mix(mix(vec3(1.0), (vec3(0.7)+sunColor)*1.50, smoothstep(150., 350.,marchResult.depth)), color.rgb, smoothstep(-TERRAINLEVEL-0.37, -TERRAINLEVEL+0.25, marchResult.hitPos.y));
      color.rgb  = mix(color*.7, color.rgb, smoothstep(-3.0, -0.15, marchResult.hitPos.y));

      color = color+(sunColor*pow(sunVisibility, 5.0));

      // sea color
      color = mix(mix(color, color+fresnel, fresnel ), color, smoothstep(-0.1, 0.15, marchResult.hitPos.y));

      vec3 reflection = color;

      #ifdef QUALITY_REFLECTIONS
        // cast rays from water surface onto terrain. If terrain is hit, color water dark in these areas.
        RayHit reflectResult = TraceTerrainReflection(terrainHit, refDir, 100); 

      if (reflectResult.hit==true)
      {
        reflection  = mix(color, vec3(.01, 0.03, .0), 0.9);
      }
      #endif
        light = GetSceneLightWater(specLevel, marchResult.normal, marchResult, rayDir, rayOrigin);   
      color=mix(mix(color.rgb, testClouds.rgb, testClouds.a*.26), mix(color.rgb, testClouds.rgb, testClouds.a), smoothstep(0., 0.7, fresnel)); 
      color=mix(mix(color.rgb, reflection, 0.5), reflection, smoothstep(0., 0.7, fresnel)); 
      color=mix(color, color+(0.5*fresnel), smoothstep(0., 0.3, fresnel)); 

      color=color*light;
      color = mix(color, skyColor, smoothstep(320., 400., marchResult.depth));
    } 
    // terrain is ABOVE water level  
    else
    {
      // get lightning based on material
      light = GetSceneLight(specLevel, marchResult.normal, marchResult, rayDir, rayOrigin);   

      // apply lightning
      color = color*light;

      #ifdef QUALITY_TREE
        // add trees
        vec4 treeColor = TraceTrees(rayOrigin, rayDir, 28, marchResult.hitPos.y-0.3 );      
      color =clamp( mix( color, treeColor.rgb*((noise2D((marchResult.hitPos.xz+planePos.xz)*36., 3.0)+vec3(0.56, 0.66, .45))*0.6)*sunColor*(.30+(0.6*light)), treeColor.a ), 0.02, 1.); 
      #endif
    }

    color = mix(color, (color+sunColor)*0.6, smoothstep(70., 300., marchResult.depth));
    // add haze when high above ground  
    color = mix(color, color+vec3(0.37, 0.58, 0.9)*sunColor, mix(0., 0.75, smoothstep(-CLOUDLEVEL*0.65, MAX_HEIGHT, planePos.y)));  
    ApplyFog(color, skyColor, rayOrigin, rayDir, marchResult.depth);
  } else
  {
    // add volumetric clouds 
    // below cloud level
    if (rayOrigin.y<-CLOUDLEVEL && rayDir.y>0.)
    {  
      vec4 cloudColor=TraceCloudsBelow(rayOrigin, rayDir, skyColor, 60);    

      // make clouds slightly light near the sun
      float sunVisibility = pow(max(0., dot(sunPos, rayDir)), 2.0)*0.10;
      color.rgb = mix(color.rgb, max(vec3(0.), cloudColor.rgb+sunVisibility), cloudColor.a);      
      //color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);       
      alpha+=cloudColor.a*0.86;
    }
  }

  // add volumetric clouds 
  // above cloud level
  if (rayOrigin.y>=-CLOUDLEVEL)
  {  
    vec4 cloudColor=TraceClouds(rayOrigin, rayDir, skyColor, 80);    
    color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);
  }

  rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );
  DrawExplosion(0, marchResult, color, rayDir, rayOrigin);
  DrawExplosion(1, marchResult, color, rayDir, rayOrigin);


  // #################################################################### //    
  // ##############             MISSILES             #################### //     
  // #################################################################### //    

  rayOrigin = vec3(CAMZOOM*cos(camRot.x), CAMZOOM*sin(camRot.y), CAMZOOM*sin(camRot.x) );
  pR(rayOrigin.xz, -turn);
  ca = setCamera( rayOrigin, vec3(0., 0., 0. ), 0.0 );
  rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );

  int adressStep = 0;
  Missile missile;
  for (int i=0; i<2; i++)
  {
    adressStep = i*100;
    missile.life = read(ivec2(100 + adressStep, 0));
    // check if missile is launched
    if (missile.life>0.)
    {
      missile.origin = vec3(4.8 - (9.6*float(i)), -0.4, -3.0);       
      missile.orientation = readRGB(ivec2(108+adressStep, 0));
      missile.pos = readRGB(ivec2(116+adressStep, 0));

      // calculate engine flare
      float lightDist = TraceEngineFlare(rayOrigin, rayDir, missile);

      // add engine flares for missiles based on engine distance
      vec3 lightFlares=vec3(0.);
      lightFlares =  mix((vec3(1., 0.4, 0.2)), vec3(0.), smoothstep(0., 1.1, lightDist));             
      lightFlares =  mix(lightFlares+(2.*vec3(1., 0.5, 0.2)), lightFlares, smoothstep(0., 0.7, lightDist));
      lightFlares =  mix(lightFlares+vec3(1., 1., 1.), lightFlares, smoothstep(0., 0.2, lightDist));

      // rayTrace missile
      RayHit marchResult = TraceMissile(rayOrigin, rayDir, 64, missile);

      // apply color and lightning to missile if hit in raymarch test    
      if (marchResult.hit)
      {
        marchResult.normal = calcMissileNormal(marchResult.hitPos, missile);  

        // create texture map and set specular levels
        vec4 col = vec4(0.45, 0.45, 0.45, 0.8);

        // flame
        col.rgb=mix(col.rgb, vec3(1.2, .55, 0.30)*2.5, smoothstep(.16, 0., marchResult.eFlameDist));

        // get lightning based on material
        vec3 light = GetMissileLightning(col.a, marchResult.normal, marchResult, rayDir, rayOrigin, missile);   

        // apply lightning
        color.rgb = col.rgb*light;

        alpha = 1.; 

        lightFlares = mix(lightFlares, vec3(.0), step(0.1, distance(marchResult.dist, marchResult.eFlameDist)));
      }

      color.rgb+=lightFlares;

      //draw smoke trail behind missile
      vec4 trailColor = TraceSmoketrail(rayOrigin, rayDir, 48, missile);     
      color.rgb = mix(color.rgb, trailColor.rgb, trailColor.a);
      alpha+=trailColor.a;   

      if (marchResult.hit) 
      { 
        break;
      }
    }
  }
  // #################################################################### //
  // #################################################################### //

  fragColor = vec4(color.rgb, min(1.0, alpha));
}

// https://www.shadertoy.com/view/lllBRn
//////////////////////////////////////////////////////////////////////////////////////
// TERRAIN BUFFER  -   RENDERS TERRAIN AND BRIDGE
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Fine noise texture. Used in noise functions.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = Buffer A. Read data from data-buffer.
// Channel 3 = Lichen texture. Used to create landscape height map and textures.
#define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
#define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
#define PI 3.14159265359
#define saturate(x) clamp(x, 0., 1.)
#pragma optimize(off) 
#define NO_UNROLL(X) (X + min(0,iFrame))

// Delete one or several of below defines to increase performance
#define TERRAIN 
#define TREES
#define QUALITY_REFLECTIONS
#define QUALITYFOLIAGE
#define GRASS
#define SHADOWS
//#define PERFORM_AO_PASS
#define BRIDGE
//#define BOAT
//#define ACCURATE_BOAT_REFLECTION

// Try enabling below define if shader doesn´t compile
//#define LOWRES_TEXTURES

float hash(float h)
{
  return fract(sin(h) * 43758.5453123);
} 

struct RayHit
{
  bool hit;  
  vec3 hitPos;
  vec3 normal;
  vec4 dist;
  float treeDist;
  float depth;
};

    
float treeDist;
vec2 cloudPos=vec2(0.);
vec3 wind=vec3(0.);
vec3 sunPos=vec3(0.);


// noise functions by IQ (somewhat modified to fit my usage)
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

#define addPos vec2(1.0, 0.0)

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

float terrainNoise(vec2 p)
{
  vec3 p3  = fract(vec3(p.xyx) * .1031);
  p3 += dot(p3, p3.yzx + 19.19);
  return fract((p3.x + p3.y) * p3.z);
}

float noise( in vec2 x )
{
  vec2 p = floor(x);
  vec2 f = fract(x);
  f = f*f*(3.0-2.0*f);

  float res = mix(mix( terrainNoise(p), terrainNoise(p + addPos.xy), f.x), 
    mix( terrainNoise(p + addPos.yx), terrainNoise(p + addPos.xx), f.x), f.y);
  return res;
}
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

#define pR(p, a) (p)*=r2(a)
mat2 r2(float r) {
  float c=cos(r), s=sin(r);
  return mat2(c, s, -s, c);
}


float sdEllipsoid( vec3 p, vec3 r )
{
  return (length( p/r ) - 1.0) * min(min(r.x, r.y), r.z);
}
#define GetHorizon(p) sdEllipsoid(p, vec3(1000., 50., 1000.))

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}
float sdConeSection( vec3 p, float h, float r1, float r2 )
{
  float d1 = -p.y - h;
  float q = p.y - h;
  float si = 0.5*(r1-r2)/h;
  float d2 = max( sqrt( dot(p.xz, p.xz)*(1.0-si*si)) + q*si - r2, q );
  return length(max(vec2(d1, d2), 0.0)) + min(max(d1, d2), 0.);
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz), p.y)) - h;
  return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
}
float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}
float fCylinder(vec3 p, float r, float height) {
  float d = length(p.xy) - r;
  d = max(d, abs(p.z) - height);
  return d;
}

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

// Repeat in two dimensions
vec2 pMod2(inout vec2 p, vec2 size) {
  vec2 c = floor((p + size*0.5)/size);
  p = mod(p + size*0.5,size) - size*0.5;
  return c;
}

float GetCloudHeightBelow(vec3 p)
{    
  vec3 p2 = (p+vec3(cloudPos.x, 0., cloudPos.y))*0.03;

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

const vec4 CLOUD_BASECOLOR =vec4(0.095, 0.095, 0.098, 0.0);

vec4 TraceCloudsBelow( vec3 origin, vec3 direction, vec3 skyColor, int steps)
{
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
  vec4 cloudCol=CLOUD_BASECOLOR;
  cloudCol.rgb=mix(cloudCol.rgb, sunColor, .850);

  float density = 0.0, t = .0, dist = 0.0;
  vec3 rayPos;
  float precis; 
  float td =.0;
  float densAdd=0.;
  float sunDensity;

  for ( int i=0; i<NO_UNROLL(steps); i++ )
  {
    rayPos = origin+direction*t;
    density = clamp(GetCloudHeightBelow(rayPos), 0., 1.)*2.6;          
    dist = -GetHorizon(rayPos);

    precis = 0.015*t;

    if (dist<precis && density>0.001)
    {    
      densAdd = 0.08*density/td;
      sunDensity = clamp(GetCloudHeightBelow(rayPos+sunPos*4.), -0.6, 2.)*2.; 
      cloudCol.rgb-=sunDensity*0.02*cloudCol.a*densAdd; 
      cloudCol.a+=(1.-cloudCol.a)*densAdd;

      cloudCol.rgb += 0.03*max(0., density-sunDensity)*densAdd;
    } 

    if (cloudCol.a > 0.99) break; 

    td = max(1.0, dist);
    t+=td;
  }

  // mix clouds color with sky color
  cloudCol.rgb = mix(cloudCol.rgb, vec3(0.97), smoothstep(100., 960., t)); 
  cloudCol.a = mix(cloudCol.a, 0., smoothstep(0., 960., t));

  return cloudCol;
}
const mat2 r2D = mat2(1.3623, 1.7531, -1.7131, 1.4623);

float GetTerrainHeight( vec3 p)
{
  vec2 p2 = (p.xz)*0.0005;

  float mainHeight = -2.3+fastFBM(p*0.025)*max(11., abs(22.*noise2D(p2))); 
  float terrainHeight=mainHeight;
  p2*=4.0;
     
  terrainHeight += textureLod( iChannel3, p2, 2.7 ).x*1.; 
  p2*=2.0;  p2 *= r2D;       
  terrainHeight -= textureLod( iChannel3, p2, 1.2 ).x*.7;
  p2*=3.0;  p2 *= r2D;          
  terrainHeight -= textureLod( iChannel3, p2, 0.5 ).x*.1;

  terrainHeight=mix(terrainHeight, mainHeight*1.4, smoothstep(1.5, 3.5, terrainHeight));
      
  vec2 offPos = p.xz-vec3(-143, 0., 292).xz;
  terrainHeight=mix(-0.6, terrainHeight,smoothstep(180., 220., length(offPos-vec2(100., -185.))));
  terrainHeight=mix(-0.6, terrainHeight, smoothstep(150., 320., length((p.z*2.5)-vec3(-143, 0., 292).z+320.)));
  terrainHeight=mix(-0.6, terrainHeight, smoothstep(50.,300., length(offPos-vec2(800., -450.))));

  return   terrainHeight;
}


float GetMountainHeight( vec3 p)
{
  vec2 p2 = p.xz*0.02;

  float d = .24+(0.65*noise(p2*.25));
  d = 120.0 * d * d ;

  float height = d * noise(p2); 
  p2 *= r2D;   d *= 0.49;
  height += d * noise(p2); 
  p2 *= r2D;   d *= 0.46;
  height += d * noise(p2); 
  p2 *= r2D;   d *= 0.43;
  height += d * noise(p2); 
  p2 *= r2D;  d *= 0.4;
  height += d * noise(p2); 
  p2 *= r2D;

  height += pow(abs(noise(p2*.002)), 8.0)*400.-5.0;

 height=mix(-200., height*0.5, smoothstep(600., 1100., length(p.xz-vec3(-143, 0., 292).xz-vec2(1800., -700.))));
  height=mix(0., height, smoothstep(600., 850., length(vec3(-143, 0., 292).xz-p.xz)));
  return  height;
}


#define GetWaterWave(p) (((-0.5+(0.5*(noise2D((p.xz+ vec2(-iTime*0.3, iTime*0.25))*2.60, 0.2)))) + (-0.5+(0.5*(noise2D((p.xz+ vec2(-iTime*-.48, iTime*-0.25))*1.60, 0.2)))))*0.5 )

float GetTreeHeight( vec3 p, float terrainHeight)
{
    vec2 checkP=p.xz;
  float tree =textureLod(iChannel3, checkP*.031, 0.).r-0.13;


  float randomFactor = 50.*(noise(p.xz*0.01));
  // remove trees near tower
  tree=mix(0., tree, smoothstep(80.+randomFactor, 100.+randomFactor, length(p.xz-vec3(-143, 0., 292).xz)));
  // remove trees in distance (out at sea)
  tree=mix(0., tree, smoothstep(230., 340., length(p.xz-vec2(100., 0.))));
  tree=mix(0., tree, smoothstep(2.20, 2.30, terrainHeight));
  return max(0., tree-0.4);
}

float GetStoneHeight(vec3 p, float terrainHeight)
{
  float height = textureLod(iChannel3, p.xz*0.075, .1).x;
  // create small stones at the coast line
  float heightAdd =textureLod(iChannel1, p.xz*0.008, 1.).x*2.;
  heightAdd *= mix(1., 0., smoothstep(0.423, 0.7, length(0.1-terrainHeight)));
  terrainHeight+=heightAdd;
      
  // add stones to hills
  height = mix(0., mix(height, 0., smoothstep(4.0, 6.0, terrainHeight)), smoothstep(-.10, 0.10, terrainHeight));
  height=mix(0., height, smoothstep(2.5, 4.0, length(p.xz-vec3(-143, 0., 292).xz)));

  return max(0., height);
}

float GetBoulderHeight( vec3 p, float terrainHeight)
{
  if (terrainHeight<1.8) return 0.;

  float height = pow(textureLod(iChannel3, p.xz*0.02, .1).x, 0.5)*0.8;
  height += textureLod(iChannel3, (p.xz*r2D)*0.04, .0).x*0.05;
  height += textureLod(iChannel1, p.xz*0.1, .1).x*0.01;
  height = mix(0., height-0.45, step(0.5, height));

  height*=.54;
  height*=12.;

  height=mix(0., height, smoothstep(1.80, 2.70, terrainHeight));
  // no boulders near tower
  height=mix(0., height, smoothstep(6., 19., length(p.xz-vec3(-143, 0., 292).xz)));
  return max(0., height);
}


float GetFoliageHeight(vec3 p, float terrainHeight, float boulderHeight, float stoneHeight)
{
  float fol =  textureLod(iChannel1, ((wind.xy*1.6*cos(p.x+p.y))+p.xz)*0.3, 0.1).r;
  fol = mix(.0, fol, step(0.5, fol));
  fol=mix(fol, 0., smoothstep(1.80, .270, terrainHeight));
  fol=mix(fol, 0., smoothstep(0.24, 0.3, stoneHeight));

  fol=mix(fol, 0., smoothstep(0.03, 0.2, boulderHeight));
  // no foliage near tower
  fol=mix(0., fol, smoothstep(4., 9., length(p.xz-vec3(-143, 0., 292).xz)));

  return max(0., fol);
}

vec3 AddWind(vec3 p, vec2 wind, vec3 offSet)
{
  p-=offSet;
  pR(p.xy, (wind.x-wind.y)*0.35);
  pR(p.zy, (wind.y+wind.x)*0.35);   
  return p+offSet;
}
vec3 TranslateBridge(vec3 p)
{  
  p = p-vec3(-143, 0., 292)-vec3(-.5, 1.75, 15.);  
  p.xz*=r2(1.7);
  return p;
}

vec3 TranslateBoat(in vec3 p)
{
  p = p-vec3(-143, 0., 292)-vec3(-8., 1.3, 33.); 
  p.xz*=r2(3.14);
  return AddWind(p, wind.xy, vec3(-2., 0, -5.));
}

vec3 TranslateBuoy(in vec3 p)
{
  p = p-vec3(-143, 0., 292)-vec3(62., 2.2, -30.); 
  return AddWind(p, wind.xy, vec3(2., 0., -1.));
}

float MapMountains(in vec3 p)
{       
  return p.y -  GetMountainHeight(p);
}



float MapBoat(vec3 p)
{
  p=TranslateBoat(p);
  // AABB
  if (sdBox(p+vec3(0., 0., .50), vec3(1.7, 1.0, 4.))>1.) return 10000.;

  // hull exterior  
  float centerDist =length(p.x-0.);    
  float centerAdd = 0.07*-smoothstep(0.04, 0.1, centerDist);
  float frontDist = max(0.01, 1.3-max(0., (0.25*(0.15*pow(length(p.z-0.), 2.)))));
  float widthAdd =mix(0.06*(floor(((p.y+frontDist) + 0.15)/0.3)), 0., step(2., length(0.-p.y)));

  float d= fCylinder( p, 1.45+widthAdd, 1.3+centerAdd+widthAdd);  
  d =min(d, sdEllipsoid( p- vec3(0, 0, 1.250), vec3(1.45+widthAdd, 1.465+centerAdd, 1.+centerAdd+widthAdd))); 
  d =min(d, sdEllipsoid( p- vec3(0, 0, -1.20), vec3(1.45+widthAdd, 1.465+centerAdd, 3.+centerAdd+widthAdd))); 

  // hull cutouts
  d= max(d, -fCylinder( p- vec3(0, 0.25, -0.10), 1.3+widthAdd, 1.4));  
  d =max(d, -max(sdEllipsoid( p- vec3(0, 0.05, -.60), vec3(1.25+widthAdd, 1.2, 3.40)),-sdBox(p-vec3(0.,0.,4.), vec3(3., 10., 3.1)))); 

  // cut of the to part of the hull to make the boat open

  d=max(d, -sdBox(p-vec3(0., 1.05+centerAdd, 0.), vec3(10., frontDist, 14.)));

  // seats
  return min(d, min(sdBox(p-vec3(0., -0.5, 0.9), vec3(1.3, 0.055, 0.35)), sdBox(p-vec3(0., -0.5, 0.9-2.2), vec3(1.3, 0.055, 0.35))));
}

float MapBridge(vec3 p)
{
  p=TranslateBridge(p);
  // AABB
  if (sdBox(p-vec3(10., -1.0, 0.0), vec3(11.5, 2.50, 2.25))>3.) return 10000.;

  vec3 bPos = p+vec3(0.36, 0.0, 0.0);
  // bottom planks
  pModInterval1(bPos.x, 0.35, 0., 60.);
  float d= sdBox(bPos-vec3(0., 0.0, 0.1), vec3(0.12, 0.08, 1.80));

  // bearing balks
  bPos = p-vec3(-1.75, -0.726, -2.);
  pModInterval1(bPos.x, 3.2, 0., 7.);
  d= min(d, sdBox(bPos-vec3(0., .0, 2.1), vec3(0.15, 0.15, 2.00)));
  float m = pModInterval1(bPos.z, 4.2, 0., 1.);
  d= min(d, sdCappedCylinder(bPos+vec3(0., 0.55, 0.), vec2(0.2, 2.8-m)));

  // side rails      
  bPos = p-vec3(10.8, 0., -1.7);
  m = pModInterval1(bPos.z, 3.60, 0., 1.);
   m = pModInterval1(bPos.y, 1.40, 0., 1.-m);
     
  d= min(d, sdBox(bPos, vec3(10., 0.14, .12)));

  return d;
}
// Simple terrain map. Skip boulders, foliage and waves
vec4 MapTerrainReflections( vec3 p)
{
    treeDist = 10000.;
  float boatDist= 10000.;
  float bridgeDist=10000.;
  float height = GetTerrainHeight(p); 
  float tHeight= height + GetStoneHeight(p, height);
  tHeight*=1.4;
  if (tHeight>0.)
  {
    tHeight +=textureLod( iChannel1, p.xz*.2, 0.2 ).x*.03;  
                #ifdef TREES
      vec3 treePos = p-vec3(0.,tHeight+2.,0.);
          pMod2(treePos.xz, vec2(7.));
      float treeHeight=GetTreeHeight(p-treePos, tHeight);
      
      if(treeHeight>0.05)
      {
        
          treeDist = sdEllipsoid(treePos,vec3(2.,4.,2.)*(1.+(0.2*cos(p.x*2.)*cos(p.y*4.0)*cos(p.z*3.0))));
      }
    #endif
  }
  #ifdef BRIDGE
    bridgeDist=MapBridge(p);   
  #endif
    #ifdef BOAT
    #ifdef ACCURATE_BOAT_REFLECTION
    boatDist=MapBoat(p); 
    #else
    // fake boat by using ellipsoid
    boatDist=sdEllipsoid( TranslateBoat(p)- vec3(0, -0.20, -1.0), vec3(1.65, 1., 3.40));
    #endif
    
  #endif

    // mask tower position by placing a cone
    return  vec4(min(treeDist,min(min(boatDist, bridgeDist), min(p.y - max(tHeight, 0.), sdConeSection(p-vec3(-143, 0., 292)-vec3(0., 13., 0.), 10.45, 3.70, 1.70)))), boatDist, bridgeDist, tHeight);
}

  // Full terrain map. Excludes tower mask
  vec4 MapTerrain( vec3 p)
{       
  float boatDist= 10000.;
  float bridgeDist=10000.;
  treeDist = 10000.;
  float water=0.;
  float height = GetTerrainHeight(p); 
  float tHeight=mix(height, 4., smoothstep(12., 1.98, length(p.xz-vec3(-143, 0., 292).xz))); 
  float boulderHeight = GetBoulderHeight(p, height);
  float stoneHeight = GetStoneHeight(p, tHeight);
  tHeight+= mix(stoneHeight, 0., step(0.1, boulderHeight));

  tHeight= mix(tHeight-.20, tHeight*1.4, smoothstep(0.0, 0.25, tHeight));

  if (tHeight>0.)
  {
    tHeight +=textureLod( iChannel1, p.xz*.2, 0.2 ).x*.03;

    tHeight+=boulderHeight;
      
                #ifdef TREES
      vec3 treePos = p-vec3(0.,tHeight+2.,0.);
      pMod2(treePos.xz, vec2(7.));
      float treeHeight=GetTreeHeight(p-treePos, tHeight);
      
      if(treeHeight>0.05)
      {
          pR(treePos.xy,wind.x*1.3);
          treeDist = sdEllipsoid(treePos,vec3(2.,4.5+(3.5*cos(treePos.z)),2.)*(1.+(0.2*noise(p*2.2+(4.*wind)))));
      }
    #endif
      
    #ifdef GRASS
      tHeight+=GetFoliageHeight(p, height, stoneHeight, boulderHeight);
    #endif

  } else
  {
    water = GetWaterWave(p);
  }

    
  #ifdef BRIDGE
    bridgeDist=MapBridge(p);    
  #endif
    #ifdef BOAT
    boatDist=MapBoat(p);
  #endif
    
    return vec4(min(treeDist,min(min(boatDist, bridgeDist), p.y -  max(tHeight, -water*0.05))), boatDist, bridgeDist, height);
}
 
float MapWater(vec3 p)
{
  return p.y - (-GetWaterWave(p)*0.05);
}

#define calcFolNormal( pos, th, bh, sh ) normalize( vec3(GetFoliageHeight(pos+vec3(0.02, 0.0, 0.0).xyy, th, bh, sh) - GetFoliageHeight(pos-vec3(0.02, 0.0, 0.0).xyy, th, bh, sh), 0.5*2.0*vec3(0.02, 0.0, 0.0).x, GetFoliageHeight(pos+vec3(0.02, 0.0, 0.0).yyx, th, bh, sh) - GetFoliageHeight(pos-vec3(0.02, 0.0, 0.0).yyx, th, bh, sh) ) )
#define calcNormal( pos) normalize( vec3(MapTerrain(pos+vec3(0.02, 0.0, 0.0).xyy).x - MapTerrain(pos-vec3(0.02, 0.0, 0.0).xyy).x, 0.5*2.0*vec3(0.02, 0.0, 0.0).x, MapTerrain(pos+vec3(0.02, 0.0, 0.0).yyx).x - MapTerrain(pos-vec3(0.02, 0.0, 0.0).yyx).x ) )
#define calcNormalWater( pos) normalize( vec3(MapWater(pos+vec3(0.02, 0.0, 0.0).xyy) - MapWater(pos-vec3(0.02, 0.0, 0.0).xyy), 0.5*2.0*vec3(0.02, 0.0, 0.0).x, MapWater(pos+vec3(0.02, 0.0, 0.0).yyx) - MapWater(pos-vec3(0.02, 0.0, 0.0).yyx) ) )
#define calcNormalMountains( pos) normalize( vec3(MapMountains(pos+vec3(0.02, 0.0, 0.0).xyy) - MapMountains(pos-vec3(0.02, 0.0, 0.0).xyy), 0.5*2.0*vec3(0.02, 0.0, 0.0).x, MapMountains(pos+vec3(0.02, 0.0, 0.0).yyx) - MapMountains(pos-vec3(0.02, 0.0, 0.0).yyx) ) )
#define calcTexNormal(sam, p) ( vec3(normalize(vec3(textureLod(sam, p + vec2(-0.001, 0), 0.).r-textureLod(sam, p + vec2(+0.001, 0), 0.).r, textureLod(sam, p + vec2(0, -0.001), 0.).r-textureLod(sam, p + vec2(0, +0.001), 0.).r, .02))) * 0.5 + 0.5 )

vec4 TraceFoliage( vec3 origin, vec3 direction, int steps, vec3 foliageMainColor)
{
  vec4 folCol = vec4(foliageMainColor, 0.);
  float t = .0;
  vec3 random = vec3(0.);
  vec3 rayPos, nn;
  float dif =0.0, densAdd =.0;
  float folHeight = 0.0;
  for ( int i=0; i<NO_UNROLL(steps); i++ )
  {
    random = vec3(0.081*cos(float(i)));
    rayPos = random+origin+direction*t;

    float terrainHeight =GetTerrainHeight(rayPos);
    float boulderHeight = GetBoulderHeight(rayPos, terrainHeight);
    float stoneHeight = GetStoneHeight(rayPos, terrainHeight);
    stoneHeight= mix(stoneHeight, 0., step(0.1, boulderHeight));  
    folHeight = GetFoliageHeight(rayPos, terrainHeight, boulderHeight, stoneHeight);


    if (folHeight>0.06)
    {
      nn= calcFolNormal(rayPos, terrainHeight, boulderHeight, stoneHeight);  
      dif = max(0., dot( nn, sunPos ));
      folCol.rgb+=0.1*dif;
      folCol.a+=(1.-folCol.a)*0.1;
    } 
    if (folCol.a>1.) break;

    t+=0.015;
  }

  return clamp(folCol, 0., 1.);
}


bool TraceTerrainReflection( vec3 origin, vec3 direction, int steps)
{
  float precis = 0.00, t = 0.0, dist = 0.0;
  vec3 rayPos;

  for ( int i=0; i<NO_UNROLL(steps); i++ )
  {
    rayPos =origin+direction*t; 
    dist = MapTerrainReflections( rayPos).x;
    precis = 0.006*t;

    if (dist<precis || t>400.0)
    {             
      return !(t>400.0);
    }

    t += dist;
  }

  return false;
}

RayHit TraceTerrain( vec3 origin, vec3 direction, int steps, float maxDist)
{
  RayHit result;
  vec4 dist = vec4(1000000.);
  float precis = 0.0, t = 0.0;
  vec3 rayPos;

  for ( int i=0; i<NO_UNROLL(steps); i++ )
  {
    rayPos =origin+direction*t; 
    dist = MapTerrain( rayPos);
    precis =0.001*t;

    if (dist.x<precis || t>maxDist)
    {             
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist = dist;  
      result.treeDist = treeDist;  
      result.hitPos = origin+((direction*t));    
      break;
    }

    t += dist.x*0.5;
  }

  return result;
}

RayHit TraceMountains( vec3 origin, vec3 direction, int steps, float maxDist)
{
  RayHit result;
  float dist=0.;
  
  float precis = 0.0, t = 0.0;
  vec3 rayPos;

  for ( int i=0; i<NO_UNROLL(steps); i++ )
  {
    rayPos =origin+direction*t; 
    dist = MapMountains( rayPos);
    precis = 0.001*t;

    if (dist<precis || t>maxDist)
    {             
      result.hit=!(t>maxDist);
      result.depth = t; 
      result.dist.x = dist;   
      result.hitPos = origin+((direction*t));    
      break;
    }

    t += dist*1.;
  }

  return result;
}

mat3 setCamera(  vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}


float SoftShadow( in vec3 origin, in vec3 direction )
{
  float res =1., t = 0.0, h;
  vec3 rayPos = vec3(origin+direction*t);

  for ( int i=0; i<NO_UNROLL(20); i++ )
  {
    h = MapTerrain(rayPos).x;

    res = min( res, 8.5*h/t );
    t += clamp( h, 0.01, 0.25);
    if ( h<0.005 ) break;
    rayPos = vec3(origin+direction*t);
  }
  return clamp( res, 0.0, 1.0 );
}
float SoftShadowTower( in vec3 origin, in vec3 direction, float res)
{
  float t = 0.0, h;
  vec3 rayPos = vec3(origin+direction*t);

  for ( int i=0; i<NO_UNROLL(11); i++ )
  {

    h = sdConeSection(rayPos-vec3(-143, 0., 292)-vec3(0., 12., 0.), 10.45, 2.40, 1.40);

    res = min( res, 6.5*h/t );
    t += clamp( h, 0.4, 1.5);
    if ( h<0.005 ) break;
    rayPos = vec3(origin+direction*t);
  }
  return clamp( res, 0.0, 1.0 );
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
  return col;
}

float calcAO( in vec3 pos, in vec3 nor )
{
  float occ = 0.0;
  float sca = 1.0;
  for ( int i=0; i<NO_UNROLL(3); i++ )
  {
    float hr = 0.01 + 0.15*float(i);
    vec3 aopos =  nor * hr + pos;
    float dd = MapTerrain( aopos ).x;
    occ += -(dd-hr)*sca;
    sca *= 0.96;
  }
  return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );
}


vec3 GetLightTerrain(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin, float illuminance)
{                
  vec3 reflectDir = reflect( rayDir, normal );
  vec3 shadowPos = origin+((rayDir*rayHit.depth)*0.98);

  float occ = 1.;
  #ifdef PERFORM_AO_PASS
    occ = calcAO(shadowPos, normal );
  #endif

  vec3 lightTot = vec3(0.0);
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  float fre = clamp(1.0+dot(normal, rayDir), 0.0, 1.0);
  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 2.0);
  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );


  #ifdef SHADOWS
    float shadow=1.;
  shadow = SoftShadow(shadowPos, sunPos);
  shadow = min(shadow, SoftShadowTower(shadowPos, sunPos, shadow));
  shadow = max(illuminance, shadow);
  dif*=shadow;
  #endif
    
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
  lightTot += 3.*dif*sunColor;

  lightTot += .65*amb*vec3(0.35, 0.45, 0.6)*occ;  
  lightTot += 0.60*skylight*clamp(GetSkyColor(reflectDir), 0., 1.)*occ;
  lightTot += 2.*specLevel*vec3(1., 0.85, 0.75)*dif;  
  fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 4.0);
  lightTot = mix( lightTot, lightTot*2., fre );

  return clamp(lightTot, 0.22, 10.);
}

vec3 GetLightMountains(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin)
{                
  vec3 reflectDir = reflect( rayDir, normal );
  vec3 shadowPos = origin+((rayDir*rayHit.depth)*0.98);
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
    
  vec3 lightTot = vec3(0.0);
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );
  float fre = clamp(1.0+dot(normal, rayDir), 0.0, 1.0);
  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 2.0);
  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );


  lightTot += 3.*dif*sunColor;

  lightTot += .65*amb*vec3(0.35, 0.45, 0.6);  
  lightTot += 0.60*skylight*clamp(GetSkyColor(reflectDir), 0., 1.);
  lightTot += 2.*specLevel*vec3(1., 0.85, 0.75)*dif;  
  fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 4.0);
  lightTot = mix( lightTot, lightTot*2., fre );

  return clamp(lightTot, 0.22, 10.);
}

vec3 GetLightWater(float specLevel, vec3 normal, RayHit rayHit, vec3 rayDir, vec3 origin)
{                
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
  vec3 reflectDir = reflect( rayDir, normal );
  float amb = clamp( 0.5+0.5*normal.y, 0.0, 1.0 );
  float dif = clamp( dot( normal, sunPos ), 0.0, 1.0 );

  specLevel*= pow(clamp( dot( reflectDir, sunPos ), 0.0, 1.0 ), 9.0);

  float skylight = smoothstep( -0.1, 0.1, reflectDir.y );
  float fre = pow( 1.0-abs(dot( normal, rayDir )), 3.0 );
  fre = mix( .03, 1.0, fre );   

  const vec3 reflection = vec3(1.0);
  vec3 lightTot = vec3(0.0);

  lightTot += 3.*dif*sunColor;

  vec3 skyCol = GetSkyColor(reflectDir);

  lightTot += 0.5*amb*vec3(0.35, 0.45, 0.6);  
  lightTot += 0.70*skylight*skyCol;
  lightTot += 2.*specLevel*vec3(1., 0.85, 0.75)*dif;  
  fre = pow( 1.0-abs(dot(rayHit.normal, rayDir)), 4.0);
  lightTot = mix( lightTot, lightTot+skyCol, fre );

  return clamp(lightTot, 0., 10.);
}



void ApplyFog(inout vec3 color, vec3 skyColor, vec3 rayOrigin, vec3 rayDir, float depth)   
{
  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
  float mixValue = smoothstep(50., 15000., depth);
  float sunVisibility = max(0., dot(sunPos, rayDir));
  // horizontal fog
  vec3 fogColor = sunColor*0.7;  
  fogColor = mix(fogColor, sunColor, smoothstep(0., 0.5, sunVisibility));   
  color = mix(color, fogColor, mixValue);

  // vertical fog
  const float heightAmount = .008;
  float fogAmount = 0.2 * exp(-rayOrigin.y*heightAmount) * (1.0-exp( -depth*rayDir.y*heightAmount ))/rayDir.y;
  color = mix(color, fogColor, min(0.5, fogAmount));
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
  vec4 x = textureLod( sam, p.yz ,0.);
  vec4 y = textureLod( sam, p.zx ,0.);
  vec4 z = textureLod( sam, p.xy ,0.);
  return (x*m.x + y*m.y + z*m.z)/(m.x+m.y+m.z);
}


#define MOSSCOLOR (vec3(29, 39, 31)/255.)
#define MOSSCOLOR2 (vec3(74, 80, 59)/315.)
#define TREECOLOR col.rgb = (0.2+(0.8*abs(noise(marchResult.hitPos*2.))))*vec3(.9, 1., .8)*0.3;

vec3 GetBridgeTexture(RayHit marchResult)
{
  vec3 checkPos = TranslateBridge(marchResult.hitPos); 
  vec3 woodTexture = vec3(BoxMap(iChannel1, vec3(checkPos.z*0.01, checkPos.yx*0.31), (marchResult.normal), 0.5).r);
  vec3 bridgeColor =  woodTexture*(0.6+(0.4*noise(checkPos.zx*17.)));
  float n = noise2D(checkPos.xz*1.3);
  return mix(bridgeColor*MOSSCOLOR2, bridgeColor, smoothstep(-.64-(2.*n), 2.269-(2.*n), marchResult.hitPos.y));
}

vec3 GetBoatTexture(RayHit marchResult)
{
  vec3 checkPos = TranslateBoat(marchResult.hitPos); 
  vec3 bCol= vec3(62, 52, 47)*1.3/255.;
  float frontDist = max(0., (0.25*(0.16*pow(length(checkPos.z-0.), 2.))));
  float n = 1.+(0.2*noise(vec3(checkPos.zx*0.01, checkPos.x)*34.));
  n *= 0.9+(0.1*noise2D(checkPos.xy*26.));  
  bCol = mix(vec3(0.6), bCol*n, step(-0.625, checkPos.y-frontDist));
  bCol = mix(vec3(0.05), bCol, step(0.08, length(-.7-(checkPos.y-frontDist))));
  bCol = mix(bCol*0.8, bCol*1.2, smoothstep(0., 0.18, length(-0.23-(checkPos.y-frontDist))));   
  bCol = mix(bCol, bCol*0.47, smoothstep(0.0, 0.32, length(0.-mod(checkPos.y-frontDist, 0.3)))); 
  return mix(bCol, bCol*0.8, smoothstep(-.1, 0.8, noise2D(checkPos.xz*3.7)));  
}


void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  wind= (vec3(0.05, -0.1, -0.1)*(cos((iTime)*2.)*sin((iTime)*.5)));
  cloudPos = vec2(-iTime*1.3, -iTime*1.65);
  sunPos =  readRGB(ivec2(50, 0));
  vec3 camData  = readRGB(ivec2(52, 0));  

  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;

  vec3 rayOrigin = vec3(vec3(-143, 0., 292).x+camData.z*cos(camRot.x), camData.y, vec3(-143, 0., 292).z+camData.z*sin(camRot.x) );    
  rayOrigin.y = readRGB(ivec2(62, 0)).y;
  mat3 ca = setCamera( rayOrigin, vec3(vec3(-143, 0., 292).x, camData.y+(11.*camRot.y), vec3(-143, 0., 292).z ), 0.0 );
  vec3 rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );

  const vec3 sunColor = vec3(1.1, 0.53, 0.27); 
    
  // create sky color fade
  vec4 color = texture(iChannel0, uv);
  color.a=10000.;
    
  #ifdef TERRAIN

    vec3 skyColor = GetSkyColor(rayDir);
    RayHit marchResult = TraceTerrain(rayOrigin, rayDir, 500, 1000.);


    // is terrain hit?
    if (marchResult.hit)
    { 
      vec3 col;
      float alpha=1.0;

      float specLevel=1.;
      col=color.rgb;

      vec3 light;

      float terrainHeight =marchResult.dist.w;
      float stoneHeight = GetStoneHeight(marchResult.hitPos, terrainHeight);     
      float treeHeight =GetTreeHeight(marchResult.hitPos, terrainHeight);
   
      // check if terrain is below water level
      if (terrainHeight<-stoneHeight && marchResult.dist.x!=marchResult.dist.z && marchResult.dist.x!=marchResult.dist.y)
      {
        marchResult.normal = calcNormalWater(marchResult.hitPos);  
        
        vec3 terrainHit = rayOrigin+((rayDir*marchResult.depth)*0.985);
        vec3 refDir = reflect(rayDir, marchResult.normal);
        vec4 testClouds = vec4(0.);        
        col = vec3(0.3);

        vec3 bottomColor =  clamp(vec3(textureLod(iChannel3, marchResult.hitPos.xz*0.13, 0.2).r*clamp( dot( calcTexNormal(iChannel3, (marchResult.hitPos.xz*0.1)+marchResult.normal.xz), sunPos ), 0.0, 1.0 )*vec3(1., 0.9, 0.7)), 0.2, 0.6);

        col = mix(col, bottomColor, smoothstep(-0.65, -0.33, terrainHeight));

        // calculate water fresnel  
        float fresnel = pow(1.0-abs(dot(rayDir, marchResult.normal)), 4.);  

        // col.rgb  = mix(col*.7, col.rgb, smoothstep(-3.0, -0.15, marchResult.hitPos.y));
        col = col+((sunColor*pow(max(0., dot(sunPos, rayDir)), 5.0))*0.5);

        vec3 reflection = col;

        #ifdef QUALITY_REFLECTIONS
          // get cloud reflections for water
          testClouds = TraceCloudsBelow(terrainHit, refDir, skyColor, 30);
        // cast rays from water surface onto terrain. If terrain is hit, color water dark in these areas.    
        if (TraceTerrainReflection(terrainHit, refDir, 40))
        {
          reflection  = mix(col, vec3(.01, 0.03, .0), 0.9);
        }
        #endif


          light = GetLightWater(specLevel, marchResult.normal, marchResult, rayDir, rayOrigin);   
        col=mix(mix(col.rgb, testClouds.rgb, testClouds.a), mix(col.rgb, testClouds.rgb, testClouds.a), smoothstep(0., 0.7, fresnel)); 
        col=mix(mix(col.rgb, reflection, 0.5), reflection, smoothstep(0., 0.3, fresnel)); 
        col=mix(mix(col.rgb, ((col+noise2D((marchResult.hitPos.xz)*24., 1.0))+vec3(0.5, 0.4, .1))*0.3, smoothstep(0., 1.0, marchResult.hitPos.y)), col+(0.5*fresnel), smoothstep(0., 0.3, fresnel)); 


        col=col*light;

        col = mix(col, skyColor, smoothstep(320., 400., marchResult.depth));
      } 
      // terrain is ABOVE water level  
      else
      {
         marchResult.normal = calcNormal(marchResult.hitPos);  

          float boulderHeight = GetBoulderHeight(marchResult.hitPos, terrainHeight)-treeHeight;     
          float foliageHeight = GetFoliageHeight(marchResult.hitPos, terrainHeight, boulderHeight, stoneHeight)-treeHeight;     

          float noiseMedium = noise(marchResult.hitPos*23.3);
          float noiseLarge = noise(marchResult.hitPos*0.3); 
          vec4 fColor = vec4(0.0);

          //texture bridge
          if ( length(marchResult.dist.x-marchResult.dist.z)<0.01)
          {
            col.rgb = GetBridgeTexture(marchResult);
              specLevel*=1.45*col.r;
          }
          //texture boat
          else if ( length(marchResult.dist.x-marchResult.dist.y)<0.01)
          { 
            col.rgb = GetBoatTexture(marchResult);
            specLevel*=col.r;
          }
          else if ( length(marchResult.dist.x-marchResult.treeDist)<0.01)
          { 
       
           TREECOLOR;
           
          }
          // texture terrain
          else
          {
            // create terrain texture
            #ifdef LOWRES_TEXTURES
            vec3 colorRocks= vec3(BoxMapFast(iChannel3, marchResult.hitPos*0.61, (marchResult.normal), 0.5).r);
            vec3 colorRocks2 = vec3(BoxMapFast(iChannel3, marchResult.hitPos*0.11, (marchResult.normal), 0.5).r);
            #else
            vec3 colorRocks= vec3(BoxMap(iChannel3, marchResult.hitPos*0.61, (marchResult.normal), 0.5).r);
            vec3 colorRocks2 = vec3(BoxMap(iChannel3, marchResult.hitPos*0.11, (marchResult.normal), 0.5).r);           
            #endif
              
            colorRocks = mix(colorRocks, colorRocks2, 0.5);

            float moss =  0.75*(1.2+noiseMedium);
            vec3 grassCol = vec3(.15, .14, .10);
            vec3 dirtCol =vec3(.2, .16, .14);
            col =colorRocks;

            float mossAmount = mix(mix(1., 0.47, max(0., noiseMedium)), 0., max(0., marchResult.normal.z));

            // create boulder texture
            vec3 boulderColor = mix(colorRocks2, colorRocks*1.4, marchResult.normal.y);
            // add boulder moss
            boulderColor = mix(boulderColor*(0.6+(0.5*noiseMedium)), vec3(0.48+(0.4*abs(noiseMedium))), smoothstep(0., .7, noiseLarge));
            boulderColor = mix(mix(moss*MOSSCOLOR2, boulderColor*0.67, max(0., noiseMedium)), boulderColor, max(0., marchResult.normal.z));

            // add stone moss
            vec3 stoneColor = mix(colorRocks2, colorRocks*1.4, marchResult.normal.y);
            stoneColor = mix(stoneColor*(0.8+(0.2*noiseMedium)), vec3(0.8), smoothstep(0., 1.5, noiseMedium));
            stoneColor = mix(mix(moss*MOSSCOLOR*1.4, stoneColor, smoothstep(0.7, 0.9, stoneHeight)), boulderColor*(0.74+(0.5*noiseMedium)), smoothstep(.0, 2.57, terrainHeight));

         
            vec3 foliageCol = mix(vec3(216., 156, 101)/255., vec3(216., 156, 101)/355., smoothstep(0.20, .50, max(0., noiseMedium)));
            foliageCol = mix(vec3(0.16), foliageCol, smoothstep(0.0, 0.74, max(0., foliageHeight)));
               
        
                  // apply textures
            col.rgb = mix(col.rgb, stoneColor, smoothstep(0.02, 0.7, stoneHeight));
            col.rgb = mix(col.rgb, boulderColor, smoothstep(0.02, .30, boulderHeight));   
            col.rgb = mix(col.rgb, foliageCol, step(0.01, foliageHeight));
              
            specLevel = mix(specLevel, 5.*stoneColor.r, step(.03, stoneHeight));
            specLevel = mix(specLevel, mix((3.2*boulderColor.r), 1.5*boulderColor.r, mossAmount), step(.03, boulderHeight));
            specLevel = mix(specLevel, 0.15, step(.03, foliageHeight));
              
          #ifdef QUALITYFOLIAGE
            fColor = TraceFoliage(marchResult.hitPos+marchResult.normal*0.004, rayDir, 32, vec3(0.55, 0.36, 0.45));    
          #endif
          }      

          // get lightning based on material
          light = GetLightTerrain(specLevel, marchResult.normal, marchResult, rayDir, rayOrigin, 0.0);   
          col = col*light;         
          col =mix( col,  saturate(mix(col, fColor.rgb* vec3(1., 0.7, 0.47), 0.55)), fColor.a );       
      }
      

      col = mix(col, (col+sunColor)*0.6, smoothstep(70., 600., marchResult.depth));

      ApplyFog(col, skyColor, rayOrigin, rayDir, marchResult.depth);
      color.rgb = col; 
      color.a= marchResult.depth;
    } 
    else  // if main trace missed terrain, continue from last ray postion and trace mountains
    {
      RayHit marchResult2 = TraceMountains(rayOrigin+(rayDir*marchResult.depth*0.7), rayDir, 100, 1000.);

      // mountains hit
      if (marchResult2.hit)
      {
        marchResult2.normal = calcNormalMountains(marchResult2.hitPos);  
 
        // adding some slight haze at mountain bottom
        vec3 col = vec3(0.5);

        vec3 light = GetLightMountains(0.6, marchResult2.normal, marchResult2, rayDir, rayOrigin);   
        col = col*light;
        col = mix(col, (col+sunColor)*0.6, smoothstep(70., 600., marchResult2.depth));
        col = mix(mix(col,vec3(.9, 0.7, 0.57)*(.4+1.27*abs(noise((marchResult2.hitPos.xz-vec2(iTime*17.0,0))*0.02))),0.5),col,smoothstep(0.,70.,marchResult2.hitPos.y));

        ApplyFog(col, skyColor, rayOrigin, rayDir, marchResult.depth);
        color.rgb = col; color.a=500.;
      }
    }
  #endif
    
  fragColor = color;
}

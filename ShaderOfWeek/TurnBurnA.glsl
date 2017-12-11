// https://www.shadertoy.com/view/MlscWX
//////////////////////////////////////////////////////////////////////////////////////
// DATA BUFFER  -  PLANE MOVEMENT, KEYBOARD CHECKS AND MISSILE UPDATE (IF LAUNCHED)
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Keyoard input. Used to capture key-presses.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = This buffer (A). Read and write data to update movement in this shader.
// Channel 3 = Lichen texture. Used to create landscape height map used in collision detection.

  #define PI acos(-1.)
  #define keyClick(ascii)   ( texelFetch(iChannel0, ivec2(ascii, 0), 0).x > 0.)
  #define keyPress(ascii)   ( texelFetch(iChannel0, ivec2(ascii, 1), 0).x > 0.)
  #define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
  #define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
  #define MAX_HEIGHT 150. 
  #define MIN_HEIGHT 0. 
  #define STARTHEIGHT 40.
  #pragma optimize(off) 
// SPACE   FIRE MISSILE
#define MISSILE_KEY 32  
// S    ROLL LEFT
#define ROLL_LEFT_KEY 83  
// F    ROLL RIGHT
#define ROLL_RIGHT_KEY 70      
// W    YAW LEFT   (PLANE STRIFE)
#define LEFT_KEY 87    
// R    YAW RIGHT   (PLANE STRIFE)
#define RIGHT_KEY 82     
// E    PITCH DOWN
#define UP_KEY 69     
// D    PITCH UP
#define DOWN_KEY 68     
// SHIFT  INC SPEED
#define SPEED_INCREASE_KEY 16     
// CTRL   DEC SPEED
#define SPEED_DECREASE_KEY 17    
// F1     ZOOM OUT
#define ZOOMOUT_KEY 112
// F2     ZOOM IN
#define ZOOMIN_KEY 113

// Alternative controls if uncommented  (lets you use arrow keys to control the plane)
/* 
// ENTER   FIRE MISSILE
#define MISSILE_KEY 13
// LEFT ARROW    ROLL LEFT
#define ROLL_LEFT_KEY 37  
// RIGHT ARROW    ROLL RIGHT
#define ROLL_RIGHT_KEY 39     
// DELETE   YAW LEFT   (PLANE STRIFE)
#define LEFT_KEY 46    
// PAGE DOWN    YAW RIGHT   (PLANE STRIFE)
#define RIGHT_KEY 34     
// UP ARROW    PITCH DOWN
#define UP_KEY 38     
// DOWN ARROW    PITCH UP
#define DOWN_KEY 40     
// SHIFT  INC SPEED
#define SPEED_INCREASE_KEY 16     
// CTRL   DEC SPEED
#define SPEED_DECREASE_KEY 17    
// F1     ZOOM OUT
#define ZOOMOUT_KEY 112
// F2     ZOOM IN
#define ZOOMIN_KEY 113
*/


vec3 sunPos=vec3(0.);
vec3 planePos=vec3(0.);
float explosionCount=0.;


struct Missile
{ 
  vec3 pos;
  float life;
  vec3 orientation;   // roll,pitch,turn amount
    vec3 startPos;
};

struct Explosion
{ 
  vec3 pos;
  float life;
};



mat3 setCamera(  vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}

mat2 r2(float r) {
  float c=cos(r), s=sin(r);
  return mat2(c, s, -s, c);
}

void pR(inout vec2 p, float a) 
{
  p*=r2(a);
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

float NoTreeZone(vec3 p)
{
    float dist = distance(readRGB(ivec2(140, 0)).xz,p.xz);
    dist = min(dist,distance(readRGB(ivec2(142, 0)).xz,p.xz));
    dist = min(dist,distance(readRGB(ivec2(144, 0)).xz,p.xz));
    dist = min(dist,distance(readRGB(ivec2(146, 0)).xz,p.xz));
    dist = min(dist,distance(readRGB(ivec2(148, 0)).xz,p.xz));
    return dist;
}
float GetTerrainHeight( vec3 p)
{
  vec2 p2 = (p.xz+planePos.xz)*0.0005;

  float heightDecrease = mix(1.0,0.,smoothstep(0.,15.0,NoTreeZone(p+planePos)));
    
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
  if(NoTreeZone(p+planePos)<25.) return 0.;
  float treeHeight = textureLod(iChannel3, (p.xz+planePos.xz)*0.006, .1).x;
  float tree = mix(0., mix(0., mix(0., 2.0, smoothstep(0.3, 0.86, treeHeight)), smoothstep(1.5, 3.5, terrainHeight)), step(0.3, treeHeight)); 
  tree -= tree*0.75;
  tree*=4.0;

  return  tree;
}

vec3 TranslatePos(vec3 p, float _direction, float _pitch, float _roll)
{
  pR(p.xz, _direction);
  pR(p.zy, _pitch);

  return p;
}

void LaunchMissile(inout Missile missile, vec3 startPos, vec3 orientation)
{
  missile.life=4.0; 
  missile.orientation = orientation;
  missile.pos =  startPos;
  missile.startPos= planePos;
  missile.orientation.y *=cos(missile.orientation.x-PI);
}

void UpdateMissile(inout Missile missile, float id, inout vec4 fragColor, vec2 fragCoord, vec3 moveDiff)
{
  float adressStep = id*100.;
     
  Explosion explosion;
 
  // read variables for explosion s
  explosion.pos = readRGB(ivec2(120+int(adressStep), 0));    
  explosion.life = read(ivec2(122+int(adressStep), 0));

  // update active missile and save variables
  if ( missile.life>0.)
  {
    missile.life-= 0.015;
    vec3 velocityAdd = vec3(0., 0., 1.4);

    pR(velocityAdd.yz, missile.orientation.y);
    pR(velocityAdd.xz, -missile.orientation.z);

    missile.pos += velocityAdd; // add velocity movement to pos
    missile.pos.xz-=moveDiff.xz; // add plane movement to pos

    // ground collision check                 
    vec3 testPoint = missile.pos;
      
    testPoint+=vec3(4.8 - (9.6*id), -0.4, -3.0);
    pR(testPoint.xz, missile.orientation.z);
    testPoint-=vec3(4.8 - (9.6*id), -0.4, -3.0);
    testPoint.y+=missile.startPos.y;
      
    float tHeight = GetTerrainHeight(testPoint);
    tHeight+=GetTreeHeight(testPoint, tHeight);

    // does missile hit terrain?
    if (testPoint.y<tHeight)
    {
      // if colliding, kill missile and spawn explosion.             
       explosion.pos =  missile.pos+missile.startPos;
       explosion.pos.y = tHeight-3.0;
       explosion.life=10.0;
       missile.life=-10.;
       explosionCount+=2.0;
       explosionCount = mod(explosionCount,10.);
    }

    fragColor.a = mix(missile.life, fragColor.a, step(1., distance(fragCoord.xy, vec2(100.0+adressStep, 0.0))));
    fragColor.rgb = mix(missile.startPos, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(102.0+adressStep, 0.0))));
    fragColor.rgb = mix(missile.orientation, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(108.0+adressStep, 0.0)))); 
    fragColor.rgb = mix(missile.pos, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(116.0+adressStep, 0.0))));
            
  }
  // ##################################################################

  // update explosion
  if ( explosion.life>0.)
  {   
    explosion.life-= 0.115;
   // explosion.life= 9.715;
    fragColor.rgb = mix(explosion.pos, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(120.0+adressStep, 0.0)))); 
    fragColor.a = mix(explosion.life, fragColor.a, step(1., distance(fragCoord.xy, vec2(122.0+adressStep, 0.0))));
      
    // terrain holes
    fragColor.rgb = mix(mix(explosion.pos, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(140.0+explosionCount, 0.0)))),fragColor.rgb,step(0.4,distance(5.0,explosion.life)));
  }
}


void ToggleEffects(inout vec4 fragColor, vec2 fragCoord)
{
   // read and save effect values from buffer  
   vec3 effects =  mix(vec3(-1.0,1.0,1.0), readRGB(ivec2(20, 0)), step(1.0, float(iFrame)));
   effects.x*=1.0+(-2.*float(keyPress(49))); //1-key  LENSDIRT
   effects.y*=1.0+(-2.*float(keyPress(50))); //2-key  GRAINFILTER
   effects.z*=1.0+(-2.*float(keyPress(51))); //3-key  ChromaticAberration
   
   vec3 effects2 =  mix(vec3(1.0,1.0,1.0), readRGB(ivec2(22, 0)), step(1.0, float(iFrame)));
   effects2.y*=1.0+(-2.*float(keyPress(52))); //4-key  AA-pass
   effects2.x*=1.0+(-2.*float(keyPress(53))); //5-key  lens flare

   fragColor.rgb = mix(effects, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(20.0, 0.0))));  
   fragColor.rgb = mix(effects2, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(22.0, 0.0))));  
}


void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 mo = iMouse.xy/iResolution.xy;
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  // read plane values from buffer
  float turn = mix(1.0, read(ivec2(1, 10)), step(1.0, float(iFrame)));
  float roll = mix(3.14, read(ivec2(1, 1)), step(1.0, float(iFrame)));
  float rudderAngle = read(ivec2(6, 1));
  float speed = read(ivec2(10, 1));
  float pitch = read(ivec2(15, 1));
  explosionCount = read(ivec2(3, 0));  
    
  sunPos = mix(normalize( vec3(-1.0, 0.3, -.50) ), readRGB(ivec2(50, 0)), step(1.0, float(iFrame)));
  planePos = mix(vec3(-400, STARTHEIGHT, -100), readRGB(ivec2(55, 0)), step(1.0, float(iFrame)));
  float CAMZOOM = mix(13.9, read(ivec2(52, 0)), step(1.0, float(iFrame)));  
  vec2 camRot = vec2(-1., 0.340);

  // setup camera and ray direction
  camRot.x+=mo.x*16.; 
  camRot.y+=mo.y*16.; 
 
  // limit roll
  roll=mod(roll, 6.28);
 
    // add turn angle based on roll  
  float turnAmount = mix(0., 1.57, smoothstep(0., 1.57, 1.57-distance(1.57, roll-3.14)));
  turnAmount += mix(0., -1.57, smoothstep(0., 1.57, 1.57-distance(-1.57, roll-3.14)));
  float PitchAdd = sin(pitch);
 
  // YAW
  turn+=0.02*rudderAngle;
  // add turn angle  
  turn+=turnAmount*0.015;
  turn-=0.1*(((pitch*0.25)*cos(roll-1.57)));
  
    turn= mod(turn,PI*2.);
  vec3 oldPlanePos = vec3(planePos.x, planePos.y, planePos.z);

  // move plane
  planePos.xz += vec2(cos(turn+1.5707963)*0.5,  sin(turn+1.5707963)*0.5)*(0.7+speed)*cos(pitch);
  planePos.y = clamp(planePos.y+((PitchAdd*0.25)*cos(roll-PI)), MIN_HEIGHT, MAX_HEIGHT);

  rudderAngle*=0.97;
  // check key inputs
  rudderAngle-=0.03*float(keyClick(LEFT_KEY));
  rudderAngle+=0.03*float(keyClick(RIGHT_KEY));
  rudderAngle=clamp(rudderAngle, -0.4, 0.4);;
  roll-=0.055*float(keyClick(ROLL_LEFT_KEY));
  roll+=0.055*float(keyClick(ROLL_RIGHT_KEY));

  speed+=(0.02*float(keyClick(SPEED_INCREASE_KEY)));
  speed-=(0.02*float(keyClick(SPEED_DECREASE_KEY)));
  speed=clamp(speed, -0.3, 1.);
   
  // prevent plane from getting into terrain
  float tHeight = GetTerrainHeight(planePos);
  tHeight+=GetTreeHeight(planePos, tHeight);
  float minHeight = tHeight+12.;
  planePos.y = max(planePos.y,minHeight);
    
   // pitch = sin(pitch);
  pitch-=(mix(0.02, 0., smoothstep(0., 3., 3.0-abs(distance(planePos.y, minHeight))))*float(keyClick(UP_KEY))); //e-key
  pitch+=(mix(0.02, 0., smoothstep(0., 3., 3.0-abs(distance(planePos.y, MAX_HEIGHT))))*float(keyClick(DOWN_KEY))); //d-key
  pitch = clamp(pitch, -1.25, 1.25);
  pitch*=0.97;

  turnAmount += mix(0., -1.57, smoothstep(0., 1.57, 1.57-distance(-1.57, roll-3.14)));
  fragColor = vec4(textureLod(iChannel2, uv,0.).rgb,0.);
    
  // ------------------------- MISSILES ------------------------------
  // NOTE: MISSILES ARE RENDERED IN BUFFER B TOGETHER WITH THE TERRAIN     
  int adressStep = 0;
  bool launchLocked=false;
  Missile missile;
  for (int i=0; i<2; i++)
  {
    adressStep = i*100;
      
    // read variables for missiles
    missile.life = read(ivec2(100 + adressStep, 0));
    missile.startPos = readRGB(ivec2(102 + adressStep, 0));  
    missile.orientation = readRGB(ivec2(108 + adressStep, 0));
    missile.pos = readRGB(ivec2(116 + adressStep, 0));

  // if missile is "dead" check if a new missile is being lanched by pressing the M-key
  if (keyPress(MISSILE_KEY) && !launchLocked)
  {    
   if (missile.life<=0.)
   {
      LaunchMissile(missile, vec3(4.8- (9.6*float(i)), -0.4, -3.0), vec3(roll, pitch, turn));  
      launchLocked=true;
   } 
 }    

  UpdateMissile(missile, float(i), fragColor, fragCoord, (planePos-oldPlanePos));
  // ##################################################################
  }

  ToggleEffects(fragColor, fragCoord);
   
  CAMZOOM-=0.3*float(keyClick(ZOOMIN_KEY));
  CAMZOOM+=0.3*float(keyClick(ZOOMOUT_KEY));
  CAMZOOM=clamp(CAMZOOM, 10., 30.);;
  
  // save roll,speed and scroll values etc to buffer A 
  fragColor.a = mix(turn, fragColor.a, step(1., distance(fragCoord.xy, vec2(1.0, 10.0)))); 
  fragColor.a = mix(speed, fragColor.a, step(1., distance(fragCoord.xy, vec2(10.0, 1.0)))); 
  fragColor.a = mix(roll, fragColor.a, step(1., distance(fragCoord.xy, vec2(1.0, 1.0)))); 
  fragColor.a = mix(pitch, fragColor.a, step(1., distance(fragCoord.xy, vec2(15.0, 1.0)))); 
  fragColor.a = mix(rudderAngle, fragColor.a, step(1., distance(fragCoord.xy, vec2(6.0, 1.0))));
  fragColor.a = mix(explosionCount, fragColor.a, step(1., distance(fragCoord.xy, vec2(3.0, 0.0)))); 
  fragColor.rgb = mix(sunPos, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(50.0, 0.0))));
  fragColor.a = mix(CAMZOOM, fragColor.a, step(1., distance(fragCoord.xy, vec2(52.0, 0.0))));
  fragColor.rgb = mix(planePos, fragColor.rgb, step(1., distance(fragCoord.xy, vec2(55.0, 0.0))));
  fragColor.rgb = mix(vec3(camRot.xy, 0.), fragColor.rgb, step(1., distance(fragCoord.xy, vec2(57.0, 0.0))));
}

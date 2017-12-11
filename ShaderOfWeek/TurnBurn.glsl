////////////////////////////////////////////////////////////////////////////////////////////
// Copyright © 2017 Kim Berkeby
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
////////////////////////////////////////////////////////////////////////////////////////////
/*

 CONTROLS:
 ---------
 SPACE  FIRE MISSILE
 
 S      ROLL LEFT
 F      ROLL RIGHT  
 E      PITCH DOWN
 D      PITCH UP
 
 W      YAW LEFT   (PLANE TURN) 
 R      YAW RIGHT   (PLANE TURN)
 
 SHIFT  INCREASE SPEED
 CTRL   DECCREASE SPEED 
 
 F1     ZOOM OUT
 F2     ZOOM IN
 
 NOTICE:
 Controls can be changed to use arrow keys if you uncomment the alternative controls in Buf A. 
 
 
 Toggle effects by pressing folloving keys:
 ------------------------------------------
 1-key  = Lens dirt  on/off               (default off)
 2-key  = Grain filter  on/off            (default on)
 3-key  = Chromatic aberration  on/off    (default on)    
 4-key  = Anti aliasing  on/off           (default on)
 5-key  = Lens flare  on/off              (default on)
 
 --------------------------------------------------------
 TO INCREASE PERFORMANCE:
 
 Delete one or several defines from Buf B:
 
 #define SHADOWS
 #define QUALITY_TREE
 #define QUALITY_REFLECTIONS
 #define EXACT_EXPLOSIONS
 --------------------------------------------------------
 
 This shader was made by using distance functions found in HG_SDF:
 http://mercury.sexy
 
 Special thanks to Inigo Quilez for his great tutorials on:
 http://iquilezles.org/
 
 Last but not least, thanks to all the nice people here at ShaderToy! :-D

*/
//////////////////////////////////////////////////////////////////////////////////////
// POST EFFECTS BUFFER
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Buffer A. Read data from data-buffer.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = Buffer C. Get the colors of the render from the last buffer.
// Channel 3 = Organic 2 texture. Used in lens dirt filter.


  #define FastNoise(posX) (  textureLod(iChannel1, (posX+0.5)/iResolution.xy, 0.0).r)
  #define readAlpha(memPos) (  textureLod(iChannel2, memPos, 0.0).a)
  #define read(memPos) (  texelFetch(iChannel0, memPos, 0).a)
  #define readRGB(memPos) (  texelFetch(iChannel0, memPos, 0).rgb)
  #define CLOUDLEVEL -70.0
  #define PI acos(-1.)
  #pragma optimize(off) 
mat3 cameraMatrix;
vec3 planePos=vec3(0.);
vec3 sunPos=vec3(0.);
const vec3 eps = vec3(0.02, 0.0, 0.0);

float GetExplosionIntensity(float life)
{
  return mix(1., .0, smoothstep(0., 5.0, distance(life, 5.)));
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

mat3 setCamera(  vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}

vec2 GetScreenPos(vec3 pos)
{
  return vec2(PI*dot( pos, cameraMatrix[0].xyz ), PI* dot( pos, cameraMatrix[1].xyz ));
}

vec3 CalculateSunFlare(vec3 rayDir, vec3 rayOrigin, vec2 screenSpace, float alpha, float enableFlare)
{
  float visibility = pow(max(0., dot(sunPos, rayDir)), 8.0);  
  if (visibility<=0.05) return vec3(0.);

  vec2 sunScreenPos = GetScreenPos(sunPos);

  vec2 uvT = screenSpace-sunScreenPos;
  float sunIntensity = (1.0/(pow(length(uvT)*4.0+1.0, 1.30)))*visibility;

  vec3 flareColor = vec3(0.);
  vec2 offSet = uvT;
  vec2 offSetStep=  0.4*sunScreenPos;
  vec3 color;
  float size=.0, dist=0.;
  
  if(enableFlare>0.)
  {
  // check if center of sun is covered by any object. MATH IS OFF AT SCREEN CHECK POS! sunScreenPos/2.0 +0.5 IS NOT EXACTLY SUN MIDDLE!
  // only draw if not covered by any object
  if (readAlpha( sunScreenPos/2.0 +0.5)<0.50)
  {
    // create flare rings
    for (float i =1.; i<8.; i++)
    {
      color.rg = vec2(abs((sin(i*53.))), 0.65);
      color.b = abs((cos(i*25.)));
      offSet += offSetStep;

      size = 0.05+((1.-sin(i*0.54))*0.28);
      dist = pow(distance(sunScreenPos, offSet), 1.20);

      flareColor += mix(vec3(0.), sunIntensity*(10.*size) * color, smoothstep(size, size-dist, dist))/(1.0-size);
    }
  }
  flareColor*=mix(0., 1.0, smoothstep(0., 0.1, visibility));
  }
    
  // flare star shape
  vec3 sunSpot = vec3(1.30, 1., .80)*sunIntensity*(sin(FastNoise((sunScreenPos.x+sunScreenPos.y)*2.3+atan(uvT.x, uvT.y)*15.)*5.0)*.12);
  // sun glow
  sunSpot+=vec3(1.0, 0.96, 0.90)*sunIntensity*.75;
  sunSpot+=vec3(1.0, 0.76, 0.20)*visibility*0.15;

  return flareColor+(sunSpot*(1.0-alpha));
}
vec3 CalculateExplosionFlare(vec3 rayDir, vec3 rayOrigin, vec2 screenSpace, float alpha, vec3 explosionPos, float enableFlare)
{

  float visibility = max(0., dot(explosionPos, rayDir));  
  if (visibility<=0.15) return vec3(0.);

  vec2 flareScreenPos = GetScreenPos(explosionPos);
  vec2 uvT = screenSpace-flareScreenPos;
  float flareIntensity = 0.2*visibility;
  vec3 flareColor = vec3(0.);
  vec2 offSet = uvT;
  vec2 offSetStep=  0.4*flareScreenPos;
  vec3 color;
  float size=.0, dist=0.; 

    if(enableFlare>0.)
    {
  // create flare rings
  for (float i =1.; i<8.; i++)
  {
    color.rg = vec2(0.75+(0.25*sin(i*i)));
    color.b = 0.75+(0.35*cos(i*i));
    offSet += offSetStep;
    size = 0.05+((1.-sin(i*0.54))*0.38);
    dist = pow(distance(flareScreenPos, offSet), 1.20);

    flareColor += mix(vec3(0.), flareIntensity*(4.*size) * color, smoothstep(size, size-dist, dist))/(1.0-size);
  }
  flareColor/=2.;
    }
  // flare star shape
  vec3 flareSpot = vec3(1.30, 1., .80)*flareIntensity*(sin(FastNoise((flareScreenPos.x+flareScreenPos.y)*5.+atan(uvT.x, uvT.y)*10.)*4.0)*.2+3.5*flareIntensity);
  // flare glow
  flareSpot+=vec3(1.0, 0.7, 0.2)*pow(visibility, 12.0)*0.3;

  return (flareColor+flareSpot)*(1.0-alpha);
}

void pR(inout vec2 p, float a)
{
  p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float DrawExplosion(int id, inout vec4 color, vec3 rayDir, vec3 rayOrigin, vec2 screenSpace, float enableFlare)
{
  id *= 100; 
  float dist =-10000.;
  float life = read(ivec2(122+id, 0));

  // check if explosion has been spawned
  if (life>0. )
  {     
    vec3 pos = normalize(readRGB(ivec2(120+id, 0))-planePos); 
    float eDist = pow(max(0., dot(pos, rayDir)), 2.0); 
    float intensity =GetExplosionIntensity(life);
    dist = eDist*intensity*1.4;
    color.rgb += CalculateExplosionFlare(rayDir, rayOrigin, screenSpace, 1.0-intensity, pos, enableFlare);
    color.rgb = mix(color.rgb, color.rgb+vec3(1.0, 0.4, 0)*0.5, eDist*intensity);
  }   
  return dist;
}  


vec3 AntiAliasing(vec2 uv)
{
  vec2 offset = vec2(0.11218413712, 0.33528304367) * (1.0 / iResolution.xy);

  return (texture(iChannel2, uv + vec2(-offset.x, offset.y)) +
    texture(iChannel2, uv + vec2( offset.y, offset.x)) +
    texture(iChannel2, uv + vec2( offset.x, -offset.y)) +
    texture(iChannel2, uv + vec2(-offset.y, -offset.x))).rgb * 0.25;
}

void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 mo = iMouse.xy/iResolution.xy;
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  // read values from buffer
  vec3 effects = readRGB(ivec2(20, 0));  
  vec3 effects2 = readRGB(ivec2(22, 0)); 
  float turn = read(ivec2(1, 10));
  sunPos = readRGB(ivec2(50, 0));
  planePos = readRGB(ivec2(55, 0));
  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;
  float CAMZOOM = read(ivec2(52, 0));  
  vec3 rayOrigin = vec3(CAMZOOM*cos(camRot.x), 3.+CAMZOOM*sin(camRot.y), -3.+CAMZOOM*sin(camRot.x) );
  pR(rayOrigin.xz, -turn);
  cameraMatrix  = setCamera( rayOrigin, vec3(0., 0., -3. ), 0.0 );
  vec3 rayDir = cameraMatrix * normalize( vec3(screenSpace.xy, 2.0) );

  vec2 d = abs((uv - 0.5) * 2.0);
  d = pow(d, vec2(2.0, 2.0));
  float minDist = -1000.0;


  vec4 color;

  // chromatic aberration?
  if (effects.z>0.)
  {
    float offSet = distance(uv, vec2(0.5))*0.005;
    // AA pass?
    if (effects2.y>0.)
    {
      color.rgb = vec3(AntiAliasing(uv + offSet).r, AntiAliasing(uv).g, AntiAliasing(uv - offSet).b);
    } else
    {
      color.rgb = vec3(texture(iChannel2, uv + offSet).r, texture(iChannel2, uv).g, texture(iChannel2, uv - offSet).b);
    }
  }
  // no chromatic aberration 
  else
  {
    // AA pass?
    if (effects2.y>0.)
    {
      color.rgb=AntiAliasing(uv);
    } else
    {
      color.rgb = texture(iChannel2, uv).rgb;
    }
  }

  color.a=textureLod(iChannel2, uv, 0.).a;

  // add sun with lens flare effect
  color.rgb += CalculateSunFlare(rayDir, rayOrigin, screenSpace, clamp(color.a, 0., 1.0),effects2.x);

  // add explosion light effects
  minDist = max(minDist, DrawExplosion(0, color, rayDir, rayOrigin, screenSpace,effects2.x));
  minDist = max(minDist, DrawExplosion(1, color, rayDir, rayOrigin, screenSpace,effects2.x));

  float cloudDistance = distance(rayOrigin.y+planePos.y, -CLOUDLEVEL);

  // grain noise
  if (effects.y>0.)
  {
    vec2 grainTexPos = ((fragCoord.xy + iTime*60.0*vec2(10, 35.))*mix(0.6, 0.2, smoothstep(5.0, 0., cloudDistance)))/iChannelResolution[0].xy;
    vec2 filmNoise = textureLod( iChannel1, grainTexPos, 0. ).rb;
    // scale up effect when flying through clouds
    color.rgb *= mix( vec3(1), mix(vec3(1, .5, 0), vec3(0, .5, 1), filmNoise.x), mix(.04, 0.7, smoothstep(5.0, 0., cloudDistance))*filmNoise.y );
  }

  // flying though clouds
  color = mix(color, clamp(color+max(0.4, fastFBM(rayOrigin+planePos)*2.), 0., 1.0), smoothstep(5.0, 0., cloudDistance));


  // Lens dirt when looking into strong light source
  if (effects.x>0.)
  {
    minDist=max(minDist, pow(max(0., dot(sunPos, rayDir)), 2.0));     
    float dirtTex = textureLod( iChannel3, (fragCoord.xy / iResolution.x), 0.3 ).r*2.5;

    color.rgb += 0.04*dirtTex*minDist;
  }

  fragColor =  vec4(pow(color.rgb, vec3(1.0/1.1)), 1.0 ) * (0.5 + 0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.2 ));
}

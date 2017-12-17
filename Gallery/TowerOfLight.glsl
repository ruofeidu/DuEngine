// https://www.shadertoy.com/view/lllBRn
////////////////////////////////////////////////////////////////////////////////////////////
// Copyright © 2017 Kim Berkeby (email: mr.kimb@hotmail.com)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
////////////////////////////////////////////////////////////////////////////////////////////
/*
 Youtube version of the shader (great thanks to Adrian Chlubek, aka afl_ext):

 https://youtu.be/pKY_-Kgs_1Q
 https://youtu.be/_Kh7GcYLM3I

 CONTROLS:
 ---------
 Hold left mouse button and move mouse to pitch and rotate camera.
  
 D     ZOOM OUT
 E     ZOOM IN

F1     ZOOM OUT (alternative)
F2     ZOOM IN  (alternative)

 R     CAMERA UP
 F     CAMERA DOWN
  

 Notice:
 If you want to invert the mouse look, please enable #define INVERT_MOUSE_Y in Buf A.


 Toggle effects by pressing folloving keys:
 ------------------------------------------

 2-key  = Grain filter  on/off                   (default on)
 3-key  = Chromatic aberration  on/off           (default on)    
 4-key  = God Rays  on/off                       (default on)
 5-key  = Lens flare  on/off                     (default on)

 ---------------------------------------------------------------------------------
 *********************************************************************************

 MANY FEATURES ARE DISABLED. PLEASE ENABLE THE DEFINES TO SEE ALL FEATURES. Thanks!

 *********************************************************************************
 ---------------------------------------------------------------------------------
 

 TO INCREASE PERFORMANCE OR VIEW:
 --------------------------------
  
  Delete one or several defines from Buf C:
 
  #define TERRAIN   (removing this will make the shader ONLY render the tower model)
  #define TREES
  #define QUALITY_REFLECTIONS
  #define QUALITYFOLIAGE
  #define GRASS
  #define SHADOWS
  #define PERFORM_AO_PASS
  #define BRIDGE
  #define BOAT

  Delete one or several defines from Buf D:
 
  #define PERFORM_AO_PASS
  #define PERFORM_AA_PASS    (deleting this will cause a lot of noise)
  #define SHADOWS

 --------------------------------------------------------
 
 This shader was made by using distance functions found in HG_SDF:
 http://mercury.sexy
 
 Special thanks to Inigo Quilez for his great tutorials on:
 http://iquilezles.org/

 Music by Muse Muh Nur:
 https://soundcloud.com/musa-muh-nur/nature-sounds-beautiful

 Last but not least, thanks to all the nice people here at ShaderToy! :-D

*/


//////////////////////////////////////////////////////////////////////////////////////
// POST EFFECTS BUFFER
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Buffer A. Read data from data-buffer.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = Buffer C. Get the colors of the render from the last buffer.
// Channel 3 = Music ( https://soundcloud.com/musa-muh-nur/nature-sounds-beautiful )

  #define FastNoise(posX) (  textureLod(iChannel1, (posX+0.5)/iResolution.xy, 0.0).r)
  #define readAlpha(memPos) (  textureLod(iChannel2, memPos, 0.0).a)
  #define read(memPos) (  texelFetch(iChannel0, memPos, 0).a)
  #define readRGB(memPos) (  texelFetch(iChannel0, memPos, 0).rgb)
  #define PI acos(-1.)
  #pragma optimize(off) 

mat3 cameraMatrix;

vec3 sunPos=vec3(0.);

float CalcSum(vec2 uvPos) 
{
    vec4 col = textureLod(iChannel2, uvPos,0.);
    float sum = (col.r+col.g+col.b)*0.333;
    return mix(0.,sum,step(0.75,sum-col.a));
}

#define VOLUMESAMPLES 24
float GetVolumetrics(vec2 pos, vec2 uv)
{
    float sum 	 = 0.;
    float weight = 1. / float(VOLUMESAMPLES);
    vec2 dir = pos-uv;
    
    for(int i = 0; i < VOLUMESAMPLES; i++)
    {
        sum += CalcSum(uv);
        uv += dir * .036;
    }
    
    return sum * weight * 0.4;
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

  float visibility = pow(max(0., dot(sunPos, rayDir)), 5.0);  
  if (visibility<=0.006) return vec3(0.);
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
      dist = pow(length(sunScreenPos-offSet), 1.20);

      flareColor += mix(vec3(0.), sunIntensity*(10.*size) * color, smoothstep(size, size-dist, dist))/(1.0-size);
    }

      flareColor = mix(flareColor,flareColor*.1, max(0.,visibility));
  flareColor += (vec3(1.0, .0, .0)  * pow(visibility, 1.)*.5);
  }
  flareColor*=mix(2., .2, smoothstep(0., 1., visibility)); 

  
  }
    
  // flare star shape
  vec3 sunSpot = vec3(1.30, 1., .80)*sunIntensity*(sin(FastNoise((sunScreenPos.x+sunScreenPos.y)*2.3+atan(uvT.x, uvT.y)*15.)*5.0)*.12);
  // sun glow
  sunSpot+=vec3(1.0, 0.96, 0.90)*sunIntensity*.75;
  sunSpot+=vec3(1.0, 0.76, 0.20)*visibility*0.245;
    
  return flareColor+(sunSpot*(1.0-alpha));
}


void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  // read values from buffer
  vec3 effects = readRGB(ivec2(120, 0));  
  vec3 effects2 = readRGB(ivec2(122, 0)); 
  float turn = read(ivec2(1, 10));
  sunPos = readRGB(ivec2(50, 0));
  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;
  vec3 camData  = readRGB(ivec2(52, 0));  

  vec3 rayOrigin = vec3(camData.z*cos(camRot.x), camData.y,camData.z*sin(camRot.x) );
     rayOrigin.y = readRGB(ivec2(62, 0)).y;
    cameraMatrix  = setCamera( rayOrigin, vec3(0., camData.y+(11.*camRot.y), 0. ), 0.0 );
  vec3 rayDir = cameraMatrix * normalize( vec3(screenSpace.xy, 2.0) );

  vec2 d = abs((uv - 0.5) * 2.0);
  d = pow(d, vec2(2.0, 2.0));
  float minDist = -1000.0;


  vec4 color;

  // chromatic aberration?
  if (effects.z>0.)
  {
    vec2 offSet = (uv.xy*2.-1.)/iResolution.xy*1.5;
    color.rgb = vec3(texture(iChannel2, uv + offSet).r, texture(iChannel2, uv).g, texture(iChannel2, uv - offSet).b);
    
  }
  // no chromatic aberration 
  else
  {
      color.rgb = texture(iChannel2, uv).rgb;
  }

  color.a=textureLod(iChannel2, uv, 0.).a;

  // add sun with lens flare effect
  color.rgb += CalculateSunFlare(rayDir, rayOrigin, screenSpace, clamp(color.a, 0., 1.0),effects2.x);

  // grain noise
  if (effects.y>0.)
  {
    vec2 grainTexPos = ((fragCoord.xy + iTime*60.0*vec2(10, 35.))*0.6)/iChannelResolution[0].xy;
    vec2 filmNoise = textureLod( iChannel1, grainTexPos, 0. ).rb;
  }

  if (effects2.y>0.)
  {
    // perform volumetric light ray pass if looking into the sun
float sunVisibility = max(0.,dot(sunPos, rayDir));
    if(sunVisibility>0.)
    {
          vec2 sunScreenPos = GetScreenPos(sunPos);
           color.rgb += mix(0.,GetVolumetrics(sunScreenPos/2.0 +0.5, uv),pow(sunVisibility,6.));
    }
  } 
    
  fragColor =  vec4(pow(color.rgb, vec3(1.0/1.1)), 1.0 ) * (0.5 + 0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.32 ));
}

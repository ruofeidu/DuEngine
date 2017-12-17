// https://www.shadertoy.com/view/lllBRn
//////////////////////////////////////////////////////////////////////////////////////
// DATA BUFFER  -  CAMERA CONTROL AND KEYBOARD CHECKS
//////////////////////////////////////////////////////////////////////////////////////
// Channel 0 = Keyoard input. Used to capture key-presses.
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = This buffer (A). Read and write data to update this shader.
// Channel 3 = Lichen texture. Used to create landscape height map and textures.
  #pragma optimize(off) 
  #define keyClick(ascii)   ( texelFetch(iChannel0, ivec2(ascii, 0), 0).x > 0.)
  #define keyPress(ascii)   ( texelFetch(iChannel0, ivec2(ascii, 1), 0).x > 0.)
  #define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
  #define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
  //#define INVERT_MOUSE_Y 

  // R    CAM UP
  #define UP_KEY 82     
  // F    CAM DOWN
  #define DOWN_KEY 70      
  // D     ZOOM OUT
  #define ZOOMOUT_KEY 68
  // E     ZOOM IN
  #define ZOOMIN_KEY 69
  // F1     ZOOM OUT (alternative)
  #define ZOOMOUT_KEY_ALT 112
  // F2     ZOOM IN (alternative)
  #define ZOOMIN_KEY_ALT 113


// noise functions by IQ (somewhat modified to fit my usage)
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
//////////////////////////////////////////////////


float GetTerrainHeight( vec3 p)
{
  vec2 p2 = (p.xz)*0.0005;

  float mainHeight = -2.3+fastFBM(p*0.025)*max(11., abs(22.*noise2D(p2))); 
  float terrainHeight=mainHeight;
  p2*=4.0;
  terrainHeight += textureLod( iChannel3, p2, 2.7 ).x*1.; 
  p2*=2.0;
  terrainHeight -= textureLod( iChannel3, p2, 1.2 ).x*.7;
  p2*=3.0;
  terrainHeight -= textureLod( iChannel3, p2, 0.5 ).x*.1;

  terrainHeight=mix(terrainHeight, mainHeight*1.4, smoothstep(1.5, 3.5, terrainHeight)); 
  terrainHeight=mix(-0.6, terrainHeight, smoothstep(200., 240., length(p.xz-vec2(0., 120.))));
  terrainHeight=mix(-0.6, terrainHeight, smoothstep(250., 300., length(p.xz-vec2(100., -100.))));

  return   terrainHeight*1.4;
}


void ToggleEffects(inout vec4 fragColor, vec2 fragCoord)
{
  // read and save effect values from buffer  
  vec3 effects =  mix(vec3(-1.0, 1.0, -1.0), readRGB(ivec2(120, 0)), step(1.0, float(iFrame)));
  effects.y*=1.0+(-2.*float(keyPress(50))); //2-key  Grain Filter
  effects.z*=1.0+(-2.*float(keyPress(51))); //3-key  ChromaticAberration

  vec3 effects2 =  mix(vec3(1.0, 1.0, 1.0), readRGB(ivec2(122, 0)), step(1.0, float(iFrame)));
  effects2.y*=1.0+(-2.*float(keyPress(52))); //4-key  God Rays
  effects2.x*=1.0+(-2.*float(keyPress(53))); //5-key  lens flare

  fragColor.rgb = mix(effects, fragColor.rgb, step(1., length(fragCoord.xy-vec2(120.0, 0.0))));  
  fragColor.rgb = mix(effects2, fragColor.rgb, step(1., length(fragCoord.xy-vec2(122.0, 0.0))));
}

mat3 setCamera(  vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, vec2 fragCoord )
{ 
  const vec3 offSet = vec3(-143, 0., 292);
  vec2 mo = iMouse.xy/iResolution.xy;
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;

  vec3 sunPos = mix(normalize( vec3(1.730, 0.13, .700) ), readRGB(ivec2(50, 0)), step(1.0, float(iFrame)));
  vec3 camData = mix(vec3(0., 7., 68.), readRGB(ivec2(52, 0)), step(1.0, float(iFrame)));  
  vec2 camRot = mix(vec2(4.73, 0.), readRGB(ivec2(57, 0)).xy, step(1.0, float(iFrame))); 
  vec3 oldOrigin = readRGB(ivec2(62, 0));
    
  if (iMouse.z>0.)
  {
    // setup camera and ray direction
    camRot.x=(mo.x*12.); 
    #ifdef INVERT_MOUSE_Y 
      camRot.y=6.-((mo.y)*12.);
#else
  camRot.y=-6.+((mo.y)*12.);
#endif
}
camRot.y = clamp(camRot.y, -3., 3.);


ToggleEffects(fragColor, fragCoord);

camData.z-=0.3*float(keyClick(ZOOMIN_KEY) || keyClick(ZOOMIN_KEY_ALT));
camData.z+=0.3*float(keyClick(ZOOMOUT_KEY) || keyClick(ZOOMOUT_KEY_ALT));
camData.z=clamp(camData.z, 4., 100.);


camData.y+=0.3*float(keyClick(UP_KEY));
camData.y-=0.3*float(keyClick(DOWN_KEY));
camData.y=clamp(camData.y, 6., 30.);

// adding a small amount of camRot.y just to check if the camera has been moved in ANY way when later doing AA pass
vec3 rayOrigin = vec3(offSet.x+camData.z*cos(camRot.x), camData.y+(0.0001*camRot.y), offSet.z+camData.z*sin(camRot.x) );    
mat3 ca = setCamera( rayOrigin, vec3(0., camData.y+(11.*camRot.y), 0. ), 0.0 );
vec3 rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );
                    
// prevent camera from going below terrain
float groundH = GetTerrainHeight(rayOrigin)+3.;   
rayOrigin.y= max(rayOrigin.y, groundH);
camData.y = max(camData.y, groundH);

fragColor.rgb = mix(sunPos, fragColor.rgb, step(1., length(fragCoord.xy-vec2(50.0, 0.0))));
fragColor.rgb = mix(camData, fragColor.rgb, step(1., length(fragCoord.xy-vec2(52.0, 0.0))));
fragColor.rgb = mix(rayOrigin, fragColor.rgb, step(1., length(fragCoord.xy-vec2(62.0, 0.0))));
fragColor.rgb = mix(oldOrigin, fragColor.rgb, step(1., length(fragCoord.xy-vec2(60.0, 0.0))));
        
fragColor.rgb = mix(vec3(camRot.xy, 0.), fragColor.rgb, step(1., length(fragCoord.xy-vec2(57.0, 0.0))));
}

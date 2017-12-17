// https://www.shadertoy.com/view/lllBRn
//////////////////////////////////////////////////////////////////////////////////////
// TERRAIN BUFFER  -   RENDERS SKY
//////////////////////////////////////////////////////////////////////////////////////
// Channel 1 = LowRes noise texture. Used in fast noise functions.
// Channel 2 = Buffer A. Read data from data-buffer.
#define read(memPos) (  texelFetch(iChannel2, memPos, 0).a)
#define readRGB(memPos) (  texelFetch(iChannel2, memPos, 0).rgb)
#pragma optimize(off) 
#define NO_UNROLL(X) (X + min(0,iFrame))
float hash(float h)
{
    return fract(sin(h) * 43758.5453123);
} 

float sdEllipsoid( vec3 p, vec3 r )
{
  return (length( p/r ) - 1.0) * min(min(r.x,r.y),r.z);
}
float GetHorizon(vec3 p) { return sdEllipsoid(p, vec3(2000., 50., 2000.)); }


vec3 sunPos=vec3(0.);


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


float GetCloudHeightBelow(vec3 p)
{         
  vec3 p2 = (p+vec3(-iTime*1.3, 0., -iTime*1.65))*0.03;

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



vec4 TraceCloudsBelow( vec3 origin, vec3 direction, vec3 skyColor, int steps)
{
  origin.y-=15.;
  const vec3 sunColor = vec3(1.0, 0.53, 0.37); 
  vec4 cloudCol=vec4(vec3(0.95, 0.95, 0.98)*0.1, 0.0);
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
    rayPos.y=mix(rayPos.y,rayPos.y+250.,smoothstep(400.,1500.,t));
      
    density = clamp(GetCloudHeightBelow(rayPos), 0., 1.)*2.6;          
    dist = -GetHorizon(rayPos);

    precis = min(0.04,0.001*t);
    if (dist<precis && density>0.001)
    {    
      densAdd = 0.08*density/td;
      sunDensity = clamp(GetCloudHeightBelow(rayPos+sunPos*4.), -0.6, 2.)*2.; 
      cloudCol.rgb-=sunDensity*0.024*cloudCol.a*densAdd; 
      cloudCol.a+=(1.-cloudCol.a)*densAdd;

      cloudCol.rgb += 0.04*max(0., density-sunDensity)*densAdd;
    } 

    if (cloudCol.a > 0.99) break; 

    td = max(1.30, dist);
    t+=td;
  }

  // mix clouds color with sky color
  cloudCol.rgb = mix(cloudCol.rgb, vec3(0.97), smoothstep(100., 960., t)); 
  cloudCol.a = mix(cloudCol.a, 0., smoothstep(0., 860., t));

  return cloudCol;
}

mat3 setCamera(  vec3 ro, vec3 ta, float cr )
{
  vec3 cw = normalize(ta-ro);
  vec3 cp = vec3(sin(cr), cos(cr), 0.0);
  vec3 cu = normalize( cross(cw, cp) );
  vec3 cv = normalize( cross(cu, cw) );
  return mat3( cu, cv, cw );
}

#define colorStep 0.004
  #define gradStep 0.0022

  // create rain bow opposite direction to the sun
  vec3 CalculateRainbow(vec3 rayDir, vec3 rayOrigin, vec2 screenSpace)
{  
  float visibility = pow(max(0., dot(vec3(sunPos.x*-1., 0., sunPos.z*-1.), rayDir)), 20.0);  

  // rainbow colors based on center distance
  float colorPos = 0.05;
  vec3 color = mix(vec3(0.), vec3(1.0, 0, 0), smoothstep(colorPos, colorPos+gradStep, visibility)) ; 
  colorPos+=colorStep;
  color = mix(color, vec3(1.0, 0.5, 0), smoothstep(colorPos, colorPos+gradStep, visibility)) ; 
  colorPos+=colorStep;
  color = mix(color, vec3(1.0, 1., 0), smoothstep(colorPos, colorPos+gradStep, visibility)) ;
  colorPos+=colorStep;
  color = mix(color, vec3(.0, 1., 0), smoothstep(colorPos, colorPos+gradStep, visibility)) ;
  colorPos+=colorStep;
  color = mix(color, vec3(.0, .20, 1.), smoothstep(colorPos, colorPos+gradStep, visibility)) ;
  colorPos+=colorStep;
  color = mix(color, vec3(.0, .0, .9), smoothstep(colorPos, colorPos+gradStep, visibility)) ;
  colorPos+=colorStep;
  color = mix(color, vec3(.3, .0, 1.), smoothstep(colorPos, colorPos+gradStep, visibility)) ;
  colorPos+=colorStep;
  color = mix(color, vec3(0.), smoothstep(colorPos, colorPos+gradStep, visibility)) ;                                   

  // tone rainbow colors to transparent the closer to rayDir = 0.0 we get
  return color*visibility*2.15*mix(0., 1.0,smoothstep(0.3, 0., length(0.3-rayDir.y)));
}

// set sky color tone. 
vec3 GetSkyColor(vec3 rayDir)
{ 
    float sun = mix(0.,pow( clamp( 0.5 + 0.5*dot(sunPos,rayDir), 0.0, 1.0 ), 3.0 ),smoothstep(.33, .0, rayDir.y));
    float sun2 = clamp( 0.75 + 0.25*dot(sunPos,rayDir), 0.0, 1.0 );
    
    vec3 col = mix(vec3(156,140,164)/255., vec3(166,134,150)/255.,smoothstep(0.8, 0.00, rayDir.y)*sun2);
    col = mix(col, vec3(239,181,169)/255.,smoothstep(0.4, .0, rayDir.y)*sun2);
    col = mix(col, vec3(255,190,136)/255.,smoothstep(.4, 1.0, sun));
    col = mix(col, vec3(255,135,103)/255.,smoothstep(.8, 1.0, sun));
    return col;
}

void mainImage( out vec4 fragColor, vec2 fragCoord )
{  
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec2 screenSpace = (-iResolution.xy + 2.0*(fragCoord))/iResolution.y;
  float alpha=0.;

  sunPos =  readRGB(ivec2(50, 0));
  vec3 camData  = readRGB(ivec2(52, 0));  

  // setup camera and ray direction
  vec2 camRot = readRGB(ivec2(57, 0)).xy;   

 vec3 rayOrigin = vec3(camData.z*cos(camRot.x), camData.y, camData.z*sin(camRot.x) );    
  rayOrigin.y = 0.3*readRGB(ivec2(62, 0)).y;
    mat3 ca = setCamera( rayOrigin, vec3(0., 0.3*camData.y+(11.*camRot.y), 0. ), 0.0 );
  vec3 rayDir = ca * normalize( vec3(screenSpace.xy, 2.0) );

  // create sky color fade
  vec3 color =  GetSkyColor(rayDir);

  // add volumetric clouds (top)
  if (rayDir.y>0.)
  {  
    vec4 cloudColor=TraceCloudsBelow(rayOrigin, rayDir, color, 60);    

    // make clouds slightly light near the sun
    float sunVisibility = pow(max(0., dot(sunPos, rayDir)), 2.0)*0.25;
    color.rgb = mix(color.rgb, max(vec3(0.), mix(cloudColor.rgb,cloudColor.rgb,.6)+sunVisibility), cloudColor.a);  
    color.rgb +=  CalculateRainbow(rayDir, rayOrigin, screenSpace);

    // color.rgb = mix(color.rgb, cloudColor.rgb, cloudColor.a);       
    alpha+=cloudColor.a*0.86;
  }
  
  fragColor = vec4(color.rgb, alpha);
}

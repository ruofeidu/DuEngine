// https://www.shadertoy.com/view/XdKGDW
#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
#define B(X,Y) (tap(iChannel1,vec2(X,Y)))
float tap(sampler2D tex,vec2 xy) { return texture(tex,xy/iResolution.xy).x; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  float x = fragCoord.x;
  float y = fragCoord.y;    
  
  float d = 100000.0;
  float r = 8.0;
  for(int i=0;i<4;i++)
  {          
     d = min(d,B(x-r,y  )+r);
     d = min(d,B(x+r,y  )+r);
     d = min(d,B(x  ,y-r)+r);
     d = min(d,B(x  ,y+r)+r);
     r = r/2.0;
  }
  
  if (A(x,y)>-0.5) { d = 0.0; };  
  
  vec2 lastResolution = texture(iChannel1,vec2(0.5,0.5)/iResolution.xy).yz;   
  float frameReset    = texture(iChannel1,vec2(1.5,0.5)/iResolution.xy).y;      
  
  if (any(notEqual(lastResolution,iResolution.xy))) { frameReset = float(iFrame); }
  
  if      (x>0.0 && x<1.0) { fragColor = vec4(d,iResolution.xy,1.0);  }
  else if (x>1.0 && y<2.0) { fragColor = vec4(d,frameReset,0.0,1.0);  }
  else                     { fragColor = vec4(d,d,d,1.0); }
}

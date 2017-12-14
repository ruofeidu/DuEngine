// https://www.shadertoy.com/view/XdKGDW
#define A(X,Y) (tap(iChannel0,vec2(X,Y)))
#define B(X,Y) (tap(iChannel1,vec2(X,Y)).x)
#define C(X,Y) (tap(iChannel2,vec2(X,Y)))

vec3 tap(sampler2D tex,vec2 xy) { return texture(tex,xy/iResolution.xy).xyz; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  float x = fragCoord.x;
  float y = fragCoord.y;
  float frameReset = texture(iChannel1,vec2(1.5,0.5)/iResolution.xy).y;
  float frame = (float(iFrame)-frameReset);
  float r = min(B(x,y),mix(512.0,1.0,clamp(max(frame/64.0-1.0,0.0),0.0,1.0)));
  
  vec3 c = (C(x-r,y  )+
            C(x+r,y  )+
            C(x  ,y-r)+
            C(x  ,y+r))/4.0;
  
  vec3 a = A(x,y);
  
  if (a.x>-0.5) { c = a; };  
      
  fragColor = vec4(c,1);
}

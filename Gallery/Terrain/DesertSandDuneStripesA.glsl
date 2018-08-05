// XdcBW4
// copied sound of 'Skin peeler' https://www.shadertoy.com/view/XtfSWX
// note: step sound disabled

vec2 add = vec2(1.0, 0.0);
#define MOD2 vec2(.16632,.17369)
#define MOD3 vec3(.16532,.17369,.15787)

float tri(in float x){return abs(fract(x)-.5)*2.0;}
//-------------------------------------------------
//  1 out, 1 in ...
float hash11(float p)
{
  vec2 p2 = fract(vec2(p) * MOD2);
  p2 += dot(p2.yx, p2.xy+19.19);
  return fract(p2.x * p2.y);
}
//-------------------------------------------------
//  2 out, 1 in...
vec2 hash21(float p)
{
  //p  = fract(p * MOD3);
  vec3 p3 = fract(vec3(p) * MOD3);
  p3 += dot(p3.xyz, p3.yzx + 19.19);
  return fract(vec2(p3.x * p3.y, p3.z*p3.x));
}
//-------------------------------------------------
///  2 out, 2 in...
vec2 hash22(vec2 p)
{
  vec3 p3 = fract(vec3(p.xyx) * MOD3);
  p3 += dot(p3.zxy, p3.yxz+19.19);
  return fract(vec2(p3.x * p3.y, p3.z*p3.x));
}
//-------------------------------------------------
//  2 out, 1 in...
vec2 Noise21(float x)
{
  float p = floor(x);
  float f = fract(x);
  f = f*f*(3.0-2.0*f);
  return  mix( hash21(p), hash21(p + 1.0), f)-.5;
}
//-------------------------------------------------
//  2 out, 1 in...
float Noise11(float x)
{
  float p = floor(x);
  float f = fract(x);
  f = f*f*(3.0-2.0*f);
  return mix( hash11(p), hash11(p + 1.0), f)-.5;
}
//-------------------------------------------------
//  2 out, 2 in...
vec2 Noise22(vec2 x)
{
  vec2 p = floor(x);
  vec2 f = fract(x);
  f = f*f*(3.0-2.0*f);
    
  vec2 res = mix(
    mix( hash22(p),          hash22(p + add.xy),f.x),
    mix( hash22(p + add.yx), hash22(p + add.xx),f.x), f.y);
  return res-.5;
}
//-------------------------------------------------
// Fractal Brownian Motion...
vec2 FBM22(vec2 x)
{
  vec2 r = vec2(0.0);
  float a = .6;
  for (int i = 0; i < 8; i++)
  {
    r += Noise22(x * a) / a;
    a += a;
  }
  return r;
}
//-------------------------------------------------
vec2 mainSound(float time)
{
  vec2 audio = vec2(.0);
  for (float t = 0.0; t < 1.0; t+=.5)
  {
    time = time+t;
    vec2 n1 = FBM22( time*(Noise21(time*3.25)*40.0+Noise21(time*.3)*7500.0+9500.0)) * (abs(Noise21(time)))*1.5;
    vec2 n2 = FBM22( time*(Noise21(time*.4)+3900.0))*abs(Noise21(time*1.5))*1.5;
    vec2 n3 = FBM22( time*(Noise21(time*1.3)+Noise21(-time*.03)*200.0+1940.0))*(.5+abs(Noise21(time-99.)))*1.5;
    vec2 s1 = sin(time*240.+(Noise21(time*.23))*(Noise21(-time*.12)*2000.0+4000.0))*abs(Noise21(time*32.3+199.))*abs(Noise21(-time*.04+9.)+.5)*4.;
    audio += (n1+n2+n3+s1)/8.0;
  }
//  float foot = tri(time*1.2);
//  audio += Noise11(time*10.0)*Noise11(time*500.0)*Noise11(time*3000.0)* smoothstep(0.6,1.,abs(foot)) *6.;
    
  return clamp(audio, -1.0, 1.0) * smoothstep(0.0, 3.0, time) * smoothstep(180.0, 170.0, time);
}
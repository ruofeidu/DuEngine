// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XsjyDW
#define load(P) texture(iChannel1,(P+.5)/iChannelResolution[1].xy,-100.)

//https://www.shadertoy.com/view/MtyXDV

// strange bug ? using at_sign @ after define command in comment produces error message:
//    Unknown Error: ERROR: 0:? : '' : syntax error
// uncomment next line to check it out...              
//#define at 64  // @    

//=================================================================
// ViewShaderData2.glsl    
//   v1.0  2017-04-11  initial release
//                     !!! BUGS: integer and float conversion displays wrong values in some cases !!! 
//   v1.1  2017-04-12  char2() corrections
//                     convertion routines corrected by Timo Kinnunen!  
// Display shader data like 
//   date, time, frameCount, runtime, fps, resolution & mouse position.
// Click and Drag mouse button to display current mouse position.
// This release 2 uses the font texture to display integer and float values.
// useful infos:
//      font:  https://www.shadertoy.com/view/MtVXRd
//   numbers:  https://www.shadertoy.com/view/llySRh
// version 1:  https://www.shadertoy.com/view/llcXDn
//=================================================================

//--- common data ---
float time = 0.0;
vec2 uv  = vec2(0.0);  // -1 .. 1
vec2 tp  = vec2(0.0);  // text position

//== font handling ================================================

#define FONT_SPACE 0.5

const vec2 vFontSize  = vec2(8.0, 15.0);  // multiples of 4x5 work best

//----- access to the image of ascii code characters ------

#define SPACE tp.x-=FONT_SPACE;

#define S(a) c+=char2(a);   tp.x-=FONT_SPACE;

#define _note  S(10);   //
#define _star  S(28);   // *
#define _smily S(29);           
#define _ tp.x-=FONT_SPACE;
#define _exc   S(33);   // !
#define _add   S(43);   // + 
#define _comma S(44);   // ,
#define _sub   S(45);   // -
#define _dot   S(46);   // .
#define _slash S(47);   // /

#define _0 S(48);
#define _1 S(49);
#define _2 S(50);
#define _3 S(51);
#define _4 S(52);
#define _5 S(53);
#define _6 S(54);
#define _7 S(55);
#define _8 S(56);
#define _9 S(57);
#define _ddot S(58);   // :
#define _sc   S(59);   // ;
#define _less S(60);   // <
#define _eq   S(61);   // =
#define _gr   S(62);   // >
#define _qm   S(63);   // ?
#define _at   S(64);   // at sign 

#define _A S(65);
#define _B S(66);
#define _C S(67);
#define _D S(68);
#define _E S(69);
#define _F S(70);
#define _G S(71);
#define _H S(72);
#define _I S(73);
#define _J S(74);
#define _K S(75);
#define _L S(76);
#define _M S(77);
#define _N S(78);
#define _O S(79);
#define _P S(80);
#define _Q S(81);
#define _R S(82);
#define _S S(83);
#define _T S(84);
#define _U S(85);
#define _V S(86);
#define _W S(87);
#define _X S(88);
#define _Y S(89);
#define _Z S(90);

#define _a S(97);
#define _b S(98);
#define _c S(99);
#define _d S(100);
#define _e S(101);
#define _f S(102);
#define _g S(103);
#define _h S(104);
#define _i S(105);
#define _j S(106);
#define _k S(107);
#define _l S(108);
#define _m S(109);
#define _n S(110);
#define _o S(111);
#define _p S(112);
#define _q S(113);
#define _r S(114);
#define _s S(115);
#define _t S(116);
#define _u S(117);
#define _v S(118);
#define _w S(119);
#define _x S(120);
#define _y S(121);
#define _z S(122);

//---------------------------------------------------------
// return font image intensity of character ch at text position tp
//---------------------------------------------------------

//float char2(float ch)    // old versions
//{ return texture(iChannel0,clamp(tp,0.,1.)/16.+fract(floor(vec2(ch,15.999-float(ch)/16.))/16.));}
//  vec4 f = texture(iChannel0,clamp(tp,0.,1.)/16.+fract(floor(vec2(ch,16.-(1e-6)-floor(ch)/16.))/16.));  

float char2(int ch)
{
  vec4 f = any(lessThan(vec4(tp,1,1), vec4(0,0,tp))) 
               ? vec4(0) 
               : texture(iChannel0,0.0625*(tp + vec2(ch - ch/16*16,15 - ch/16)));  
  if (iMouse.z > 0.0) 
    return f.x;   // 2d 
  else
    return f.x * (f.y+0.3)*(f.z+0.3)*2.0;   // 3d
}

//== drawings =============================================

//--- draw line segment from A to B ---
float drawSegment(vec2 A, vec2 B, float r)  // 
{
    vec2 g = B - A;
    vec2 h = uv - A;
    float d = length(h - g * clamp(dot(g, h) / dot(g,g), 0.0, 1.0));
	return smoothstep(r, 0.5*r, d);
}
//--- draw circle at pos with given radius ---
float circle(in vec2 pos, in float radius, in float halo)
{
  return clamp (halo * (radius - length(uv-pos)), 0.0, 1.0);
}

//--- display number fraction with leading zeros --- 
float drawFract(int digits, float fn) 
{ 
  float c = 0.0; 
  fn = fract(fn) * 10.0; 
  for (int i = 1; i < 60; i++) 
  {
    c += char2(48 + int(fn)); // add 0..9
    tp.x -= FONT_SPACE; 
    digits -= 1; 
    fn = fract(fn) * 10.0; 
    if (digits <= 0 || fn == 0.0) break; 
  } 
  tp.x -= FONT_SPACE*float(digits); 
  return c; 
}
                                                                                                             
//--- display integer value --- 
float drawInt(int val, int minDigits)
{
  float c = 0.; 
  if (val < 0) 
  { val = -val; 
    if (minDigits < 1) minDigits = 1;
    else minDigits--;
    _sub                   // add minus char2
  } 
  int fn = val, digits = 1; // get number of digits 
  for (int n=0; n<10; n++)
  {
    fn /= 10; 
    if (fn == 0) break; 
    digits++;
  } 
  digits = max(minDigits, digits); 
  tp.x -= FONT_SPACE * float(digits); 
  for (int n=1; n < 11; n++) 
  { 
    tp.x += FONT_SPACE; // space
    c += char2(48 + (val-((val/=10)*10))); // add 0..9 
    if (n >= digits) break;
  } 
  tp.x -= FONT_SPACE * float(digits); 
  return c;
}

//--- display float value ---
float drawFloat(float fn, int prec, int maxDigits)
{ 
  float tpx = tp.x-FONT_SPACE*float(maxDigits);
  float c = 0.; 
  if (fn < 0.0) 
  { 
    c = char2(45); // write minus sign
    fn = -fn; 
  }
  tp.x -= FONT_SPACE; 
  c += drawInt(int(fn),1); 
  c += char2(46); SPACE; // add dot 
  c += drawFract(prec, fract(fn)); 
  tp.x = min(tp.x, tpx); 
  return c; 
}

float drawFloat(float value)           {return drawFloat(value,2,5);} 

float drawFloat(float value, int prec) {return drawFloat(value,prec,2);} 

float drawInt(int value)               {return drawInt(value,1);}

//=================================================================

const vec3 headColor = vec3(0.90, 0.60, 0.20);
const vec3 backColor = vec3(0.15, 0.10, 0.10);
const vec3 mpColor   = vec3(0.99, 0.99, 0.00);
const vec3 mxColor   = vec3(1.00, 0.00, 0.00);
const vec3 myColor   = vec3(0.00, 1.00, 0.00);
      vec3 dotColor  = vec3(0.50, 0.50, 0.00);
      vec3 drawColor = vec3(1.0, 1.0, 0.0);
      vec3 vColor    = backColor;

float aspect = 1.0;
vec2 pixelPos   = vec2(0.0);  // pixel position:  0 .. resolution-1
vec2 mousePos   = vec2(200);  // mouse pixel position  
vec2 lp         = vec2(0.5);  // last mouse position 
vec2 mp         = vec2(0.5);  // current mouse position 
vec2 resolution = vec2(0.0);  // window resolution

//----------------------------------------------------------------
void SetTextPosition(float x, float y)  //x=line, y=column
{
  tp = 10.0*uv; 
  tp.x = tp.x +17. - x;
  tp.y = tp.y -9.4 + y;
}
//----------------------------------------------------------------
void SetColor(float red, float green, float blue)
{
  drawColor = vec3(red,green,blue);    
}
//----------------------------------------------------------------
void WriteFloat(const in float fValue 
               ,const in int maxDigits 
               ,const in int decimalPlaces)
{
  vColor = mix(vColor, drawColor, drawFloat (fValue, decimalPlaces));
  SPACE;
}
//----------------------------------------------------------------
void WriteInteger(const in int iValue)
{
  vColor = mix(vColor, drawColor, drawInt (iValue));
  SPACE;
}
//----------------------------------------------------------------
void WriteDate()
{
  float c = 0.0;
  c += drawInt(int(iDate.x));       _sub;
  c += drawInt(int(iDate.y +1.0));  _sub;
  c += drawInt(int(iDate.z)); _
  vColor = mix(vColor, drawColor, c);
}
//----------------------------------------------------------------
void WriteTime()
{
  float c = 0.0;
  c += drawInt(int(mod(iDate.w / 3600.0, 24.0)));    _ddot;
  c += drawInt(int(mod(iDate.w / 60.0 ,  60.0)),2);  _ddot;
  c += drawInt(int(mod(iDate.w,          60.0)),2);  _
  vColor = mix(vColor, drawColor, c);
}
//----------------------------------------------------------------
void WriteFPS()
{
  // print Frames Per Second - FPS  see https://www.shadertoy.com/view/lsKGWV
  //float fps = (1.0 / iTimeDelta + 0.5);
  float fps = iFrameRate;
  SetColor (0.8, 0.6, 0.3);
  WriteFloat(fps, 6, 1);
  float c = 0.0;
  _f _p _s
  vColor = mix(vColor, drawColor, c);
}
//----------------------------------------------------------------
void WriteMousePos(float ytext, vec2 mPos)
{
  int digits = 3;
  float radius = resolution.x / 200.;

  // print dot at mPos.xy 
  if (iMouse.z > 0.0) dotColor = mpColor;
  float r = length(mPos.xy - pixelPos) - radius;
  vColor += mix(vec3(0), dotColor, (1.0 - clamp(r, 0.0, 1.0)));

  // print first mouse value
  SetTextPosition(1., ytext);

  // print mouse position
  if (ytext == 7.)
  {
    drawColor = mxColor;
    WriteFloat(mPos.x,6,3);
    SPACE;
    drawColor = myColor;
    WriteFloat(mPos.y,6,3);
  }
  else
  {
    drawColor = mxColor;
    WriteInteger(int(mPos.x));
    SPACE;
    drawColor = myColor;
    WriteInteger(int(mPos.y));
  }
}    
//----------------------------------------------------------------
void WriteText1()
{
  SetTextPosition(1.,1.);
  float c = 0.0;
  //_star _ _V _i _e _w _ _S _h _a _d _e _r   
  //_ _D _a _t _a _ _2 _ _ _v _1 _dot _1 _ _star 
  vColor += c * headColor;
}
//----------------------------------------------------------------
void WriteTestValues()
{
  float c = 0.0;
  SetTextPosition(1.,12.);
    c += drawInt(123, 8);   
  _ c += drawInt(-1234567890);    // right now !!!
  _ c += drawInt(0);                
  _ c += drawInt(-1);                
  _ c += drawFloat(-123.456);     // right now !!!

  SetTextPosition(1.,13.);
    c += drawInt(-123, 8);   
  _ c += drawInt(1234567890,11);
  _ c += drawFloat(0.0,0,0);
  _ c += drawFloat(1.0,0,0);
  _ c += drawFloat(654.321);      // nearly right
  _ c += drawFloat(999.9, 1);
  _ c += drawFloat(pow(10., 3.),1);   
  _ c += drawFloat(pow(10., 6.),1);   
  
  SetTextPosition(1.,14.);
  c += drawFloat(exp2(-126.0),60);
  vColor += c * headColor;
}
//---------------------------------------------------------
// draw ring at given position
//---------------------------------------------------------
float ring(vec2 pos, float radius, float thick)
{
  return mix(1.0, 0.0, smoothstep(thick, thick + 0.01, abs(length(uv-pos) - radius)));
}
//----------------------------------------------------------------
// define center coodinates
#define CC(c) (2.0 * c / resolution - 1.0) * ratio;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  time = iTime;
  resolution = iResolution.xy;
  aspect = resolution.x / resolution.y;    // aspect ratio
  vec2 ratio = vec2(aspect, 1.0);
  pixelPos = fragCoord.xy;  //  0 .. resolution
  mousePos = iMouse.xy;     //  0 .. resolution
  uv = CC(pixelPos);        // -1 .. 1
  mp = CC(iMouse.xy);       // -1 .. 1
  lp = CC(iMouse.zw);       // -1 .. 1
    
  // draw axis
  vColor = mix(vColor, vec3(0.2), drawSegment(vec2(-99.,0.), vec2(99.,0.), 0.01));
  vColor = mix(vColor, vec3(0.2), drawSegment(vec2(0.,-99.), vec2(0.,99.), 0.01));

  // version & test values   
  WriteText1();     
  WriteTestValues();
      
  // mouse position & coordinates
  WriteMousePos(5., iMouse.zw);  // last position
  WriteMousePos(6., iMouse.xy);  // current position

  // circle Radius
  float radius = length(mp - lp);
  SetColor (0.9, 0.9, 0.2);
  float c = 0.0;
  _  _r _eq
  vColor += c * drawColor;
  WriteFloat (radius,6,2);    
      
  // Circle
  float intensity = ring(mp.xy, radius, 0.01);
  drawColor = vec3(1.5, 0.4, 0.5);
  vColor = mix(vColor, drawColor, intensity*0.2);
    
  // Resolution
  SetTextPosition(27.0, 1.0);
  SetColor (0.8, 0.8, 0.8);
  WriteInteger(int(iResolution.x));  _star _  vColor += c * drawColor;
  WriteInteger(int(iResolution.y));

  // Date
  SetTextPosition(1.0, 19.);
  SetColor (0.9, 0.9, 0.4);
  WriteDate();   
  SPACE
      
  // Time
  SetColor (1.0, 0.0, 1.0);
  WriteTime();
  SPACE

  // Frame Counter
  SetColor (0.4, 0.7, 0.4);
  WriteInteger(iFrame);
  SPACE

  // Shader Time
  SetColor (0.0, 1.0, 1.0);
  WriteFloat(time, 6, 2);
  SPACE
      
  // Frames Per Second
  WriteFPS();

  fragColor = vec4(vColor,1.0);
}

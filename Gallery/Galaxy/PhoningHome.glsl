// https://www.shadertoy.com/view/4dl3W8
// "phoning home" fragment shader by movAX13h, May 2013

// A fragment shader heavily inspired by T-Shirt artwork (I dont know the artist):
// http://empoz.com/shopping/images/medium/mpd/GP019-BLK-Funny-ET-Telephone-tee-shirt_MED.jpg

// This was my first raymarching shader.

// Using some of iqs distance functions.
// Fragments of code borrowed from all over ShaderToy.

// There is no real lighting in this scene, transparency and illumination is
// based on the distance of the ray inside the main box and is not accurate because
// the value is incremented inside the marcher which does not march the same number
// of steps for all pixels. This effect fits the flat style of E.T and the cell, so I kept it.
// Anyways, by commenting the following line, everything "light" is off.
#define ILLUMINATION

// Uncomment the following define to enable Dave Hoskins' "Warp speed" shader 
// in the background (https://www.shadertoy.com/view/Msl3WH)
// Daves shader is based on Kalis "Cosmos" shader (https://www.shadertoy.com/view/MssGD8)
// I liked it so much, I had to see how it combines :)
#define WARP_SHADER


float udBox( vec3 p, vec3 b ) 
{	
	return length(max(abs(p)-b,0.0)); 
}

float sdBox( vec3 p, vec3 b ) 
{	
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

float sdSegment(vec3 p, vec3 a, vec3 b, float r )
{
	vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length(pa - ba*h) - r;
}

float time;

vec4 scene(vec3 p, inout float t, inout vec3 tcol)
{
	float d, d1, d2, d3, d4, d5, f, v;
	
	#ifdef ILLUMINATION
	vec3 col = vec3(0.06, 0.06, 0.16);
	#else
    vec3 col = vec3(1.0);
	#endif
	
	// cell
	d1 = sdBox(p, vec3(0.6, 1.2, 0.5));
	v = sdBox(p-vec3(0.0, 0.01, 0.0), vec3(0.58, 1.1, 0.48)); // along y
	d3 = sdBox(p-vec3(0.0, 0.05, 0.0), vec3(0.58, 0.97, 0.7)); // along z
	d4 = sdBox(p-vec3(0.0, 0.05, 0.0), vec3(0.7, 0.97, 0.48)); // along x
	d = max(-d4, max(-d3, max(-v, d1)));
	
	// sash bars	
	d = min(d, udBox(p-vec3(0.0, -0.45, 0.48), vec3(0.58, 0.01, 0.01)));
	d = min(d, udBox(p-vec3(0.0, 0.05, 0.48), vec3(0.58, 0.01, 0.01)));
	d = min(d, udBox(p-vec3(0.0, 0.55, 0.48), vec3(0.58, 0.01, 0.01)));
	
	d = min(d, udBox(p-vec3(0.0, -0.45, -0.48), vec3(0.58, 0.01, 0.01)));
	d = min(d, udBox(p-vec3(0.0, 0.05, -0.48), vec3(0.58, 0.01, 0.01)));
	d = min(d, udBox(p-vec3(0.0, 0.55, -0.48), vec3(0.58, 0.01, 0.01)));
	
	d = min(d, udBox(p-vec3(0.58, 0.05, 0.0), vec3(0.01, 0.01, 0.48)));
	d = min(d, udBox(p-vec3(0.58, 0.02, 0.0), vec3(0.01, 1.0, 0.01)));

	// inner life
	if (v < 0.0) 
	{
		// phone & handset
		//d1 = 100.0;
		//d2 = 100.0;
		d1 = udRoundBox(p-vec3(-0.493, 0.1, 0.22), vec3(0.05, 0.3, 0.16), 0.02);
		d2 = udRoundBox(p-vec3(-0.475, 0.2, 0.22), vec3(0.07, 0.26, 0.16), 0.02);
		d3 = sdSegment(p, vec3(0.03 , -0.1 , 0.2), vec3(-0.1 , 0.02 , 0.16), 0.03);
		d4 = udRoundBox(p-vec3(0.03 , -0.14 , 0.2), vec3(0.01, 0.01, 0.01), 0.04);
		d5 = udRoundBox(p-vec3(-0.12 , 0.0 , 0.16), vec3(0.01, 0.01, 0.01), 0.04);
		d = min(d, min(min(min(min(d5,d4),d3),d2),d1));
		
		// cable
		if (abs(p.x+0.16) < 0.22) 
		{
			d = min(d, sdSegment(p, vec3(p.x     , -0.23 + sin( p.x     *12.0)*0.2, 0.2), 
						 		    vec3(p.x-0.1 , -0.23 + sin((p.x-0.1)*12.0)*0.2, 0.2), 0.01));
		}
		
		// E.T.
		
		// head	
		d1 = sdSegment(p, vec3(0.11  , 0.42 , 0.12), vec3(0.11  , 0.43 , -0.12), 0.1); // eyes
		d2 = sdSegment(p, vec3(0.05  , 0.34 , 0.0), vec3(0.38 , 0.3 ,  0.0), 0.1); // mouth area
		d3 = sdSegment(p, vec3(0.17 , 0.44 , 0.0),  vec3(0.38 , 0.3 ,  0.0), 0.13); // skull
		d4 = sdSegment(p, vec3(0.35  , 0.31 , 0.0),  vec3(0.38 , -0.2  ,  0.0), 0.06); // neck
		d = min(d, min(min(min(d4,d3),d2),d1));	
		
		// pointing arm/hand
		d1 = sdSegment(p, vec3( 0.2 , -0.18 , -0.18),  vec3(-0.08  , -0.04 , 0.0), 0.05);
		d2 = sdSegment(p, vec3(-0.1 , -0.04  ,  0.0), vec3(-0.13 , 0.29 , 0.11), 0.03);
		d = min(d, min(d2,d1));
		
		// fingers
		d1 = sdSegment(p, vec3(-0.13 , 0.32 , 0.11), vec3(-0.4  , 0.5+p.x*0.3 , 0.14), 0.012); // pointing
		d2 = sdSegment(p, vec3(-0.12 , 0.31 , 0.12), vec3(-0.24 , 0.33  , 0.1), 0.014); // angled
		d3 = sdSegment(p, vec3(-0.25 , 0.33  , 0.1), vec3(-0.26 , 0.28  , 0.1), 0.012);
		d4 = sdSegment(p, vec3(-0.13 , 0.31 , 0.13), vec3(-0.25 , 0.3 , 0.15), 0.014); // thumb
		d = min(d, min(min(min(d4,d3),d2),d1));	
		
		// other arm
		d1 = sdSegment(p, vec3(0.2, -0.14, 0.18), vec3(0.21, -0.3, 0.2), 0.05);
		d2 = sdSegment(p, vec3(0.21, -0.3, 0.2), vec3(0.03, -0.1, 0.2), 0.04);
		d = min(d, min(d2, d1));
		
		// body & legs
		d1 = sdSegment(p, vec3(0.3, -0.22, 0.0), vec3(0.26, -0.76, 0.1), 0.23);
		d2 = sdSegment(p, vec3(0.3, -0.22, 0.0), vec3(0.26, -0.76, -0.1), 0.23);
		d3 = sdSegment(p, vec3(0.3, -0.22, 0.0), vec3(0.18, -0.72, 0.0), 0.23);
		d4 = sdSegment(p, vec3(0.27, -0.72, 0.16), vec3(0.28, -1.0, 0.14), 0.1);
		d5 = sdSegment(p, vec3(0.28, -0.72, -0.16), vec3(0.28, -1.0, -0.14), 0.1);
		d = min(d, min(min(min(min(d5,d4),d3),d2),d1));
	
		// finger tip light
		float blink = mod(floor(time*10.0), 2.0);
		f = length(vec3(-0.4, 0.38, 0.14)-p);
		tcol += blink*0.04*smoothstep(0.2, 0.0, f)*vec3(0.2, 0.08, 0.0);
		tcol = mix(tcol, vec3(0.9, 0.08, 0.0), blink*smoothstep(0.06, 0.0, f));
		t += blink*0.1*smoothstep(0.2, 0.0, f);
		
		// glass
		t = max(0.2, t + 0.04 + 0.02*sin(p.y*5.0+time));
		tcol += smoothstep(0.1, 1.2, p.y*0.3)*(1.0-tcol);
		
		// flies
		f = length(0.3*vec3(sin(time*0.2+66.0), 3.2+sin(time*0.7)*0.5, cos(time*0.6))-p);
		d = min(d, f - 0.01);
		tcol += step(f, 0.01)*0.01;
		
		f = length(0.4*vec3(sin(-time*0.4), 3.3+sin(-t*0.5)*cos(t+100.0), sin(time*0.34+32.0))-p);
		d = min(d, f - 0.006);
		tcol += step(f, 0.01)*0.01;
		
		f = length(0.36*vec3(sin(time*0.6), 3.4+sin(time*0.5)*sin(-time*0.2), sin(-time*0.3))-p);
		d = min(d, f - 0.006);
		tcol += step(f, 0.01)*0.01;

		// swirl
		/*
		d1 = 0.1*sin((p.y+time)*8.0);
		d2 = 0.1*cos((p.y+time)*8.0);
		d3 = sdSegment(p, vec3(d1 , mod(time*6.0, 8.0) - 4.0, d2),  
						  vec3(d1 , mod(time*6.0, 8.0) - 2.0, d2), 0.47);
		
		tcol = mix(tcol, vec3(1.0, 1.0, 1.0), 1.0-smoothstep(-0.5,0.0, d3));
		if (d3 < 0.0) t += 0.1;
		*/
	}	
	
	return vec4(col, d);
}

vec3 Dave_Hoskins_Warp_Shader(in vec2 fragCoord)
{
	float s = 0.0, v = 0.0;
	vec2 uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
	float t = time*0.005;
	uv.x = (uv.x * iResolution.x / iResolution.y) + sin(t)*.5;
	float si = sin(t+2.17); // ...Squiffy rotation matrix!
	float co = cos(t);
	uv *= mat2(co, si, -si, co);
	vec3 col = vec3(0.0);
	for (int r = 0; r < 100; r++) 
	{
		vec3 p= vec3(0.3, 0.2, floor(time) * 0.0008) + s * vec3(uv, 0.143);
		p.z = mod(p.z,2.0);
		for (int i=0; i < 10; i++) p = abs(p*2.04) / dot(p, p) - 0.75;
		v += length(p*p)*smoothstep(0.0, 0.5, 0.9 - s) * .002;
		col +=  vec3(v * 0.8, 1.1 - s * 0.5, .7 + v * 0.5) * v * 0.013;
		s += .01;
	}	
	return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
	#ifdef WARP_SHADER
	time = (iTime+2.4) * 60.0;
	vec3 col = Dave_Hoskins_Warp_Shader(fragCoord);
	#endif
	
	time = iTime + 7.3;
    vec2 pos = (fragCoord.xy*2.0 - iResolution.xy) / iResolution.y;
	
    float focus = 3.0;
    float far = 9.0;
	
	float atime = time*0.4;
	vec3 cp = vec3(2.0+sin(atime)*3.0, 0.6+sin(atime)*0.6, 5.0+cos(atime)); // anim perspective
  	//vec3 cp = vec3(sin(iTime)*6.0, .0, cos(iTime)*6.0);
  	//vec3 cp = vec3(sin(iTime)*4.0, sin(iTime*2.0)*0.7, cos(iTime)*7.0); 
	
	if (iMouse.z > 0.0)
	{
		float d = (iResolution.y-iMouse.y)*0.01+3.0;
		cp = vec3(sin(iMouse.x*0.01)*d, .0, cos(iMouse.x*0.01)*d);
	}
	
    vec3 ct = vec3(0.0, 0.0, 0.0);
   	vec3 cd = normalize(ct-cp);
    vec3 cu  = vec3(sin(time), 1.0, cos(time));
    vec3 cs = cross(cd, cu);
    vec3 dir = normalize(cs*pos.x + cu*pos.y + cd*focus);
	
    vec3 ray = cp;
	float dist = 0.0;
    vec4 s;
	
	float t = 0.06;
	vec3 tcol = vec3(0.0, 0.5, 0.7);
	
    for(int i=0; i < 40; i++) 
	{
        s = scene(ray, t, tcol);
		
        dist += s.w;
        ray += dir * s.w;
		
        if(s.w < 0.01) break;
		
        if(dist > far) 
		{ 
			dist = far; 
			break; 
		}
    }
	
	#ifndef ILLUMINATION
	t = 0.0;
	#endif
	
    float b = 1.0 - dist/far;
	vec3 c = mix(vec3(b * s.rgb), tcol, t);
	
	#ifdef WARP_SHADER
	col = mix(c, col, smoothstep(0.5, 0.99, min(0.7-b, 1.0-t))); // mix shaders
    fragColor = vec4(col, 1.0);
	#else
	fragColor = vec4(c, 1.0);
	#endif
}

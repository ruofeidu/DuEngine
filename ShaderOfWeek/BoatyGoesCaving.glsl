// https://www.shadertoy.com/view/https://www.shadertoy.com/view/ldBBDm
//[SH17B] Boaty Goes Caving
// The unsolicited travels of Boaty McBoatface..
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Information on Boaty McBoatface https://youtu.be/2omBAJ0AN00
// I don't think it actually has a head-light, but what the hell...

// The objects are rendered by tracing through the scene scraping off any geometry that gets within an expanding limit
// This provides a form of anti-alising and makes a nice fuzzy distance focus.

// The ocean has 4 layers, a blotchy background effect, floating detritus, water caustic light, and a god-ray effect.
// Other features are a movable stop-light & scattering, a blurry propellor and a very cool sound tracak found on SoundCloud.


// Uncomment to get back floating detritus...
//#define FLOATY_BITS

struct March
{
    vec3 pos;
    float alpha;
    float dist;
};

#define STACK_SIZE 8
March stack[STACK_SIZE];

int spointer;
float gTime, focus, specular, floatyBits, scatter;
vec3 diver, sunLight, headLight, heading;
mat3 diverMat;

#define TAU 6.28318530718
#define SUN_COLOUR vec3(.9, 1.2, 1.2)
#define FOG_COLOUR vec3(.0, .16, .13)

//========================================================================
// Utilities...

#define HASHSCALE1 .1031
#define HASHSCALE3 vec3(.1031, .1030, .0973)
#define HASHSCALE4 vec4(1031, .1030, .0973, .1099)

#define F length(.5-fract(k.xyw*=mat3(-2,-1,2, 3,-2,1, 1,2,2)*

float getCaustic(vec2 p)
{
    vec4 k = vec4(gTime*.005);
    k.xy = p/8e1;
    
    return pow(min(min(F.5)),F.4))),F.3))),8.)*40.;
}
    

// Thanks to iq for all the shape stuff...

//----------------------------------------------------------------------------------------


float sdCone( in vec3 p, in vec3 c )
{
    vec2 q = vec2( length(p.xy), p.z );
    float d1 = -q.x-c.z;
    float d2 = max( dot(q,c.xy), q.y);
    return length(max(vec2(d1,d2),0.0)) + min(max(d1,d2), 0.);
}
//----------------------------------------------------------------------------------------
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
	vec3 pa = p-a, ba = b-a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h ) - r;
}

//----------------------------------------------------------------------------------------
float rBox( vec3 p, vec3 b, float r )
{
    return length(max(abs(p)-b,0.0))-r;
}

//----------------------------------------------------------------------------------------
float segment(vec3 p,  vec3 a, vec3 b, float r1, float r2)
{
	vec3 pa = p - a;
	vec3 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h ) - r1 + r2*h;
}

//----------------------------------------------------------------------------------------
float cylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xy),p.z)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

//--------------------------------------------------------------------------
vec3 texCube(in sampler2D tex, in vec3 p, in vec3 n )
{
  
	vec3 x = textureLod(tex, p.yz, 0.0).xyz;
	vec3 y = textureLod(tex, p.zx, 0.0).xyz;
	vec3 z = textureLod(tex, p.xy, 0.0).xyz;
	return (x*abs(n.x) + y*abs(n.y) + z*abs(n.z))/(1e-20+abs(n.x)+abs(n.y)+abs(n.z));
}

//----------------------------------------------------------------------------------------
vec2 rot2D(vec2 p, float a)
{
	float si = sin(a);
	float co = cos(a);
	return mat2(co, si, -si, co) * p;
}

//----------------------------------------------------------------------------------------
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * HASHSCALE1);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}


//----------------------------------------------------------------------------------------
// Thanks to Nimitz for the triangular noise stuff...
float tri(in float x){return abs(fract(x)-.5);}
vec3 tri3(in vec3 p){return vec3( tri(p.z+tri(p.y)), tri(p.z+tri(p.x)), tri(p.y+tri(p.x)));}
float noise3d(in vec3 p, in int si)
{
    float z=1.4;
	float rz = 0.;
    vec3 bp = p;
	for (int i=0; i<= si; i++ )
	{
        vec3 dg = tri3(bp);
        p += (dg);

        bp *= 1.8;
		z *= 1.4;
		p *= 1.3;
        
        rz+= (tri(p.z+tri(p.x+tri(p.y))))/z;
        bp += 0.2;
	}
	return rz;
}

//----------------------------------------------------------------------------------------
float sMin( float a, float b, float k )
{
    
	float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.-h);
}
//----------------------------------------------------------------------------------------
float sMax(float a, float b, float s){
    
    float h = clamp( 0.5 + 0.5*(a-b)/s, 0., 1.);
    return mix(b, a, h) + h*(1.0-h)*s;
}

//========================================================================================

float sphereRadius(float t)
{
	t = abs(t-focus);
	t *= 0.02;
	return clamp(t*t, 20.0/iResolution.y, 2000.0/iResolution.y);
}

//--------------------------------------------------------------------------
vec2 cameraPath( float t )
{
    vec2 p = vec2(120.0 * sin(.01*t), 20.+ cos(.0071*t) * 80.0+sin(0.003*t)*80.0 );
	return p;
} 

//--------------------------------------------------------------------------
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = textureLod( iChannel3, (uv+ 0.5)/256.0, 0.0).yx;
	return mix( rg.x, rg.y, f.z );
}

//--------------------------------------------------------------------------
float diverMap(vec3 p)
{
	vec3 fin = p, fin2 = p;
    
    vec3 b = diverMat * (diver - p);
    float d = segment(b, vec3(.0, 0, 0), vec3(0,0,-4), 1.5, 1.3); 
    d = sMin(d, cylinder(b+vec3(0,0,0), vec2(.5,2)), 3.1); 
    d = min(d, rBox(b+vec3(0,0,1), vec3(3.0, .0, .5), .001));

   
    fin = diverMat * (diver - fin);
    fin.xy = rot2D(fin.xy, .5);
    //fin.x = abs(fin.x);     
   	fin += vec3(1.,0,3.5);
    
    d = min(d, rBox(fin, vec3(1.0, .02, .2), .01));
    
    fin2 = diverMat * (diver - fin2);
    fin2.xy = rot2D(fin2.xy, -.5);
    fin2 += vec3(-1.,0,3.5);

   	d = min(d, rBox(fin2, vec3(1.0, .01, .2), .001));
    
    fin  = diverMat * (diver - p);
    d = min(d, rBox(fin+vec3(0,1,3.5), vec3(.01, 1.0, .2), .001));
    
    
    fin = diverMat * (diver - p);
    fin.xy = rot2D(fin.xy, -abs(length(fin)*4.)+gTime*.8);
    fin += vec3(0.,0,4.);
    d = min(d, rBox(fin, vec3(.6, .15, .01), .01));
	
	return d;
}

void diverCol(vec3 p, in float di, inout vec3 alb)
{
   	vec3 fin = p, fin2 = p;
    
    vec3 b = diverMat * (diver - p);
    float d = segment(b, vec3(.0, 0, 0), vec3(0,0,-3.5), 1.5, 1.2); 
    
    d = sMin(di, cylinder(b+vec3(0,0,0), vec2(.5,2)), 3.1);


    if (d  < 2.5)
    {
        alb = vec3(.8,.8,0);
        specular  = 1.0;
    }

    
    
    d = min(d, rBox(b+vec3(0,0,1), vec3(3.0, .0, .5), .001));
    if (d < 0.1) alb = vec3(1,1,1);
   
    fin = diverMat * (diver - fin);
    fin.xy = rot2D(fin.xy, .5);
    //fin.x = abs(fin.x);     
   	fin += vec3(1.,0,3.5);
    
    d = min(d, rBox(fin, vec3(1.0, .02, .2), .01));
    
    fin2 = diverMat * (diver - fin2);
    fin2.xy = rot2D(fin2.xy, -.5);
    fin2 += vec3(-1.,0,3.5);

   	d = min(d, rBox(fin2, vec3(1.0, .01, .2), .001));
    
    fin  = diverMat * (diver - p);
    d = min(d, rBox(fin+vec3(0,1,3.5), vec3(.01, 1.0, .1), .001));
       
    fin = diverMat * (diver - p);
   fin.xy = rot2D(fin.xy, -abs(length(fin)*4.)+gTime*.8);
    fin += vec3(0.,0,4.);
	d = min(d, rBox(fin, vec3(.6, .15, .01), .01));
    if (d < .2)
    {
        alb = vec3(1,1,1);
        specular  = 1.0;
    }
	
}

//--------------------------------------------------------------------------
float map( in vec3 p, const in int detail )
{
    vec3 q = p * 0.0007;
    //q.y*= 2.;
    float d = noise3d(q, detail)*370.;
    d = p.y-d+20.;

    q = p;
    q.xy -= cameraPath(q.z);
    q.y*=2.;  
    d = sMax(d, (10.-length(q.xy)), 400.);
    d = min(diverMap(p), d);
    if (detail <8 )
    {
        vec3 light= (diverMat*(p-diver));
        light.xz = rot2D(light.xz, sin(gTime*.03)*1.1);

        float s = sdCone( light, vec3(8,8,10))/length(light*light);
        scatter += max(-s, 0.0);
    }
    return d;
}

//--------------------------------------------------------------------------
float rays(vec2 uv, vec3 dir)
{
    float bri = 0.0;
    uv.x*= 1.0+dir.y*.5;
    uv.x += dir.x*.1;

    bri += getCaustic(uv * vec2(40., 0.1))*.2;
    bri -= pow(abs(1.0-uv.y)*.5,16.0);
    bri  = clamp(bri,0.0,1.0);
    
    return bri;
}
//--------------------------------------------------------------------------
vec3 getOcean(vec3 dir, vec2 uv, vec3 pos)
{
    vec3 col;
    vec3 clou = dir * 2. + pos*.01+iTime*.2;
	float t = noise(dir);
    t += noise(clou * 2.1) * .5;
    t += noise(clou * 4.3) * .25;
    t += noise(clou * 7.9) * .125;
	col = FOG_COLOUR + vec3(.04,.08,.1) *t;
    col+= pow(max(dot(sunLight, dir), 0.0)*.8, 4.0);
    return col;
}

float cloudy(in vec3 pos)
{
    pos = pos*.01 - gTime*.005;
    float t = noise(pos) * .5;
    t += noise(pos * 2.) * .25;
    t += noise(pos * 4.) * .125;
    t =  pow(max(t-.5, 0.), 4.0)*40.;
    return t;
}

//--------------------------------------------------------------------------
vec3 getNormal(vec3 p, float e)
{
    return normalize( vec3( map(p+vec3(e,0.0,0.0), 9) - map(p-vec3(e,0.0,0.0), 9),
                            map(p+vec3(0.0,e,0.0), 9) - map(p-vec3(0.0,e,0.0), 9),
                            map(p+vec3(0.0,0.0,e), 9) - map(p-vec3(0.0,0.0,e), 9) ) );
}

//--------------------------------------------------------------------------
//Fill the stack by marching through the scene...
float marchScene(in vec3 rO, in vec3 rD, vec2 co)
{
	float t = hash12(co)*3.;
	vec4 normal = vec4(0.0);
	vec3 p;
    float alphaAcc = 0.0;

#ifdef FLOATY_BITS
    floatyBits = 0.0;
#endif
    spointer = 0;
	for( int j=0; j < 100; j++ )
	{
        // Check if it's full or too far...
		if (spointer == STACK_SIZE || t > 800.0 || alphaAcc >= 1.) break;
		p = rO + t*rD;
		float sphereR = sphereRadius(t);
		float h = map(p, 3);
 #ifdef FLOATY_BITS
 	floatyBits += cloudy(p);
 #endif
		if( h < sphereR)
		{
            float alpha = (1.0 - alphaAcc) * min(((sphereR-h) / sphereR), 1.0);
			stack[spointer].pos = p;
            stack[spointer].alpha = alpha;
            stack[spointer].dist = t;
            alphaAcc += alpha;
	        spointer++;
        }
		t +=  h*.55 + t*.002+.01;
	}
 #ifdef FLOATY_BITS
   floatyBits = min(floatyBits, .6);
 #endif
    return alphaAcc;
}	

//--------------------------------------------------------------------------
// Grab the colour...
vec3 albedo(vec3 pos, vec3 nor)
{
    specular  = .0;
    vec3 alb  = texCube(iChannel0, pos*.0005, nor);
    vec3 alb2 = texCube(iChannel2, pos*.005, nor);
    
    alb = mix(alb2, alb,  smoothstep(-150., 70.0, pos.y));
    alb=alb*alb*1.2;
    
    diverCol(pos, 200.0, alb);

    return alb;
}

//--------------------------------------------------------------------------
float shadow(in vec3 ro, in vec3 rd)
{
	float res = 1.0;
    
    float t = .0;
    for( int i = 0; i < 12; i++ )
    {
		float h = map(ro + rd*t, 2);
        res = min( res, 3.*h/t );
        t += h*1.5+.2;
    }
    return clamp( res, 0., 1.0 );
}

// Set up a camera matrix
//--------------------------------------------------------------------------
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}


//--------------------------------------------------------------------------
vec3 lighting(in vec3 mat, in vec3 pos, in vec3 normal, in vec3 eyeDir, in float d)
{
  
	float sh = shadow(pos+normal*(.05+(1.0-specular)*10.),  sunLight);
    // Light surface with 'sun'...
	vec3 col = mat * SUN_COLOUR*(max(dot(sunLight,normal), 0.0))*sh;
    col +=  getCaustic(pos.xz*1.1+gTime*.02)*max(normal.y, 0.)*sh*.3*SUN_COLOUR;
    
    col += mat * max(dot(headLight,normal), 0.0) * smoothstep(.7, .9, dot(heading, headLight))*1.6;
    // Ambient...
	col += mat  * abs(normal.y*.07);
    
    normal = reflect(eyeDir, normal); // Specular...
    col += pow(max(dot(sunLight, normal), 0.0), 8.0)  * SUN_COLOUR * sh * specular;

	return min(col, 1.0);
}


//--------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    sunLight  = normalize( vec3(  0.5, 0.8,  0.3 ) );
    specular = 0.0;
	float m = (iMouse.x/iResolution.x)*500.0+170.;
	gTime = (iTime*4.0+m)*8.;
    vec2 xy = abs((fragCoord.xy / iResolution.xy)-.5);
    if (xy.y > .39)
	{
		// Top and bottom cine-crop - what a waste! :)
		fragColor=vec4(0,0,0,1);
		return;
	}
	vec2 uv = (-iResolution.xy + 2.0 * fragCoord ) / iResolution.y;
    diver.z = gTime + 10.;  diver.xy = cameraPath(diver.z);
    heading.z = diver.z+50.; heading.xy = cameraPath(heading.z);
    heading = normalize(diver-heading);
   
    // Use the camera matrix function to orientate the submarine and spin it's light...
    diverMat = setCamera(vec3(0), heading, 0.);
	heading.xz = rot2D(heading.xz, sin(gTime*.03)*1.1);

    
	vec3 camPos, camTar;
    camPos.z = gTime+sin(gTime*.02)*.5;		camPos.xy = cameraPath(camPos.z);
    camPos.y+=sin(gTime*.005)*6.;
    camTar.z = gTime+200.; camTar.xy = cameraPath(camTar.z);
    focus = 30.;//(diver.z- camPos.z)*.6;
   
        
    mat3 camMat = setCamera(camPos, camTar, sin(gTime*.01)*.6);
    vec3 dir = camMat * normalize( vec3(uv,cos((length(uv)))));
     vec3 ocean = getOcean(dir, uv, camPos);
    vec3 col = vec3(0);
    scatter = 0.0;
    
    float alpha = marchScene(camPos, dir, fragCoord);
    // Render the stack...
    if (alpha > .0)
    {

        for (int i = 0; i < spointer; i++)
        {
            vec3  p = stack[i].pos; 
            float d = stack[i].dist;
            
            vec3 nor =  getNormal(p, sphereRadius(d)*.5);
            vec3 mat = albedo(p, nor);
            
   	        headLight = normalize(diver-p);
            vec3  temp = lighting(mat, p, nor, dir, d);
            temp = mix(ocean, temp , exp(-d*.005));
            col += temp * stack[i].alpha;
        }
    }
    col += ocean *  (1.0-alpha);
    // Get shadow from the camera for the god-ray stuff...
    float sh = shadow(camPos,  sunLight)*.4;

    col += rays(uv+heading.xz*.2, dir)*sh;
    if (dir.y > 0.0 && alpha < .5)
    {
        float d = ((220.0-camPos.y) / dir.y);
    	vec2 sur = (dir.xz*d) + camPos.xz;
    	col += getCaustic(sur)*pow(abs(dir.y), 2.0)*.15;
    }
#ifdef FLOATY_BITS
    // Add floaty bits and the head-light scattering
    col= mix(col, FOG_COLOUR+(.03-floatyBits*.01),floatyBits);
 #endif

    
    col = min(col+scatter*.08, 1.0);
    col = col*col*(3.0-col*2.0);
    //col = col*col*3.0;
	col = sqrt(col);
    col *= pow(abs(35.0* (.39-xy.y))*(.5-xy.x), .3 );
	fragColor = vec4(col*smoothstep(.0, 4.,iTime), 1);//texture(iChannel1, fract(uv)).xyz,1.0);
    
}
// Alps.
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// https://www.shadertoy.com/view/4ssXW2
// Uses a ridged fractal noise with corrosion effects for higher altitudes.

//#define STEREO   // RED left eye.
//#define SHADOWS  // fake shadows.
#define MOD3 vec3(.0631,.07369,.08787)
//#define MOD4 vec4(.0631,.07369,.08787, .09987)
vec3 sunLight  = normalize( vec3(  -0.2, 0.2,  -1.0 ) );
vec3 sunColour = vec3(1.0, .88, .75);
float specular = 0.0;
vec3 cameraPos;
float ambient;
const vec2 add = vec2(1.0,0.0);

// This peturbs the fractal positions for each iteration down...
// Helps make nice twisted landscapes...
const mat2 rotate2D = mat2(1.6623, 1.850, -1.7131, 1.4623);

//--------------------------------------------------------------------------
// Noise functions...
//----------------------------------------------------------------------------------------
float Hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(p3.x * p3.y * p3.z);
}
//--------------------------------------------------------------------------
float Noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
    f = f*f*(1.5-f)*2.0;
    
    float res = mix(mix( Hash12(p), Hash12(p + add.xy),f.x),
                    mix( Hash12(p + add.yx), Hash12(p + add.xx),f.x),f.y);
    return res;
}

//--------------------------------------------------------------------------
vec3 NoiseD( in vec2 x )
{
	x+=4.2;
    vec2 p = floor(x);
    vec2 f = fract(x);

    vec2 u = f*f*(1.5-f)*2.0;;
    
    float a = Hash12(p);
    float b = Hash12(p + add.xy);
    float c = Hash12(p + add.yx);
    float d = Hash12(p + add.xx);
	return vec3(a+(b-a)*u.x+(c-a)*u.y+(a-b-c+d)*u.x*u.y,
				6.0*f*(f-1.0)*(vec2(b-a,c-a)+(a-b-c+d)*u.yx));
}

float Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(1.5-f)*2.0;
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = textureLod( iChannel0, (uv+ 0.5)/256.0, -0.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}
#define WARP  .15
#define SCALE  .0023
#define HEIGHT 55.
#define LACUNARITY 2.13
//--------------------------------------------------------------------------
// Low-def version for ray-marching through the height field...
float Terrain( in vec2 p)
{
	p *= SCALE;
	float sum = 0.0;
	float freq = 1.;
	float amp = 3.5;
	vec2 dsum = vec2(0,0);
	for(int i=0; i < 5; i++)
	{
		vec3 n = NoiseD(p + (WARP * dsum * freq));
		sum += amp * (1.0 - abs(n.x-.5)*2.0);
		dsum += amp * n.yz * -n.x;
		freq *= LACUNARITY;
		amp = amp*.4 * min(sum*.22, 1.0);
		p = rotate2D * p;
	}
	return sum * HEIGHT;	
}

//--------------------------------------------------------------------------
// High-def version only used for grabbing normal information....
float Terrain2( in vec2 p, in float d)
{
    int stop = 1+int(9.0-d*.000004);
	p *= SCALE;
	float sum = 0.0;
	float freq = 1.;
	float amp = 3.5;
	vec2 dsum = vec2(0,0);
    vec3 n;
	for(int i=0; i < 9; i++)
	{
        if (i > stop) break;
		n = NoiseD(p + (WARP * dsum * freq));
		sum += amp * (1.0 - abs(n.x-.5)*2.0);
		dsum += amp * n.yz * -n.x;
		freq *= LACUNARITY;
		amp = amp*.4 * min(sum*.22, 1.0);
        sum += n.x/(222.5+dot(dsum, dsum));
		p = rotate2D * p;
	}
	return sum * HEIGHT;
}

// Low detailed camera version... 
float TerrainCam( in vec2 p)
{
    
	p *= SCALE;
	float sum = 0.0;
	float freq = 1.;
	float amp = 3.5;
	vec2 dsum = vec2(0,0);
	for(int i=0; i < 2; i++)
	{
		vec3 n = NoiseD(p + (WARP * dsum * freq));
		sum += amp * (1.0 - abs(n.x-.5)*2.0);
		dsum += amp * n.yz * -n.x;
		freq *= LACUNARITY;
		amp = amp*.4 * min(sum*.22, 1.0);
		p = rotate2D * p;
	}
	return sum * HEIGHT;
	
}

float FBM( vec3 p )
{
    
    p *= .015;
    p.xz *= .3;
    //p.zy -= iTime * .04;
    
    float f;
	f  = 0.5000	 * Noise(p); p = p * 3.02; //p.y -= gTime*.2;
	f += 0.2500	 * Noise(p); p = p * 3.03; //p.y += gTime*.06;
	f += 0.1250	 * Noise(p); p = p * 4.01;
    f += 0.0625	 * Noise(p); p = p * 4.023;
    //f += 0.03125 * Noise(p);
    return f;
}


//--------------------------------------------------------------------------
// Map to lower resolution for height field mapping for Scene function...
float Map(in vec3 p)
{
	float h = Terrain(p.xz);
    return p.y - h;
}

//--------------------------------------------------------------------------
float MapClouds(vec3 p)
{
	float h = FBM(p)*1.0;
	return (-h+.6);// + (p.y)*.0002);
}
//--------------------------------------------------------------------------
// Grab all sky information for a given ray from camera
vec3 GetSky(in vec3 rd)
{
	float v = pow(1.0-max(rd.y,0.0),10.);
	vec3  sky = vec3(v*sunColour.x*0.42+.04, v*sunColour.y*0.4+0.09, v*sunColour.z*0.4+.17);
	return sky;
}

//--------------------------------------------------------------------------
// Merge mountains into the sky background for correct disappearance...
vec3 ApplyFog( in vec3  rgb, in float dis, in vec3 dir)
{
	return mix(GetSky(dir), rgb, exp(-.000001*dis) );
}

//--------------------------------------------------------------------------
// Calculate sun light...
void DoLighting(inout vec3 mat, in vec3 pos, in vec3 normal, in vec3 eyeDir, in float dis)
{
    float h = dot(sunLight,normal);

#ifdef SHADOWS
   	vec3  eps = vec3(1.0,0.0,0.0);
    vec3 nor;
	nor.x = Terrain(pos.xz-eps.xy) - Terrain(pos.xz+eps.xy);
    nor.y = 1.0*eps.x;
    nor.z = Terrain(pos.xz-eps.yx) - Terrain(pos.xz+eps.yx);
	nor = normalize(nor);
	float shad = clamp(1.0*dot(nor,sunLight), 0.0, 1.0 );
    float c = max(h, 0.0) * shad;
#else
    float c = max(h, 0.0);
#endif    
	vec3 R = reflect(sunLight, normal);
	mat = mat * sunColour * c * vec3(.9, .9, 1.0) +  GetSky(R)*ambient;
	// Specular...
	if (h > 0.0)
	{
		float specAmount = pow( max(dot(R, normalize(eyeDir)), 0.0), 34.0)*specular;
		mat += sunColour * specAmount;
	}
}

//--------------------------------------------------------------------------
vec3 TerrainColour(vec3 pos, vec3 normal, float dis)
{
	vec3 mat;
	specular = .0;
	ambient = .4 * abs(normal.y);
	vec3 dir = normalize(pos-cameraPos);
	
	float disSqrd = dis * dis;// Squaring it gives better distance scales.

	float f = clamp(Noise(pos.xz*.001), 0.0,1.0);//*10.8;
	f *= Noise(pos.zx*.2+normal.xz*1.5);
	//f *= .5;
	mat = mix(vec3(.1), vec3(.1, .07, .01), f);

	// Snow...
	if (pos.y > 75.0 && normal.y > .2)
	{
		float snow = smoothstep(0.0, 1.0, (pos.y - 75.0 - Noise(pos.xz * .3)*Noise(pos.xz * .027)*83.0) * 0.2 * (normal.y));
		mat = mix(mat, vec3(.8,.9,1.0), min(snow, 1.0));
		specular += snow*.7;
		ambient+=snow *.05;
	}

	DoLighting(mat, pos, normal,dir, disSqrd);
	
	mat = ApplyFog(mat, disSqrd, dir);
	return mat;
}

//--------------------------------------------------------------------------
float BinarySubdivision(in vec3 rO, in vec3 rD, vec2 dist)
{
	// Home in on the surface by dividing by two and split...
	for (int n = 0; n < 6; n++)
	{
		float halfwayT = (dist.x + dist.y) * .5;
		vec3 p = rO + halfwayT*rD;
		if (Map(p) < .5) {
			dist.x = halfwayT;
		} else {
			dist.y = halfwayT;
		}
	}
	return dist.x;
}

//--------------------------------------------------------------------------
bool Scene(in vec3 rO, in vec3 rD, in vec2 uv, out float resT, out vec2 cloud)
{
    float t = 10.0 + Hash12(uv*3333.0)* 13.0;
	float oldT = 0.0;
	float delta = 0.0;
	bool fin = false;
	vec2 distances;
    vec2 shade = cloud = vec2(0.0, 0.0);
    vec3 p = vec3(0.0);
	for( int j=0; j< 105; j++ )
	{
		if (p.y > 650.0 || t > 1300.0) break;
		p = rO + t*rD;
		float h = Map(p); // ...Get this positions height mapping.
		// Are we inside, and close enough to fudge a hit?...
		if( h < .5)
		{
			fin = true;
			distances = vec2(t, oldT);
			break;
		}
        		
		delta = clamp(0.5*h, .002, 20.0) + (t*0.004);
		oldT = t;
		t += delta;

   		h = MapClouds(p);
        
		shade.y = max(-h, 0.0); 
		shade.x = smoothstep(.03, 1.5, shade.y);
        //shade.x = shade.x*shade.x;
		cloud += shade * (1.0 - cloud.y);


	}
	if (fin) resT = BinarySubdivision(rO, rD, distances);
    
    cloud.x = 1.0-(cloud.x*5.3);//cloud.x = min(pow(max(cloud.x, 0.05), .3), 1.0);
 

	return fin;
}

//--------------------------------------------------------------------------
vec3 CameraPath( float t )
{
	float m = 1.0+(iMouse.x/iResolution.x)*300.0;
	t =((iTime*2.0)+m+4005.0)*.004 + t;
    vec2 p = 1500.0*vec2( sin(4.5*t), cos(4.0*t) );
	return vec3(-4800.0+p.x, 0.6, -200.0+p.y);
}

//--------------------------------------------------------------------------
// Some would say, most of the magic is done in post! :D
vec3 PostEffects(vec3 rgb, vec2 uv)
{

    rgb = mix( rgb, vec3(dot(rgb,vec3(0.333))), -1. );
    rgb = sqrt(rgb);
   	rgb *= .5+0.5*pow(70.0*uv.x*(uv.y-.12)*(1.0-uv.x)*(.88-uv.y), 0.2 );
    //rgb = clamp(rgb+Hash12(rgb.rb+uv*iTime)*.1, 0.0, 1.0);
	return rgb;
}

//--------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = fragCoord.xy / iResolution.xy;
	vec2 uv = (-1.0 + 2.0*xy) * vec2(iResolution.x/iResolution.y,1.0);
	vec3 camTar;
    
    if (xy.y < .12 || xy.y >= .88)
	{
		// Top and bottom cine-crop - what a waste! :)
		fragColor=vec4(vec4(0.0));
		return;
	}

	#ifdef STEREO
	float isCyan = mod(fragCoord.x + mod(fragCoord.y,2.0),2.0);
	#endif

	// Use several forward heights, of decreasing influence with distance from the camera.

	cameraPos.xz = CameraPath(0.0).xz;
	camTar.xz	 = CameraPath(.05).xz;
	camTar.y = cameraPos.y = TerrainCam(CameraPath(0.0).xz) + 85.0;
    cameraPos.y +=  smoothstep(5.0, 0.0, iTime)*180.0;
    camTar.y -= camTar.y * .005;
	
	float roll = 0.2*sin(iTime*.3);
	vec3 cw = normalize(camTar-cameraPos);
	vec3 cp = vec3(sin(roll), cos(roll),0.0);
	vec3 cu = (cross(cw,cp));
	vec3 cv = (cross(cu,cw));
	vec3 rd = normalize( uv.x*cu + uv.y*cv + 1.4*cw );

	#ifdef STEREO
	cameraPos += 6.*cu*isCyan; // move camera to the right - the rd vector is still good
	#endif

	vec3 col;
	float distance;
    vec2 cloud;
	if( !Scene(cameraPos,rd, uv, distance, cloud) )
	{
		// Missed scene, now just get the sky value...
		col = GetSky(rd);
        float sunAmount = max( dot( rd, sunLight), 0.0 );
       	col = col + sunColour * pow(sunAmount, 8.0)*.8;
		col = col+ sunColour * min(pow(sunAmount, 800.0), .4);
	} 
	else
	{
		// Get world coordinate of landscape...
		vec3 pos = cameraPos + distance * rd;
		// Get normal from sampling the high definition height map
		// Use the distance to sample larger gaps to help stop aliasing...
        float d = distance*distance;
		float p = min(4.0, .0001+.00002 * d);
        
		vec3 nor  	= vec3(0.0,		    Terrain2(pos.xz, d), 0.0);
		vec3 v2		= nor-vec3(p,		Terrain2(pos.xz+vec2(p,0.0), d), 0.0);
		vec3 v3		= nor-vec3(0.0,		Terrain2(pos.xz+vec2(0.0,-p), d), -p);
		nor = cross(v2, v3);
		nor = normalize(nor);

		// Get the colour using all available data...
		col = TerrainColour(pos, nor, distance);
	}
    float bri = pow(max(dot(rd, sunLight), 0.0), 24.0)*2.0;
    bri = ((cloud.y)) * bri;
    col = mix(col, vec3(min(bri+cloud.x * vec3(1.,.95, .9), 1.0)), min(cloud.y*(bri+1.0), 1.0));

	col = PostEffects(min(col, 1.0), xy);
	
	#ifdef STEREO	
	col *= vec3( isCyan, 1.0-isCyan, 1.0-isCyan );	
	#endif
	
	fragColor=vec4(col*smoothstep(0.0, 2.0, iTime) ,1.0);
}

//--------------------------------------------------------------------------

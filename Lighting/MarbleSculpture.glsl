// https://www.shadertoy.com/view/MdXSzX
// Ben Quantock 2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// control range of SSS
// .3 - exaggerated / realistic for a small object
// .05 - realistic for human-scale (I think)
#define TRANSMISSION_RANGE .15
	
//#define FAST

// keys
const int kA=65,kB=66,kC=67,kD=68,kE=69,kF=70,kG=71,kH=72,kI=73,kJ=74,kK=75,kL=76,kM=77,kN=78,kO=79,kP=80,kQ=81,kR=82,kS=83,kT=84,kU=85,kV=86,kW=87,kX=88,kY=89,kZ=90;
const int k0=48,k1=49,k2=50,k3=51,k4=52,k5=53,k6=54,k7=55,k8=56,k9=57;
const int kSpace=32,kLeft=37,kUp=38,kRight=39,kDown=40;


// TOGGLES:

const int kAmbientOcclusion = kA;
const int kReflectionOcclusion = kR;
const int kSubsurface = kS;
const int kLensFX = kL;
const int kDarkScene = kD;


// consts
const float tau = 6.2831853;
const float phi = 1.61803398875;

// globals
vec3 envBrightness = vec3(1);
const vec3 darkEnvBrightness = vec3(.02,.03,.05);


// key is javascript keycode: http://www.webonweboff.com/tips/js/event_key_codes.aspx
bool ReadKey( int key, bool toggle )
{
	float keyVal = textureLod( iChannel3, vec2( (float(key)+.5)/256.0, toggle?.75:.25 ), 0.0 ).x;
	return (keyVal>.5)?true:false;
}


bool Toggle( int val )
{
	return !ReadKey( val, true );
}


vec2 Noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);

	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;

#ifdef FAST
	vec4 rg = textureLod( iChannel0, (uv+0.5)/256.0, 0.0 );
#else
	// high precision interpolation, if needed
	vec4 rg = mix( mix(
				textureLod( iChannel0, (floor(uv)+0.5)/256.0, 0.0 ),
				textureLod( iChannel0, (floor(uv)+vec2(1,0)+0.5)/256.0, 0.0 ),
				fract(uv.x) ),
				  mix(
				textureLod( iChannel0, (floor(uv)+vec2(0,1)+0.5)/256.0, 0.0 ),
				textureLod( iChannel0, (floor(uv)+1.5)/256.0, 0.0 ),
				fract(uv.x) ),
				fract(uv.y) );
#endif			  

	return mix( rg.yw, rg.xz, f.z );
}


float Sphere( vec3 p, vec3 c, float r )
{
	return length(p-c)-r;
}

float Tet( vec3 p, vec3 c, float r )
{
	p -= c;
	vec2 s = -vec2(1,-1)/sqrt(3.0);
	return max(max(max(
			dot(p,s.xxx),dot(p,s.yyx)),
			dot(p,s.yxy)),dot(p,s.xyy)) - r*mix(1.0,1.0/sqrt(3.0),1.0);
}

float Oct( vec3 p, vec3 c, float r )
{
	p -= c;
	vec2 s = vec2(1,-1)/sqrt(3.0);
	return max(max(max(
			abs(dot(p,s.xxx)),abs(dot(p,s.yyx))),
			abs(dot(p,s.yxy))),abs(dot(p,s.xyy))) - r*mix(1.0,1.0/sqrt(3.0),.5);
}

float Cube( vec3 p, vec3 c, float r )
{
	p -= c;
	return max(max(abs(p.x),abs(p.y)),abs(p.z))-r*mix(1.0,1.0/sqrt(3.0),.5);
}

float CubeFrame( vec3 p, vec3 c, float r )
{
	r = r*mix(1.0,1.0/sqrt(3.0),.5);
	p -= c;
	p = abs(p);
	float rr = r*.1;
	p -= vec3(r-rr);
	// whichever axis is most negative should be clamped to 0
	if ( p.x < p.z ) p = p.zyx;
	if ( p.y < p.z ) p = p.xzy;
	p.z = max(0.0,p.z);
	return length(p)-rr;
}

float DistanceField( vec3 p, float t )
{
	return
			min(min(min(min(min(min(min(min(
				Sphere(p,vec3(0,.48,0),.1),
				Oct(p,vec3(0,.2,0),.2)),
				CubeFrame(p,vec3(0,-.05,0),.3)),
				Sphere(p,vec3(0,-.6,0),.4)),
				Cube(p,vec3(0,-1.7,0),1.0)),
				Cube(p,vec3(0,-2.9,0),2.0)),
				Cube(p,vec3(0,-8.0,0),8.0)),
				Cube(p,vec3(0,3,-11),8.0)),
				CubeFrame(p,vec3(0),4.0));

	// spiral candle
/*	p.xz = p.xz*cos(p.y*4.0)+vec2(1,-1)*p.zx*sin(p.y*4.0);
	return max(
				max( p.y-.5, -p.y-1.),
				(min(
					max(abs(p.x),abs(p.z)),
					max(abs(p.x+p.z),abs(p.z-p.x))/sqrt(2.0)
				)-.15)*.8);*/
}

float DistanceField( vec3 p )
{
	return DistanceField( p, 0.0 );
}


vec3 Sky( vec3 ray )
{
	return envBrightness*mix( vec3(.8), vec3(0), exp2(-(1.0/max(ray.y,.01))*vec3(.4,.6,1.0)) );
}


vec3 Shade( vec3 pos, vec3 ray, vec3 normal, vec3 lightDir1, vec3 lightDir2, vec3 lightCol1, vec3 lightCol2, float shadowMask1, float shadowMask2, float distance )
{
	// checker pattern
	vec3 albedoMain;	
	vec3 albedoVein;
	vec3 marbleAxis;
	vec3 check = fract((pos-vec3(0,-.18,0))*.5/1.5-.25)-.5;
	if ( check.x*check.y*check.z > .0 )
	{
		albedoMain = vec3(.3,.04,.02);
		albedoVein = vec3(1,.8,.5);
		marbleAxis = normalize(vec3(1,-3,2));
	}
	else
	{
		albedoMain = vec3(.8,.85,.9);
		albedoVein = vec3(.1,0,0);
		marbleAxis = normalize(vec3(1,2,3));
	}

	// marble pattern
/*	float marble = dot(pos,marbleAxis); // orientation (perp to seams)

	// multi-fractal noise
	vec3 mfp = pos*4.0; // noise frequency
	vec2 mfNoise = vec2(0);
	mfNoise += Noise(mfp);
	mfNoise += Noise(mfp*2.0)/2.0;
	mfNoise += Noise(mfp*4.0)/4.0;
	marble += mfNoise.x*.5; // noise amplitude
	
	marble *= 3.0; // adjust frequancy

//	vec3 albedo = vec3(1,.95,.9);
//	vec3 albedo = vec3(.7,.5,1);
//	vec3 albedo = vec3(.5,.3,.13);

	marble = abs(1.0-2.0*fract(marble)); // triangle wave
	marble = pow(smoothstep( 0.0, 1.0, marble ),20.0); // curve to thin the veins
*/

	// better marble
	vec3 mfp = (pos + dot(pos,marbleAxis)*marbleAxis*2.0)*2.0;
	float marble = 0.0;
	marble += abs(Noise(mfp).x-.5);
	marble += abs(Noise(mfp*2.0).x-.5)/2.0;
	marble += abs(Noise(mfp*4.0).x-.5)/4.0;
	marble += abs(Noise(mfp*8.0).x-.5)/8.0;
	marble /= 1.0-1.0/8.0;
	marble = pow( 1.0-marble,10.0); // curve to thin the veins
	
	vec3 albedo = mix( albedoMain, albedoVein, marble );


	vec3 ambient = envBrightness*mix( vec3(.2,.27,.4), vec3(.4), (-normal.y*.5+.5) ); // ambient
//		ambient = mix( vec3(.03,.05,.08), vec3(.1), (-normal.y+1.0) ); // ambient
	// ambient occlusion, based on my DF Lighting: https://www.shadertoy.com/view/XdBGW3
	float aoRange = distance/20.0;
	
	float occlusion = max( 0.0, 1.0 - DistanceField( pos + normal*aoRange )/aoRange ); // can be > 1.0
	occlusion = exp2( -2.0*pow(occlusion,2.0) ); // tweak the curve
	if ( Toggle(kAmbientOcclusion) )
		ambient *= occlusion*.8+.2; // reduce occlusion to imply indirect sub surface scattering

	float ndotl1 = max(.0,dot(normal,lightDir1));
	float ndotl2 = max(.0,dot(normal,lightDir2));
	float lightCut1 = smoothstep(.0,.1,ndotl1);//pow(ndotl,2.0);
	float lightCut2 = smoothstep(.0,.1,ndotl2);//pow(ndotl,2.0);

	vec3 light = vec3(0);
//	if ( Toggle(kDirectLight,3) )
	light += lightCol1*shadowMask1*ndotl1;
	light += lightCol2*shadowMask2*ndotl2;


	// And sub surface scattering too! Because, why not?
	float transmissionRange = TRANSMISSION_RANGE;//iMouse.x/iResolution.x;//distance/10.0; // this really should be constant... right?
	float transmission1 = DistanceField( pos + lightDir1*transmissionRange )/transmissionRange;
	float transmission2 = DistanceField( pos + lightDir2*transmissionRange )/transmissionRange;
	vec3 sslight = lightCol1 * smoothstep(0.0,1.0,transmission1) + lightCol2 * smoothstep(0.0,1.0,transmission2);
	vec3 subsurface = vec3(1,.8,.5) * sslight;


	float specularity = 1.0-marble;
	//specularity = mix( specularity, Noise(pos/.02).x, .1 ); // add some noise
	
	vec3 h1 = normalize(lightDir1-ray);
	vec3 h2 = normalize(lightDir2-ray);
	float specPower = exp2(mix(5.0,12.0,specularity));
	vec3 specular1 = lightCol1*shadowMask1*pow(max(.0,dot(normal,h1))*lightCut1, specPower)*specPower/32.0;
	vec3 specular2 = lightCol2*shadowMask2*pow(max(.0,dot(normal,h2))*lightCut2, specPower)*specPower/32.0;
	
	vec3 rray = reflect(ray,normal);
	vec3 reflection = Sky( rray );
	
	
	// specular occlusion, adjust the divisor for the gradient we expect
	float specOcclusion = max( 0.0, 1.0 - DistanceField( pos + rray*aoRange )/(aoRange*max(.01,dot(rray,normal))) ); // can be > 1.0
	specOcclusion = exp2( -2.0*pow(specOcclusion,2.0) ); // tweak the curve
	
	// prevent sparkles in heavily occluded areas
	specOcclusion *= occlusion;

	if ( Toggle(kReflectionOcclusion) )
		reflection *= specOcclusion; // could fire an additional ray for more accurate results
	
	float fresnel = pow( 1.0+dot(normal,ray), 5.0 );
	fresnel = mix( mix( .0, .01, specularity ), mix( .4, 1.0, specularity ), fresnel );
	
	vec3 result = vec3(0);

	// comment these out to toggle various parts of the effect
	light += ambient;

	if ( Toggle(kSubsurface) )
		light = mix( light, subsurface, .5 );//iMouse.y/iResolution.y );
	
	result = light*albedo;

	result = mix( result, reflection, fresnel );
	
	result += specular1 + specular2;

	return result;
}




// Isosurface Renderer
#ifdef FAST
const int traceLimit=40;
const float traceSize=.005;
#else
const int traceLimit=60;
const float traceSize=.002;
#endif	

float Trace( vec3 pos, vec3 ray, float traceStart, float traceEnd )
{
	float t = traceStart;
	float h;
	for( int i=0; i < traceLimit; i++ )
	{
		h = DistanceField( pos+t*ray, t );
		if ( h < traceSize || t > traceEnd )
			break;
		t = t+h;
	}
	
	if ( t > traceEnd )//|| h > .001 )
		return 0.0;
	
	return t;
}

float TraceMin( vec3 pos, vec3 ray, float traceStart, float traceEnd )
{
	float Min = traceEnd;
	float t = traceStart;
	float h;
	for( int i=0; i < traceLimit; i++ )
	{
		h = DistanceField( pos+t*ray, t );
		if ( h < .001 || t > traceEnd )
			break;
		Min = min(h,Min);
		t = t+max(h,.1);
	}
	
	if ( h < .001 )
		return 0.0;
	
	return Min;
}

vec3 Normal( vec3 pos, vec3 ray, float t )
{
	// in theory we should be able to get a good gradient using just 4 points

	float pitch = .2 * t / iResolution.x;
#ifdef FAST
	// don't sample smaller than the interpolation errors in Noise()
	pitch = max( pitch, .005 );
#endif
	
	vec2 d = vec2(-1,1) * pitch;

	vec3 p0 = pos+d.xxx; // tetrahedral offsets
	vec3 p1 = pos+d.xyy;
	vec3 p2 = pos+d.yxy;
	vec3 p3 = pos+d.yyx;
	
	float f0 = DistanceField(p0,t);
	float f1 = DistanceField(p1,t);
	float f2 = DistanceField(p2,t);
	float f3 = DistanceField(p3,t);
	
	vec3 grad = p0*f0+p1*f1+p2*f2+p3*f3 - pos*(f0+f1+f2+f3);
	
	// prevent normals pointing away from camera (caused by precision errors)
	float gdr = dot ( grad, ray );
	grad -= max(.0,gdr)*ray;
	
	return normalize(grad);
}


// Camera

vec3 Ray( float zoom, vec2 fragCoord )
{
	return vec3( fragCoord.xy-iResolution.xy*.5, iResolution.x*zoom );
}

vec3 Rotate( inout vec3 v, vec2 a )
{
	vec4 cs = vec4( cos(a.x), sin(a.x), cos(a.y), sin(a.y) );
	
	v.yz = v.yz*cs.x+v.zy*cs.y*vec2(-1,1);
	v.xz = v.xz*cs.z+v.zx*cs.w*vec2(1,-1);
	
	vec3 p;
	p.xz = vec2( -cs.w, -cs.z )*cs.x;
	p.y = cs.y;
	
	return p;
}


// Camera Effects

void BarrelDistortion( inout vec3 ray, float degree )
{
	// would love to get some disperson on this, but that means more rays
	ray.z /= degree;
	ray.z = ( ray.z*ray.z - dot(ray.xy,ray.xy) ); // fisheye
	ray.z = degree*sqrt(ray.z);
}

vec3 LensFlare( vec3 ray, vec3 lightCol, vec3 light, float lightVisible, float sky, vec2 fragCoord )
{
	vec2 dirtuv = fragCoord.xy/iResolution.x;
	
	float dirt = 1.0-texture( iChannel1, dirtuv ).r;
	
	float l = (dot(light,ray)*.5+.5);
	
	return (
			((pow(l,30.0)+.05)*dirt*.1
			+ 1.0*pow(l,200.0))*lightVisible + sky*1.0*pow(l,5000.0)
		   )*lightCol
		   + 5.0*pow(smoothstep(.9999,1.0,l),20.0) * lightVisible * normalize(lightCol);
}


float SmoothMax( float a, float b, float smoothing )
{
	return a-sqrt(smoothing*smoothing+pow(max(.0,a-b),2.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	if ( Toggle(kDarkScene) )
		envBrightness = darkEnvBrightness;
	
	vec3 ray = Ray(.7,fragCoord);
	
	if ( Toggle(kLensFX) )
		BarrelDistortion( ray, .5 );
	
	ray = normalize(ray);
	vec3 localRay = ray;

	vec2 mouse = vec2(.2,.5);
	if ( iMouse.z > .0 )
		mouse = vec2(.5)-iMouse.yx/iResolution.yx;
		
	float T = iTime*.1;
	vec3 pos = 3.0*Rotate( ray, vec2(.2,0.0-T)+vec2(-1.0,-6.3)*mouse );
	//pos += vec3(0,.3,0) + T*vec3(0,0,-1);
	
	vec3 col;

	vec3 lightDir1 = normalize(vec3(3,1,-2));
	float lt = iTime;
	vec3 lightPos = vec3(cos(lt*.9),sin(lt/phi),sin(lt))*vec3(.6,1.0,.6)+vec3(0,.2,0);
	
	vec3 lightCol1 = vec3(1.1,1,.9)*1.4*envBrightness;
	vec3 lightCol2 = vec3(.8,.4,.2)*2.0;
	
	float lightRange2 = .4; // distance of intensity = 1.0
	
	float traceStart = .5;
	float traceEnd = 40.0;
	
	float t = Trace( pos, ray, traceStart, traceEnd );
	if ( t > .0 )
	{
		vec3 p = pos + ray*t;
		
		// shadow test
		vec3 lightDir2 = lightPos-p;
		float lightIntensity2 = length(lightDir2);
		lightDir2 /= lightIntensity2;
		lightIntensity2 = lightRange2/(.1+lightIntensity2*lightIntensity2);
		
		float s1 = 0.0;
		s1 = Trace( p, lightDir1, .05, 20.0 );
		float s2 = 0.0;
		s2 = Trace( p, lightDir2, .05, length(lightPos-p) );
		
		vec3 n = Normal(p, ray, t);
		col = Shade( p, ray, n, lightDir1, lightDir2,
					lightCol1, lightCol2*lightIntensity2,
					(s1>.0)?0.0:1.0, (s2>.0)?0.0:1.0, t );
		
		// fog
		float f = 200.0;
		col = mix( vec3(.8), col, exp2(-t*vec3(.4,.6,1.0)/f) );
	}
	else
	{
		col = Sky( ray );
	}
	
	if ( Toggle(kLensFX) )
	{
		vec3 lightDir2 = lightPos-pos;
		float lightIntensity2 = length(lightDir2);
		lightDir2 /= lightIntensity2;
		lightIntensity2 = lightRange2/(.1+lightIntensity2*lightIntensity2);

		// lens flare
		float s1 = TraceMin( pos, lightDir1, .5, 40.0 );
		float s2 = TraceMin( pos, lightDir2, .5, length(lightPos-pos) );
		col += LensFlare( ray, lightCol1, lightDir1, smoothstep(.01,.1,s1), step(t,.0),fragCoord );
		col += LensFlare( ray, lightCol2*lightIntensity2, lightDir2, smoothstep(.01,.1,s2), step(t,.0),fragCoord );
	
		// vignetting:
		col *= smoothstep( .7, .0, dot(localRay.xy,localRay.xy) );
	
		// compress bright colours, ( because bloom vanishes in vignette )
		vec3 c = (col-1.0);
		c = sqrt(c*c+.05); // soft abs
		col = mix(col,1.0-c,.48); // .5 = never saturate, .0 = linear
		
		// grain
		vec2 grainuv = fragCoord.xy + floor(iTime*60.0)*vec2(37,41);
		vec2 filmNoise = texture( iChannel0, .5*grainuv/iChannelResolution[0].xy ).rb;
		col *= mix( vec3(1), mix(vec3(1,.5,0),vec3(0,.5,1),filmNoise.x), .1*filmNoise.y );
	}
	
	// compress bright colours
	float l = max(col.x,max(col.y,col.z));//dot(col,normalize(vec3(2,4,1)));
	l = max(l,.01); // prevent div by zero, darker colours will have no curve
	float l2 = SmoothMax(l,1.0,.01);
	col *= l2/l;
	
	fragColor = vec4(pow(col,vec3(1.0/2.2)),1);
}

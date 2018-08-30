// https://www.shadertoy.com/view/4dSBDt
//#define VOLUME_TEXTURES
#define NOISE_TEXTURES

const float PI	 	= 3.141592;
#define EPSILON_NRM (0.1 / iResolution.x)

// Cloud parameters
const float EARTH_RADIUS = 6300e3;
const float CLOUD_START = 800.0;
const float CLOUD_HEIGHT = 600.0;
const vec3 SUN_POWER = vec3(1.0,0.9,0.6) * 750.;
const vec3 LOW_SCATTER = vec3(1.0, 0.7, 0.5);

// Ocean parameter
// Procedural generation mostly from TDM https://www.shadertoy.com/view/Ms2SD1
const int ITER_GEOMETRY = 3;
const int ITER_FRAGMENT = 5;
const float SEA_HEIGHT = 0.6;
const float SEA_CHOPPY = 4.0;
const float SEA_FREQ = 0.16;
const vec3 SEA_BASE = 8.0*vec3(0.1,0.21,0.35);

// Cube parameters
const vec3 albedo = vec3(0.95, 0.16, 0.015);

// Noise generation functions (by iq)
float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float hash( vec2 p ) {
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453123);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
#ifdef VOLUME_TEXTURES    
    return textureLod(iChannel2, (p+f+0.5)/32.0, 0.0).x;
#else
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = textureLod( iChannel1, (uv+0.5)/256.0, 0.0).yx;
	return mix( rg.x, rg.y, f.z );
#endif
}

float noise( in vec2 p ) {
    vec2 i = floor( p );
    vec2 f = fract( p );	
	f = f*f*(3.0-2.0*f);
#ifdef NOISE_TEXTURES
    return textureLod(iChannel3, (i+f+vec2(0.5))/64.0, 0.0).x*2.0 -1.0;
#else    
    return -1.0+2.0*mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), f.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), f.x), f.y);
#endif
}

float fbm( vec3 p )
{
    mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );    
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p );
    return f;
}

float intersectSphere(vec3 origin, vec3 dir, vec3 spherePos, float sphereRad)
{
	vec3 oc = origin - spherePos;
	float b = 2.0 * dot(dir, oc);
	float c = dot(oc, oc) - sphereRad*sphereRad;
	float disc = b * b - 4.0 * c;
	if (disc < 0.0)
		return -1.0;    
    float q = (-b + ((b < 0.0) ? -sqrt(disc) : sqrt(disc))) / 2.0;
	float t0 = q;
	float t1 = c / q;
	if (t0 > t1) {
		float temp = t0;
		t0 = t1;
		t1 = temp;
	}
	if (t1 < 0.0)
		return -1.0;
    
    return (t0 < 0.0) ? t1 : t0;
}

float clouds(vec3 p, out float cloudHeight, bool fast)
{
#if 1
    float atmoHeight = length(p - vec3(0.0, -EARTH_RADIUS, 0.0)) - EARTH_RADIUS;
    cloudHeight = clamp((atmoHeight-CLOUD_START)/(CLOUD_HEIGHT), 0.0, 1.0);
    p.z += iTime*10.3;
    float largeWeather = clamp((textureLod(iChannel0, -0.00005*p.zx, 0.0).x-0.18)*5.0, 0.0, 2.0);
    p.x += iTime*8.3;
    float weather = largeWeather*max(0.0, textureLod(iChannel0, 0.0002*p.zx, 0.0).x-0.28)/0.72;
    weather *= smoothstep(0.0, 0.5, cloudHeight) * smoothstep(1.0, 0.5, cloudHeight);
    float cloudShape = pow(weather, 0.3+1.5*smoothstep(0.2, 0.5, cloudHeight));
    if(cloudShape <= 0.0)
        return 0.0;    
    p.x += iTime*12.3;
	float den= max(0.0, cloudShape-0.7*fbm(p*.01));
    if(den <= 0.0)
        return 0.0;
    
    if(fast)
    	return largeWeather*0.2*min(1.0, 5.0*den);

    p.y += iTime*15.2;
    den= max(0.0, den-0.2*fbm(p*0.05));
    return largeWeather*0.2*min(1.0, 5.0*den);
#else
    return 0.0;
#endif
}

// From https://www.shadertoy.com/view/4sjBDG
float numericalMieFit(float costh)
{
    // This function was optimized to minimize (delta*delta)/reference in order to capture
    // the low intensity behavior.
    float bestParams[10];
    bestParams[0]=9.805233e-06;
    bestParams[1]=-6.500000e+01;
    bestParams[2]=-5.500000e+01;
    bestParams[3]=8.194068e-01;
    bestParams[4]=1.388198e-01;
    bestParams[5]=-8.370334e+01;
    bestParams[6]=7.810083e+00;
    bestParams[7]=2.054747e-03;
    bestParams[8]=2.600563e-02;
    bestParams[9]=-4.552125e-12;
    
    float p1 = costh + bestParams[3];
    vec4 expValues = exp(vec4(bestParams[1] *costh+bestParams[2], bestParams[5] *p1*p1, bestParams[6] *costh, bestParams[9] *costh));
    vec4 expValWeight= vec4(bestParams[0], bestParams[4], bestParams[7], bestParams[8]);
    return dot(expValues, expValWeight);
}

float lightRay(vec3 p, float phaseFunction, float dC, float mu, vec3 sun_direction, float cloudHeight, bool fast)
{
    int nbSampleLight = fast ? 7 : 20;
	float zMaxl         = 600.;
    float stepL         = zMaxl/float(nbSampleLight);
    
    float lighRayDen = 0.0;    
    p += sun_direction*stepL*hash(dot(p, vec3(12.256, 2.646, 6.356)) + iTime);
    for(int j=0; j<nbSampleLight; j++)
    {
        float cloudHeight;
        lighRayDen += clouds( p + sun_direction*float(j)*stepL, cloudHeight, fast);
    }    
    if(fast)
    {
        return (0.5*exp(-0.4*stepL*lighRayDen) + max(0.0, -mu*0.6+0.3)*exp(-0.02*stepL*lighRayDen))*phaseFunction;
    }
    float scatterAmount = mix(0.008, 1.0, smoothstep(0.96, 0.0, mu));
    float beersLaw = exp(-stepL*lighRayDen)+0.5*scatterAmount*exp(-0.1*stepL*lighRayDen)+scatterAmount*0.4*exp(-0.02*stepL*lighRayDen);
    return beersLaw * phaseFunction * mix(0.05 + 1.5*pow(min(1.0, dC*8.5), 0.3+5.5*cloudHeight), 1.0, clamp(lighRayDen*0.4, 0.0, 1.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
    return length(max(abs(p)-b,0.0))-r;
}

mat3 cubeForm = mat3(1.0);
float Yelevation = 0.0;
float map( in vec3 pos )
{
    pos *= cubeForm;
    pos.y += Yelevation;
    
    pos.y += 3.66;
    pos.z += 0.4;
    pos *= 0.35;
        
    float res = udRoundBox(  pos-vec3( 0.0,1.25, 0.0), vec3(0.15), 0.01 );
    res = min( res, udRoundBox(  pos-vec3( 0.33,1.25, 0.0), vec3(0.15), 0.01 ) );
    res = min( res, udRoundBox(  pos-vec3( 0.33,1.25, 0.33), vec3(0.15), 0.01 ) );
    res = min( res, udRoundBox(  pos-vec3( 0.0,1.25, 0.33), vec3(0.15), 0.01 ) );
    
    res = min( res, udRoundBox(  pos-vec3( 0.0,1.58, 0.0), vec3(0.15), 0.01 ) );
    res = min( res, udRoundBox(  pos-vec3( 0.0,1.58, 0.33), vec3(0.15), 0.01 ) );
    res = min( res, udRoundBox(  pos-vec3( 0.33,1.58, 0.0), vec3(0.15), 0.01 ) ); 
    return res;
}

float sea_octave(vec2 uv, float choppy) {
    uv += noise(uv);        
    vec2 wv = 1.0-abs(sin(uv));
    vec2 swv = abs(cos(uv));    
    wv = mix(wv,swv,wv);
    return pow(1.0-pow(wv.x * wv.y,0.65),choppy);
}

float mapWater(vec3 p, int steps, bool cube) {
    float freq = SEA_FREQ;
    float amp = SEA_HEIGHT;
    float choppy = SEA_CHOPPY;
    vec2 uv = p.xz; uv.x *= 0.75;
    
    float d, h = 0.0;
    const float SEA_SPEED = 0.8;
    const mat2 octave_m = mat2(1.6,1.2,-1.2,1.6);
    float seaTime = (1.0 + iTime * SEA_SPEED);
    for(int i = 0; i < steps; i++)
    {        
    	d = sea_octave((uv+seaTime)*freq,choppy);
    	d += sea_octave((uv-seaTime)*freq,choppy);
        h += d * amp;        
    	uv *= octave_m; freq *= 1.9; amp *= 0.22;
        choppy = mix(choppy,1.0,0.2);
    }
    if(!cube)
        return p.y -h;
    
    return p.y - h - 0.2*exp(-max(0.0, 23.0*map(p)));
}

float Schlick (float f0, float VoH )
{
	return f0+(1.-f0)*pow(1.0-VoH,5.0);
}

vec3 skyRay(vec3 org, vec3 dir, vec3 sun_direction, bool fast)
{
    const float ATM_START = EARTH_RADIUS+CLOUD_START;
	const float ATM_END = ATM_START+CLOUD_HEIGHT;
    
    int nbSample = fast ? 13 : 35;   
    vec3 color = vec3(0.0);
	float distToAtmStart = intersectSphere(org, dir, vec3(0.0, -EARTH_RADIUS, 0.0), ATM_START);
    float distToAtmEnd = intersectSphere(org, dir, vec3(0.0, -EARTH_RADIUS, 0.0), ATM_END);
    vec3 p = org + distToAtmStart * dir;    
    float stepS = (distToAtmEnd-distToAtmStart) / float(nbSample);    
    float T = 1.;    
    float mu = dot(sun_direction, dir);
    float phaseFunction = numericalMieFit(mu);
    p += dir*stepS*hash(dot(dir, vec3(12.256, 2.646, 6.356)) + iTime);
    if(dir.y > 0.015)
	for(int i=0; i<nbSample; i++)
	{        
        float cloudHeight;
		float density = clouds(p, cloudHeight, fast);
		if(density>0.)
		{
			float intensity = lightRay(p, phaseFunction, density, mu, sun_direction, cloudHeight, fast);        
            vec3 ambient = (0.5 + 0.6*cloudHeight)*vec3(0.2, 0.5, 1.0)*6.5 + vec3(0.8) * max(0.0, 1.0-2.0*cloudHeight);
            vec3 radiance = ambient + SUN_POWER*intensity;
            radiance*=density;			
            color += T*(radiance - radiance * exp(-density * stepS)) / density;   // By Seb Hillaire                  
            T *= exp(-density*stepS);            
			if( T <= 0.05)
				break;
        }
		p += dir*stepS;
	}
        
    if(!fast)
    {
        vec3 pC = org + intersectSphere(org, dir, vec3(0.0, -EARTH_RADIUS, 0.0), ATM_END+1000.0)*dir;
    	color += T*vec3(3.0)*max(0.0, fbm(vec3(1.0, 1.0, 1.8)*pC*0.002)-0.4);
    }
	vec3 background = 6.0*mix(vec3(0.2, 0.52, 1.0), vec3(0.8, 0.95, 1.0), pow(0.5+0.5*mu, 15.0))+mix(vec3(3.5), vec3(0.0), min(1.0, 2.3*dir.y));
    if(!fast) 	background += T*vec3(1e4*smoothstep(0.9998, 1.0, mu));
    color += background * T;
    
    return color;
}

float D_GGX(in float r, in float NoH, in vec3 h)
{
    float a = NoH * r;
    float k = r / ((1.0 - NoH * NoH) + a * a);
    return k * k * (1.0 / PI);
}

float castRay( in vec3 ro, in vec3 rd, in float tmin)
{
    float tmax = 10.0;   
#if 1
    float maxY = 3.0;
    float minY = -1.0;
    // bounding volume
    float tp1 = (minY-ro.y)/rd.y; if( tp1>0.0 ) tmax = min( tmax, tp1 );
    float tp2 = (maxY-ro.y)/rd.y; if( tp2>0.0 ) { if( ro.y>maxY ) tmin = max( tmin, tp2 );
                                                 else           tmax = min( tmax, tp2 ); }
#endif    
    float t = tmin;
    for( int i=0; i<100; i++ )
    {
	    float precis = 0.0005*t;
	    float res = map( ro+rd*t );
        if( res<precis || t>tmax ) break;
        t += res;
    }
    if( t>tmax ) return -1.;
    return t;
}


float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<14; i++ )
    {
		float h = map( ro + rd*t );
        res = min( res, 8.*h/t );
        t += clamp( h, 0.08, 0.25 );
        if( res<0.001 || t>tmax ) break;
    }
    return max(0.0, res);
}

vec3 calcNormal( in vec3 pos)
{
    vec2 e = vec2(1.0,-1.0)*EPSILON_NRM;
    return normalize( e.xyy*map( pos + e.xyy ) + 
					  e.yyx*map( pos + e.yyx ) + 
					  e.yxy*map( pos + e.yxy ) + 
					  e.xxx*map( pos + e.xxx ) );
}

float calcAO( in vec3 pos, in vec3 nor )
{
	float sca = 10.2;
    float hr = 0.05;  
    float dd = map( nor * 0.15 + pos ); 
    return clamp( 1.0 + (dd-hr)*sca, 0.0, 1.0 );     
}

vec3 renderCubeFast(in vec3 p, in vec3 dir, in vec3 sun_direction, in float res)
{
    vec3 pos = p + res*dir;
    vec3 nor = calcNormal( pos );
    float NoL = max(0.0, dot(sun_direction, nor));    
    vec3 color = 0.6*NoL*SUN_POWER*albedo/PI; // diffuse
    //color *= softshadow(pos, sun_direction, 0.001, 2.0); // Shadow
    color += albedo * vec3(0.3, 0.6, 1.0)* 35.0 * (0.75 + 0.25*nor.y); // skylight
    return color;
}

float HenyeyGreenstein(float mu, float inG)
{
	return (1.-inG * inG)/(pow(1.+inG*inG - 2.0 * inG*mu, 1.5)*4.0* PI);
}

vec3 getSeaColor(in vec3 p, in vec3 N, in vec3 sun_direction, in vec3 dir, in vec3 dist, in float mu, in float cloudShadow)
{    
    vec3 L = normalize(vec3(0.0)+reflect(dir, N));
    vec3 V = -dir;
	float NoV = clamp(abs(dot(N, V))+1e-5,0.0, 1.0);
    float NoL = max(0.0, dot(N, L));
    float VoH = max(0.0, dot(V, normalize(V+L)));    
    float fresnel = Schlick(0.02, NoV);    
    float cubeRes = castRay(p, L, 0.0001);
    vec3 reflection = skyRay(p, L, sun_direction, true);
    if(cubeRes != -1.)
        reflection = renderCubeFast(p, L, sun_direction, cubeRes);    
    vec3 color = mix(cloudShadow*SEA_BASE, reflection, fresnel);    
    float subsurfaceAmount = 12.0*HenyeyGreenstein(mu, 0.5);
    const vec3 SEA_WATER_COLOR = 0.6*vec3(0.8,0.9,0.6);
    color += subsurfaceAmount * SEA_WATER_COLOR * max(0.0, 1.0+p.y - 0.6*SEA_HEIGHT);    
    if(cubeRes == -1.)
    {
    	vec3 H = normalize(V+sun_direction);
        float NoL = max(0.0, dot(N, sun_direction));
        float roughness = 0.05;
    	color += LOW_SCATTER*0.4*vec3(NoL/PI*fresnel*SUN_POWER*D_GGX(roughness, max(0.0, dot(N, H)), H));
    }
    color += 9.0*max(0.0, smoothstep(0.35, 0.6, p.y - SEA_HEIGHT) * N.x); // Foam
    float foamShadow = max(0.0, dot(sun_direction.xz, normalize(p.xz-vec2(0.0, 0.0))));
    color += foamShadow*2.5*smoothstep(0.06+0.06*N.z,0.0,map(p))*max(0.0, N.y); // Foam at cube entry
    return color;
}

vec3 getNormalWater(vec3 p, float eps) {   
    vec3 n;
    n.y = mapWater(p, ITER_FRAGMENT, true);    
    n.x = mapWater(vec3(p.x+eps,p.y,p.z), ITER_FRAGMENT, true) - n.y;
    n.z = mapWater(vec3(p.x,p.y,p.z+eps), ITER_FRAGMENT, true) - n.y;
    n.y = eps;  
    return normalize(n);
}

float heightMapTracing(vec3 ori, vec3 dir, out vec3 p) {  
    float tm = 0.0;
    float tx = 1e8;    
    float hx = mapWater(ori + dir * tx, ITER_GEOMETRY, true);
    if(hx > 0.0) return tx;   
    float hm = mapWater(ori + dir * tm, ITER_GEOMETRY, true);    
    float tmid = 0.0;
    for(int i = 0; i < 8; i++)
    {
        tmid = mix(tm,tx, hm/(hm-hx));                   
        p = ori + dir * tmid;                   
    	float hmid = mapWater(p, ITER_GEOMETRY, true);
		if(hmid < 0.0)
        {
        	tx = tmid;
            hx = hmid;
        } else
        {
            tm = tmid;
            hm = hmid;
        }
    }
    return tmid;
}

vec3 worldReflection(vec3 org, vec3 dir, vec3 sun_direction)
{    
    if(castRay(org, dir, 0.05) != -1. || dir.y < 0.0)
        return vec3(0.0);
    
    return skyRay(org, dir, sun_direction, true);
}

vec3 renderCube(vec3 p, vec3 dir, vec3 sun_direction, float res)
{
    vec3 pos = p + res*dir;
    vec3 nor = calcNormal( pos );
    float occ = calcAO( pos, nor );
    float NoL = max(0.0, dot(sun_direction, nor));
    float sunShadow = softshadow(pos, sun_direction, 0.001, 2.0);
    vec3 color = 0.6*NoL*SUN_POWER*albedo* sunShadow/PI; // diffuse
    color += albedo*occ * vec3(0.3, 0.6, 1.0)* 35.0 * (0.75 + 0.25*nor.y); // skylight
    color += Schlick(0.04, max(0.0, dot(nor, -dir)))*worldReflection(pos, reflect(dir, nor), sun_direction)*max(0.0, occ-0.7)/0.7; // specular
    return color;
}

void setupCubeForm()
{
    const float EPS_EL = 0.9;
    float elevationX = mapWater(vec3(EPS_EL, 0.0, 0.0), 2, false);
    float elevationY = mapWater(vec3(-EPS_EL, 0.0, -EPS_EL), 2,false);
    float elevationZ = mapWater(vec3(-EPS_EL, 0.0, EPS_EL), 2,false);
    
    float waveRotX = elevationX - (elevationY + elevationZ) * 0.5;
    float waveRotZ = ((elevationZ - elevationX)+(elevationX - elevationY))*0.5;
    vec2 euler = vec2(0.3- waveRotZ, -0.15- waveRotX);    
    vec2 s = sin(euler);
    vec2 c = cos(euler);
    
    mat3 rotX = mat3(
        1.0, 0.0, 0.0,
        0.0, c.x, s.x,
        0.0, -s.x, c.x
    );
      
    mat3 rotZ = mat3(
        c.y, s.y, 0.0,
        -s.y, c.y, 0.0,
        0.0, 0.0, 1.0
    );
    
    cubeForm = inverse(rotX*rotZ);  
    Yelevation = 0.333*(elevationX + elevationY + elevationZ);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 v = -1.0 + 2.0*q;
    v.x *= iResolution.x/ iResolution.y;
    vec2 mo = iMouse.xy / iResolution.xy;
    
    float camRot = -7.0*mo.x;
    vec3 org = (vec3(6.0*cos(camRot), mix(2.2, 10.0, mo.y), 6.0*sin(camRot)));    
	vec3 ta = vec3(0.0, mix(1.2, 12.0, mo.y), 0.0);
    
    if (iMouse.z < 0.)
    {
        vec3 offset = -0.4*vec3(-5.7, 0.0, 1.6);
        ta = vec3(0.0, 2.9, 0.0)+offset;
        org = vec3(1.6, 3.1, 5.7)+offset;
    }
    
    vec3 ww = normalize( ta - org);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 dir = normalize( v.x*uu + v.y*vv + 1.4*ww );
	vec3 color=vec3(.0);
    vec3 sun_direction = normalize( vec3(0.6,0.45,-0.8) );
	float fogDistance = intersectSphere(org, dir, vec3(0.0, -EARTH_RADIUS, 0.0), EARTH_RADIUS);
    float mu = dot(sun_direction, dir);
    
    setupCubeForm();
    float cubeRes = castRay(org, dir, 2.0);
    
    // Sky
    if(fogDistance == -1. && cubeRes == -1.)
    {
        color = skyRay(org, dir, sun_direction, false); 
        fogDistance = intersectSphere(org, dir, vec3(0.0, -EARTH_RADIUS, 0.0), EARTH_RADIUS+160.0);
    }
    else if(fogDistance == -1. && cubeRes != -1.)
    {
        color.xyz = renderCube(org, dir, sun_direction, cubeRes);
        fogDistance = cubeRes;
    }
    else // water
    {
        vec3 waterHitPoint;
    	heightMapTracing(org,dir,waterHitPoint);         
    	vec3 dist = waterHitPoint - org;
    	vec3 n = getNormalWater(waterHitPoint, dot(dist,dist) * EPSILON_NRM);
        float cloudShadow= 1.0-textureLod(iChannel0, waterHitPoint.xz*0.008-vec2(0.0, 0.03*iTime), 7.0).x;        
   	 	color = getSeaColor(waterHitPoint,n,sun_direction,dir,dist, mu, cloudShadow); 
        
        if(cubeRes != -1.)
        {
            float distT = length(dist);
            if(cubeRes > distT) // Under the water cube
            {
                vec3 refr = refract(dir, n, 0.75);
            	cubeRes = castRay(waterHitPoint, refr, 0.001);            	
                if(cubeRes != -1.)
                {
                    vec3 cube = renderCube(waterHitPoint, refr, sun_direction, cubeRes); 
        			float fresnel = 1.0 - Schlick(0.04, max(0.0, dot(n, -dir)));
            		color.xyz += fresnel * (cube.xyz *vec3(0.7, 0.8, 0.9)*exp(-0.01*vec3(60.0, 15.0, 1.0)*max(0.0, cubeRes)) - SEA_BASE * cloudShadow);
                }
            }
            else
            {
                color = renderCube(org, dir, sun_direction, cubeRes);
            }            
            fogDistance = cubeRes;
        }
    }  
    
    float fogPhase = 0.5*HenyeyGreenstein(mu, 0.7)+0.5*HenyeyGreenstein(mu, -0.6);    
    fragColor = vec4(mix(fogPhase*0.1*LOW_SCATTER*SUN_POWER+10.0*vec3(0.55, 0.8, 1.0), color, exp(-0.0003*fogDistance)), 1.0);
}

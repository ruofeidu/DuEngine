#define SPEED .1
#define FOV 3.
#define SLICES 12.
#define CAKE_POS .15

#define MAX_STEPS 100
#define SHADOW_STEPS 100
#define SHADOW_SOFTNESS 50.
#define EPS .0001
#define RENDER_DIST 5.
#define AO_SAMPLES 5.
#define AO_RANGE 20.
#define LIGHT_COLOR vec3(1.,.5,.3)

#define PI 3.14159265359
#define saturate(x) clamp(x, 0., 1.)

// simple hash function
float hash(vec3 uv) {
    float f = fract(sin(dot(uv, vec3(.09123898, .0231233, .0532234))) * 1e5);
    return f;
}

// 3d noise function (linear interpolation between hash of integer bounds)
float noise(vec3 uv) {
    vec3 fuv = floor(uv);
    vec4 cell0 = vec4(
        hash(fuv + vec3(0, 0, 0)),
        hash(fuv + vec3(0, 1, 0)),
        hash(fuv + vec3(1, 0, 0)),
        hash(fuv + vec3(1, 1, 0))
    );
    vec2 axis0 = mix(cell0.xz, cell0.yw, fract(uv.y));
    float val0 = mix(axis0.x, axis0.y, fract(uv.x));
    vec4 cell1 = vec4(
        hash(fuv + vec3(0, 0, 1)),
        hash(fuv + vec3(0, 1, 1)),
        hash(fuv + vec3(1, 0, 1)),
        hash(fuv + vec3(1, 1, 1))
    );
    vec2 axis1 = mix(cell1.xz, cell1.yw, fract(uv.y));
    float val1 = mix(axis1.x, axis1.y, fract(uv.x));
    return mix(val0, val1, fract(uv.z));
}

// fractional brownian motion
float fbm(vec3 uv) {
    float f = 0.;
    float r = 1.;
    for (int i = 0; i < 4; ++i) {
        f += noise((uv + 10.) * r) / (r *= 2.);
    }
    return f / (1. - 1. / r);
}

// rotate 2d space with given angle
void tRotate(inout vec2 p, float angel) {
    float s = sin(angel), c = cos(angel);
	p *= mat2(c, -s, s, c);
}

// repeat space along an axis
float tRepeat1(inout float p, float r) {
    float id = floor((p + r * .5) / r);
    p = mod(p + r * .5, r) - r * .5;
    return id;
}

// divide 2d space into s chunks around the center
void tFan(inout vec2 p, float s) {
    float k = s / PI / 2.;
    tRotate(p, -floor((atan(p.y, p.x)) * k + .5) / k);
}

// rectangle distance
float sdRect(vec2 p, vec2 r) {
    p = abs(p) - r;
	return min(max(p.x, p.y), 0.) + length(max(p, 0.));
}

// sphere distance
float sdSphere(vec3 p, float r) {
	return length(p) - r;
}

// cylinder distance r - radius, l - height
float sdCylinder(vec3 p, float r, float l) {
    p.xy = vec2(abs(p.y) - l, length(p.xz) - r);
    return min(max(p.x, p.y), 0.) + length(max(p.xy, 0.));
}

// union
float opU(float a, float b) {
    return min(a, b);
}

// intersection
float opI(float a, float b) {
    return max(a, b);
}

// substraction
float opS(float a, float b) {
    return max(a, -b);
}

// smooth union
float opSU(float a, float b, float k)
{
    float h = clamp(.5 + .5 * (b - a) / k, 0., 1.);
    return mix(b, a, h) - k * h * (1. - h);
}

// the icing on the cake
float sdIcingOnTheCake(vec3 p) {
    
    // twist
    tRotate(p.xz, p.y * 3.);
    
    // add an infinite box
    float d = sdRect(p.xz, vec2(.4));
    
    // add another box, rotated by 45 degrees, smoothly
    tRotate(p.xz, PI / 4.);
    d = opSU(d, sdRect(p.xz, vec2(.4)), .1);
    
    // add a slope
    d += p.y + .2;
    
    // divide the distance, because by now it has been ruined, then intersect smoothly with a sphere
    d = -opSU(-d * .5, -sdSphere(p, .5), .1);
    return d;
}

// distance estimation of everything together
float map(vec3 p) {
    vec3 q = p;
    
    // rounded cylinder for the cake
    float r = .02;
    float d = sdCylinder(p, .5 - r, .2 -r) - r;
    
    // blend in the icing
    tFan(q.xz, SLICES);
	d = opSU(d, sdIcingOnTheCake((q - vec3(.4, .3, 0)) * 5.) / 5., .04);
	//d = opSU(d, sdIcingOnTheCake((q - vec3(.4, .3, 0)) * 2.) / 5., .01);
    
    // cut the cake
    tRotate(p.xz, PI / SLICES);
    float slice = p.z;
    float a = fract((floor(iTime * SPEED * SLICES)) / SLICES - .5) * PI * 2.;
   // a = PI * 0.5 / 8.0 * 2.0;
    tRotate(p.xz, a);
    slice = (a < PI) ? opU(slice, p.z) : opI(slice, p.z);
    return opS(d, slice);
}

// trace the scene from ro (origin) to rd (direction, normalized)
// until hit or reached maxDist, outputs distance traveled and the number of steps
float trace(vec3 ro, vec3 rd, float maxDist, out float steps) {
    float total = 0.;
    steps = 0.;
    
    for (int i = 0; i < MAX_STEPS; ++i) {
        ++steps;
        float d = map(ro + rd * total);
        total += d;
        if (d < EPS || maxDist < total) break;
    }
    
    return total;
}

// get the soft shadow value
float softShadow(vec3 ro, vec3 rd, float maxDist) {
    float total = 0.;
    float s = 1.;
    
    for (int i = 0; i < SHADOW_STEPS; ++i) {
        float d = map(ro + rd * total);
        if (d < EPS) {
            s = 0.;
            break;
        }
        if (maxDist < total) break;
        s = min(s, SHADOW_SOFTNESS * d / total);
        total += d;
    }
    
    return s;
}

// calculate the normal vector
vec3 getNormal(vec3 p) {
    vec2 e = vec2(.0001, 0);
    return normalize(vec3(
        map(p + e.xyy) - map(p - e.xyy),
        map(p + e.yxy) - map(p - e.yxy),
        map(p + e.yyx) - map(p - e.yyx)
	));
}

// ambient occlusion
float calculateAO(vec3 p, vec3 n) {
    
    float r = 0., w = 1., d;
    
    for (float i = 1.; i <= AO_SAMPLES; i++){
        d = i / AO_SAMPLES / AO_RANGE;
        r += w * (d - map(p + n * d));
        w *= .5;
    }
    
    return 1.-saturate(r * AO_RANGE);
}

// texture function
vec3 _texture(vec3 p) {
    vec3 q = p;
    q.y += .05;
    tRepeat1(q.y, .095);
    vec3 t = mix(fbm(fbm(p * 10.) + p * 10.) * vec3(.5) + vec3(.5),
                fbm(p * 100.) * vec3(.5, .0, .0),1. - 
                saturate((opI(sdCylinder(p, .5, .175),sdCylinder(q, .48, .035)) + (fbm(p * 100.)- .5) * .02 ) * 100.));
    return saturate(t);
}

// texture used for bump mapping
float bumpTexture(vec3 p) {
    vec3 q = p;
    q.y += .05;
    tRepeat1(q.y, .095);
    float t = mix(fbm(fbm(p * 20.) + p * 10.) * .5 + .25,
                fbm(p * 100.), 1. - 
                saturate((opI(sdCylinder(p, .5, .175),sdCylinder(q, .48, .035)) + (fbm(p * 100.)- .5) * .02 ) * 100.));
    return saturate(t);
}

// bump mapping from Shane
vec3 doBumpMap(vec3 p, vec3 nor, float bumpfactor) {
    
    vec2 e = vec2(.0001, 0);
    float ref = bumpTexture(p);                 
    vec3 grad = vec3(bumpTexture(p - e.xyy) - ref,
                     bumpTexture(p - e.yxy) - ref,
                     bumpTexture(p - e.yyx) - ref) / e.x;
             
    grad -= nor * dot(nor, grad);          
                      
    return normalize(nor + grad * bumpfactor);
	
}

#ifdef LOW_QUALITY

	#define kRaymarchMaxIter 32
	#define kMaxIter 3
	#define kShadowIter 8

#else

	#define kRaymarchMaxIter 128
	#define kMaxIter 4
	#define kShadowIter 16

#endif 

//#define ENABLE_MIRROR

//#define BURN_DOWN

float fSceneIntensity = 0.5;

vec3 vFlameLightColour = vec3(1.0, 0.5, 0.1) * 10.0;
vec3 vFlameColour1 = vec3(1.0, 0.5, 0.1);
vec3 vFlameColour2 = vec3(1.0, 0.05, 0.01);

vec3 GetFlameWander()
{
    vec3 vFlameWander = vec3(0.0, 0.0, 0.0);

	vFlameWander.x = sin(iTime * 20.0);
	vFlameWander.z = sin(iTime * 10.0) * 2.0;

    return vFlameWander;	
}

float fWaxExtinction = 5.0;

float kExposure = 3.5;

vec3 vCandlestickPos = vec3(0.0, 0.0, 0.0);

#ifndef BURN_DOWN
	float fCandleTop = max(0.0, 0.1);
#else
	float fCandleTop = max(2.2, 1.0 - iTime * 0.005);
#endif

vec3 GetLightPos()
{
    return vCandlestickPos + vec3(0.0, fCandleTop + 0.35, 0.0) - GetFlameWander() * 0.01;
}

#define kMaterialWood   0.0
#define kMaterialGold 	1.0
#define kMaterialWax 	2.0
#define kMaterialWick	3.0
#define kMaterialChrome	4.0
#define kMaterialPaper	5.0

vec2 GetDistanceCandlestick( const in vec3 vPos )
{
	vec2 vProfilePos = vec2( length(vPos.xz), vPos.y );

	float fTop = 2.0;
	float fBottom = 0.0;
	
	float fOutside = -1.0;
	
	float fDist = vProfilePos.x;	
	float fVerticalPos = vProfilePos.y;
	
	if(fVerticalPos > fTop)
	{
		fVerticalPos = fTop;
		fOutside = 1.0;
	}

	if(fVerticalPos < fBottom)
	{
		fVerticalPos = fBottom;		
		fOutside = 1.0;
	}

	float t = fVerticalPos;
	float a = 3.14 * 2.0;
	float b = 0.15;
	float fHorizontalPos = 0.4 + sin(t * a) * b;
	float fHorizontalPosDelta = (cos(t * a) * a * b) / a;
	
	float fHorizontalDist = vProfilePos.x - fHorizontalPos;
	
	if(fOutside > 0.0)
	{
		vec2 vClosest = vec2(min(fHorizontalPos, vProfilePos.x), fVerticalPos);
		
		fDist = length(vClosest - vProfilePos);		
	}
	else
	{
		
		if(fHorizontalDist > 0.0)
		{
			fOutside = 1.0;
		}

		if(fOutside < 0.0)
		{		
			float fTopDist = fTop - fVerticalPos;
			float fBottomDist = fVerticalPos - fBottom;
			fDist = min(fTopDist, fBottomDist);
			fDist = min(fDist, -fHorizontalDist);
		}
		else
		{
			fDist = fHorizontalDist / sqrt(1.0 + fHorizontalPosDelta * fHorizontalPosDelta);	
		}
	}
	
	float fBevel = 0.1;
	float fStickDistance = fOutside * fDist -fBevel;
	
	float fBaseTop = 0.1;
	float fBaseRadius = 1.0;
	vec2 vBaseClosest = vProfilePos;
	vBaseClosest.y = min(vBaseClosest.y, fBaseTop);
	vBaseClosest.x = min(vBaseClosest.x, fBaseRadius);

	float fBaseDistance = length(vProfilePos - vBaseClosest) - fBevel;
	
	return vec2( min(fStickDistance, fBaseDistance), kMaterialGold);
}


float GetDistanceWaxTop( const in vec3 vPos )
{
	vec2 vProfilePos = vec2( length(vPos.xz), vPos.y );

	float fCurve = 1.0;
	
	return vProfilePos.y - fCandleTop - vProfilePos.x * vProfilePos.x * fCurve;	
}

vec2 GetDistanceCandle( const in vec3 vPos )
{
	vec2 vProfilePos = vec2( length(vPos.xz), vPos.y );
	
	float fDistance = vProfilePos.x - 0.15;
		
	float fDistanceTop = sdCylinder(vPos, 0.15, 0.2);
        
    //GetDistanceWaxTop(vPos);
	
	if (fDistanceTop > fDistance)
	{
		fDistance = fDistanceTop;
	}
	
	return vec2(fDistance, kMaterialWax);
}

vec2 GetSceneDistance( vec3 vPos )
{    
	vec3 vCandlestickLocalPos = vPos - vCandlestickPos;	

	vec2 vResult = vec2(1.0, -1.0);
	
	vec2 vCandle = GetDistanceCandle(vCandlestickLocalPos);
	if(vCandle.x < vResult.x)
	{
		vResult = vCandle;
	}

	return vResult;
}


vec2 Raycast( const in vec3 vOrigin, const in vec3 vDir )
{
	vec2 d = vec2(0.0, -1.0);
	float t = 0.01;
	for(int i=0; i<kRaymarchMaxIter; i++)
	{
		d = GetSceneDistance(vOrigin + vDir * t);
		if(abs(d.x) < 0.001)
		{
			break;
		}
		t += d.x;
		if(t > 100.0)
		{
			break;
		}
	}
	
	return vec2(t, d.y);
}


vec3 GetSceneNormal( const in vec3 vPos )
{
    const float fDelta = 0.001;

    vec3 vOffset1 = vec3( fDelta, -fDelta, -fDelta);
    vec3 vOffset2 = vec3(-fDelta, -fDelta,  fDelta);
    vec3 vOffset3 = vec3(-fDelta,  fDelta, -fDelta);
    vec3 vOffset4 = vec3( fDelta,  fDelta,  fDelta);

    float f1 = GetSceneDistance( vPos + vOffset1 ).x;
    float f2 = GetSceneDistance( vPos + vOffset2 ).x;
    float f3 = GetSceneDistance( vPos + vOffset3 ).x;
    float f4 = GetSceneDistance( vPos + vOffset4 ).x;

    vec3 vNormal = vOffset1 * f1 + vOffset2 * f2 + vOffset3 * f3 + vOffset4 * f4;

    return normalize( vNormal );
}


vec3 GetFlameIntensity( const in vec3 vOrigin, const in vec3 vDir, const in float fDistance )
{
	vec3 vFlamePos = vec3(0.0, fCandleTop + 0.25, 0.0) + vCandlestickPos;
	vec3 vToFlame = vFlamePos - vOrigin;
	
	float fClosestDot = dot(vDir, vToFlame);
	fClosestDot = clamp(fClosestDot, 0.0, fDistance);
	
	vec3 vClosestPos = vOrigin + vDir * fClosestDot;
	vec3 vClosestToFlame = vClosestPos - vFlamePos;
	
	vClosestToFlame.xz *= (vClosestToFlame.y + 1.0) * 1.5;
	vClosestToFlame.y *= 0.5;
	vClosestToFlame *= 8.0;

	float fSwayAmount = (1.0 + vClosestToFlame.y ) * 0.05;
	vClosestToFlame += GetFlameWander() * fSwayAmount;
	
	float fClosestDist = length(vClosestToFlame);
		
	float fBrightness = smoothstep(1.0, 0.5, fClosestDist) * 2.0;
			
	float fHeightFade = (vClosestToFlame.y * 0.5 + 0.5);
	fBrightness *= clamp(dot(vClosestToFlame.xz, vClosestToFlame.xz) + fHeightFade, 0.0, 1.0);

	return mix(vFlameColour1 * 32.0, vFlameColour2, 1.0 - fBrightness) * fBrightness;
}
vec3 GetFlareIntensity( const in vec3 vOrigin, const in vec3 vDir )
{
	vec3 vToFlame = GetLightPos() - vOrigin;

	
	float fClosestDot = dot(vDir, vToFlame);
	fClosestDot = max(fClosestDot, 0.0);
	
	vec3 vClosestPos = vOrigin + vDir * fClosestDot;
	vec3 vClosestToFlame = vClosestPos - GetLightPos();
	
	float fClosestDist = length(vClosestToFlame);
		
	float fBrightness = (1.0 / (fClosestDist + 1.0));	

	return vFlameColour1 * pow(fBrightness, 5.0);
}
float GetAmbientOcclusion( const in vec3 vPos, const in vec3 vNormal)
{	
	float fAmbientOcclusion = 0.0;
	
	float fStep = 0.1;
	float fDist = 0.0;
	for(int i=0; i<=5; i++)
	{
		fDist += fStep;
		
		vec2 vSceneDist = GetSceneDistance(vPos + vNormal * fDist);
		
		float fAmount = (fDist - vSceneDist.x);
		
		fAmbientOcclusion += max(0.0, fAmount * fDist );                                  
	}
	
	return max(1.0 - fAmbientOcclusion, 0.0);
}


vec3 SampleDiffuse( const in vec3 vDir )
{
	vec3 vSample = texture(iChannel1, vDir, 0.0).rgb;
	vSample = vSample * vSample;
	
	// hack bright spots out of blurred environment
	float fMag = length(vSample);	
	vSample = mix(vSample, vec3(0.15, 0.06, 0.03), smoothstep(0.1, 0.25, fMag));
	
	return vSample * fSceneIntensity;
}



vec2 GetDistanceSphere( const in vec3 vPos )
{
	float fDistance = length(vPos - vec3(1.3, 0.75, 1.0)) - 0.75;

	return vec2(fDistance, kMaterialChrome);
}
vec3 RotateX( const in vec3 vPos, const in float s, const in float c )
{
	vec3 vResult = vec3( vPos.x, c * vPos.y + s * vPos.z, -s * vPos.y + c * vPos.z);

	return vResult;
}

vec3 RotateY( const in vec3 vPos, const in float s, const in float c )
{
	vec3 vResult = vec3( c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);

	return vResult;
}

float GetDistanceBox( const in vec3 vPos, const in vec3 vDimension )
{
	vec3 vDist = abs(vPos) - vDimension;
  	float fDistance =  min(max(vDist.x,max(vDist.y,vDist.z)),0.0) + length(max(vDist,0.0));

	return fDistance;	
}
float g_PaperRotSin = sin(-0.1);
float g_PaperRotCos = cos(-0.1);

vec2 GetDistanceShadowCasters( const in vec3 vPos )
{
	vec2 vResult = vec2(1000.0, -1.0);

	vec3 vCandlestickLocalPos = vPos - vCandlestickPos;	

	vec2 vCandlestick = GetDistanceCandlestick(vCandlestickLocalPos);
	if(vCandlestick.x < vResult.x)
	{
		vResult = vCandlestick;
	}
	
	vec2 vSphere = GetDistanceSphere(vPos);
	if(vSphere.x < vResult.x)
	{
		vResult = vSphere;
	}
	
	
	vec3 vPapereLocalPos = RotateY(vPos, g_PaperRotSin, g_PaperRotCos);
	
	#ifdef ENABLE_MIRROR
	
	vec3 vMirrorLocalPos = vPos - vec3(0.0, 0.0, 3.5);
	vMirrorLocalPos = RotateY(vMirrorLocalPos, g_MirrorRotSin, g_MirrorRotCos);
	
	vec2 vMirrorStand = GetDistanceMirrorStand(vMirrorLocalPos);
	if(vMirrorStand.x < vResult.x)
	{
		vResult = vMirrorStand;
	}
	
	
	vec3 vMirrorPaneLocalPos = vMirrorLocalPos - vec3(0.0, 2.7, 0.0);	
	vMirrorPaneLocalPos = RotateX(vMirrorPaneLocalPos, g_MirrorTiltSin, g_MirrorTiltCos);
	
	vec2 vMirror = GetDistanceMirror(vMirrorPaneLocalPos);
	if(vMirror.x < vResult.x)
	{
		vResult = vMirror;
	}
	#endif	

	return vResult;
}


float RaycastShadow( const in vec3 vOrigin, const in vec3 vDir, const in float k )
{
	float fShadow = 1.0;
	float t = 0.01;
	float fDelta = 1.0 / float(kShadowIter);
	for(int i=0; i<kShadowIter; i++)
	{
		float d = GetDistanceShadowCasters(vOrigin + vDir * t).x;
		
		fShadow = min( fShadow, k * d / t );
		
		t = t + fDelta;
	}
	
	return clamp(fShadow, 0.0, 1.0);
}


void TraceRay( inout vec3 vOrigin, inout vec3 vDir, out vec3 vColour, inout vec3 vRemaining )
{	
    vec3 vLightPos = GetLightPos();
	vec2 vHit = Raycast(vOrigin, vDir);
	
	vec3 vHitPos = vOrigin + vDir * vHit.x;
	vec3 vHitNormal = GetSceneNormal(vHitPos);
	
	vec3 vAlbedo = vec3(0.0);
	vec3 vSpecR0 = vec3(0.0);
	float fSmoothness = 0.0;

	vec3 vEmissive = vec3(0.0);
	vec3 vGlow = GetFlameIntensity(vOrigin, vDir, vHit.x);

	if(vHit.x > 20.0)
	{
		vColour = vGlow + GetFlareIntensity(vOrigin, vDir);
		vColour *= vRemaining;
		vOrigin = vHitPos;
	}
	else
	{
		float fAmbientOcclusion = GetAmbientOcclusion(vHitPos, vHitNormal);
	
		if(vHit.y <= kMaterialWax)
		{
			vAlbedo = vec3(0.9);
			vSpecR0 = vec3(0.01);
			
			float fDistanceThroughWax = GetDistanceWaxTop(vHitPos - vCandlestickPos - GetFlameWander() * 0.025);
			vEmissive = vFlameLightColour * (exp(fWaxExtinction * fDistanceThroughWax));
		}
		else
		if(vHit.y <= kMaterialWick)			
		{
			vAlbedo = vec3(0.01);
		}
		else
		if(vHit.y <= kMaterialChrome)			
		{
			vAlbedo = vec3(0.3);
			vSpecR0 = vec3(0.85);
			fSmoothness = 1.0;
		}
		else
		if(vHit.y <= kMaterialPaper)			
		{
			vAlbedo = vec3(0.9);
			vSpecR0 = vec3(0.0);
			fSmoothness = 0.0;
		}

				
		vec3 vDiffuseLight = SampleDiffuse(vHitNormal) * fAmbientOcclusion;
			
		vec3 vToLight = vLightPos - vHitPos;
		float fDistToLight = length(vToLight);
		vec3 vNormToLight = normalize(vToLight);
		
		float fDot = clamp(dot(vNormToLight, vHitNormal), 0.0, 1.0);
		
		float fShadow = RaycastShadow(vHitPos, vToLight, 1.0);
	
		// Fake shadow from candle
		fShadow *= smoothstep(0.4, 0.6, length(vToLight.xz) / max(vToLight.y, 0.01));

		fShadow = mix(0.1 + 0.15 * fAmbientOcclusion, 1.0, fShadow);
	
		vec3 vLightIntensity = vFlameLightColour * fDot * fShadow;
		vLightIntensity /= fDistToLight * fDistToLight;
		vDiffuseLight += vLightIntensity;
		
		vec3 vReflectDir = normalize(reflect(vDir, vHitNormal));
		
		vec3 vHalf = normalize(vReflectDir + -vDir);
		float fFresnelDot = clamp(1.0 - dot(vHalf, -vDir), 0.0, 1.0);	
		float fFresnel = pow(fFresnelDot, 5.0);
				
		vec3 vReflectFraction = vSpecR0 + (vec3(1.0) - vSpecR0) * fFresnel * fSmoothness;
	
		vColour = (vDiffuseLight * vAlbedo + vEmissive) * (vec3(1.0) - vReflectFraction);
		vColour += GetFlareIntensity(vOrigin, vDir);
		vColour += vGlow;
		vColour *= vRemaining;
		vRemaining *= vReflectFraction;
		vOrigin = vHitPos;
		vDir = vReflectDir;
	}
	
}


vec3 Tonemap( vec3 x )
{
    float a = 0.010;
    float b = 0.132;
    float c = 0.010;
    float d = 0.163;
    float e = 0.101;

    return ( x * ( a * x + b ) ) / ( x * ( c * x + d ) + e );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // transform screen coordinates
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;
    
    // transform mouse coordinates
	vec2 mouse = iMouse.xy / iResolution.xy * 2. - 1.;
    mouse.x *= iResolution.x / iResolution.y;
    mouse *= 2.;
    
    // set up camera position
    vec3 ro =  vec3(0, 0, -2);
    vec3 rd = normalize(vec3(uv, FOV));
    
    // light is relative to the camera
    vec3 light = ro + vec3(-.6, .1, -.1);
    
    vec2 rot = vec2(0);
    if (iMouse.z > 0.) {
    	// rotate the scene using the mouse
        rot = -mouse;
    } else {
        // otherwise rotate constantly as time passes
        
        rot = vec2(-iTime * SPEED * PI + .3, .5);
        //rot = -mouse;
    }
    
    tRotate(rd.yz, rot.y);
    tRotate(rd.xz, rot.x);
    tRotate(light.yz, rot.y);
    tRotate(light.xz, rot.x);
    tRotate(ro.yz, rot.y);
    tRotate(ro.xz, rot.x);
    
    // march
    float steps, dist = trace(ro, rd, RENDER_DIST, steps); 
    
    // calculate hit point coordinates
    vec3 p = ro + rd * dist;
    
    // calculate normal
    vec3 normal = getNormal(p);
    normal = doBumpMap( p, normal, .01);
    
    // light direction
    vec3 l = normalize(light - p);
    
    // calculate shadow
    vec3 shadowStart = p + normal * EPS * 10.;
    float shadowDistance = distance(shadowStart,light);
    float shadow = softShadow(shadowStart, l, shadowDistance);
    
    // ambient light
    float ambient = .25;
    
    // diffuse light
    float diffuse = max(0., dot(l, normal));
    
    // specular light
    float specular = pow(max(0., dot(reflect(-l, normal), -rd)), 4.);
    
    // "ambient occlusion"
    float ao = calculateAO(p, normal) * .5 + .5;
    
    // add this all up
	fragColor.rgb = (ao * _texture(p)) * (ambient * (2. - LIGHT_COLOR) * .5 + (specular + diffuse) * shadow * LIGHT_COLOR);
    
    // fog
    vec4 fogColor = vec4(vec3(0,.01,.014) * (2. - length(uv)), 1.);
    fragColor = mix(fragColor, fogColor, saturate(dist * dist * .05));
    
    // if we passed the cake, then apply a dark glow, this makes the cake pop out
    if (length(p) > .6) 
        fragColor *= saturate(1. - sqrt(steps / float(MAX_STEPS)) * 1.5);
    
    vec3 outsideCake = fragColor.rgb;
    
	vec3 vRemaining = vec3(1.0);
    vec3 vColour = vec3(0.0);
	TraceRay(ro, rd, vColour, vRemaining);
    
    vColour = pow(vColour, vec3(2.2));
	fragColor.rgb = mix(fragColor.rgb, vColour, 0.1);
    
    vColour = Tonemap(vColour);
    
    //fragColor.rgb = Tonemap(fragColor.rgb);
    // gamma correction
    fragColor = pow(fragColor, vec4(1. / 2.2));
    		
    
    //
    vec2 V = fragCoord.xy / iResolution.xy;
    float edgeEffect = pow( 32.0 * V.y * V.x * (1.0 - V.y) * (1.0 - V.x), 0.15 );
    
    if (length(outsideCake.rgb) < 0.2 || edgeEffect < 0.1) {
    	fragColor = mix(texture(iChannel0, rd), fragColor, length(fragColor) * 0.5);     
    }
    fragColor = fragColor * edgeEffect;
}

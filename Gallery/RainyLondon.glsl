// Rainy London
// By David Hoskins.

// Uses parts of 'Reprojection' by P_Malin for modelling.
// https://www.shadertoy.com/view/XdlGzH


#define NUM_LIGHTS 11

vec4 lightArray[NUM_LIGHTS];
vec3 lightColours[NUM_LIGHTS];

const float kPI = 3.141592654;

struct C_Ray
{
    vec3 vOrigin;
    vec3 vDir;
};
C_Ray ray;

vec2 coord;

//----------------------------------------------------------------------------------------
float sMin( float a, float b )
{
    float k = 1.5;
	float h = clamp(0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.-h);
}

//-----------------------------------------------------------------------------------------
vec3 RotateY( const in vec3 vPos, const in float ang)
{
	float s = sin(ang);
	float c = cos(ang);
	vec3 vResult = vec3( c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);

	return vResult;
}

//-----------------------------------------------------------------------------------------
float Hash(in vec2 p)
{
	return fract(sin(dot(p, vec2(27.16898, 28.90563))) * 44549.5473453);
}

//-----------------------------------------------------------------------------------------
float Noise(in vec2 p)
{
	vec2 f;
	f = fract(p);			// Separate integer from fractional
    p = floor(p);
    f = f*f*(3.0-2.0*f);	// Cosine interpolation approximation
    float res = mix(mix(Hash(p),
						Hash(p + vec2(1.0, 0.0)), f.x),
					mix(Hash(p + vec2(0.0, 1.0)),
						Hash(p + vec2(1.0, 1.0)), f.x), f.y);
    return res;
}

//----------------------------------------------------------------------------------------
float RoundBox( vec3 p, vec3 b)
{
	return length(max(abs(p)-b,0.0))-.5;
}

//-----------------------------------------------------------------------------------------
float GetDistanceBox(const in vec3 vPos, const in vec3 vDimension)
{
	return length(max(abs(vPos)-vDimension,0.0));
}

//-----------------------------------------------------------------------------------------
float MapToScene( const in vec3 vPos )
{   
	float fResult = 1000.0;
	
	float fFloorDist = vPos.y + 3.2;	
	fResult = min(fResult, fFloorDist);
	
	vec3 vBuilding1Pos = vec3(68.8, 0.0, 55.0);
	const float fBuilding1Radius = 58.5;
	vec3 vBuilding1Offset = vBuilding1Pos - vPos;
	float fBuilding1Dist = length(vBuilding1Offset.xz) - fBuilding1Radius;
	
	fResult = min(fResult, fBuilding1Dist);
	
	vec3 vBuilding2Pos = vec3(60.0, 0.0, 55.0);
	const float fBuilding2Radius = 100.0;
	vec3 vBuilding2Offset = vBuilding2Pos - vPos;
	float fBuilding2Dist = length(vBuilding2Offset.xz) - fBuilding2Radius;
	fBuilding2Dist = max(vBuilding2Offset.z - 16.0, -fBuilding2Dist); // back only
	
	fResult = min(fResult, fBuilding2Dist);

	vec3 vBollardDomain = vPos;
	vBollardDomain -= vec3(1.0, -2.0, 14.2);
	//vBollardDomain = RotateY(vBollardDomain, 0.6);
	float fBollardDist = RoundBox(vBollardDomain, vec3(-0.2, .75, -.2));
		
	fResult = min(fResult, fBollardDist);
	
	vec3 vFenceDomain = vPos;
	vFenceDomain -= vec3(-5.5, -2.5, 7.0);
	vFenceDomain = RotateY(vFenceDomain, 1.5);
	float fFenceDist = GetDistanceBox(vFenceDomain, vec3(0.5, 1.2, 0.2));
		
	fResult = min(fResult, fFenceDist);
	
	vec3 vCabDomain = vPos;
	vCabDomain -= vec3(-1.4, -1.55,29.5);
	vCabDomain = RotateY(vCabDomain, 0.1);
	float fCabDist = RoundBox(vCabDomain+vec3(0.0, .85, 0.0), vec3(.8, .54, 2.5));
	fResult = min(fResult, fCabDist);
	fCabDist = RoundBox(vCabDomain, vec3(.6, 1.2, 1.2));
	fResult = sMin(fResult, fCabDist);

	vec3 vBusDomain = vPos;
	vBusDomain -= vec3(-15., 0.0, 29.5);
	vBusDomain = RotateY(vBusDomain, 0.35);
	float fBusDist = RoundBox(vBusDomain, vec3(.55, 1.8, 4.0));
		
	fResult = min(fResult, fBusDist);
		
	vec3 vBusShelter = vPos;
	vBusShelter -= vec3(7.5, -2.0, 30.0);
	vBusShelter = RotateY(vBusShelter, 0.3);
	float fBusShelterDist = RoundBox(vBusShelter, vec3(.725, 5.3, 1.7));
		
	fResult = min(fResult, fBusShelterDist);
	
	vec3 vRailings = vPos;
	vRailings -= vec3(15.0, -.55, 18.0);
	vRailings = RotateY(vRailings, 0.3);
	float fRailings = RoundBox(vRailings, vec3(.0, -.1, 7.5));
		
	fResult = min(fResult, fRailings);
	
	vec3 vCentralPavement = vPos;
	vCentralPavement -= vec3(5.3, -3.0, 8.0);
	vCentralPavement = RotateY(vCentralPavement, 0.6);
	float fCentralPavementDist = GetDistanceBox(vCentralPavement, vec3(0.8, 0.2, 8.0));
		
	fResult = min(fResult, fCentralPavementDist);
	
	return fResult;
}

//----------------------------------------------------------------------------------------
float Raymarch( const in C_Ray ray )
{        
    float fDistance = .1;
    bool hit = false;
    for(int i=0;i < 50; i++)
    {
			float fSceneDist = MapToScene( ray.vOrigin + ray.vDir * fDistance );
			if(fSceneDist <= 0.01 || fDistance >= 150.0)
			{
				hit = true;
                break;
			} 

        	fDistance = fDistance + fSceneDist;
	}
	
	return fDistance;
}

//----------------------------------------------------------------------------------------
vec3 Normal( in vec3 pos )
{
	vec2 eps = vec2( 0.01, 0.0);
	vec3 nor = vec3(
	    MapToScene(pos+eps.xyy) - MapToScene(pos-eps.xyy),
	    MapToScene(pos+eps.yxy) - MapToScene(pos-eps.yxy),
	    MapToScene(pos+eps.yyx) - MapToScene(pos-eps.yyx) );
	return normalize(nor);
}

//----------------------------------------------------------------------------------------
void GetCameraRay( const in vec3 vPos, const in vec3 vForwards, const in vec3 vWorldUp, out C_Ray ray)
{
    vec2 vUV = coord.xy;
    vec2 vViewCoord = vUV * 2.0 - 1.0;	

	vViewCoord.y *= -1.0;

    ray.vOrigin = vPos;

    vec3 vRight = normalize(cross(vWorldUp, vForwards));
    vec3 vUp = cross(vRight, vForwards);
        
    ray.vDir = normalize( vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards);    
}

//----------------------------------------------------------------------------------------
void GetCameraRayLookat( const in vec3 vPos, const in vec3 vInterest, out C_Ray ray)
{
	vec3 vForwards = normalize(vInterest - vPos);
	vec3 vUp = vec3(0.0, 1.0, 0.0);

	GetCameraRay(vPos, vForwards, vUp, ray);
}

//----------------------------------------------------------------------------------------
vec3 Render(vec3 vCamPos, vec3 vHitPos, out vec3 normal)
{
	normal = Normal(vHitPos);
		
	float fProjectionDist = .5;
	vec2 vUV = vec2(((vHitPos.xy) * fProjectionDist) / vHitPos.z);
	
	vec2 vProjectionOffset = vec2(-0.5, -0.62);
	vUV += vProjectionOffset;
		
	vUV.y = 1.0 - vUV.y;
		
	vec3 col = vec3(0.0);
	float dis = pow(max(vHitPos.z-vCamPos.z-20.0, 0.0), .5) * .4;

	for (int y = 0; y < 3; y++)
	{
		for (int x = 0; x < 3; x++)
		{
			col += texture(iChannel0, vUV + (vec2(x, y) * dis / iChannelResolution[3].xy)).rgb;
		}
	}
	col /= 9.0;
	
//	col = texture(iChannel0, vUV).rgb;
	
	col *= 3.0 / pow(vHitPos.z, .7);

	vec3 lightCol = vec3(1.0);
	for (int i = 0; i < NUM_LIGHTS; i++)
	{
		col += pow(max(dot(normalize(lightArray[i].xyz-ray.vOrigin), ray.vDir), 0.0), lightArray[i].w)*.7
						* lightColours[i];
		vec3 lightDir = lightArray[i].xyz-vHitPos;
		dis = (dot(lightDir, lightDir));
		lightDir /= pow(dis, .3);
		col += lightColours[i] * max(dot(normal, lightDir), 0.0) * 2.5/dis;

	}
	return min(col, 1.0);
}

//----------------------------------------------------------------------------------------
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Yes, that's right, this is done for EVERY pixel! Haha - *gulp*
	// X, Y, Z, POWER...
	lightArray[0]  = vec4(10.5, 10.5, 37., 130.);		// Right street lamp
	lightArray[1]  = vec4(-30.0, 11.5, 40., 150.);		// Near left Street lamp
	lightArray[2]  = vec4(15.1, 2.5, 20., 100.);		// Large right window
	lightArray[3]  = vec4(-12.1, 10.3, 70., 350.);		// Distant street light
	lightArray[4]  = vec4(.95, -1.75, 13.5, 239.);		// Road light
	lightArray[5]  = vec4(-30., 4.7, 31.5, 250.);		// Underground sign
	lightArray[6]  = vec4(-1.7, -1.8, 24.8, 15450.);	// Taxi left light
	lightArray[7]  = vec4(-.3, -1.8, 25., 15450.);		// Taxi right light
	lightArray[8]  = vec4(-14.0, -1.15, 24.8, 2500.0);	// Bus red left
	lightArray[9]  = vec4(-12.8, -1.15, 25.3, 2500.0);	// Bus red right
	lightArray[10] = vec4(-18.9, .5, 55.5, 100.0);		// Bus headlights
	
	// R, G, B...
	lightColours[0]  = vec3(.85);			// Right street lamp
	lightColours[1]  = vec3(1.3);			// Near left Street lamp
	lightColours[2]  = vec3(.8, .8, .5);	// Large right window
	lightColours[3]  = vec3(1.0);			// Distant street light
	lightColours[4]  = vec3(.7, .5, .1);	// Road light
	lightColours[5]  = vec3(0.5, .8, 1.0);	// Underground sign
	lightColours[6]  = vec3(.5, .6, .6);	// Taxi left light
	lightColours[7]  = vec3(.5, .6, .6);	// Taxi right light
	lightColours[8]  = vec3(.12, 0.0, 0.0);	// Bas red left
	lightColours[9]  = vec3(.12, 0.0, 0.0);	// Bus read right
	lightColours[10] = vec3(.5, .5, .4);	// Bus headlights
	
    vec3 vCameraPos = vec3(0.0, 0.0, 9.8);
	float ang = iTime * .3 + 3.4;
	float head = pow(abs(sin(ang*8.0)), 1.5) * .15;
	vCameraPos += vec3(cos(ang) * 2.5, head,  sin(ang) * 8.5);
    coord = fragCoord.xy / iResolution.xy;
	
	vec3 vCameraIntrest = vec3(-1.0, head, 25.0);
	GetCameraRayLookat( vCameraPos, vCameraIntrest, ray);
	vec3 originalRayDir = ray.vDir;

    float fHitDist = Raymarch(ray);
	vec3 vHitPos = ray.vOrigin + ray.vDir * fHitDist;
	//vec3 vHitPos = vCameraPos + ray.vDir * fHitDist;
	vec3 normal;
	vec3 col = Render(ray.vOrigin, vHitPos, normal);
	
	if (normal.y > .3)
	{
		ray.vOrigin = vHitPos;
		ray.vDir = reflect(ray.vDir, normal);
		float animate = fract(iTime * 37.3918754) * 157.0;
		ray.vDir += vec3(Noise(vHitPos.xz * 37.0 + animate)-.5, 0.0,
						 Noise(vHitPos.xz * 37.0 + animate)-.5) * .1;
		ray.vDir = normalize(ray.vDir);
		
	    fHitDist = Raymarch(ray);
		
		vec3 refPos = ray.vOrigin + ray.vDir * fHitDist;
		float n = (Noise(vHitPos.xz*4.0) + Noise(vHitPos.xz)) * .5;
		n = pow(n, .3) / ( 1.5 + fHitDist * .01);
		float amount = smoothstep(0.3, 1.0, max(normal.y, 0.0));
		col = mix(col, Render(ray.vOrigin, refPos, normal), n * amount);
	}
	
	// Twelve layers of rain sheets...
	vec2 q = fragCoord.xy/iResolution.xy;
	float dis = 1.;
	for (int i = 0; i < 12; i++)
	{
		vec3 plane = vCameraPos + originalRayDir * dis;
		//plane.z -= (texture(iChannel3, q*iTime).x*3.5);
		if (plane.z < vHitPos.z)
		{
			float f = pow(dis, .45)+.25;

			vec2 st =  f * (q * vec2(1.5, .05)+vec2(-iTime*.1+q.y*.5, iTime*.12));
			f = (texture(iChannel3, st * .5, -99.0).x + texture(iChannel3, st*.284, -99.0).y);
			f = clamp(pow(abs(f)*.5, 29.0) * 140.0, 0.00, q.y*.4+.05);

			vec3 bri = vec3(.25);
			for (int t = 0; t < NUM_LIGHTS; t++)
			{
				vec3 v3 = lightArray[t].xyz - plane.xyz;
				float l = dot(v3, v3);
				l = max(3.0-(l*l * .02), 0.0);
				bri += l * lightColours[t];
				
			}
			col += bri*f;
		}
		dis += 3.5;
	}
	col = clamp(col, 0.0, 1.0);
			
	if(iMouse.z > 0.0)
	{
		vec3 vGrid =  step(fract(vHitPos / 2.0), vec3(0.9));
		col = mix(vec3(1.0, 1.0, 1.0), col, vGrid);
	}
	col = mix(texture(iChannel0, vec2(q.x, 1.0-q.y)).xyz, col, smoothstep(2.25, 4.0, iTime));
	//col = pow(col, vec3(1.1));
	
	fragColor = vec4(col, 1.0);
}
	
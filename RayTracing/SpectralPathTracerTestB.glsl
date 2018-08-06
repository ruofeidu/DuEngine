
#define ABSORPTION 		1
#define SCATTERING 		1
#define TRANSPARENCY 	1
#define BLOOM 			1
#define BIG_BLOOM 		1
#define DEPTH_OF_FIELD 	1

#define SPECTRAL 		1
#define RGB 			0

#define LIGHT_BULB_SCENE	0
#define PIPELINE_SCENE 0
#define GEARS_SCENE 0
#define TEST_TUBES_SCENE 0

#define MAX_PATH_LENGTH 50.0


struct WaveInfo
{
#if SPECTRAL    
    float wavelength;
    vec3 rgb;
#endif

#if RGB    
    int unused;
#endif    
};
    
struct PathColor
{
#if SPECTRAL    
    float fIntensity;
#endif    

#if RGB
	vec3 vRGB;
#endif    
};
    
PathColor PathColor_Zero()
{
#if SPECTRAL    
    return PathColor( 0.0 );
#endif    
    
#if RGB
	return PathColor( vec3(0) );
#endif    
    
}

PathColor PathColor_One()
{
#if SPECTRAL    
    return PathColor( 1.0 );
#endif    
#if RGB
	return PathColor( vec3(1) );
#endif    
}

float FFalloff( float f1, float f2, float range )
{
    return smoothstep( range, 0.0, abs( f1 - f2 ) );
}

PathColor ColorScale_sRGB( WaveInfo wave, vec3 sRGB )
{
#if SPECTRAL    
    
#if 1
    vec3 sRGBRanges = vec3( 40, 50, 70.0 );
	vec3 sRGBApproxWavelengths = vec3( 610.0, 549.0, 468.0 );
    float x = FFalloff( wave.wavelength, sRGBApproxWavelengths.x, sRGBRanges.x) * sRGB.x
        + FFalloff( wave.wavelength, sRGBApproxWavelengths.y, sRGBRanges.y) * sRGB.y
        + FFalloff( wave.wavelength, sRGBApproxWavelengths.z, sRGBRanges.z) * sRGB.z;
	return  PathColor( x * 1.5 ); 
#else    
    return  PathColor( dot( sRGB, wave.rgb ));
#endif    
    
#endif
    
    
#if RGB
    return PathColor( sRGB );
#endif
}

PathColor ColorScale( PathColor a, PathColor b )
{
#if SPECTRAL    
    return PathColor( a.fIntensity * b.fIntensity );
#endif    
#if RGB
    return PathColor( a.vRGB * b.vRGB );
#endif    
}

PathColor ColorScale( PathColor a, float s )
{
#if SPECTRAL    
    return PathColor( a.fIntensity * s );
#endif    
#if RGB
    return PathColor( a.vRGB * s );
#endif    
}

PathColor ColorAdd( PathColor a, PathColor b )
{
#if SPECTRAL    
    return PathColor( a.fIntensity + b.fIntensity );
#endif    
#if RGB
    return PathColor( a.vRGB + b.vRGB );
#endif    
}

PathColor ColorSub( PathColor a, PathColor b )
{
#if SPECTRAL    
    return PathColor( a.fIntensity - b.fIntensity );
#endif    
#if RGB
    return PathColor( a.vRGB - b.vRGB );
#endif    
}

float ColorIntensity( PathColor a )
{
#if SPECTRAL    
    return a.fIntensity;
#endif    
#if RGB
    return dot( a.vRGB, vec3( 1.0 / 3.0 ) );    
#endif        
}


// Bradford E to D65 ( http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html )
const mat3 cat = mat3(
    0.9531874, -0.0265906,  0.0238731,
-0.0382467,  1.0288406,  0.0094060,
 0.0026068, -0.0030332,  1.0892565);


vec3 To_sRGB( WaveInfo wave, PathColor c )
{
#if SPECTRAL      
            
    return c.fIntensity * wave.rgb * cat;
#endif        

#if RGB
	return c.vRGB;
#endif      
}

float SpecParamFromGloss( float gloss )
{
    float PB_GGX_MAX_SPEC_POWER=32.0;
	float exponent = pow( 2.0f, gloss * PB_GGX_MAX_SPEC_POWER );
	return 2.0f  / ( 2.0f + exponent ); // matches alpha^2 for GGX physically-based shader
}




float GGX_D( float NdotH , float alpha2 )
{
	float denom = ( NdotH * NdotH ) * ( alpha2 - 1.0f ) + 1.0f;
	return alpha2 / ( denom * denom );	
}


float GGX_PDF( const float NdotH, const in float alpha2 )
{
	//const float LdotH = NdotH;
	//return GGX_D( NdotH, alpha2 ) * NdotH  / (4.0f * PI * LdotH);

	// simplified as NdotH == LdotH
	return GGX_D( NdotH, alpha2 ) / (4.0f * PI);
}

// Z is preserved, Y may be modified to make matrix orthogonal
mat3 OrthoNormalMatrixFromZY( vec3 zDirIn, vec3 yHintDir )
{
	vec3 xDir = normalize( cross( zDirIn, yHintDir ) );
	vec3 yDir = normalize( cross( xDir, zDirIn ) );
	vec3 zDir = normalize( zDirIn );

	mat3 result = mat3( xDir, yDir, zDir );
		
	return result;
}


mat3 OrthoNormalMatrixFromZ( vec3 zDir )
{
	if ( abs( zDir.y ) < 0.999f )
	{
		vec3 yAxis = vec3( 0.0f, 1.0f, 0.0f );
		return OrthoNormalMatrixFromZY( zDir, yAxis );
	}
	else
	{
		vec3 xAxis = vec3( 1.0f, 0.0f, 0.0f );
		return OrthoNormalMatrixFromZY( zDir, xAxis );
	}
}

vec3 SphericalToCartesianDirection( vec2 spherical )
{
	float theta = spherical.x;
	float phi = spherical.y;
	float sinTheta = sin( theta );

	return vec3( cos( phi ) * sinTheta, sin( phi ) * sinTheta, cos( theta ) );
}

// Transform from a uniform 2D 0->1 sample space to a spherical co-ordiante with a probability distribution that represents important GGX half-angle vector locations
vec2 ImportanceSampleGGXTransform( const vec2 uniformSamplePos, const in float alpha2 )
{
	// [Karis2013]  Real Shading in Unreal Engine 4
	// http://blog.tobias-franke.eu/2014/03/30/notes_on_importance_sampling.html

	float theta = acos( sqrt( (1.0f - uniformSamplePos.y) /
							( (alpha2 - 1.0f) * uniformSamplePos.y + 1.0f )
							) );

	float phi = 2.0f * PI * uniformSamplePos.x;

	return vec2( theta, phi );
}

// Transform from a uniform 2D 0->1 sample space to a direction vector with a probability distribution that represents important GGX half-angle vector locations
vec3 ImportanceSampleGGX( vec2 uniformSamplePos, vec3 N, float alpha2 )
{
	vec2 sphereSamplePos = ImportanceSampleGGXTransform( uniformSamplePos, alpha2 );

	vec3 specSpaceH = SphericalToCartesianDirection( sphereSamplePos );
	
	mat3 specToCubeMat = OrthoNormalMatrixFromZ( N );

	return specToCubeMat * specSpaceH;
}

vec3 PointOnHemisphereCosine( inout uint seed, vec3 n )
{
    // from smallpt: http://www.kevinbeason.com/smallpt/

    vec2 uv = FRand2( seed );

    float r1 = 2.0f * PI * uv.x;
    float r2 = uv.y;
    float r2s = sqrt(r2);

    vec3 w = n;
    vec3 u;
    if (abs(w.x) > 0.1f)
        u = cross(vec3( 0.0f, 1.0f, 0.0f ), w);
    else
        u = cross(vec3( 1.0f, 0.0f, 0.0f ), w);

    u = normalize(u);
    vec3 v = cross(w, u);
    vec3 d = (u*cos(r1)*r2s + v*sin(r1)*r2s + w*sqrt(1.0 - r2));
    d = normalize(d);

    return d;
}


vec3 PointOnSphereUniform( inout uint seed )
{
    vec2 uv = FRand2( seed );
    
    float theta= acos( 2.0 * uv.y - 1.0f );
    float phi = 2.0f * PI * uv.x;
    
    return SphericalToCartesianDirection( vec2( theta, phi ) );    
}


vec3 PointOnHemisphereUniform( inout uint seed, vec3 n )
{
    vec3 dir = PointOnSphereUniform( seed );
    if ( dot( dir, n ) < 0.0 )
    {
        dir = -dir;
    }
    return dir;
}



struct SceneResult
{
	float fDist;
	int iObjectId;
    vec3 vUVW;
};

SceneResult SceneResult_Default()
{
    return SceneResult( MAX_PATH_LENGTH, -1, vec3(0) );
}
    
SceneResult SceneResult_Union( SceneResult a, SceneResult b )
{
    if ( b.fDist < a.fDist )
    {
        return b;
    }
    return a;
}
    
SceneResult SceneResult_Subtract( SceneResult a, SceneResult b )
{
    b.fDist = -b.fDist;
    if ( a.fDist < b.fDist )
    {
        return b;
    }
    
    return a;
}

void SceneResult_Combine( inout SceneResult inside, inout SceneResult outside, SceneResult newObject, int insideObj )
{
    if ( newObject.iObjectId == insideObj )
    {
	    outside = SceneResult_Subtract( outside, newObject );
    }
    else
    {
	    inside = SceneResult_Union( inside, newObject );
    }    
}

SceneResult Scene_GetDistance( vec3 vPos, int insideObjId );    

vec3 Scene_GetNormal( const in vec3 vPos, int insideObjId )
{
    const float fDelta = 0.0001;
    vec2 e = vec2( -1, 1 );
    
    vec3 vNormal = 
        Scene_GetDistance( e.yxx * fDelta + vPos, insideObjId ).fDist * e.yxx + 
        Scene_GetDistance( e.xxy * fDelta + vPos, insideObjId ).fDist * e.xxy + 
        Scene_GetDistance( e.xyx * fDelta + vPos, insideObjId ).fDist * e.xyx + 
        Scene_GetDistance( e.yyy * fDelta + vPos, insideObjId ).fDist * e.yyy;
    
    return normalize( vNormal );
}   

SceneResult Scene_Trace( const in vec3 vRayOrigin, const in vec3 vRayDir, float minDist, float maxDist, int insideObjId )
{	
    SceneResult result;
    result.fDist = 0.0;
    result.vUVW = vec3(0.0);
    result.iObjectId = -1;
    
	float t = minDist;
	const int kRaymarchMaxIter = 128;
	for(int i=0; i<NO_UNROLL(kRaymarchMaxIter); i++)
	{		
        float epsilon = 0.0001 * t;
		result = Scene_GetDistance( vRayOrigin + vRayDir * t, insideObjId );
        if ( abs(result.fDist) < epsilon )
		{
			break;
		}
                        
        if ( t > maxDist )
        {
            result.iObjectId = -1;
	        t = maxDist;
            break;
        }       
        
        if ( result.fDist > 1.0 )
        {
            result.iObjectId = -1;            
        }    
        
        t += result.fDist;        
	}
    
    result.fDist = t;

    return result;
}    

struct SurfaceInfo
{
    vec3 vPos;
    vec3 vNormal;
    vec3 vBumpNormal;    
    vec3 vAlbedo;
    PathColor cR0;
    float fGloss;
    PathColor cEmissive;
    float fTransparency;
};
    
SurfaceInfo Scene_GetSurfaceInfo( const in vec3 vRayOrigin,  const in vec3 vRayDir, WaveInfo wave, SceneResult traceResult, int insideObjectId );

PathColor Light_GetFresnel( vec3 vView, vec3 vNormal, PathColor cR0, float fGloss )
{
    float NdotV = max( 0.0, dot( vView, vNormal ) );
    
    float f = pow( 1.0 - NdotV, 5.0 ) * pow( fGloss, 20.0 );

    return ColorAdd( cR0, ColorScale( ColorSub( PathColor_One(), cR0), f ) );   
}

int
    MAT_COLORED_GLASS = 1,
    MAT_COLORED_GLASS_2 = 2,
    MAT_COLORLESS_GLASS = 3,
    MAT_FROSTED_GLASS = 4,
    MAT_TEXTURED_FLOOR = 5,
    MAT_EMISSIVE_LIGHT = 6,
    MAT_CHROME = 7,
    MAT_GOLD = 8,
    MAT_WHITE_GLOSS = 9,
    MAT_WHITE_MATT = 10,
    MAT_WINE = 11,
    MAT_FILAMENT = 12,
    MAT_PENDANT = 13,
    MAT_PIPE = 14,
    MAT_GRASS = 15,
    MAT_GEAR = 16,
    MAT_STAND = 17;

float DistanceCapsule( vec3 vPos, vec3 vP0, vec3 vP1, float r )
{
	vec3 pa = vPos - vP0;
	vec3 ba = vP1 - vP0;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	
	return length( pa - ba*h ) - r;    
}

float GetDistanceMug( const in vec3 vPos )
{
	float fDistCylinderOutside = length(vPos.xz) - 1.0;
	float fDistCylinderInterior = length(vPos.xz) - 0.9;
	float fTop = vPos.y - 1.0;
       
	float r1 = 0.6;
	float r2 = 0.15;
	vec2 q = vec2(length(vPos.xy + vec2(1.2, -0.1))-r1,vPos.z);
	float fDistHandle = length(q)-r2;
       
	float fDistMug = max(max(min(fDistCylinderOutside, fDistHandle), fTop), -fDistCylinderInterior);
	return fDistMug;
}

float GetDistanceWine( vec3 vPos )
{
    vec3 vLocalPos = vPos;
    vLocalPos.y -= 2.0;
    
    vec2 vPos2 = vec2(length(vLocalPos.xz), vLocalPos.y);
    
    vec2 vSphOrigin = vec2(0);
    vec2 vSphPos = vPos2 - vSphOrigin;   
    
    float fBowlDistance = length( vSphPos ) -  0.6 + 0.01;
    
    vec3 vWaterNormal = vec3(0,1,0);
    
    float fTime = 0.0;
    
    vWaterNormal.x = sin( fTime * 5.0) * 0.01;
    vWaterNormal.z = cos( fTime * 5.0) * 0.01;
    
    vWaterNormal = normalize( vWaterNormal );
    float fWaterLevel = dot(vLocalPos, vWaterNormal) - 0.1;
        
    return max( fBowlDistance, fWaterLevel );
}

float GetDistanceWineGlass( vec3 vPos )
{
    vec2 vPos2 = vec2(length(vPos.xz), vPos.y);
    
    vec2 vSphOrigin = vec2(0,2.0);
    vec2 vSphPos = vPos2 - vSphOrigin;
    
    vec2 vClosest = vSphPos;
    
    if ( vClosest.y > 0.3 ) vClosest.y = 0.3;
    vClosest = normalize(vClosest) * 0.6;
    
    float fBowlDistance = distance( vClosest, vSphPos ) - 0.015;
    
    vec2 vStemClosest = vPos2;
    vStemClosest.x = 0.0;    
    vStemClosest.y = clamp(vStemClosest.y, 0.0, 1.35);
    
    float fStemRadius = vStemClosest.y - 0.5;
    fStemRadius = fStemRadius * fStemRadius * 0.02 + 0.03;
    
    float fStemDistance = distance( vPos2, vStemClosest ) - fStemRadius;
        
    vec2 norm = normalize( vec2( 0.4, 1.0 ) );
    vec2 vBaseClosest = vPos2;
    float fBaseDistance = dot( vPos2 - vec2(0.0, 0.025), norm ) - 0.2;
    fBaseDistance = max( fBaseDistance, vPos2.x - 0.5 ); 

    float fDistance = SmoothMin(fBowlDistance, fStemDistance, 0.2);
    fDistance = SmoothMin(fDistance, fBaseDistance, 0.2);
    
    fDistance = max( fDistance, vSphPos.y - 0.5 );
        
    return fDistance;
}

// http://www.iquilezles.org/www/articles/smin/smin.htm
// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}


vec3 DomainRotateSymmetry( vec3 vPos, const in float fSteps )
{
	float angle = atan( vPos.x, vPos.z );
	
	float fScale = fSteps / (PI * 2.0);
	float steppedAngle = (floor(angle * fScale + 0.5)) / fScale;
	
	float s = sin(-steppedAngle);
	float c = cos(-steppedAngle);
	
	vec3 vResult = vec3( c * vPos.x + s * vPos.z, 
			     vPos.y,
			     -s * vPos.x + c * vPos.z);
	
	return vResult;
}

float BulbGlassDist( vec3 vPos )
{
    float fSphereDist = length( vPos ) - 1.0;
    float fCylinderDist = length( vPos.xz ) - 0.5;
    fCylinderDist = max( fCylinderDist, -vPos.y );
    float fGlassDist = smin( fSphereDist, fCylinderDist, 0.5 );
    fGlassDist = max( fGlassDist, vPos.y - 1.5);
    return fGlassDist;
}

SceneResult Scene_GetDistanceBulb( vec3 vPos )
{
    SceneResult result;
    
    result.fDist = BulbGlassDist( vPos );
    
    float fGlassThickness = 0.005;
    
    result.fDist = abs( result.fDist + fGlassThickness ) - fGlassThickness;
    
    result.vUVW = vec3(vPos);
    result.iObjectId = MAT_COLORLESS_GLASS;            

    return result;
}

SceneResult Scene_LightBulbSceneGetDistance( vec3 vPos, int insideObjId )
{    
    SceneResult resultInside = SceneResult_Default();
    SceneResult resultOutside = SceneResult_Default();
    if ( insideObjId != -1 )
    {
    	resultOutside.fDist = -10000.0;
    }
    
    SceneResult resultBulb = Scene_GetDistanceBulb( vPos );
    SceneResult_Combine( resultInside, resultOutside, resultBulb, insideObjId );
    
    
    SceneResult resultPendant;
    float yTop = 2.3;
    float yBottom = 1.5;
    float pRad1 = 0.55;
    float pRadTop = 0.5;
    float t = (vPos.y - yBottom) / ( yTop - yBottom );
    resultPendant.fDist = length( vPos.xz ) - mix( pRad1, pRadTop, t );
    resultPendant.fDist = max( resultPendant.fDist, -vPos.y + yBottom );
    resultPendant.fDist = max( resultPendant.fDist, vPos.y - yTop );
    resultPendant.fDist = min( resultPendant.fDist, length( vPos - vec3(0,yTop,0) ) - pRadTop );

    resultPendant.vUVW = vec3(vPos);
    resultPendant.iObjectId = MAT_PENDANT;
    
    float fInnerDist = length( vPos - vec3(0,1.5, 0) ) - 0.4;
    if ( -fInnerDist > resultPendant.fDist )
    {
	    resultPendant.fDist = -fInnerDist;
    	resultPendant.iObjectId = MAT_CHROME;
    }
    
    
    SceneResult_Combine( resultInside, resultOutside, resultPendant, insideObjId );

    
    SceneResult resultFlex;
    resultFlex.fDist = length( vPos.xz ) - 0.05;
    resultFlex.fDist = max( resultFlex.fDist, -vPos.y + 1.5f );
    resultFlex.fDist = max( resultFlex.fDist, vPos.y - 5.0f );
    
    resultFlex.vUVW = vec3(vPos);
    resultFlex.iObjectId = MAT_WHITE_GLOSS;
    
    SceneResult_Combine( resultInside, resultOutside, resultFlex, insideObjId );
    
    
    
    SceneResult resultProngs;
    vec3 vProngDomain = vPos;
    vProngDomain.x = abs( vProngDomain.x );
    resultProngs.fDist = DistanceCapsule( vProngDomain, vec3( 0.4, 1.0, 0), vec3(0.05, 2.0, 0.0), 0.01 );
    resultProngs.vUVW = vec3(vPos);
    resultProngs.iObjectId = MAT_CHROME;
    
    SceneResult_Combine( resultInside, resultOutside, resultProngs, insideObjId );
    
    SceneResult resultFilament;
    //resultFilament.fDist = length( vPos ) - 0.1;
    
    vec3 vFilamentDomain = DomainRotateSymmetry( vPos, 6.0);
	resultFilament.fDist = DistanceCapsule( vFilamentDomain, vec3( 0.0, 0.6, 0.3), vec3(0.0, -0.6, 0.3), 0.02 );

    resultFilament.vUVW = vec3(vPos);
    resultFilament.iObjectId = MAT_FILAMENT;
    
    SceneResult_Combine( resultInside, resultOutside, resultFilament, insideObjId );
    
    SceneResult resultWall;
    
    resultWall.fDist = vPos.z + 2.0;
    resultWall.vUVW = vec3(vPos * 0.2);
    resultWall.iObjectId = MAT_TEXTURED_FLOOR;

    SceneResult_Combine( resultInside, resultOutside, resultWall, insideObjId );
    
    return SceneResult_Union( resultInside, resultOutside );
}

SceneResult Scene_TestSceneGetDistance( vec3 vPos, int insideObjId )
{    
    SceneResult resultInside = SceneResult_Default();
    SceneResult resultOutside = SceneResult_Default();
    if ( insideObjId != -1 )
    {
    	resultOutside.fDist = -10000.0;
    }
    
    
    SceneResult resultFloor;
    
    resultFloor.fDist = vPos.y;
    resultFloor.vUVW = vec3(vPos.zxy * 0.1);
    resultFloor.iObjectId = MAT_TEXTURED_FLOOR;

    SceneResult_Combine( resultInside, resultOutside, resultFloor, insideObjId );

    vec2 vRepeat = vec2(15.0);
    vec2 vOffset = vRepeat / 2.0;
    vec3 vPosRepeat = vPos;
    vPosRepeat.xz = fract((vPos.xz + vOffset) / vRepeat) * vRepeat - vOffset;
    
    
    vec3 vSphDomain = vPosRepeat;
    vSphDomain.z = abs(vSphDomain.z + 1.5) - 1.5;
    
    SceneResult sph1result;
    
    vec3 vSph1Pos =  vSphDomain - vec3(0,1,0);
    sph1result.fDist = length(vSph1Pos) - 1.0;
    sph1result.vUVW = vec3(vPos);
    sph1result.iObjectId = MAT_COLORED_GLASS;
    
    if ( vPosRepeat.z < -2.0 )
    {
        sph1result.iObjectId = MAT_COLORED_GLASS_2;
    }
    SceneResult_Combine( resultInside, resultOutside, sph1result, insideObjId );    
    
    SceneResult sph4result;
    
    vec3 vSph4Pos =  vSphDomain - vec3(3,1,0.0);
    sph4result.fDist = length( vSph4Pos) - 1.0;
    sph4result.vUVW = vec3(vPos);
    sph4result.iObjectId = MAT_CHROME;
    
    if ( vPosRepeat.z < -2.0 )
    {
        sph4result.iObjectId = MAT_GOLD;
    }

    SceneResult_Combine( resultInside, resultOutside, sph4result, insideObjId );
    
    SceneResult sph5result;
    vec3 vSph5Pos =  vSphDomain - vec3(-3,1.0,0.0);
    sph5result.fDist = length( vSph5Pos) - 1.0;
    //sph5result.fDist = GetDistanceWineGlass( vSph5Pos - vec3(0,-1,0) );
    //sph5result.fDist = GetDistanceMug( vSph5Pos );
    sph5result.vUVW = vec3(vPos);
    sph5result.iObjectId = MAT_WHITE_GLOSS;
    
    if ( vPosRepeat.z < -2.0 )
    {
	    sph5result.iObjectId = MAT_WHITE_MATT;
    }    
    
    SceneResult_Combine( resultInside, resultOutside, sph5result, insideObjId );     
  

    SceneResult lightResult;
    
    vec3 vPosRepeat2 = vPos;
    vec2 vOffset2 = vec2(5.0);
    vPosRepeat2.xz = fract((vPos.xz + vOffset2) / 10.0) * 10.0 - vOffset2;
    
    lightResult.fDist = DistanceCapsule( vPosRepeat2, vec3(0.0,5.0,-1.5), vec3(0.0,5.0,1.5), 0.25);
    lightResult.vUVW = vec3(vPosRepeat2);
    lightResult.iObjectId = MAT_EMISSIVE_LIGHT;

    SceneResult_Combine( resultInside, resultOutside, lightResult, insideObjId );
    
    {
        vec3 vSphPos = vec3(1,4,0) - vSphDomain;

        SceneResult glassSphResult;
        glassSphResult.fDist = length( vSphPos ) - 1.0;
    	glassSphResult.vUVW = vec3(vPos);
    	glassSphResult.iObjectId = MAT_FROSTED_GLASS;
        
        if ( vPosRepeat.z < -2.0 )
        {
            glassSphResult.iObjectId = MAT_COLORLESS_GLASS;
        }
	    SceneResult_Combine( resultInside, resultOutside, glassSphResult, insideObjId );
    }
    
    {
    	vec3 vGlassPos =  vPosRepeat - vec3(4.5,0, -2.5);

        //sph1result.fDist = min( sph1result.fDist, GetDistanceWineGlass( vGlassPos - vec3(0,-1,0) ) );
        
        SceneResult glassResult;
    
    	glassResult.fDist = GetDistanceWineGlass( vGlassPos );
                
    	glassResult.vUVW = vec3(vPos);
    	glassResult.iObjectId = MAT_COLORLESS_GLASS;
    
	    SceneResult_Combine( resultInside, resultOutside, glassResult, insideObjId );
        
        
        SceneResult resultWine;

        resultWine.fDist = GetDistanceWine( vGlassPos );
        resultWine.vUVW = vec3(vPos);
        resultWine.iObjectId = MAT_WINE;
        
    
	    SceneResult_Combine( resultInside, resultOutside, resultWine, insideObjId );        
    }

    SceneResult resultPrism;
    vec3 vPrismPos = vPosRepeat - vec3(5, 4.0, 0.0 );
    resultPrism.fDist = vPrismPos.y;
    vPrismPos = DomainRotateSymmetry( vPrismPos, 3.0 );
    resultPrism.fDist = max( resultPrism.fDist, vPrismPos.z - 0.4 );
    //resultPrism.fDist = length( vPrismPos.xz ) - 0.4;
    resultPrism.vUVW = vec3(vPos);
    resultPrism.iObjectId = MAT_COLORLESS_GLASS;

    SceneResult_Combine( resultInside, resultOutside, resultPrism, insideObjId );        
    
    
    
    return SceneResult_Union( resultInside, resultOutside );
}

SceneResult Scene_PipelineSceneGetDistance( vec3 vPos, int insideObjId )
{    
    SceneResult resultInside = SceneResult_Default();
    SceneResult resultOutside = SceneResult_Default();
    if ( insideObjId != -1 )
    {
    	resultOutside.fDist = -10000.0;
    }
    
    
    SceneResult resultFloor;
    
    resultFloor.fDist = vPos.y;
    resultFloor.vUVW = vec3(vPos.zxy * 0.1);
    resultFloor.iObjectId = MAT_GRASS;

    SceneResult_Combine( resultInside, resultOutside, resultFloor, insideObjId );
    
    
    float fRepeat = 5.0;
    float fOffset = fRepeat / 2.0;
    vec3 vPosRepeat = vPos;
    vPosRepeat.x = fract((vPosRepeat.x + fOffset) / fRepeat) * fRepeat - fOffset;
    
    
    vec3 vSphDomain = vPosRepeat;
    
    SceneResult pipeResult;
    
    vec3 vPipePos =  vSphDomain - vec3(0,1,0);
    
    float fAng = atan( vPipePos.x, vPipePos.y );
    
    pipeResult.fDist = length(vPipePos.xy) - 1.0;
    pipeResult.vUVW = vec3(vPos);
    pipeResult.vUVW.x = fAng;
    pipeResult.vUVW.y = vPos.z * 0.1;
    pipeResult.iObjectId = MAT_PIPE;
    
	SceneResult_Combine( resultInside, resultOutside, pipeResult, insideObjId );        
    
    
    {
        vec3 vPosRepeat2 = vPosRepeat;
        
    
    	float fRepeat = 4.0;
    	float fOffset = fRepeat / 2.0;
    	vec3 vPosRepeat = vPos;
    	vPosRepeat2.z = fract((vPosRepeat2.z + fOffset) / fRepeat) * fRepeat - fOffset;        
        
        
        vec3 vDiskPos =  vPosRepeat2 - vec3(0,1,0);
    	SceneResult diskResult;
        
        diskResult.fDist = length(vDiskPos.xy) - 1.2;
        diskResult.fDist = max( diskResult.fDist, vDiskPos.z - 0.1);
        diskResult.fDist = max( diskResult.fDist, -vDiskPos.z - 0.1);
        //pipeResult.fDist = min( pipeResult.fDist, -(vPosRepeat2.z -0.1) );
        //pipeResult.fDist = min( pipeResult.fDist, -0.1 );
        diskResult.vUVW = vec3(vPos);
    	//diskResult.vUVW.x = fAng * 0.01 + 0.3;
        diskResult.vUVW.x = fAng * 0.5 + 0.3;
    	diskResult.vUVW.y = vDiskPos.z + 0.9 + length( vDiskPos.xy); 
        
        diskResult.iObjectId = MAT_PIPE;

        SceneResult_Combine( resultInside, resultOutside, diskResult, insideObjId );        
         
    }
    
    return SceneResult_Union( resultInside, resultOutside );
}



vec3 DomainRepeatXZGetTile( const in vec3 vPos, const in vec2 vRepeat, out vec2 vTile )
{
	vec3 vResult = vPos;
	vec2 vTilePos = (vPos.xz / vRepeat) + 0.5;
	vTile = floor(vTilePos + 1000.0);
	vResult.xz = (fract(vTilePos) - 0.5) * vRepeat;
	return vResult;
}

vec3 DomainRepeatXZLimitGetTile( const in vec3 vPos, const in vec2 vRepeat, vec2 vLimit, out vec2 vTile )
{
	vec3 vResult = vPos;
	vec2 vTilePos = (vPos.xz / vRepeat) + 0.5;
	vTile = floor(vTilePos);
    vTile = clamp( vTile, vec2(0), vLimit );
	vResult.xz = ((vTilePos - vTile) - 0.5) * vRepeat;
	return vResult;
}

vec3 DomainRepeatXZ( const in vec3 vPos, const in vec2 vRepeat )
{
	vec3 vResult = vPos;
	vec2 vTilePos = (vPos.xz / vRepeat) + 0.5;
	vResult.xz = (fract(vTilePos) - 0.5) * vRepeat;
	return vResult;
}

float GetDistanceGear( const in vec3 vPos )
{
	float fOuterCylinder = length(vPos.xz) - 1.05;
	if(fOuterCylinder > 0.5)
	{
		return fOuterCylinder;
	}
	
	vec3 vToothDomain = DomainRotateSymmetry(vPos, 16.0);
	vToothDomain.xz = abs(vToothDomain.xz);
	float fGearDist = dot(vToothDomain.xz,normalize(vec2(1.0, 0.55))) - 0.55;
	float fSlabDist = abs(vPos.y + 0.1) - 0.15;
	
	vec3 vHoleDomain = abs(vPos);
	vHoleDomain -= 0.4;
	float fHoleDist = length(vHoleDomain.xz) - 0.3;
    
    fHoleDist = max( fHoleDist, length(vPos.xz) - 0.65);
	
	float fBarDist =vToothDomain.z - 0.15;
	fBarDist = max(vPos.y - 0.1, fBarDist);
	
	float fResult = fGearDist;
	fResult = max(fResult, fSlabDist);
	fResult = max(fResult, fOuterCylinder);
	fResult = max(fResult, -fHoleDist);
    
    fResult = max(fResult, vToothDomain.y + vToothDomain.z * 0.25 - 0.25);    
    fResult = max(fResult, -max( length(vPos.xz) - 0.75, -vPos.y - 0.01 ) );
    
	fResult = min(fResult, fBarDist);
	return fResult;
}

SceneResult Scene_GearsSceneGetDistance( vec3 vPos, int insideObjId )
{    
    SceneResult resultInside = SceneResult_Default();
    SceneResult resultOutside = SceneResult_Default();
    if ( insideObjId != -1 )
    {
    	resultOutside.fDist = -10000.0;
    }
    
    float fTime = 0.0f;
    
    
    SceneResult resultFloor;
    
    resultFloor.fDist = vPos.y;
    resultFloor.vUVW = vec3(vPos.zxy * 0.1);
    resultFloor.iObjectId = MAT_TEXTURED_FLOOR;

            
    SceneResult_Combine( resultInside, resultOutside, resultFloor, insideObjId );            	
    
    float fRepeatX = 3.5;
	vec2 vChainTile;
	vec2 vRepeat = vec2(fRepeatX, 8.0);
	vec3 vRepeatDomain = DomainRepeatXZGetTile(vPos, vRepeat, vChainTile);
			
    float fGearDist = 1000.0;
    {
		vec3 vGearDomain1 = DomainRepeatXZ(vPos+vec3(0.0, 0.0, 4.0), vRepeat);
        vGearDomain1.y -= 0.4;
		vGearDomain1 = RotateY( vGearDomain1, fTime);		
        
	    SceneResult resultGearA;

        resultGearA.fDist = GetDistanceGear(vGearDomain1);
        resultGearA.vUVW = vec3(vGearDomain1.zxy * 0.1);
        resultGearA.iObjectId = MAT_GEAR;    
        
    	SceneResult_Combine( resultInside, resultOutside, resultGearA, insideObjId );            	
        
        
		vec3 vGearDomain2 = DomainRepeatXZ(vPos+vec3(fRepeatX * 0.5, 0.0, 4.0), vRepeat);
        vGearDomain2.y -= 0.43;
        vGearDomain2.z += 1.0;
		vGearDomain2 = RotateY( vGearDomain2, -fTime + (2.0 * PI / 32.0) + 0.18);
        
	    SceneResult resultGearB;

        resultGearB.fDist = GetDistanceGear(vGearDomain2);
        resultGearB.vUVW = vec3(vGearDomain2.zxy * 0.1);
        resultGearB.iObjectId = MAT_GEAR;    
        
    	SceneResult_Combine( resultInside, resultOutside, resultGearB, insideObjId );            	
        
		
	}
    
  	SceneResult sph1result;
    
    vec3 vSph1Pos =  vPos - vec3(0,3,0);
    sph1result.fDist = length(vSph1Pos) - 1.0;
    sph1result.vUVW = vec3(vPos);
    sph1result.iObjectId = MAT_EMISSIVE_LIGHT;
    
    SceneResult_Combine( resultInside, resultOutside, sph1result, insideObjId );    
    
    

    return SceneResult_Union( resultInside, resultOutside );
}

SceneResult Scene_TubesSceneGetDistance( vec3 vPos, int insideObjId )
{    
    SceneResult resultInside = SceneResult_Default();
    SceneResult resultOutside = SceneResult_Default();
    if ( insideObjId != -1 )
    {
    	resultOutside.fDist = -10000.0;
    }
    
    float fTime = 0.0f;
    
    
    SceneResult resultFloor;
    
    resultFloor.fDist = vPos.y;
    resultFloor.vUVW = vec3(vPos.zxy * 0.1);
    resultFloor.iObjectId = MAT_TEXTURED_FLOOR;

            
    SceneResult_Combine( resultInside, resultOutside, resultFloor, insideObjId );            	
        
    SceneResult resultTube;
    
    float fTubeRadius = 0.1;
    float fTubeHeight = 1.5;
    
    vec3 vTubeDomain = vPos - vec3( 0, fTubeRadius, 0);
    
    float fStandBaseHeight = 0.2;
    vTubeDomain.y -= fStandBaseHeight;
    
    vec2 vTile;
    vec2 vRepeatSpacing = vec2(0.5, 0.5);
    vec2 vRepeatMax = vec2(1,3);
    vTubeDomain = DomainRepeatXZLimitGetTile( vTubeDomain, vRepeatSpacing, vRepeatMax, vTile ); 
    
    float fLipDist = length( vec2(length(vTubeDomain.xz)-fTubeRadius - 0.02,vTubeDomain.y - fTubeHeight) ) - 0.01;
    
    float fClosestY = clamp( vTubeDomain.y, 0.0, fTubeHeight );
    float fTubeDist = length( vTubeDomain - vec3(0, fClosestY, 0 )) - fTubeRadius;
    float fGlassDist = abs( fTubeDist ) - 0.02;    
    fGlassDist = max( fGlassDist, vTubeDomain.y - fTubeHeight);
    fGlassDist = min( fGlassDist, fLipDist );
    resultTube.fDist = fGlassDist;
    resultTube.vUVW = vPos;
    resultTube.iObjectId = MAT_COLORLESS_GLASS;

    SceneResult_Combine( resultInside, resultOutside, resultTube, insideObjId );            	

    float fLiquidHeight = 0.75 + sin(vTile.x * 12.234 + vTile.y * 3.456) * 0.6;
    
    float fLiquidDist = fTubeDist;
    fLiquidDist = max( fLiquidDist, vTubeDomain.y - fLiquidHeight );

    SceneResult liquidResult;
    liquidResult.fDist = fLiquidDist;
    liquidResult.vUVW = vPos;
    liquidResult.iObjectId = MAT_COLORED_GLASS;

    if ( HashWang( uint(vTile.x + vTile.y * vRepeatMax.x + 5.) ) % 2u == 0u )
	{
	    liquidResult.iObjectId = MAT_COLORED_GLASS_2;
    }
    
    SceneResult_Combine( resultInside, resultOutside, liquidResult, insideObjId );      


    float fStandDist = 100.0;
    {
        float fBevel = 0.05;
        float fBorder = 0.3;
        vec3 vStandMin = vec3(-fBorder, 0.0, -fBorder);    
        vec3 vStandMax = vec3(fBorder, fStandBaseHeight, fBorder);
        vStandMax.xz += vec2(vRepeatMax * vRepeatSpacing);
        vec3 vClosest = clamp( vPos, vStandMin + fBevel, vStandMax - fBevel );
        fStandDist = min( fStandDist, length( vClosest - vPos ) - fBevel );
    }
    
    {
        float fBevel = 0.05;
        float fBorder = 0.2;
        float fStandRackHeight = 1.0;
        float fStandRackSize = 0.1;
        vec3 vStandMin = vec3(-fBorder, fStandRackHeight, -fBorder);    
        vec3 vStandMax = vec3(fBorder, fStandRackHeight + fStandRackSize, fBorder);
        vStandMax.xz += vec2(vRepeatMax * vRepeatSpacing);
        vec3 vClosest = clamp( vPos, vStandMin + fBevel, vStandMax - fBevel );
        float fRackDist = length( vClosest - vPos ) - fBevel;
        fRackDist = max( fRackDist, -(fTubeDist - 0.04) );
        fStandDist = min( fStandDist, fRackDist );
    }
    
    {
        vec3 vStandPoleDomain = vPos;
        vStandPoleDomain.x -= vRepeatSpacing.x * 0.5;
        float fMirror = 0.8;
        vStandPoleDomain.z = (-abs(vStandPoleDomain.z - fMirror) + fMirror);
        float fPoleDist = length(vStandPoleDomain.xz) - 0.05;

        fPoleDist = max( fPoleDist, (vStandPoleDomain.y - 1.0) );
        
        fStandDist = min( fStandDist, fPoleDist );
        
    }
    
  	SceneResult standResult;
    standResult.fDist = fStandDist;
    standResult.vUVW = vPos;
    standResult.iObjectId = MAT_STAND;

    SceneResult_Combine( resultInside, resultOutside, standResult, insideObjId );      
    
  	SceneResult sph1result;
    
    vec3 vSph1Pos =  vPos - vec3(3,2,0);
    sph1result.fDist = length(vSph1Pos) - 0.5;
    sph1result.vUVW = vec3(vPos);
    sph1result.iObjectId = MAT_EMISSIVE_LIGHT;
    
    SceneResult_Combine( resultInside, resultOutside, sph1result, insideObjId );      
    
    return SceneResult_Union( resultInside, resultOutside );
}


SceneResult Scene_GetDistance( vec3 vPos, int insideObjId )
{
#if TEST_TUBES_SCENE
    return Scene_TubesSceneGetDistance( vPos, insideObjId );
#elif GEARS_SCENE
    return Scene_GearsSceneGetDistance( vPos, insideObjId );
#elif PIPELINE_SCENE    
    return Scene_PipelineSceneGetDistance( vPos, insideObjId );
#elif LIGHT_BULB_SCENE
    vPos.x = -vPos.x;
    vPos.z = -vPos.z;
    vPos -= vec3(-1,1.5,3);
    return Scene_LightBulbSceneGetDistance( vPos, insideObjId );
#else
    return Scene_TestSceneGetDistance( vPos, insideObjId );
#endif
}

PathColor BlackBody( WaveInfo wave, float t, float i )
{
#if SPECTRAL
	return PathColor( BlackBody( t, wave.wavelength ) * i );
#endif        
#if RGB
    vec3 w = vec3( 610.0, 549.0, 468.0 );
    vec3 vEmissive = vec3(0.0);
    vEmissive.r = BlackBody( t, w.r );
    vEmissive.g = BlackBody( t, w.g );
    vEmissive.b = BlackBody( t, w.b );
    return PathColor( vEmissive * i );
#endif        
    
}

SurfaceInfo Scene_GetSurfaceInfo( const in vec3 vRayOrigin,  const in vec3 vRayDir, WaveInfo wave, SceneResult traceResult, int insideObjId )
{
    SurfaceInfo surfaceInfo;
    
    surfaceInfo.vPos = vRayOrigin + vRayDir * (traceResult.fDist);
    
    surfaceInfo.vNormal = Scene_GetNormal( surfaceInfo.vPos, insideObjId ); 
    
    surfaceInfo.vBumpNormal = surfaceInfo.vNormal;
    surfaceInfo.vAlbedo = vec3(1.0);
#if SPECTRAL    
    surfaceInfo.cR0 = PathColor( 0.02 );
#endif
#if RGB
    surfaceInfo.cR0 = PathColor( vec3( 0.02 ) );
#endif
    
    surfaceInfo.fGloss = 1.0;
    surfaceInfo.cEmissive = PathColor_Zero();
    surfaceInfo.fTransparency = 0.0;
    

    
    if ( traceResult.iObjectId == MAT_WINE )
    {
        surfaceInfo.fTransparency = 1.0;
        surfaceInfo.fGloss = 1.0;
    }
    
    if ( traceResult.iObjectId == MAT_COLORLESS_GLASS )
    {
        surfaceInfo.fGloss = 1.0;
        surfaceInfo.vAlbedo = vec3(0.01);
        surfaceInfo.fTransparency = 1.0;
    }

    if ( traceResult.iObjectId == MAT_FROSTED_GLASS )
    {
        surfaceInfo.fGloss = 0.3;
        surfaceInfo.vAlbedo = vec3(0.01);
        surfaceInfo.fTransparency = 1.0;        
    }
    
    if ( traceResult.iObjectId == MAT_COLORED_GLASS )
    {
        surfaceInfo.fGloss = 0.5;
        surfaceInfo.fTransparency = 1.0;
    }

    if ( traceResult.iObjectId == MAT_COLORED_GLASS_2 )
    {
        surfaceInfo.fGloss = 1.0;
        surfaceInfo.fTransparency = 1.0;
    }    
    
    if ( traceResult.iObjectId == MAT_TEXTURED_FLOOR )
    {
    	surfaceInfo.vAlbedo = textureLod(iChannel2, traceResult.vUVW.xy, 0.0 ).rgb;
        surfaceInfo.fGloss = 1.0 - clamp( surfaceInfo.vAlbedo.r * 1.8 - 0.5, 0.0, 1.0);
        surfaceInfo.vAlbedo = surfaceInfo.vAlbedo * surfaceInfo.vAlbedo;
        
        //surfaceInfo.vAlbedo = vec3(0.25);
        
        
        /*
        // The floor is lava
        float t = 1.0 - surfaceInfo.vAlbedo.r;
        surfaceInfo.cEmissive = BlackBody(wave, 2200.0 * t * t, 3e-9);
        surfaceInfo.vAlbedo *= 1.0 - t;
        */
    }
    
    if ( traceResult.iObjectId == MAT_STAND )
    {
    	surfaceInfo.vAlbedo = textureLod(iChannel2, traceResult.vUVW.xy, 0.0 ).rgb;
        surfaceInfo.fGloss = 1.0 - clamp( surfaceInfo.vAlbedo.r * 2.8 - 0.3, 0.0, 1.0);
        surfaceInfo.vAlbedo = surfaceInfo.vAlbedo * surfaceInfo.vAlbedo;
        surfaceInfo.vAlbedo *= vec3(1.0, 0.4, 0.2);
        
        //surfaceInfo.vAlbedo = vec3(0.25);
        
        
        /*
        // The floor is lava
        float t = 1.0 - surfaceInfo.vAlbedo.r;
        surfaceInfo.cEmissive = BlackBody(wave, 2200.0 * t * t, 3e-9);
        surfaceInfo.vAlbedo *= 1.0 - t;
        */
    }    
    
    if ( traceResult.iObjectId == MAT_EMISSIVE_LIGHT || traceResult.iObjectId == MAT_FILAMENT )
    {
        float t = 6500.0;
        float i = 3e-12;                
        
        if ( mod( surfaceInfo.vPos.x, 20.0) < 10.0 )
        {
            t += 2000.0;
        }
        else
        {
            t -= 1000.0;
        }
        
        if ( traceResult.iObjectId == MAT_FILAMENT )
        {
            t = 6500.0 - 3000.0;
            i = 3e-10;            
        }
            
        
        if ( traceResult.vUVW.z > 1.5 || traceResult.vUVW.z < -1.5 || traceResult.vUVW.y > 5.0 )
        {
            i = 0.0;
            surfaceInfo.fGloss = 1.0f;
		    surfaceInfo.cR0 = PathColor_One();
        }
        
        surfaceInfo.cEmissive = BlackBody( wave, t, i );
    }

    if ( traceResult.iObjectId == MAT_CHROME )
    {
    	surfaceInfo.vAlbedo = vec3(0.9, 0.5, 0.05) * 0.1;
        surfaceInfo.fGloss = 1.0;        
		surfaceInfo.cR0 = PathColor_One();
    }

    
#if PIPELINE_SCENE    
    if ( traceResult.iObjectId == MAT_PIPE )
    {
    	//surfaceInfo.vAlbedo = vec3(0.9, 0.5, 0.05) * 0.1;
        //surfaceInfo.fGloss = 1.0;        
        
    	surfaceInfo.vAlbedo = textureLod(iChannel2, traceResult.vUVW.xy, 0.0 ).rgb;
        surfaceInfo.fGloss = 1.0 - clamp( surfaceInfo.vAlbedo.r * 1.8 - 0.5, 0.0, 1.0);
        surfaceInfo.vAlbedo = surfaceInfo.vAlbedo * surfaceInfo.vAlbedo;
        
        //surfaceInfo.fGloss = pow( surfaceInfo.fGloss, 0.1);
        
        
		//surfaceInfo.cR0 = PathColor_One();        
    }    
    
    
    if ( traceResult.iObjectId == MAT_GRASS )
    {
    	surfaceInfo.vAlbedo = textureLod(iChannel2, traceResult.vUVW.xy, 0.0 ).rgb;
        surfaceInfo.fGloss = 1.0 - clamp( surfaceInfo.vAlbedo.r * 1.8 - 0.5, 0.0, 1.0);
        surfaceInfo.vAlbedo = surfaceInfo.vAlbedo * surfaceInfo.vAlbedo;
        
        surfaceInfo.vAlbedo = mix( vec3(0.4, 0.5, 0.1) * 0.1, vec3( 0.6, 0.8, 0.05), surfaceInfo.vAlbedo );
        
        //surfaceInfo.vAlbedo = vec3(0.25);
        
        
        /*
        // The floor is lava
        float t = 1.0 - surfaceInfo.vAlbedo.r;
        surfaceInfo.cEmissive = BlackBody(wave, 2200.0 * t * t, 3e-9);
        surfaceInfo.vAlbedo *= 1.0 - t;
        */
    }     
#endif    
    
#if GEARS_SCENE    
    if ( traceResult.iObjectId == MAT_GEAR )
    {
    	//surfaceInfo.vAlbedo = vec3(0.9, 0.5, 0.05) * 0.1;
        //surfaceInfo.fGloss = 1.0;        
        
    	surfaceInfo.vAlbedo = textureLod(iChannel2, traceResult.vUVW.xy * 4.0 + vec2(0.0, 0.5), 0.0 ).rgb;
        surfaceInfo.vAlbedo = surfaceInfo.vAlbedo * surfaceInfo.vAlbedo;
        surfaceInfo.vAlbedo.g *= 0.5;
        surfaceInfo.vAlbedo.b *= 0.2;
        surfaceInfo.vAlbedo *= 0.5;

        float fDirt = textureLod(iChannel2, traceResult.vUVW.yx * 5.0 + 0.25, 0.0 ).b;        
        fDirt = clamp( fDirt * 3.0 - 0.4, 0.0, 1.0);
        //fDirt = 1.0;

        float fGloss = textureLod(iChannel2, traceResult.vUVW.yx * 3.0, 0.0 ).g;
        
        fGloss = fGloss * fGloss;
        
        surfaceInfo.fGloss = mix( fGloss, 1.0, fDirt );
        
        surfaceInfo.vAlbedo = mix( vec3(0.1), surfaceInfo.vAlbedo, fDirt);
        
        //surfaceInfo.cR0 = PathColor_One();        
        //surfaceInfo.fGloss = pow( surfaceInfo.fGloss, 0.1);
        
        surfaceInfo.cR0 = ColorScale_sRGB( wave, mix( vec3( 0.6, 0.55, 0.5 ), vec3(0.02), fDirt) );
    }       
#endif    
    
    
   

    if ( traceResult.iObjectId == MAT_GOLD )
    {
    	surfaceInfo.vAlbedo = vec3(0.9, 0.5, 0.05) * 0.1;
        surfaceInfo.fGloss = 1.0;        
		surfaceInfo.cR0 = PathColor_One();
        
        surfaceInfo.cR0 = ColorScale_sRGB( wave, vec3( 0.9, 0.5, 0.05 ) );
    }    
    if ( traceResult.iObjectId == MAT_WHITE_GLOSS )
    {
    	surfaceInfo.vAlbedo = vec3(0.9, 0.9, 0.9);
        surfaceInfo.fGloss = 1.0;        
    }    
    
    if ( traceResult.iObjectId == MAT_PENDANT )
    {
    	surfaceInfo.vAlbedo = vec3(0.9, 0.9, 0.9);
        surfaceInfo.fGloss = 1.0;        
        if ( traceResult.vUVW.y > 2.0 && traceResult.vUVW.y < 2.1 )
        {
	    	surfaceInfo.vAlbedo = vec3(0.3);
        }    
    }
    
    if ( traceResult.iObjectId == MAT_WHITE_MATT )
    {
    	surfaceInfo.vAlbedo = vec3(1.0, 1.0, 1.0);
        surfaceInfo.fGloss = 0.0;        
    }    
    
    return surfaceInfo;
}

struct Medium
{
    float fScatteringDensity;
    float fRefractiveIndex;
    PathColor cAbsorb;
};


// https://en.m.wikipedia.org/wiki/Cauchy%27s_equation
float Cauchy(float w_nm, float B, float C)
{
    float w_um = w_nm / 1000.0;
    
    float w2 = w_um * w_um;
    
    return B + C / w2;
}

// https://en.wikipedia.org/wiki/Sellmeier_equation
float Sellmeier( float w_nm, vec3 B, vec3 C )
{
    float w_um = w_nm / 1000.0;
    
    float w2 = w_um * w_um;

    vec3 t = (B * w2) / (vec3(w2) - C);
    return sqrt( 1.0f + t.x + t.y + t.z );
}

Medium Scene_GetMedium( WaveInfo wave, int iObjectId )
{
    Medium medium;
    
    medium.fScatteringDensity = 0.0; //0.0025;//0.0015;
    medium.fRefractiveIndex = 1.0;
        
    bool bGlass = false;
    vec3 vAbsorb = vec3(1.0)  - vec3(0.99);
      
#if SPECTRAL
		float fRefractionWavelength_nm = wave.wavelength;
#else    
    	float fRefractionWavelength_nm = 540.0;        
#endif 
    
    if ( iObjectId == MAT_WINE )
    {
    	vAbsorb = vec3(1.0)  - vec3(0.9, 0.9, 0.3);
        //medium.fRefractiveIndex = 1.330;
        medium.fRefractiveIndex = Cauchy( fRefractionWavelength_nm,1.330, 0.00743 );
        
    }
    
    if ( iObjectId == MAT_COLORLESS_GLASS || iObjectId == MAT_FROSTED_GLASS )
    {
    	vAbsorb = vec3(1.0)  - vec3(0.9);
        bGlass = true;
    }
    
    if ( iObjectId == MAT_COLORED_GLASS )
    {
    	vAbsorb = vec3(1.0)  - vec3(0.9, 0.1, 0.1);
        medium.fScatteringDensity = 0.3;
        
        #if TEST_TUBES_SCENE
			//medium.fScatteringDensity = 2.0;
	    	vAbsorb = vec3(0, 3, 4);
        #endif
        bGlass = true;
    }
    
    if ( iObjectId == MAT_COLORED_GLASS_2 )
    {
    	vAbsorb = vec3(1.0)  - vec3(0.1, 0.3, 0.9 );
        
        #if TEST_TUBES_SCENE
			//medium.fScatteringDensity = 2.0;
	    	vAbsorb = vec3(4, 3, 0);
        #endif        
        medium.fScatteringDensity = 0.3;
        bGlass = true;
    }
    
    if ( bGlass )
    {                  
#if 0
        medium.fRefractiveIndex = Cauchy( fRefractionWavelength_nm, 1.5220, 0.00459 );
#else
        
        vec3 B = vec3(1.03961212, 0.231792344, 1.01046945);
        vec3 C = vec3(6.00069867e-3, 2.00179144e-2, 1.03560653e2);
        medium.fRefractiveIndex = Sellmeier( fRefractionWavelength_nm, B, C );
        
#endif        
    }
    
    medium.cAbsorb = ColorScale_sRGB( wave, vAbsorb );
    return medium;
}


PathColor SampleEnvironment( WaveInfo wave, vec3 vDir )
{
    vec3 vEnvMap = textureLod(iChannel1, vDir, 0.0).rgb;
    vEnvMap = vEnvMap * vEnvMap;
    float kEnvmapExposure = 20.0;
    float fExposureFactor = 1.0 - pow(2.0, -kEnvmapExposure);
    vEnvMap = -log2(1.0 - vEnvMap * fExposureFactor);           
    return ColorScale_sRGB( wave, vEnvMap );    
}

float ScatteringRayLifetime( float pDensity, float fRand )
{
    // avoid log(0) and divide by 0
    pDensity = clamp( pDensity, 0.000001, 0.999999 );
    
    // avoid log(0)
    fRand = max( 0.000001, fRand );
    
    // logn(X) / logn(X) is the same for all bases
    float g = log2( fRand ) / log2( 1.0f - pDensity );
    return g;
}


PathColor TraceScene( vec3 vRayOrigin, vec3 vRayDir, WaveInfo wave, inout uint seed )
{
    float fPathLength = MAX_PATH_LENGTH;
    float fStartDist = 0.0;
    
    int MAX_PATH_ITER = 10;
    
    PathColor cResult = PathColor_Zero();    
    PathColor cRemaining = PathColor_One();
        
    int insideObjId = -1;
    Medium medium;
    
    SceneResult initResult = Scene_GetDistance( vRayOrigin, -1 );
    if ( initResult.fDist <= 0.0 )
    {
    	insideObjId = initResult.iObjectId;
    }
	
    medium = Scene_GetMedium( wave, insideObjId );
    

    for( int pathIter = 0; pathIter < NO_UNROLL(MAX_PATH_ITER); pathIter++ )
    {
        SceneResult traceResult = Scene_Trace( vRayOrigin, vRayDir, fStartDist, fPathLength, insideObjId );
                
#if SCATTERING     
        
        // scattering 
        float fRandomScatter = FRand( seed );
        
        // probability of scattering per unit distance
        float pDensity = medium.fScatteringDensity;

        float fLifeTime = ScatteringRayLifetime( pDensity, fRandomScatter );
        if ( traceResult.fDist > fLifeTime )
        {
            traceResult.fDist = fLifeTime;
	        fPathLength -= traceResult.fDist;
            
            // Scattering
            
            // Todo - phase function...
            vRayOrigin = vRayOrigin + vRayDir * fLifeTime;
            vRayDir = normalize( vRayDir + 0.1 * PointOnSphereUniform( seed ));
            if ( FRand( seed ) < 0.5 )
            {
                 vRayDir = -vRayDir;
            }
            vRayDir = PointOnSphereUniform( seed );
            //vRemaining *= vec3(0.5, 0.8, 0.9);  
            
            continue;
        }        
#endif        
      
#if ABSORPTION
        // absorption
        float fODist = clamp(traceResult.fDist, 0.0, MAX_PATH_LENGTH );
#if SPECTRAL
        float fTemp = exp( medium.cAbsorb.fIntensity * -fODist );
        PathColor cExtinction = PathColor( fTemp );
#endif      
#if RGB
        vec3 vTemp = exp( medium.cAbsorb.vRGB * -fODist );
        PathColor cExtinction = PathColor( vTemp );
#endif
        cRemaining = ColorScale( cRemaining, cExtinction );
        
#endif        
        fPathLength -= traceResult.fDist;
        
        if ( traceResult.iObjectId < 0 )
        {
            PathColor cEnv = SampleEnvironment( wave, vRayDir );
            cResult = ColorAdd( cResult, ColorScale( cEnv, cRemaining ) );
                        
            break;
        }
        
        int newInsideObjId = insideObjId;
        
        int from = insideObjId;
        int to = traceResult.iObjectId;                
        if ( insideObjId == traceResult.iObjectId )
        {
            to = -1;
        }        
        
        SurfaceInfo surfaceInfo = Scene_GetSurfaceInfo( vRayOrigin, vRayDir, wave, traceResult, insideObjId );        

        float fFromRefractiveIndex = medium.fRefractiveIndex;
        
	    medium = Scene_GetMedium( wave, to );
        
        // hit something
        vRayOrigin = surfaceInfo.vPos;

		PathColor cFresnel = Light_GetFresnel( -vRayDir, surfaceInfo.vBumpNormal, surfaceInfo.cR0, surfaceInfo.fGloss );

        bool bFresnel = false;
        {
	        float fRand = FRand(seed);
            #if SPECTRAL    
            bFresnel = cFresnel.fIntensity > fRand;
        #endif

        #if RGB
            
		if ( cFresnel.vRGB.x == cFresnel.vRGB.y && cFresnel.vRGB.x == cFresnel.vRGB.z && cFresnel.vRGB.y == cFresnel.vRGB.z )
        {
            bFresnel = cFresnel.vRGB[0] > fRand;
        }
        else
        {
            float fBase = fRand * 2.9999;
            int iChannel = int( floor( fBase ) );
            float fRand2 = fBase - float(iChannel);
            bFresnel = cFresnel.vRGB[iChannel] > fRand2;
            
            vec3 scale = vec3(0);
            scale[iChannel] = 3.0f;
            cRemaining.vRGB *= scale;
        }
        #endif             
        }

        vec2 uniformSamplePos = FRand2( seed );        

        float alpha2 = SpecParamFromGloss(surfaceInfo.fGloss);

        vec3 N = surfaceInfo.vBumpNormal;
        vec3 V = -vRayDir;
        vec3 H = ImportanceSampleGGX( uniformSamplePos, N, alpha2 );        
        
        float fToRefractiveIndex = medium.fRefractiveIndex;

       	// Hack - use GGX for refraction "gloss"
        vec3 vRefract = refract( -V, H, fFromRefractiveIndex / fToRefractiveIndex );
        
        if ( length( vRefract ) <= 0.0 )
        {
            bFresnel = true;
        }
        
        if ( bFresnel )
        {
            vRayDir = reflect( -V, H );
        }
        else
        {
            cResult = ColorAdd( cResult, ColorScale( surfaceInfo.cEmissive, cRemaining ) );
            
#if TRANSPARENCY            
            // transparency
            float fTransparency = surfaceInfo.fTransparency;
            if ( FRand( seed ) < fTransparency )
            {                                
				vRayDir = vRefract;
                newInsideObjId = to;                
            }
			else
#endif                
            {
                // diffuse...                
                vRayDir = PointOnHemisphereCosine( seed, surfaceInfo.vNormal );
                cRemaining = ColorScale( cRemaining, ColorScale_sRGB( wave, surfaceInfo.vAlbedo ) );
            }
        }
        
        insideObjId = newInsideObjId;
        
        fStartDist = 0.1 / abs(dot( vRayDir, surfaceInfo.vNormal )); 
        
        if ( ColorIntensity( cRemaining ) < 0.005 )
        {
            break;
        }
    }
    
    return cResult;
}


vec2 BokehShapeCircle( float fRand )
{
    fRand *= PI * 2.0;
    return vec2( sin( fRand ), cos( fRand ) );
}

vec2 BokehShapePoly( float fSides, float fBladeAngleOffset, float fRand )
{
    vec2 A, B;
    
    float t = fRand * fSides;
    float t0 = floor(t);
    float t1 = t0 + 1.0;
    float b = fract(t);
    
    t0 += 0.5;
    t1 += 0.5;
    
    t0 = fBladeAngleOffset + (t0 * TAU) / fSides;
    t1 = fBladeAngleOffset + (t1 * TAU) / fSides;
    
    A = vec2( sin(t0), cos(t0) );
    B = vec2( sin(t1), cos(t1) );
    
    return mix( A, B, b );
}

float BokehMask( vec2 vUV, vec2 vBokehShape )
{
    //return 1.0;
    vec2 vOrigin = -(vUV * 2.0 - 1.0);
    vOrigin *= 0.8;
    float d = length( vOrigin - vBokehShape ); 
    return clamp( (1.0 - d) * 20.0, 0.0, 1.0 ) * 1.5;
}

float NormalDistributionRand( inout uint seed )
{
    // https://en.wikipedia.org/wiki/Box%E2%80%93Muller_transform
    
    float U1 = FRand(seed);
    float U2 = FRand(seed);
    
    return sqrt( -2.0 * log( U1 ) ) * cos( TAU * U2 );
}

void mainImage( out vec4 vFragColor, in vec2 vFragCoord )
{
    vec2 vUV = vFragCoord/iResolution.xy;
    
    vec2 vWindow = (vUV - 0.5) * 2.0;
    vWindow.x *= iResolution.x / iResolution.y;
    
    CameraState cam;
	Cam_LoadState( cam, iChannel3, ivec2(0) );
    
    float fAspectRatio = iResolution.x / iResolution.y;
    
    vec3 vRayOrigin, vRayDir;
    Cam_GetCameraRay( vUV, fAspectRatio, cam, vRayOrigin, vRayDir );    
    
    vec3 vCamDir = cam.vTarget - cam.vPos;
    

    uint seed = uint( iTime * 23.456 ) + uint(vFragCoord.x *23.45f) * 12326u + uint(vFragCoord.y * 36.43) * 42332u;
    
    int PATH_COUNT = 30;
    
    float fPathCount = texelFetch( iChannel3, ivec2(7,0), 0).z;

    int iPathsTraced = 0;
    vec3 vColor = vec3(0);
    
#if GEARS_SCENE
    cam.fPlaneInFocus = 2.5;
   #endif
    
 #if  TEST_TUBES_SCENE
    cam.fPlaneInFocus = 3.0;
   #endif   
    for ( int pathIndex = 0; pathIndex < NO_UNROLL(PATH_COUNT); pathIndex++ )
    {
        if ( pathIndex > int(fPathCount) )
        {
            break;
        }
        
        iPathsTraced++;
        seed = HashWang( seed );
        
        vec3 vRayOrigin2 = vRayOrigin;
        vec3 vRayDir2 = vRayDir;

#if SPECTRAL        
        WaveInfo wave;
        wave.wavelength = mix( 380.0, 780.0, FRand( seed ) );
        
        mat3 m = mat3(
            0.9415037, -0.0321240,  0.0584672,
			-0.0428238,  1.0250998,  0.0203309,
 			0.0101511, -0.0161170,  1.2847354 );
        
        vec3 XYZ = WavelengthToXYZ(wave.wavelength);
        wave.rgb = XYZtosRGB( XYZ  );
        //wave.rgb = XYZ * XYZtoRGB( Primaries_Rec709 );
        //wave.rgb = clamp( wave.rgb, vec3(0.0), vec3(1.0));
#endif        

#if RGB
        WaveInfo wave = WaveInfo(0);
#endif
        
#if SPECTRAL        
		float fRefractiveIndex = Cauchy( wave.wavelength, 1.5220, 0.00459 );        
        vRayDir2 = refract( vRayDir, -normalize(vRayDir + vCamDir * 0.5), fRefractiveIndex ); 
#endif        
        
        // Depth of field    
        mat3 perpMat = OrthoNormalMatrixFromZ( vCamDir );
        float fBokehMask = 1.0;
        
        float fBladeCount = 6.0;
        float fBladeAngleOffset = 0.2;
#if DEPTH_OF_FIELD        
		float fBokehShapeRand = FRand( seed );
		float fBokehDistRand = FRand( seed );
        
        vec2 vBokehShape = BokehShapePoly( fBladeCount, fBladeAngleOffset, fBokehShapeRand );
        //vec2 vBokehShape = BokehShapeCircle( fBokehShapeRand );
        
        vec2 vBokehUV = vBokehShape * (pow( fBokehDistRand, 0.4 ) );
        
        fBokehMask = BokehMask( vUV, vBokehUV );
        if ( fBokehMask <= 0.0 )
        {
            // this will increment paths traced without adding color
            continue;
        }
        
        
        vBokehUV *= 0.05;
        
        vec3 vBokehOffset = vec3( vBokehUV, 0.0 ) * perpMat;
        
        vRayDir2 += vBokehOffset / cam.fPlaneInFocus;
        vRayOrigin2 -= vBokehOffset;
#endif        
        
        // bloom
        vec2 vBloomUV = vec2(0.0);
#if BLOOM || BIG_BLOOM   
#if BIG_BLOOM
        float fBladeIndex = floor(FRand(seed) * fBladeCount);
        float fBladeAngle = fBladeAngleOffset + fBladeIndex * TAU / fBladeCount;
        vec2 vBlade = vec2( sin( fBladeAngle ), cos( fBladeAngle ) );
        float fDist = 0.0f;
		//fDist += -log( FRand(seed) ) * 0.001;
        fDist += pow( FRand(seed), 150.0 );
        vBloomUV += vBlade * fDist;
#endif        

        vec2 vBloomShape = BokehShapeCircle( FRand(seed) );
        float fNormRand = NormalDistributionRand( seed );
        vBloomUV += vBloomShape * fNormRand * 0.0005;
#endif        
        
        vec2 vAAUV = FRand2( seed ) / iResolution.xy;
        
        vec3 vRayJitter = vec3( vBloomUV + vAAUV, 0.0 ) * perpMat;        
        
        vRayDir2 += vRayJitter;
                
        PathColor colResult = TraceScene( vRayOrigin2, vRayDir2, wave, seed );
        colResult = ColorScale( colResult, fBokehMask );
        
        vColor += To_sRGB( wave, colResult );
    }
    
#if SPECTRAL
    
#if 0
    //hacking around...
    Chromaticities Primaries_Rec709_SampleAvg =
	Chromaticities(
        vec2( 0.6400, 0.3300 ),	// R
        vec2( 0.3000, 0.6000 ),	// G
        vec2( 0.1500, 0.0600 ), 	// B
        vec2( 1.0 / 3.0 ) );	// W
    
    mat3 m = RGBtoXYZ(Primaries_Rec709_SampleAvg) * XYZtoRGB( Primaries_Rec709 );
    vColor = vColor * m;
#endif    
    
    vColor *= 3.0;
#endif 
        
    vFragColor = vec4( vColor, iPathsTraced );
    
    vec4 vLast = texelFetch( iChannel0, ivec2(vFragCoord), 0 );

    if ( cam.bStationary )
    {
	    vFragColor += vLast;
    }    
}

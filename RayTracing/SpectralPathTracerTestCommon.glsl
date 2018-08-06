
#define PI 3.141592654f
#define TAU ( PI * 2.0f )

#define NO_UNROLL(X) (X + min(0,iFrame))
#define NO_UNROLLU(X) (X + uint(min(0,iFrame)))


//  _   _           _       _____                 _   _                 
// | | | | __ _ ___| |__   |  ___|   _ _ __   ___| |_(_) ___  _ __  ___ 
// | |_| |/ _` / __| '_ \  | |_ | | | | '_ \ / __| __| |/ _ \| '_ \/ __|
// |  _  | (_| \__ \ | | | |  _|| |_| | | | | (__| |_| | (_) | | | \__ \
// |_| |_|\__,_|___/_| |_| |_|   \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
//                                                                      

// http://web.archive.org/web/20071223173210/http://www.concentric.net/~Ttwang/tech/inthash.htm
uint HashWang( uint a )
{
	a = (a ^ 61u) ^ (a >> 16u);
	a = a + (a << 3u);
	a = a ^ (a >> 4u);
	a = a * 0x27d4eb2du;
	a = a ^ (a >> 15u);
	return a;
}

uint HashHugo( uint n )
{
    // integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
    n = n * (n * n * 15731U + 789221U) + 1376312589U;    
    
    return n;
}

uint Rand( inout uint seed )
{
    seed += 13u;
    return HashWang( seed );
}

float FRand( inout uint seed )
{
    uint urand = Rand( seed );    
    const uint mantissaMask = (0xffffffffu) >> ( 32u - 23u );
    return fract(float(urand & mantissaMask) / float(mantissaMask)); 
    //return uintBitsToFloat( (urand & mantissaMask) | (127u << 23u) );
}

vec2 FRand2( inout uint seed )
{
    return vec2( FRand( seed ), FRand( seed ) );
}

vec3 FRand3( inout uint seed )
{
    return vec3( FRand( seed ), FRand( seed ), FRand( seed ) );
}

float SRand( inout uint seed )
{
    return FRand( seed ) * 2.0 - 1.0;
}

vec2 SRand2( inout uint seed )
{
    return FRand2( seed ) * 2.0 - 1.0;
}

vec3 SRand3( inout uint seed )
{
    return FRand3( seed ) * 2.0 - 1.0;
}

//  ____        _          ____  _                             
// |  _ \  __ _| |_ __ _  / ___|| |_ ___  _ __ __ _  __ _  ___ 
// | | | |/ _` | __/ _` | \___ \| __/ _ \| '__/ _` |/ _` |/ _ \
// | |_| | (_| | || (_| |  ___) | || (_) | | | (_| | (_| |  __/
// |____/ \__,_|\__\__,_| |____/ \__\___/|_|  \__,_|\__, |\___|
//                                                  |___/      
//

vec4 LoadVec4( sampler2D sampler, in ivec2 vAddr )
{
    return texelFetch( sampler, vAddr, 0 );
}

vec3 LoadVec3( sampler2D sampler, in ivec2 vAddr )
{
    return LoadVec4( sampler, vAddr ).xyz;
}

bool AtAddress( ivec2 p, ivec2 c ) { return all( equal( p, c ) ); }

void StoreVec4( in ivec2 vAddr, in vec4 vValue, inout vec4 fragColor, in ivec2 fragCoord )
{
    fragColor = AtAddress( fragCoord, vAddr ) ? vValue : fragColor;
}

void StoreVec3( in ivec2 vAddr, in vec3 vValue, inout vec4 fragColor, in ivec2 fragCoord )
{
    StoreVec4( vAddr, vec4( vValue, 0.0 ), fragColor, fragCoord);
}

//
//  ____       _        _   _             
// |  _ \ ___ | |_ __ _| |_(_) ___  _ __  
// | |_) / _ \| __/ _` | __| |/ _ \| '_ \ 
// |  _ < (_) | || (_| | |_| | (_) | | | |
// |_| \_\___/ \__\__,_|\__|_|\___/|_| |_|
//                                        
//

vec3 RotateX( const in vec3 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);
    
    vec3 vResult = vec3( vPos.x, c * vPos.y + s * vPos.z, -s * vPos.y + c * vPos.z);
    
    return vResult;
}

vec3 RotateY( const in vec3 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);
    
    vec3 vResult = vec3( c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);
    
    return vResult;
}

vec3 RotateZ( const in vec3 vPos, const in float fAngle )
{
    float s = sin(fAngle);
    float c = cos(fAngle);
    
    vec3 vResult = vec3( c * vPos.x + s * vPos.y, -s * vPos.x + c * vPos.y, vPos.z);
    
    return vResult;
}


//   ___              _                  _             
//  / _ \ _   _  __ _| |_ ___ _ __ _ __ (_) ___  _ __  
// | | | | | | |/ _` | __/ _ \ '__| '_ \| |/ _ \| '_ \ 
// | |_| | |_| | (_| | ||  __/ |  | | | | | (_) | | | |
//  \__\_\\__,_|\__,_|\__\___|_|  |_| |_|_|\___/|_| |_|
//                                                     
//

vec4 QuatMul(const in vec4 lhs, const in vec4 rhs) 
{
      return vec4( lhs.y*rhs.z - lhs.z*rhs.y + lhs.x*rhs.w + lhs.w*rhs.x,
                   lhs.z*rhs.x - lhs.x*rhs.z + lhs.y*rhs.w + lhs.w*rhs.y,
                   lhs.x*rhs.y - lhs.y*rhs.x + lhs.z*rhs.w + lhs.w*rhs.z,
                   lhs.w*rhs.w - lhs.x*rhs.x - lhs.y*rhs.y - lhs.z*rhs.z);
}

vec4 QuatFromAxisAngle( vec3 vAxis, float fAngle )
{
	return vec4( normalize(vAxis) * sin(fAngle), cos(fAngle) );    
}

vec4 QuatFromVec3( vec3 vRot )
{
    float l = length( vRot );
    if ( l <= 0.0 )
    {
        return vec4( 0.0, 0.0, 0.0, 1.0 );
    }
    return QuatFromAxisAngle( vRot, l );
}

mat3 QuatToMat3( const in vec4 q )
{
	vec4 qSq = q * q;
	float xy2 = q.x * q.y * 2.0;
	float xz2 = q.x * q.z * 2.0;
	float yz2 = q.y * q.z * 2.0;
	float wx2 = q.w * q.x * 2.0;
	float wy2 = q.w * q.y * 2.0;
	float wz2 = q.w * q.z * 2.0;
 
	return mat3 (	
     qSq.w + qSq.x - qSq.y - qSq.z, xy2 - wz2, xz2 + wy2,
     xy2 + wz2, qSq.w - qSq.x + qSq.y - qSq.z, yz2 - wx2,
     xz2 - wy2, yz2 + wx2, qSq.w - qSq.x - qSq.y + qSq.z );
}

vec3 QuatMul( vec3 v, vec4 q )
{
    // TODO Validate vs other quat code
    vec3 t = 2.0 * cross(q.xyz, v);
	return v + q.w * t + cross(q.xyz, t);
}

//
//  _  __          _                         _ 
// | |/ /___ _   _| |__   ___   __ _ _ __ __| |
// | ' // _ \ | | | '_ \ / _ \ / _` | '__/ _` |
// | . \  __/ |_| | |_) | (_) | (_| | | | (_| |
// |_|\_\___|\__, |_.__/ \___/ \__,_|_|  \__,_|
//           |___/                             
//

const int KEY_SPACE = 32;
const int KEY_LEFT  = 37;
const int KEY_UP    = 38;
const int KEY_RIGHT = 39;
const int KEY_DOWN  = 40;
const int KEY_A     = 65;
const int KEY_B     = 66;
const int KEY_C     = 67;
const int KEY_D     = 68;
const int KEY_E     = 69;
const int KEY_F     = 70;
const int KEY_G     = 71;
const int KEY_H     = 72;
const int KEY_I     = 73;
const int KEY_J     = 74;
const int KEY_K     = 75;
const int KEY_L     = 76;
const int KEY_M     = 77;
const int KEY_N     = 78;
const int KEY_O     = 79;
const int KEY_P     = 80;
const int KEY_Q     = 81;
const int KEY_R     = 82;
const int KEY_S     = 83;
const int KEY_T     = 84;
const int KEY_U     = 85;
const int KEY_V     = 86;
const int KEY_W     = 87;
const int KEY_X     = 88;
const int KEY_Y     = 89;
const int KEY_Z     = 90;
const int KEY_COMMA = 188;
const int KEY_PER   = 190;

const int KEY_1 = 	49;
const int KEY_2 = 	50;
const int KEY_3 = 	51;
const int KEY_ENTER = 13;
const int KEY_SHIFT = 16;
const int KEY_CTRL  = 17;
const int KEY_ALT   = 18;
const int KEY_TAB	= 9;

bool Key_IsPressed( sampler2D samp, int key)
{
    return texelFetch( samp, ivec2(key, 0), 0 ).x > 0.0;    
}

bool Key_IsToggled(sampler2D samp, int key)
{
    return texelFetch( samp, ivec2(key, 2), 0 ).x > 0.0;    
}


//
//   ____                               
//  / ___|__ _ _ __ ___   ___ _ __ __ _ 
// | |   / _` | '_ ` _ \ / _ \ '__/ _` |
// | |__| (_| | | | | | |  __/ | | (_| |
//  \____\__,_|_| |_| |_|\___|_|  \__,_|
//                                      


struct CameraState
{
    vec3 vPos;
    vec3 vTarget;
    vec3 vUp;
    float fFov;
    vec2 vJitter;
    float fPlaneInFocus;
    bool bStationary;
};
    
void Cam_LoadState( out CameraState cam, sampler2D sampler, ivec2 addr )
{
    vec4 vPos = LoadVec4( sampler, addr + ivec2(0,0) );
    cam.vPos = vPos.xyz;
    vec4 targetFov = LoadVec4( sampler, addr + ivec2(1,0) );
    cam.vTarget = targetFov.xyz;
    cam.fFov = targetFov.w;
    vec4 vUp = LoadVec4( sampler, addr + ivec2(2,0) );
    cam.vUp = vUp.xyz;
    
    vec4 jitterDof = LoadVec4( sampler, addr + ivec2(3,0) );
    cam.vJitter = jitterDof.xy;
    cam.fPlaneInFocus = jitterDof.z;
    cam.bStationary = jitterDof.w > 0.0;
}

void Cam_StoreState( ivec2 addr, const in CameraState cam, inout vec4 fragColor, in ivec2 fragCoord )
{
    StoreVec4( addr + ivec2(0,0), vec4( cam.vPos, 0 ), fragColor, fragCoord );
    StoreVec4( addr + ivec2(1,0), vec4( cam.vTarget, cam.fFov ), fragColor, fragCoord );    
    StoreVec4( addr + ivec2(2,0), vec4( cam.vUp, 0 ), fragColor, fragCoord );    
    StoreVec4( addr + ivec2(3,0), vec4( cam.vJitter, cam.fPlaneInFocus, cam.bStationary ? 1.0f : 0.0f ), fragColor, fragCoord );    
}

mat3 Cam_GetWorldToCameraRotMatrix( const CameraState cameraState )
{
    vec3 vForward = normalize( cameraState.vTarget - cameraState.vPos );
	vec3 vRight = normalize( cross( cameraState.vUp, vForward) );
	vec3 vUp = normalize( cross(vForward, vRight) );
    
    return mat3( vRight, vUp, vForward );
}

vec2 Cam_GetViewCoordFromUV( vec2 vUV, float fAspectRatio )
{
	vec2 vWindow = vUV * 2.0 - 1.0;
	vWindow.x *= fAspectRatio;

	return vWindow;	
}

void Cam_GetCameraRay( const vec2 vUV, const float fAspectRatio, const CameraState cam, out vec3 vRayOrigin, out vec3 vRayDir )
{
    vec2 vView = Cam_GetViewCoordFromUV( vUV, fAspectRatio );
    vRayOrigin = cam.vPos;
    float fPerspDist = 1.0 / tan( radians( cam.fFov ) );
    vRayDir = normalize( Cam_GetWorldToCameraRotMatrix( cam ) * vec3( vView, fPerspDist ) );
}

// fAspectRatio = iResolution.x / iResolution.y;
vec2 Cam_GetUVFromWindowCoord( const in vec2 vWindow, float fAspectRatio )
{
    vec2 vScaledWindow = vWindow;
    vScaledWindow.x /= fAspectRatio;

    return (vScaledWindow * 0.5 + 0.5);
}

vec2 Cam_WorldToWindowCoord(const in vec3 vWorldPos, const in CameraState cameraState )
{
    vec3 vOffset = vWorldPos - cameraState.vPos;
    vec3 vCameraLocal;

    vCameraLocal = vOffset * Cam_GetWorldToCameraRotMatrix( cameraState );
	
    vec2 vWindowPos = vCameraLocal.xy / (vCameraLocal.z * tan( radians( cameraState.fFov ) ));
    
    return vWindowPos;
}

float EncodeDepthAndObject( float depth, int objectId )
{
    //depth = max( 0.0, depth );
    //objectId = max( 0, objectId + 1 );
    //return exp2(-depth) + float(objectId);
    return depth;
}

float DecodeDepthAndObjectId( float value, out int objectId )
{
    objectId = 0;
    return max(0.0, value);
    //objectId = int( floor( value ) ) - 1; 
    //return abs( -log2(fract(value)) );
}


// Misc

float SmoothMin( float a, float b, float k )
{
	//return min(a,b);
	
	
    //float k = 0.06;
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}



// Spectrum to xyz approx function from Sloan http://jcgt.org/published/0002/02/01/paper.pdf
// Inputs:  Wavelength in nanometers
float xFit_1931( float wave )
{
    float t1 = (wave-442.0)*((wave<442.0)?0.0624:0.0374),
          t2 = (wave-599.8)*((wave<599.8)?0.0264:0.0323),
          t3 = (wave-501.1)*((wave<501.1)?0.0490:0.0382);
    return 0.362*exp(-0.5*t1*t1) + 1.056*exp(-0.5*t2*t2)- 0.065*exp(-0.5*t3*t3);
}
float yFit_1931( float wave )
{
    float t1 = (wave-568.8)*((wave<568.8)?0.0213:0.0247),
          t2 = (wave-530.9)*((wave<530.9)?0.0613:0.0322);
    return 0.821*exp(-0.5*t1*t1) + 0.286*exp(-0.5*t2*t2);
}
float zFit_1931( float wave )
{
    float t1 = (wave-437.0)*((wave<437.0)?0.0845:0.0278),
          t2 = (wave-459.0)*((wave<459.0)?0.0385:0.0725);
    return 1.217*exp(-0.5*t1*t1) + 0.681*exp(-0.5*t2*t2);
}

#define xyzFit_1931(w) vec3( xFit_1931(w), yFit_1931(w), zFit_1931(w) ) 

// http://www.cie.co.at/technical-work/technical-resources
vec3 standardObserver1931[] =
    vec3[] (
    vec3( 0.001368, 0.000039, 0.006450 ), // 380 nm
    vec3( 0.002236, 0.000064, 0.010550 ), // 385 nm
    vec3( 0.004243, 0.000120, 0.020050 ), // 390 nm
    vec3( 0.007650, 0.000217, 0.036210 ), // 395 nm
    vec3( 0.014310, 0.000396, 0.067850 ), // 400 nm
    vec3( 0.023190, 0.000640, 0.110200 ), // 405 nm
    vec3( 0.043510, 0.001210, 0.207400 ), // 410 nm
    vec3( 0.077630, 0.002180, 0.371300 ), // 415 nm
    vec3( 0.134380, 0.004000, 0.645600 ), // 420 nm
    vec3( 0.214770, 0.007300, 1.039050 ), // 425 nm
    vec3( 0.283900, 0.011600, 1.385600 ), // 430 nm
    vec3( 0.328500, 0.016840, 1.622960 ), // 435 nm
    vec3( 0.348280, 0.023000, 1.747060 ), // 440 nm
    vec3( 0.348060, 0.029800, 1.782600 ), // 445 nm
    vec3( 0.336200, 0.038000, 1.772110 ), // 450 nm
    vec3( 0.318700, 0.048000, 1.744100 ), // 455 nm
    vec3( 0.290800, 0.060000, 1.669200 ), // 460 nm
    vec3( 0.251100, 0.073900, 1.528100 ), // 465 nm
    vec3( 0.195360, 0.090980, 1.287640 ), // 470 nm
    vec3( 0.142100, 0.112600, 1.041900 ), // 475 nm
    vec3( 0.095640, 0.139020, 0.812950 ), // 480 nm
    vec3( 0.057950, 0.169300, 0.616200 ), // 485 nm
    vec3( 0.032010, 0.208020, 0.465180 ), // 490 nm
    vec3( 0.014700, 0.258600, 0.353300 ), // 495 nm
    vec3( 0.004900, 0.323000, 0.272000 ), // 500 nm
    vec3( 0.002400, 0.407300, 0.212300 ), // 505 nm
    vec3( 0.009300, 0.503000, 0.158200 ), // 510 nm
    vec3( 0.029100, 0.608200, 0.111700 ), // 515 nm
    vec3( 0.063270, 0.710000, 0.078250 ), // 520 nm
    vec3( 0.109600, 0.793200, 0.057250 ), // 525 nm
    vec3( 0.165500, 0.862000, 0.042160 ), // 530 nm
    vec3( 0.225750, 0.914850, 0.029840 ), // 535 nm
    vec3( 0.290400, 0.954000, 0.020300 ), // 540 nm
    vec3( 0.359700, 0.980300, 0.013400 ), // 545 nm
    vec3( 0.433450, 0.994950, 0.008750 ), // 550 nm
    vec3( 0.512050, 1.000000, 0.005750 ), // 555 nm
    vec3( 0.594500, 0.995000, 0.003900 ), // 560 nm
    vec3( 0.678400, 0.978600, 0.002750 ), // 565 nm
    vec3( 0.762100, 0.952000, 0.002100 ), // 570 nm
    vec3( 0.842500, 0.915400, 0.001800 ), // 575 nm
    vec3( 0.916300, 0.870000, 0.001650 ), // 580 nm
    vec3( 0.978600, 0.816300, 0.001400 ), // 585 nm
    vec3( 1.026300, 0.757000, 0.001100 ), // 590 nm
    vec3( 1.056700, 0.694900, 0.001000 ), // 595 nm
    vec3( 1.062200, 0.631000, 0.000800 ), // 600 nm
    vec3( 1.045600, 0.566800, 0.000600 ), // 605 nm
    vec3( 1.002600, 0.503000, 0.000340 ), // 610 nm
    vec3( 0.938400, 0.441200, 0.000240 ), // 615 nm
    vec3( 0.854450, 0.381000, 0.000190 ), // 620 nm
    vec3( 0.751400, 0.321000, 0.000100 ), // 625 nm
    vec3( 0.642400, 0.265000, 0.000050 ), // 630 nm
    vec3( 0.541900, 0.217000, 0.000030 ), // 635 nm
    vec3( 0.447900, 0.175000, 0.000020 ), // 640 nm
    vec3( 0.360800, 0.138200, 0.000010 ), // 645 nm
    vec3( 0.283500, 0.107000, 0.000000 ), // 650 nm
    vec3( 0.218700, 0.081600, 0.000000 ), // 655 nm
    vec3( 0.164900, 0.061000, 0.000000 ), // 660 nm
    vec3( 0.121200, 0.044580, 0.000000 ), // 665 nm
    vec3( 0.087400, 0.032000, 0.000000 ), // 670 nm
    vec3( 0.063600, 0.023200, 0.000000 ), // 675 nm
    vec3( 0.046770, 0.017000, 0.000000 ), // 680 nm
    vec3( 0.032900, 0.011920, 0.000000 ), // 685 nm
    vec3( 0.022700, 0.008210, 0.000000 ), // 690 nm
    vec3( 0.015840, 0.005723, 0.000000 ), // 695 nm
    vec3( 0.011359, 0.004102, 0.000000 ), // 700 nm
    vec3( 0.008111, 0.002929, 0.000000 ), // 705 nm
    vec3( 0.005790, 0.002091, 0.000000 ), // 710 nm
    vec3( 0.004109, 0.001484, 0.000000 ), // 715 nm
    vec3( 0.002899, 0.001047, 0.000000 ), // 720 nm
    vec3( 0.002049, 0.000740, 0.000000 ), // 725 nm
    vec3( 0.001440, 0.000520, 0.000000 ), // 730 nm
    vec3( 0.001000, 0.000361, 0.000000 ), // 735 nm
    vec3( 0.000690, 0.000249, 0.000000 ), // 740 nm
    vec3( 0.000476, 0.000172, 0.000000 ), // 745 nm
    vec3( 0.000332, 0.000120, 0.000000 ), // 750 nm
    vec3( 0.000235, 0.000085, 0.000000 ), // 755 nm
    vec3( 0.000166, 0.000060, 0.000000 ), // 760 nm
    vec3( 0.000117, 0.000042, 0.000000 ), // 765 nm
    vec3( 0.000083, 0.000030, 0.000000 ), // 770 nm
    vec3( 0.000059, 0.000021, 0.000000 ), // 775 nm
    vec3( 0.000042, 0.000015, 0.000000 )  // 780 nm
);
float standardObserver1931_w_min = 380.0f;
float standardObserver1931_w_max = 780.0f;
int standardObserver1931_length = 81;

vec3 WavelengthToXYZLinear( float fWavelength )
{
    float fPos = ( fWavelength - standardObserver1931_w_min ) / (standardObserver1931_w_max - standardObserver1931_w_min);
    float fIndex = fPos * float(standardObserver1931_length);
    float fFloorIndex = floor(fIndex);
    float fBlend = clamp( fIndex - fFloorIndex, 0.0, 1.0 );
    int iIndex0 = int(fFloorIndex);
    int iIndex1 = iIndex0 + 1;
    iIndex1 = min( iIndex1, standardObserver1931_length - 1);

    return mix( standardObserver1931[iIndex0], standardObserver1931[iIndex1], fBlend );
}

vec3 XYZtosRGB( vec3 XYZ )
{
    // XYZ to sRGB
    // http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
   mat3 m = mat3 (
        3.2404542, -1.5371385, -0.4985314,
		-0.9692660,  1.8760108,  0.0415560,
 		0.0556434, -0.2040259,  1.0572252 );
    
    return XYZ * m;
}

vec3 sRGBtoXYZ( vec3 RGB )
{
   // sRGB to XYZ
   // http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html

   mat3 m = mat3(  	0.4124564,  0.3575761, 0.1804375,
 					0.2126729,  0.7151522, 0.0721750,
 					0.0193339,  0.1191920, 0.9503041 );
    
    
    return RGB * m;
}

vec3 WavelengthToXYZ( float f )
{    
    //return xyzFit_1931( f ) * mXYZtoSRGB;
    
    return WavelengthToXYZLinear( f );
}


struct Chromaticities
{
    vec2 R, G, B, W;
};
    
vec3 CIE_xy_to_xyz( vec2 xy )
{
    return vec3( xy, 1.0f - xy.x - xy.y );
}

vec3 CIE_xyY_to_XYZ( vec3 CIE_xyY )
{
    float x = CIE_xyY[0];
    float y = CIE_xyY[1];
    float Y = CIE_xyY[2];
    
    float X = (Y / y) * x;
    float Z = (Y / y) * (1.0 - x - y);
        
	return vec3( X, Y, Z );        
}

vec3 CIE_XYZ_to_xyY( vec3 CIE_XYZ )
{
    float X = CIE_XYZ[0];
    float Y = CIE_XYZ[1];
    float Z = CIE_XYZ[2];
    
    float N = X + Y + Z;
    
    float x = X / N;
    float y = Y / N;
    float z = Z / N;
    
    return vec3(x,y,Y);
}

Chromaticities Primaries_Rec709 =
Chromaticities(
        vec2( 0.6400, 0.3300 ),	// R
        vec2( 0.3000, 0.6000 ),	// G
        vec2( 0.1500, 0.0600 ), 	// B
        vec2( 0.3127, 0.3290 ) );	// W

Chromaticities Primaries_Rec2020 =
Chromaticities(
        vec2( 0.708,  0.292 ),	// R
        vec2( 0.170,  0.797 ),	// G
        vec2( 0.131,  0.046 ),  	// B
        vec2( 0.3127, 0.3290 ) );	// W

Chromaticities Primaries_DCI_P3_D65 =
Chromaticities(
        vec2( 0.680,  0.320 ),	// R
        vec2( 0.265,  0.690 ),	// G
        vec2( 0.150,  0.060 ),  	// B
        vec2( 0.3127, 0.3290 ) );	// W

mat3 RGBtoXYZ( Chromaticities chroma )
{
    // xyz is a projection of XYZ co-ordinates onto to the plane x+y+z = 1
    // so we can reconstruct 'z' from x and y
    
    vec3 R = CIE_xy_to_xyz( chroma.R );
    vec3 G = CIE_xy_to_xyz( chroma.G );
    vec3 B = CIE_xy_to_xyz( chroma.B );
    vec3 W = CIE_xy_to_xyz( chroma.W );
    
    // We want vectors in the directions R, G and B to form the basis of
    // our matrix...
    
	mat3 mPrimaries = mat3 ( R, G, B );
    
    // but we want to scale R,G and B so they result in the
    // direction W when the matrix is multiplied by (1,1,1)
    
    vec3 W_XYZ = W / W.y;
	vec3 vScale = inverse( mPrimaries ) * W_XYZ;
    
    return transpose( mat3( R * vScale.x, G * vScale.y, B * vScale.z ) );
}

mat3 XYZtoRGB( Chromaticities chroma )
{
    return inverse( RGBtoXYZ(chroma) );
}

// chromatic adaptation

// http://www.brucelindbloom.com/index.html?Eqn_ChromAdapt.html    

// Test viewing condition CIE XYZ tristimulus values of whitepoint.
vec3 XYZ_w = vec3( 1.09850,	1.00000,	0.35585); // Illuminant A
// Reference viewing condition CIE XYZ tristimulus values of whitepoint.
vec3 XYZ_wr = vec3(0.95047,	1.00000,	1.08883); // D65


const mat3 CA_A_to_D65_VonKries = mat3(
    0.9394987, -0.2339150,  0.4281177,
	-0.0256939,  1.0263828,  0.0051761,
 	0.0000000,  0.0000000,  3.0598005
    );


const mat3 CA_A_to_D65_Bradford = mat3(
    0.8446965, -0.1179225,  0.3948108,
	-0.1366303,  1.1041226,  0.1291718,
 	0.0798489, -0.1348999,  3.1924009
    );


const mat3 mCAT_VonKries = mat3 ( 
    0.4002400,  0.7076000, -0.0808100,
	-0.2263000,  1.1653200,  0.0457000,
 	0.0000000,  0.0000000,  0.9182200 );

const mat3 mCAT_02 = mat3( 	0.7328, 0.4296, -0.1624,
							-0.7036, 1.6975, 0.0061,
 							0.0030, 0.0136, 0.9834 );

const mat3 mCAT_Bradford = mat3 (  0.8951000, 0.2664000, -0.1614000,
								-0.7502000,  1.7135000,  0.0367000,
 								0.0389000, -0.0685000,  1.0296000 );


mat3 GetChromaticAdaptionMatrix()
{
    //return inverse(CA_A_to_D65_VonKries);    
    //return inverse(CA_A_to_D65_Bradford);
        
    //return mat3(1,0,0, 0,1,0, 0,0,1); // do nothing
    
	//mat3 M = mCAT_02;
    //mat3 M = mCAT_Bradford;
    mat3 M = mCAT_VonKries;
    //mat3 M = mat3(1,0,0,0,1,0,0,0,1);
    
    vec3 w = XYZ_w * M;
    vec3 wr = XYZ_wr * M;
    vec3 s = w / wr;
    
    mat3 d = mat3( 
        s.x,	0,		0,  
        0,		s.y,	0,
        0,		0,		s.z );
        
    mat3 cat = M * d * inverse(M);
    return cat;
}

float BlackBody( float t, float w_nm )
{
    float h = 6.6e-34; // Planck constant
    float k = 1.4e-23; // Boltzmann constant
    float c = 3e8;// Speed of light

    float w = w_nm / 1e9;

    // Planck's law https://en.wikipedia.org/wiki/Planck%27s_law
    
    float w5 = w*w*w*w*w;    
    float o = 2.*h*(c*c) / (w5 * (exp(h*c/(w*k*t)) - 1.0));

    return o;    
}
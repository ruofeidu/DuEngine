//https://www.shadertoy.com/view/4sSXWt
//Implementation of Multiple Importance Sampling technique(E.Veach 1995)
//example shows MIS for direct light calculation
//Idea behind technique is that every monte-carlo sampling technique has 
//variance and this variance comes from low probability of success.
//So if you have 2 or more unbiased monte-carlo sampling techniques 
//which gives you different response on same situation you can predict 
//which of those responses contains more variance and weight them
//correspondingly to decrease overal variance and stay unbiased.
#define PIXEL_SAMPLES 2
#define LIGHT_SAMPLES 4
#define BSDF_SAMPLES 4
#define FRAME_TIME 0.05	//for motion blur
#define IMPORTANCE_SAMPLE_LIGHTS
#define SHADOWS

//light sampling technique *******************
//#define SAMPLE_LIGHT_AREA
#define SAMPLE_LIGHT_SOLIDANGLE
//********************************************

#define SHOW_PLANES
#define SHOW_TEXT

#define GAMMA 2.2
const vec3 backgroundColor = vec3( 0.2 );

//used macros and constants
#define HALF_PI 			1.5707963
#define PI 					3.1415926
#define TWO_PI 				6.2831852
#define FOUR_PI 			12.566370
#define INV_PI 				0.3183099
#define INV_TWO_PI 			0.1591549
#define INV_FOUR_PI 		0.0795775
#define EPSILON 			0.0001
#define IN_RANGE(x,a,b)		(((x) > (a)) && ((x) < (b)))
#define EQUAL_FLT(a,b,eps)	(((a)>((b)-(eps))) && ((a)<((b)+(eps))))
#define IS_ZERO(a) 			EQUAL_FLT(a,0.0,EPSILON)
//********************************************

#ifdef SHOW_TEXT
struct Disk {
    vec2 position_;
    float radius_innder_;
    float radius_outter_;
    float angle_begin_;
    float angle_end_;
};
    
struct Box {
    vec2 position_;
    vec2 dimensions_;	//positive
};

bool pointInBox( vec2 p, Box box ) {
    if( IN_RANGE( p.x, box.position_.x, box.position_.x + box.dimensions_.x ) &&
      	IN_RANGE( p.y, box.position_.y, box.position_.y + box.dimensions_.y ) )
        return true;
    
    return false;
}

bool pointInDisk( vec2 p, Disk disk ) {
    Box bbox = Box(disk.position_ - vec2(disk.radius_outter_)*1.01, vec2(disk.radius_outter_)*2.01 );
    
    //primitive level culling
    if( !pointInBox( p, bbox ) )
        return false;
    
    vec2 v = p - disk.position_;
    
    float rho;
    rho = sqrt( v.x*v.x + v.y*v.y );
    
    if( !IN_RANGE( rho, disk.radius_innder_, disk.radius_outter_ ) )
        return false;
    
	float theta = atan( v.y, v.x );
    theta += PI;
    
    if( !IN_RANGE( theta, disk.angle_begin_, disk.angle_end_ ) )
        return false;
    
    return true;
}

vec2 fontDim = vec2(5.0,5.0);

bool is_point_on_B( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 0.0 ), vec2( 0.5, 1.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 2.0 ), vec2( 0.5, 1.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 4.0 ), vec2( 0.5, 1.0 ) ) ) 					||
       	pointInDisk( p, Disk( vec2( 1.5, 1.5 ), 0.5, 1.5, HALF_PI, PI+HALF_PI ) ) 	||
      	pointInDisk( p, Disk( vec2( 1.5, 3.5 ), 0.5, 1.5, HALF_PI, PI+HALF_PI ) ) )
        return true;
    return false;
}

bool is_point_on_R( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 				||
       	pointInBox( p, Box( vec2( 1.0, 2.0 ), vec2( 0.5, 1.0 ) ) ) 				||
       	pointInBox( p, Box( vec2( 1.0, 4.0 ), vec2( 0.5, 1.0 ) ) ) 				||
       	pointInBox( p, Box( vec2( 2.0, 0.0 ), vec2( 1.0, 1.5 ) ) ) 				||
       	pointInDisk( p, Disk( vec2( 1.5, 1.5 ), 0.5, 1.5, PI, PI+HALF_PI ) ) 	||
      	pointInDisk( p, Disk( vec2( 1.5, 3.5 ), 0.5, 1.5, HALF_PI, PI+HALF_PI ) ) )
        return true;
    return false;
}

bool is_point_on_D( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 0.0 ), vec2( 0.5, 1.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 2.0, 1.5 ), vec2( 1.0, 2.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 4.0 ), vec2( 0.5, 1.0 ) ) ) 					||
       	pointInDisk( p, Disk( vec2( 1.5, 1.5 ), 0.5, 1.5, HALF_PI, PI ) ) 	||
      	pointInDisk( p, Disk( vec2( 1.5, 3.5 ), 0.5, 1.5, PI, PI+HALF_PI ) ) )
        return true;
    return false;
}

bool is_point_on_F( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 2.0 ), vec2( 1.5, 1.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 4.0 ), vec2( 2.0, 1.0 ) ) ) )
        return true;
    return false;
}

bool is_point_on_I( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) )
        return true;
    return false;
}

bool is_point_on_M( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 4.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 2.0, 2.0 ), vec2( 1.0, 3.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 4.0 ), vec2( 3.0, 1.0 ) ) ) )
        return true;
    return false;
}

bool is_point_on_S( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.5, 1.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.5, 4.0 ), vec2( 1.5, 1.0 ) ) ) 					||
       	pointInDisk( p, Disk( vec2( 1.5, 1.5 ), 0.5, 1.5, HALF_PI, HALF_PI+PI ) ) 	||
       	pointInDisk( p, Disk( vec2( 1.5, 3.5 ), 0.5, 1.5, HALF_PI+PI, TWO_PI ) ) 	||
      	pointInDisk( p, Disk( vec2( 1.5, 3.5 ), 0.5, 1.5, 0.0, HALF_PI ) ) )
        return true;
    return false;
}

bool is_point_on_L( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 3.0, 1.0 ) ) ) )
        return true;
    return false;
}

bool is_point_on_G( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 1.5 ), vec2( 1.0, 2.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 2.0, 3.0 ), vec2( 1.0, 0.5 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.5, 0.0 ), vec2( 1.5, 2.0 ) ) ) 					||
       	pointInDisk( p, Disk( vec2( 1.5, 1.5 ), 0.5, 1.5, 0.0, HALF_PI ) ) 	||
      	pointInDisk( p, Disk( vec2( 1.5, 3.5 ), 0.5, 1.5, PI, TWO_PI ) ) )
        return true;
    return false;
}

bool is_point_on_H( vec2 p ) {
    if( pointInBox( p, Box( vec2( 0.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 2.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 1.0, 2.0 ), vec2( 1.0, 1.0 ) ) ) )
        return true;
    return false;
}

bool is_point_on_T( vec2 p ) {
    if( pointInBox( p, Box( vec2( 1.0, 0.0 ), vec2( 1.0, 5.0 ) ) ) 					||
       	pointInBox( p, Box( vec2( 0.0, 4.0 ), vec2( 3.0, 1.0 ) ) ) )
        return true;
    return false;
}

bool is_point_on_BRDF( vec2 p ) {
    //Object level culling
    Box bbox = Box( vec2(0.0), vec2(16.0,5.0) );
    if( !pointInBox( p, bbox ) )
        return false;
    
    vec2 offsetVec = vec2( 0.0 );
    
    if( is_point_on_B( p ) ||
      	is_point_on_R( p - (offsetVec += vec2(4.0,0.0)) ) ||
      	is_point_on_D( p - (offsetVec += vec2(4.0,0.0)) ) ||
      	is_point_on_F( p - (offsetVec += vec2(4.0,0.0)) ) ) {
        return true;
    }
    
    return false;
}

bool is_point_on_MIS( vec2 p ) {
    //Object level culling
    Box bbox = Box( vec2(0.0), vec2(12.0,5.0) );
    if( !pointInBox( p, bbox ) )
        return false;
    
    vec2 v = vec2(fontDim.x + 1.0,0.0);
    vec2 offsetVec = vec2( 0.0 );
    
    if( is_point_on_M( p ) ||
      	is_point_on_I( p - (offsetVec += vec2(6.0,0.0)) ) ||
      	is_point_on_S( p - (offsetVec += vec2(2.0,0.0)) )) {
        return true;
    }
    
    return false;
}

bool is_point_on_LIGHT( vec2 p ) {
    //Object level culling
    Box bbox = Box( vec2(0.0), vec2(20.0,5.0) );
    if( !pointInBox( p, bbox ) )
        return false;
    
    vec2 offsetVec = vec2( 0.0 );
    
    if( is_point_on_L( p ) ||
      	is_point_on_I( p - (offsetVec += vec2(4.0,0.0)) ) ||
      	is_point_on_G( p - (offsetVec += vec2(2.0,0.0)) ) ||
      	is_point_on_H( p - (offsetVec += vec2(4.0,0.0)) ) ||
      	is_point_on_T( p - (offsetVec += vec2(4.0,0.0)) )) {
        return true;
    }
    
    return false;
}

#endif


#define MATERIAL_COUNT 		8
#define BSDF_COUNT 			3
#define BSDF_R_DIFFUSE 		0
#define BSDF_R_GLOSSY 		1
#define BSDF_R_LIGHT 		2

//***********************************
//sampling types
#define SAMPLING_LIGHT				0
#define SAMPLING_BSDF				1
#define SAMPLING_LIGHT_AND_BSDF_MIS	2
#define SAMPLING_NONE				3
int samplingTechnique;
float split1;
float split2;

void initSamplingTechnique(float p) {
    float k = iMouse.x/iResolution.x;
    if(iMouse.z<0.0 || iMouse.x==0.0) {
      	split1 = 0.0;
        split2 = iResolution.x;  
    } else {
        split1 = iMouse.x*k;
        split2 = iMouse.x + (iResolution.x-iMouse.x)*k;
    }
    
    if(p < split1-1.0) {
        samplingTechnique = SAMPLING_BSDF;
    } else if((p > split1+1.0) && (p < split2-1.0)) {
        samplingTechnique = SAMPLING_LIGHT_AND_BSDF_MIS;
    } else if(p > split2+1.0){
        samplingTechnique = SAMPLING_LIGHT;
    } else {
        samplingTechnique = SAMPLING_NONE;
    }
}
//***********************************

#define LIGHT_COUNT (4)
#define LIGHT_COUNT_INV (0.25)
#define WALL_COUNT 	(2)

//MIS heuristics *****************************
#define MIS_HEURISTIC_BALANCE
//#define MIS_HEURISTIC_POWER

float misWeightPower( in float a, in float b ) {
    float a2 = a*a;
    float b2 = b*b;
    float a2b2 = a2 + b2;
    return a2 / a2b2;
}
float misWeightBalance( in float a, in float b ) {
    float ab = a + b;
    
    return a / ab;
}
float misWeight( in float pdfA, in float pdfB ) {
#ifdef MIS_HEURISTIC_POWER
    return misWeightPower(pdfA,pdfB);
#else
    return misWeightBalance(pdfA,pdfB);
#endif
}
//********************************************
            
// random number generator **********
// taken from iq :)
float seed;	//seed initialized in main
float rnd() { return fract(sin(seed++)*43758.5453123); }
//***********************************

// Color corversion code from: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
//************************************************************************************


//////////////////////////////////////////////////////////////////////////
// Converting PDF from Solid angle to Area
float PdfWtoA( float aPdfW, float aDist2, float aCosThere ){
    if( aDist2 < EPSILON )
        return 0.0;
    return aPdfW * abs(aCosThere) / aDist2;
}

// Converting PDF between from Area to Solid angle
float PdfAtoW( float aPdfA, float aDist2, float aCosThere ){
    float absCosTheta = abs(aCosThere);
    if( absCosTheta < EPSILON )
        return 0.0;
    
    return aPdfA * aDist2 / absCosTheta;
}
//////////////////////////////////////////////////////////////////////////

// Data structures ****************** 
struct Sphere { vec3 pos; float radius; float radiusSq; float area; };
struct LightSamplingRecord { vec3 w; float d; float pdf; };
struct Plane { vec4 abcd; };
struct Range { float min_; float max_; };
struct Material { vec3 color; float roughness_; int bsdf_; };
struct RaySurfaceHit { vec3 N; vec3 E; int mtl_id; int obj_id; float dist; };
struct Ray { vec3 origin; vec3 dir; };
struct Camera { mat3 rotate; vec3 pos; float fovV; };
//***********************************
    
// ************ SCENE ***************
Plane walls[WALL_COUNT];
Sphere lights[LIGHT_COUNT];

#ifdef SHOW_PLANES
#define PLANE_COUNT (3)
Plane planes[PLANE_COUNT];
Range planeZRanges[PLANE_COUNT];
float planeHalfWidth = 2.3;
#endif
//***********************************

// ************************  INTERSECTION FUNCTIONS **************************
bool raySphereIntersection( Ray ray, in Sphere sph, out float t ) {
    t = -1.0;
	vec3  ce = ray.origin - sph.pos;
	float b = dot( ray.dir, ce );
	float c = dot( ce, ce ) - sph.radiusSq;
	float h = b*b - c;
    if( h > 0.0 ) {
		t = -b - sqrt(h);
	}
	
	return ( t > 0.0 );
}

bool rayPlaneIntersection( Ray ray, Plane plane, out float t ){
    float dotVN = dot( ray.dir, plane.abcd.xyz );
   
    if ( abs( dotVN ) < EPSILON ) {
        return false;
    }
    
	t = -(dot( ray.origin, plane.abcd.xyz ) + plane.abcd.w)/dotVN;
    
    return ( t > 0.0 );
}
// ***************************************************************************

void updateScene(float t) {
    //init lights
    t *= 4.0;

    float moveSize = 0.7;
    float a = 0.0;
    float speed = 2.0;
    float val;
    
    //1
    val = a+t*speed;    
    lights[0].pos = vec3( -2.0, 1.4, -5.0 ) + vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(0)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //2
    val = a+t*speed;    
    lights[1].pos = vec3( -1.1, 1.4, -5.0 ) + vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(1)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //3
    val = a+t*speed;    
    lights[2].pos = vec3( 0.0, 1.4, -5.0 ) + vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(2)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //4
    val = a+t*speed;    
    lights[3].pos = vec3( 1.6, 1.4, -5.0 ) + vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(3)*LIGHT_COUNT_INV);
    a += 0.4;
}

void initScene() {
    //init lights
    lights[0] = Sphere( vec3( -2.0, 1.4, -5.0 ), 0.05, 0.0025, 0.0314159 );
	lights[1] = Sphere( vec3( -1.1, 1.4, -5.0 ), 0.2, 0.04, 0.5026548 );
	lights[2] = Sphere( vec3( 0.0, 1.4, -5.0 ), 0.4, 0.16, 2.0106193 );
	lights[3] = Sphere( vec3( 1.6, 1.4, -5.0 ), 0.8, 0.64, 8.0424770 );
    
    float moveSize = 0.7;
    float a = 0.0;
    float speed = 2.0;
    float val;
    
    //1
    val = a+iTime*speed;    
    lights[0].pos += vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(0)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //2
    val = a+iTime*speed;    
    lights[1].pos += vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(1)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //3
    val = a+iTime*speed;    
    lights[2].pos += vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(2)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //4
    val = a+iTime*speed;    
    lights[3].pos += vec3( 0.0, sin(val), cos(val) )*moveSize*(1.0-float(3)*LIGHT_COUNT_INV);
    a += 0.4;
    
    //init walls
    walls[0].abcd = vec4( normalize(vec3(0.0, 1.0, -EPSILON)), 1.0 );
    //walls[0].abcd = vec4( 0.0, 1.0, 0.0, 1.0 );
    walls[1].abcd = vec4( 0.0, 0.0, 1.0, 6.2 );
    
#ifdef SHOW_PLANES
    //init planes
    vec3 planeNormal = normalize( vec3( 0.0, 1.0, 1.2 ) );
    planes[0].abcd = vec4( planeNormal, 3.8 );
    planeZRanges[0].min_ = -5.8;
    planeZRanges[0].max_ = -5.0;
    
    planeNormal = normalize( vec3( 0.0, 1.0, 0.7 ) );
    planes[1].abcd = vec4( planeNormal, 2.8 );
    planeZRanges[1].min_ = -4.8;
    planeZRanges[1].max_ = -4.0;
    
    planeNormal = normalize( vec3( 0.0, 1.0, 0.3 ) );
    planes[2].abcd = vec4( planeNormal, 1.8 );
    planeZRanges[2].min_ = -3.8;
    planeZRanges[2].max_ = -3.0;
#endif
}

#define GET_LIGHT_SPHERE_CONST(i) lights[i]


Material materialLibrary[MATERIAL_COUNT];

#define INIT_MTL(i,bsdf,phongExp,colorVal) materialLibrary[i].bsdf_=bsdf; materialLibrary[i].roughness_=phongExp; materialLibrary[i].color=colorVal;
void initMaterialLibrary()
{
    vec3 white = vec3( 1.0, 1.0, 1.0 );
    vec3 gray = vec3( 0.8, 0.8, 0.8 );
    
    //walls
    INIT_MTL( 0, BSDF_R_DIFFUSE, 0.0, white );
	
    //planes
    INIT_MTL( 1, BSDF_R_GLOSSY, 4096.0, gray );
    INIT_MTL( 2, BSDF_R_GLOSSY, 128.0, gray );
    INIT_MTL( 3, BSDF_R_GLOSSY, 32.0, gray );
    
    //lights
    float totalIntencity = 6.0;
    float min_x = lights[0].pos.x;
    float max_x = lights[3].pos.x;
    float x_range = max_x - min_x;
    float h1 = ((lights[0].pos.x-min_x)/x_range)*0.6;
    float h2 = ((lights[1].pos.x-min_x)/x_range)*0.6;
    float h3 = ((lights[2].pos.x-min_x)/x_range)*0.6;
    float h4 = ((lights[3].pos.x-min_x)/x_range)*0.6;
    float s = 0.7;
    float v1 = 1.0/(FOUR_PI*lights[0].radiusSq);
    float v2 = 1.0/(FOUR_PI*lights[1].radiusSq);
    float v3 = 1.0/(FOUR_PI*lights[2].radiusSq);
    float v4 = 1.0/(FOUR_PI*lights[3].radiusSq);
    
    INIT_MTL( 4, BSDF_R_LIGHT, 0.0, hsv2rgb( vec3( h1, s, v1 ) )*totalIntencity );
    INIT_MTL( 5, BSDF_R_LIGHT, 0.0, hsv2rgb( vec3( h2, s, v2 ) )*totalIntencity );
    INIT_MTL( 6, BSDF_R_LIGHT, 0.0, hsv2rgb( vec3( h3, s, v3 ) )*totalIntencity );
    INIT_MTL( 7, BSDF_R_LIGHT, 0.0, hsv2rgb( vec3( h4, s, v4 ) )*totalIntencity );
}

Material getMaterialFromLibrary( int index ){
#if __VERSION__ >= 300
    return materialLibrary[index];
#else
    if(index == 0) return materialLibrary[0];
    if(index == 1) return materialLibrary[1];
    if(index == 2) return materialLibrary[2];
    if(index == 3) return materialLibrary[3];
    if(index == 4) return materialLibrary[4];
    if(index == 5) return materialLibrary[5];
    if(index == 6) return materialLibrary[6];
    return materialLibrary[7];
#endif
}

void getLightInfo( in int index, out Sphere sphere, out vec3 intensity ) {
#if __VERSION__ >= 300
    sphere = lights[index];
#else
    if(index == 0) { sphere = lights[0]; } else
    if(index == 1) { sphere = lights[1]; } else
    if(index == 2) { sphere = lights[2]; } else
    			   { sphere = lights[3]; }
#endif
    intensity = getMaterialFromLibrary(4+index).color;
}

// Geometry functions ***********************************************************
vec2 uniformPointWithinCircle( in float radius, in float Xi1, in float Xi2 ) {
    float r = radius*sqrt(Xi1);
    float theta = Xi2*TWO_PI;
	return vec2( r*cos(theta), r*sin(theta) );
}

vec3 uniformDirectionWithinCone( in vec3 d, in float phi, in float sina, in float cosa ) {    
	vec3 w = normalize(d);
    vec3 u = normalize(cross(w.yzx, w));
    vec3 v = cross(w, u);
	return (u*cos(phi) + v*sin(phi)) * sina + w * cosa;
}

void basis(in vec3 n, out vec3 b1, out vec3 b2) {
    float sign_ = sign(n.z);
	float a = -1.0 / (sign_ + n.z);
	float b = n.x * n.y * a;
	b1 = vec3(1.0 + sign_ * n.x * n.x * a, sign_ * b, -sign_ * n.x);
	b2 = vec3(b, sign_ + n.y * n.y * a, -n.y);
}

vec3 localToWorld( in vec3 localDir, in vec3 normal ) {
    vec3 a,b;
    basis( normal, a, b );
	return localDir.x*a + localDir.y*b + localDir.z*normal;
}

vec3 sphericalToCartesian( in float rho, in float phi, in float theta ) {
    float sinTheta = sin(theta);
    return vec3( sinTheta*cos(phi), sinTheta*sin(phi), cos(theta) )*rho;
}

vec3 sampleHemisphereCosWeighted( in vec3 n, in float Xi1, in float Xi2 ) {
    float theta = acos(sqrt(1.0-Xi1));
    float phi = TWO_PI * Xi2;

    return localToWorld( sphericalToCartesian( 1.0, phi, theta ), n );
}

vec3 randomDirection( in float Xi1, in float Xi2 ) {
    float theta = acos(1.0 - 2.0*Xi1);
    float phi = TWO_PI * Xi2;
    
    return sphericalToCartesian( 1.0, phi, theta );
}
//*****************************************************************************


// BSDF functions *************************************************************
float evaluateBlinn( in  vec3 N, in vec3 E, in vec3 L, in float roughness ) {
    vec3 H = normalize(E + L);
    float dotNH = dot(N,H);
    return (roughness + 2.0) / (8.0 * PI) * pow(dotNH, roughness);
}

vec3 sampleBlinn( in vec3 N, in vec3 E, in float roughness, in float r1, in float r2, out float pdf ) {
    float cosTheta = pow( r1, 1.0/( roughness ) );
    float phi = r2*TWO_PI;
    float theta = acos( cosTheta );
    vec3 H = localToWorld( sphericalToCartesian( 1.0, phi, theta ), N );
    float dotNH = dot(H,N);
    vec3 dir = reflect( E*(-1.0), H );
    
    float normalizationFactor = (roughness + 1.0) / TWO_PI;
    pdf = pow( cosTheta, roughness ) * normalizationFactor;
    pdf *= 1.0/(4.0 * dot(E, H));
    
    return dir;
}

float evaluateLambertian( in vec3 N, in vec3 L ) {
    return clamp( dot( N, L ), 0.0, 1.0 )*INV_PI;
}

vec3 sampleLambertian( in vec3 N, in float r1, in float r2, out float pdf ){
    vec3 dir = sampleHemisphereCosWeighted( N, r1, r2 );
    pdf = INV_PI;//evaluateLambertian( N, dir );
    return dir;
}
//*****************************************************************************

///////////////////////////////////////////////////////////////////////
void initCamera( in vec3 pos, in vec3 frontDir, in vec3 upDir, in float fovV, out Camera dst ) {
	vec3 back = normalize( -frontDir );
	vec3 right = normalize( cross( upDir, back ) );
	vec3 up = cross( back, right );
    dst.rotate[0] = right;
    dst.rotate[1] = up;
    dst.rotate[2] = back;
    dst.fovV = fovV;
    dst.pos = pos;
}

Ray genRay( in Camera camera, in vec2 pixel ) {
	vec2 iPlaneSize=2.*tan(0.5*camera.fovV)*vec2(iResolution.x/iResolution.y,1.);
	vec2 ixy=(pixel/iResolution.xy - 0.5)*iPlaneSize;
    
    Ray ray;
    ray.origin = camera.pos;
	ray.dir = camera.rotate*normalize(vec3(ixy.x,ixy.y,-1.0));

	return ray;
}


bool raySceneIntersection( 	in Ray ray,
                          	in float distMin,
                          	out RaySurfaceHit hit ) {
    hit.obj_id = -1;
    hit.dist = 1000.0;
    hit.E = ray.dir*(-1.0);
    
    //check lights
    for( int i1=0; i1<LIGHT_COUNT; i1++ ){
        float dist;
        if( raySphereIntersection( ray, lights[i1], dist ) && (dist>distMin) && ( dist < hit.dist ) ) {
            hit.dist = dist;
          	vec3 hitpos = ray.origin + ray.dir*hit.dist;
    		hit.N = (hitpos - lights[i1].pos)*(1.0/lights[i1].radius);
    		hit.mtl_id = 4 + i1;
            hit.obj_id = i1;
        }
    }
    
    //check walls
    for( int i=0; i<WALL_COUNT; i++ ){
        float dist;
        if( rayPlaneIntersection( ray, walls[i], dist ) && (dist>distMin) && (dist < hit.dist ) ){
            hit.dist = dist;
//            hit.pos = ray.origin + ray.dir*hit.dist;
    		hit.N = walls[i].abcd.xyz;
    		hit.mtl_id = 0;
            hit.obj_id = LIGHT_COUNT + i;
        }
    }
    
#ifdef SHOW_PLANES
    //check planes
    for( int i=0; i<PLANE_COUNT; i++ ){
        float dist;
        if( rayPlaneIntersection( ray, planes[i], dist ) && (dist>distMin) && (dist < hit.dist ) ){
            vec3 hitPos = ray.origin + ray.dir*dist;
            if( (hitPos.z < planeZRanges[i].max_ ) && (hitPos.z > planeZRanges[i].min_) && (hitPos.x < planeHalfWidth ) && (hitPos.x > -planeHalfWidth ) ) {
                hit.dist = dist;
//                hit.pos = hitPos;
                hit.N = planes[i].abcd.xyz;
                hit.mtl_id = 1+i;
                hit.obj_id = LIGHT_COUNT + WALL_COUNT + i;
            }        
        }
    }
#endif
    
    return ( hit.obj_id != -1 );
}

void sampleSphericalLight( in vec3 x, in Sphere sphere, float Xi1, float Xi2, out LightSamplingRecord sampleRec ) {
#ifdef SAMPLE_LIGHT_AREA
    vec3 n = randomDirection( Xi1, Xi2 );
    vec3 p = sphere.pos + n*sphere.radius;
    float pdfA = 1.0/sphere.area;
    
    vec3 Wi = p - x;
    
    float d2 = dot(Wi,Wi);
    sampleRec.d = sqrt(d2);
    sampleRec.w = Wi/sampleRec.d; 
    float cosTheta = max( 0.0, dot(n, -sampleRec.w) );
    sampleRec.pdf = PdfAtoW( pdfA, d2, cosTheta );
#else
    vec3 w = sphere.pos - x;	//direction to light center
	float dc_2 = dot(w, w);		//squared distance to light center
    float dc = sqrt(dc_2);		//distance to light center
    
    if( dc_2 > sphere.radiusSq ) {
    	float sin_theta_max_2 = sphere.radiusSq / dc_2;
		float cos_theta_max = sqrt( 1.0 - clamp( sin_theta_max_2, 0.0, 1.0 ) );
    	float cos_theta = mix( cos_theta_max, 1.0, Xi1 );
        float sin_theta_2 = 1.0 - cos_theta*cos_theta;
    	float sin_theta = sqrt(sin_theta_2);
        sampleRec.w = uniformDirectionWithinCone( w, TWO_PI*Xi2, sin_theta, cos_theta );
    	sampleRec.pdf = 1.0/( TWO_PI * (1.0 - cos_theta_max) );
        
        //Calculate intersection distance
		//http://ompf2.com/viewtopic.php?f=3&t=1914
        sampleRec.d = dc*cos_theta - sqrt(sphere.radiusSq - dc_2*sin_theta_2);
    } else {
        sampleRec.w = randomDirection( Xi1, Xi2 );
        sampleRec.pdf = 1.0/FOUR_PI;
    	raySphereIntersection( Ray(x,sampleRec.w), sphere, sampleRec.d );
    }
#endif
}

float sphericalLightSamplingPdf( in vec3 x, in vec3 wi, float d, in vec3 n1, in Sphere sphere ) {
#ifdef SAMPLE_LIGHT_SOLIDANGLE
    float solidangle;
    vec3 w = sphere.pos - x;	//direction to light center
	float dc_2 = dot(w, w);		//squared distance to light center
    float dc = sqrt(dc_2);		//distance to light center
    
    if( dc_2 > sphere.radiusSq ) {
    	float sin_theta_max_2 = clamp( sphere.radiusSq / dc_2, 0.0, 1.0);
		float cos_theta_max = sqrt( 1.0 - sin_theta_max_2 );
    	solidangle = TWO_PI * (1.0 - cos_theta_max);
    } else { 
    	solidangle = FOUR_PI;
    }
    
    return 1.0/solidangle;
#else
    float lightPdfA = 1.0/sphere.area;
    float cosTheta1 = max( 0.0, dot( n1, -wi ) );
    return PdfAtoW( lightPdfA, d*d, cosTheta1 );
#endif
}

vec3 sampleBSDF( in vec3 x, in RaySurfaceHit hit, in Material mtl, in bool useMIS ) {
    vec3 Lo = vec3( 0.0 );
    float bsdfSamplingPdf = 1.0/float(BSDF_SAMPLES);
    vec3 n = hit.N * vec3((dot(hit.E, hit.N) < 0.0) ? -1.0 : 1.0);
    
    for( int i=0; i<BSDF_SAMPLES; i++ ) {
        //Generate direction proportional to bsdf
        vec3 bsdfDir;
        float bsdfPdfW;
        float Xi1 = rnd();
        float Xi2 = rnd();
        float strataSize = 1.0 / float(BSDF_SAMPLES);
        Xi2 = strataSize * (float(i) + Xi2);
        
        if( mtl.bsdf_ == BSDF_R_GLOSSY ) {
            bsdfDir = sampleBlinn( n, hit.E, mtl.roughness_, Xi1, Xi2, bsdfPdfW );
        } else {
            bsdfDir = sampleLambertian( n, Xi1, Xi2, bsdfPdfW );
        }
        
        float dotNWi = dot( bsdfDir, n );

        //Continue if sampled direction is under surface
        if( (dotNWi > 0.0) && (bsdfPdfW > EPSILON) ){
            //calculate light visibility
            RaySurfaceHit newHit;
            if( raySceneIntersection( Ray( x, bsdfDir ), EPSILON, newHit ) && (newHit.obj_id < LIGHT_COUNT) ) {
                //Get hit light Info
                vec3 Li;
                Sphere lightSphere;
                getLightInfo( newHit.obj_id, lightSphere, Li );

                //Read light info
                float weight = 1.0;
				float lightPdfW;
                if ( useMIS ) {
                    lightPdfW = sphericalLightSamplingPdf( x, bsdfDir, newHit.dist, newHit.N, lightSphere );
                    lightPdfW *= 1.0/float(LIGHT_COUNT);
                    weight = misWeight( bsdfPdfW, lightPdfW );
                }

                Lo += Li*dotNWi*weight;
            }
        }
    }

    return Lo*bsdfSamplingPdf;
}                        	

int chooseOneLight(in float Xi, out float pdf) {
   	pdf = 1.0/float(LIGHT_COUNT);
    return int(Xi*float(LIGHT_COUNT));
}

vec3 sampleLight( 	in vec3 x, in RaySurfaceHit hit, in Material mtl, in bool useMIS ) {
    vec3 Lo = vec3( 0.0 );	//outgoing radiance
    float lightSamplingPdf = 1.0/float(LIGHT_SAMPLES);
   
    for( int i=0; i<LIGHT_SAMPLES; i++ ) {
        //select light uniformly
        float Xi = rnd();
        float strataSize = 1.0 / float(LIGHT_SAMPLES);
        Xi = strataSize * (float(i) + Xi);
        float lightPickPdf;
        int lightId = chooseOneLight(Xi, lightPickPdf);

        //Read light info
        vec3 Li;				//incomming radiance
        Sphere lightSphere;
        getLightInfo( lightId, lightSphere, Li );
        
        float Xi1 = rnd();
        float Xi2 = rnd();
        LightSamplingRecord sampleRec;
        sampleSphericalLight( x, lightSphere, Xi1, Xi2, sampleRec );
        
        float lightPdfW = lightPickPdf*sampleRec.pdf;
        vec3 Wi = sampleRec.w;
        
        float dotNWi = dot(Wi,hit.N);

        if ( (dotNWi > 0.0) && (lightPdfW > EPSILON) ) {
            Ray shadowRay = Ray( x, Wi );
            RaySurfaceHit newHit;
            bool visible = true;
#ifdef SHADOWS
            visible = ( raySceneIntersection( shadowRay, EPSILON, newHit ) && EQUAL_FLT(newHit.dist,sampleRec.d,EPSILON) );
#endif
            if(visible) {
                float brdf;
    			float brdfPdfW;			//pdf of choosing Wi with 'bsdf sampling' technique
                
                if( mtl.bsdf_ == BSDF_R_GLOSSY ) {
                    brdf = evaluateBlinn( hit.N, hit.E, Wi, mtl.roughness_ );
                    brdfPdfW = brdf;	//sampling Pdf matches brdf
                } else {
                    brdf = evaluateLambertian( hit.N, Wi );
                    brdfPdfW = brdf;	//sampling Pdf matches brdf
                }

                float weight = 1.0;
                if( useMIS ) {
                    weight = misWeight( lightPdfW, brdfPdfW );
                }
                
                Lo += ( Li * brdf * weight * dotNWi ) / lightPdfW;
            }
        }
    }
    
    return Lo*lightSamplingPdf;
}

vec3 Radiance( in Ray ray ) {
    RaySurfaceHit hit;
    if( raySceneIntersection( ray, 0.0, hit ) ) {
    	Material mtl = getMaterialFromLibrary( hit.mtl_id );

        vec3 f, Le;

        if( mtl.bsdf_ == BSDF_R_LIGHT ) {
            Le = mtl.color;
            f = vec3( 1.0, 1.0, 1.0 );
        } else {
            Le = vec3( 0.0 );
            f = mtl.color;
        }
        
        vec3 hitPos = ray.origin + ray.dir*hit.dist;
            
        vec3 directLight = vec3(0.0);
        if( samplingTechnique == SAMPLING_LIGHT ) {
            directLight += sampleLight( hitPos, hit, mtl, false );
        } else if( samplingTechnique == SAMPLING_BSDF ) {
            directLight += sampleBSDF( hitPos, hit, mtl, false );
        } else {
            directLight += sampleBSDF( hitPos, hit, mtl, true );
            directLight += sampleLight( hitPos, hit, mtl, true );
        }

        return Le + f * directLight;
    }

    return backgroundColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    seed = /*iTime +*/ iResolution.y * fragCoord.x / iResolution.x + fragCoord.y / iResolution.y;
    
	float sinTime = sin(iTime*0.2);
    
    Camera camera;
    initScene();
    initMaterialLibrary();
    
    vec2 splitterPos = iMouse.xy;
    if ( splitterPos.x == 0.0 && splitterPos.y == 0.0 ) {
        splitterPos = iResolution.xy*0.5;
    }
    initSamplingTechnique((iMouse.x==0.0)?iResolution.x*0.5:fragCoord.x);
    
    if(samplingTechnique == SAMPLING_NONE) {
        fragColor = vec4( 1.0 );
        return;
    }
	
    Ray ray;
	vec3 accumulatedColor = vec3( 0.0 );
	for(int si=0; si<PIXEL_SAMPLES; ++si ){
        //stratified sampling for t
        float tprev = iTime;
        float tnext = iTime+FRAME_TIME;
        float tStrata = 1.0/float(PIXEL_SAMPLES);
        float tnorm = tStrata*(float(si)+rnd());
        float t = mix(tprev,tnext,tnorm);
        
        //for object motion blur
        updateScene(t);
        
        //update camera for camera motion blur
        vec3 cameraPos = vec3( 0.0, 1.0 + sin(t*0.45), 3.0 + sin(t*0.4)*3.0 );
    	vec3 cameraTarget = vec3( sin(t*0.4)*0.3, 0.0, -5.0 );
    	initCamera( cameraPos, cameraTarget - cameraPos, vec3( 0.0, 1.0, 0.0 ), radians(45.0), camera );
        
        vec2 subPixelCoord = vec2(rnd(), rnd());
        vec2 screenCoord = fragCoord.xy + subPixelCoord;
        ray = genRay( camera, screenCoord );
        
        accumulatedColor += Radiance( ray );
        
#ifdef SHOW_TEXT
        float fontScale = 3.2;
        vec2 offset_brdf = vec2( 2.0*fontScale, 0.0 )*fontScale;
        vec2 offset_mis = vec2( 1.5*fontScale, 0.0 )*fontScale;
        vec2 offset_light = vec2( 2.0*fontScale, 0.0 )*fontScale;

        if( is_point_on_BRDF( (screenCoord.xy - vec2(split1*0.5,iResolution.y*0.03) + offset_brdf )*(1.0/fontScale) ) ) {
            float val = clamp(split1/iResolution.x, 0.0, 0.9 );
            accumulatedColor += vec3( val ); 
        }
        
        if( is_point_on_MIS( (screenCoord.xy - vec2((split1+split2)*0.5,iResolution.y*0.03) + offset_mis )*(1.0/fontScale) ) ) {
            float val = clamp((split2-split1)/(0.6*iResolution.x), 0.0, 0.9 );
            accumulatedColor += vec3( val );
        }
        
        if( is_point_on_LIGHT( (screenCoord.xy - vec2((split2+iResolution.x)*0.5,iResolution.y*0.03) + offset_light )*(1.0/fontScale) )) {
            float val = clamp((iResolution.x-split2)/iResolution.x, 0.0, 0.9 );
            accumulatedColor += vec3( val );
        }
#endif
	}
	
	//devide to sample count
	accumulatedColor = accumulatedColor*(1.0/float(PIXEL_SAMPLES));
	
	//gamma correction
    accumulatedColor = pow( accumulatedColor, vec3( 1.0 / GAMMA ) );
    
	fragColor = vec4( accumulatedColor,1.0 );
}
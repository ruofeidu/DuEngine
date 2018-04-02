// 
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Forked from https://www.shadertoy.com/view/XljGWR
// Distance function, camera setup and base for raymarching from iq's // https://www.shadertoy.com/view/Xds3zN


#define OBJECT_MAP_FUNCTION map1

#define calcRecursion rec3 // use n rays levels (rays1 to rays6): total  RAY_COUNT = 2^n-1
#define DIST_EPSILON 0.005

#define ID_SKY 2.001
#define ID_FLOOR 1.
#define ID_LIGHT 1.001
#define ID_GLASS_WALL 2.000
#define ETA 0.85
#define M_PI				3.1415926535897932384626433832795

#define DENSITY_MIN 0.1
#define DENSITY_MAX 0.1
#define MATERIAL_COLOR vec3(0.5,0.8,1)*0.1
#define AIR_COLOR vec3(0.5,0.8,1)*0.1


#define SURFACE_COLOR vec3(0.8,1.,0.9)
//#define SURFACE_COLOR vec3(0.8,1.,0.8)*(1.-0.2* mod( floor(5.0*p.z) + floor(5.1*p.x) + floor(5.1*p.y), 2.0))
//#define SURFACE_COLOR vec3(0.8,1.,0.8)*(0.6+0.4*noise(p.xz*30. + p.yz*23.))
 vec3 LIGHT_DIR = normalize(vec3(-0.6,0.7,-0.3));
//-------------------------------------------------------------------------------

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 n) {
	const vec2 d = vec2(0.0, 1.0);
	vec2 b = floor(n), f = smoothstep(vec2(0.0), vec2(1.0), fract(n));
	return mix(mix(rand(b), rand(b + d.yx), f.x), mix(rand(b + d.xy), rand(b + d.yy), f.x), f.y);
}

struct CP {
    float dist;
    vec3 normal;
    float mat;
    vec3 p;
};
    
    
struct Ray {
    vec3 rd;
    CP cp;
    vec3 col;
    float share;
    float eta;
};
    
    
//-------------------------------------------------------------------------------
//  https://www.shadertoy.com/view/Xds3zN
float sdBox( vec3 p, vec3 b )
{
   vec3 d = abs(p) - b;
   return (min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0)));
}

float sdSphere( vec3 p, float r)
{
   return (length(p)-r);
}

float sdPlane( vec3 p )
{
	return p.y;
}

float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  return abs(length(max(abs(p)-b,0.0))-r);
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}


float sdCone( vec3 p, vec2 c )
{
    // c must be normalized
    float q = length(p.xy);
    return dot(c,vec2(q,p.z));
}

vec3 opU( vec3 d1, vec3 d2 )
{
   
	return (d1.x<d2.x) ? d1 : d2;
}

vec3 opS(  vec3 d1, vec3 d2 )
{
    return -d1.x>d2.x ? d2: d1;
}

//-------------------------------------------------------------------------------



vec3 map1(in vec3 pos) {
    vec3 res =  vec3((sdCappedCylinder(pos-vec3(0,0.49,-0.4), vec2(0.3,0.5))), ID_GLASS_WALL, ETA);
    res = opU(res, vec3(sdSphere(pos-vec3(0.,0.31,0.4),0.3),ID_GLASS_WALL, ETA));
  //  res = opU(res, vec3(sdTorus(pos.yxz-vec3(0.3,0.,-0.7),vec2(0.2,0.1)),ID_GLASS_WALL, ETA));
    res.x =abs(res.x);
   
 	return res;
}

vec3 map(in vec3 pos) {
    vec3 res = vec3(sdPlane(pos), ID_FLOOR, -1. );
	return opU(res, OBJECT_MAP_FUNCTION(pos));    
}

//-------------------------------------------------------------------------------

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.0001, 0.0, 0.0 );
    float d = map(pos).x;
    return normalize( vec3(
	    map(pos+eps.xyy).x - d,
	    map(pos+eps.yxy).x - d,
	    map(pos+eps.yyx).x - d)
	);
}

              
CP findIntersection(vec3 p, vec3 rd) {
     
    float tmin = 0.000;
    float tmax = 50.0;
    
	float precis = DIST_EPSILON;
    float t = tmin;
    float eta = -1.;
    vec3 res;
    for( int i=0; i<50; i++ )
    {
	  	res = map(p+rd*t);
        eta = res.z;
        if( res.x<precis || t>tmax ) break;
        t += res.x;
    }
    
    p+=rd*t;
    // calculate normal in the father point to avoid artifacts
    vec3 n = calcNormal(p-rd*(precis-res.x));
    CP cp = CP(t, n, res.y, p);

    return cp;
}

//-------------------------------------------------------------------------------


vec3 refractCaustic(vec3 p, vec3 rd, vec3 ld, float eta) {
     vec3 cl = vec3(1);
    for(int j = 0; j < 2; ++j) {

        CP cp = findIntersection(p, rd);
        if (length(cp.p) > 2.) {
            break;
        }
        cl *= SURFACE_COLOR;//*(abs(dot(rd, cp.normal)));
        vec3 normal = sign(dot(rd, cp.normal))*cp.normal;
        rd = refract(rd, -normal, eta);

        p = cp.p;
        eta = 1./eta;
        p += normal*DIST_EPSILON*2.;
    }
     float d = clamp( dot( rd, ld ), 0.0, 1.0 );
     return smoothstep(0.99, 1., d)*cl;
}

vec3 caustic(vec3 p,vec3 ld, Ray ray) {
    vec3 VX = normalize(cross(ld, vec3(0,1,0)));
	vec3 VY = normalize(cross(ld, VX));     
    vec3 c = vec3(0);
    
    const int N =3;
    p += ray.cp.normal*DIST_EPSILON;
   
    for(int i = 0; i < N;++i) {
        
        float n1 = rand(p.xz*10. + vec2(iTime*2. +float(i)*123.));
        float n2 = rand(p.xz*15. +vec2(iTime*3. +float(i)*111.));

        vec3 rd = ld+(VX*(n1-0.5)+VY*(n2-0.5))*0.1;
       // rd = ld;
        rd = normalize(rd);

 		vec3 cl = refractCaustic(p, rd, ld, ray.eta);
        
      	c += cl* dot(rd,ray.cp.normal);
    }
    return c*3./float(N);
}

// lightning is based on https://www.shadertoy.com/view/Xds3zN
vec3 getFloorColor(in Ray ray) {
    
    vec3 col = vec3(0);
    vec3 pos = ray.cp.p;
    vec3 ref = reflect( ray.rd, ray.cp.normal );
    
    float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
    col = 0.4 + 0.1*f*vec3(1.0);

    float dif = clamp( dot( ray.cp.normal, LIGHT_DIR ), 0.0, 1.0 );
    vec3 brdf = vec3(0.0);
    brdf += caustic(pos, LIGHT_DIR, ray);
    brdf += 1.20*dif*vec3(1.00,0.90,0.60);
    col = col*brdf;
    // exclude branching
    col *= (ID_GLASS_WALL-ray.cp.mat);

    return col;
}
    

vec3 getColor(in Ray ray) {

    vec3 p = ray.cp.p ;// can be used by SURFACE_COLOR define
    vec3 c1 = ray.col * SURFACE_COLOR;
    vec3 c2 = getFloorColor(ray);
    // exclude branching
    return mix(c2, c1, ray.cp.mat - ID_FLOOR);

}    

//-------------------------------------------------------------------------------


vec3 getRayColor(Ray ray) {


    float d = mix(DENSITY_MIN, DENSITY_MAX, (ray.eta - ETA)/(1./ETA-ETA));
    vec3 matColor = mix(AIR_COLOR, MATERIAL_COLOR, (ray.eta - ETA)/(1./ETA-ETA));
    vec3 col = getColor(ray);

    float q = exp(-d*ray.cp.dist);
    col = col*q+matColor*(1.-q);
    return col*ray.share;
}

void getRays(inout Ray ray, out Ray r1, out Ray r2) {
     vec3 p = ray.cp.p;
    float cs = dot(ray.cp.normal, ray.rd);
    // simple approximation
    float fresnel = 1.0-abs(cs);
//	fresnel = mix(0.1, 1., 1.0-abs(cs));
    float r = ray.cp.mat - ID_FLOOR;
     vec3 normal = sign(cs)*ray.cp.normal;
    vec3 refr = refract(ray.rd, -normal, ray.eta);
    vec3 refl = reflect(ray.rd, ray.cp.normal);
    vec3 z = normal*DIST_EPSILON*2.;
    p += z;
    r1 = Ray(refr, findIntersection(p, refr),  vec3(0),(1.-fresnel)*r, 1./ray.eta);
    p -= 2.*z;
    r2 = Ray( refl, findIntersection(p, refl), vec3(0),r*fresnel, ray.eta);
}
    
// set of "recursion" functions

void rec1(inout Ray ray) {
    ray.col += getRayColor(ray);
}


void rec2(inout Ray ray) {
	
    Ray r1,r2;
    getRays(ray, r1, r2);

    ray.col += getRayColor(r1);
    ray.col += getRayColor(r2);
}

void rec3(inout Ray ray) {
    
    Ray r1,r2;
    getRays(ray, r1, r2);
    
    rec2(r1);
    ray.col += getRayColor(r1);
    // use first level of relfection rays only to improve performance
    rec1(r2);
    ray.col += getRayColor(r2);
}

void rec4(inout Ray ray) {
    Ray r1,r2;
    getRays(ray, r1, r2);
    
    rec3(r1);
    ray.col += getRayColor(r1);
    // use first level of relfection rays only to improve performance
    rec1(r2);
    ray.col += getRayColor(r2);
}

void rec5(inout Ray ray) {
    Ray r1,r2;
    getRays(ray, r1, r2);
    
    rec4(r1);
    ray.col += getRayColor(r1);
    // use first level of relfection rays only to improve performance
    rec1(r2);
    ray.col += getRayColor(r2);
}

void rec6(inout Ray ray) {
    Ray r1,r2;
    getRays(ray, r1, r2);
    
    rec5(r1);
    ray.col += getRayColor(r1);
    
    // use only first level of relfection to improve performance
    rec1(r2);
    ray.col += getRayColor(r2);
}



vec3 castRay(vec3 p, vec3 rd) {
    CP cp = findIntersection(p, rd);
   
    Ray ray = Ray( rd, cp, vec3(0), 1., ETA);
    calcRecursion(ray);
    ray.col = getRayColor(ray);
	return ray.col;
    
}

vec3 render(vec3 p, vec3 rd) {
    vec3 col= castRay(p, rd);
    return col;
}

// https://www.shadertoy.com/view/Xds3zN
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy-0.5;

    uv.x*=iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy/iResolution.xy;
    // this strange construction is used to define initial view angle
    // simple "IF" condition can work incorrectly on weak GPU 
    // (at least on one of tested computers_
    mo = mix(vec2(0.6,0.3),mo, sign(mo.x+mo.y));


    mo.y+=0.02;
	mo.y *=1.57;
    float time =0.;//sin(iTime);//iTime*0.1;;
	mo.x*=10.;
    float R = 4.3;
    
    float Y = sin(mo.y);
    float X = cos(mo.y);
	vec3 ro = vec3(cos(time + mo.x)*X, Y, X*sin(time + mo.x) )*R;
	vec3 ta = vec3( 0,0.4,0);
	
	// camera-to-world transformation
    mat3 ca = setCamera( ro, ta,0. );
    
    // ray direction
	vec3 rd = ca * normalize( vec3(uv.xy,2.5) );
    
    vec3 c = render(ro, rd);

	fragColor = vec4(c, 1);
}
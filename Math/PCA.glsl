// XlsGRl
// fit a plane to a point cloud using least squares via singular value decomposition (SVD)
// the technique is called PCA (Principle Component Analysis)

// number of random points to track
// you need at least 3 or ... well.
// less points need more sweeps.
#define POINT_COUNT 13

// set to 1 to see some mightly fine plane fittin'
#define SHAPE_CLOUD 0

// plane needs to orient towards smallest eigenvalue, so leave this on
#define SORT_EIGENVALUES 1

// SVD parts are public domain

// for some reason, too many sweeps ruin the anisotropic distribution
// of the eigenvalues; so higher is not always better.
#define SVD_NUM_SWEEPS 6

// use approximate eigensolver instead
#define INVERSE_ITER_EIGEN 0

// GLSL prerequisites

#define IN(t,x) in t x
#define OUT(t, x) out t x
#define INOUT(t, x) inout t x
#define rsqrt inversesqrt

#define SWIZZLE_XYZ(v) v.xyz
            
// SVD
////////////////////////////////////////////////////////////////////////////////

const float Small_Number = 1.e-3;
const float Tiny_Number = 1.e-20;

void givens_coeffs_sym(float a_pp, float a_pq, float a_qq, OUT(float,c), OUT(float,s)) {
    if (a_pq == 0.0) {
        c = 1.0;
        s = 0.0;
        return;
    }
    float tau = (a_qq - a_pp) / (2.0 * a_pq);
    float stt = sqrt(1.0 + tau * tau);
    float tan = 1.0 / ((tau >= 0.0) ? (tau + stt) : (tau - stt));
    c = rsqrt(1.0 + tan * tan);
    s = tan * c;
}

void svd_rotate_xy(INOUT(float,x), INOUT(float,y), IN(float,c), IN(float,s)) {
    float u = x; float v = y;
    x = c * u - s * v;
    y = s * u + c * v;
}

void svd_rotateq_xy(INOUT(float,x), INOUT(float,y), INOUT(float,a), IN(float,c), IN(float,s)) {
    float cc = c * c; float ss = s * s;
    float mx = 2.0 * c * s * a;
    float u = x; float v = y;
    x = cc * u - mx + ss * v;
    y = ss * u + mx + cc * v;
}

void svd_rotate01(INOUT(mat3,vtav), INOUT(mat3,v)) {
    if (vtav[0][1] == 0.0) return;
    
    float c, s;
    givens_coeffs_sym(vtav[0][0], vtav[0][1], vtav[1][1], c, s);
    svd_rotateq_xy(vtav[0][0],vtav[1][1],vtav[0][1],c,s);
    svd_rotate_xy(vtav[0][2], vtav[1][2], c, s);
    vtav[0][1] = 0.0;
    
    svd_rotate_xy(v[0][0], v[0][1], c, s);
    svd_rotate_xy(v[1][0], v[1][1], c, s);
    svd_rotate_xy(v[2][0], v[2][1], c, s);
}

void svd_rotate02(INOUT(mat3,vtav), INOUT(mat3,v)) {
    if (vtav[0][2] == 0.0) return;
    
    float c, s;
    givens_coeffs_sym(vtav[0][0], vtav[0][2], vtav[2][2], c, s);
    svd_rotateq_xy(vtav[0][0],vtav[2][2],vtav[0][2],c,s);
    svd_rotate_xy(vtav[0][1], vtav[1][2], c, s);
    vtav[0][2] = 0.0;
    
    svd_rotate_xy(v[0][0], v[0][2], c, s);
    svd_rotate_xy(v[1][0], v[1][2], c, s);
    svd_rotate_xy(v[2][0], v[2][2], c, s);
}

void svd_rotate12(INOUT(mat3,vtav), INOUT(mat3,v)) {
    if (vtav[1][2] == 0.0) return;
    
    float c, s;
    givens_coeffs_sym(vtav[1][1], vtav[1][2], vtav[2][2], c, s);
    svd_rotateq_xy(vtav[1][1],vtav[2][2],vtav[1][2],c,s);
    svd_rotate_xy(vtav[0][1], vtav[0][2], c, s);
    vtav[1][2] = 0.0;
    
    svd_rotate_xy(v[0][1], v[0][2], c, s);
    svd_rotate_xy(v[1][1], v[1][2], c, s);
    svd_rotate_xy(v[2][1], v[2][2], c, s);
}

float svd_off(IN(mat3,a)) {
    return sqrt(2.0 * ((a[0][1] * a[0][1]) + (a[0][2] * a[0][2]) + (a[1][2] * a[1][2])));
}


void svd_solve_sym(IN(mat3,a), OUT(vec3,sigma), INOUT(mat3,v)) {
    // assuming that A is symmetric: can optimize all operations for 
    // the lower left triagonal
    mat3 vtav = a;
    // assuming V is identity: you can also pass a matrix the rotations
    // should be applied to
    // U is not computed
    for (int i = 0; i < SVD_NUM_SWEEPS; ++i) {
        if (svd_off(vtav) < Small_Number)
            continue;
        svd_rotate01(vtav, v);
        svd_rotate02(vtav, v);
        svd_rotate12(vtav, v);        
    }
    sigma = vec3(vtav[0][0],vtav[1][1],vtav[2][2]);    
}

// QEF
////////////////////////////////////////////////////////////////////////////////

void qef_add(
    IN(vec3,p),
    IN(vec3,masspoint),
    INOUT(mat3,ATA)) {
    p -= masspoint;
    ATA[0][0] += p.x * p.x;
    ATA[0][1] += p.x * p.y;
    ATA[0][2] += p.x * p.z;
    ATA[1][1] += p.y * p.y;
    ATA[1][2] += p.y * p.z;
    ATA[2][2] += p.z * p.z;
}

void swap(inout float a, inout float b) {
    float x = a;
    a = b;
    b = x;
}

void swap_vec3(inout vec3 a, inout vec3 b) {
    vec3 x = a;
    a = b;
    b = -x;
}

mat3 transp(mat3 m) {
    return mat3(
        	m[0][0], m[1][0], m[2][0],
        	m[0][1], m[1][1], m[2][1],
        	m[0][2], m[1][2], m[2][2]
        );
}

// approximate eigensolver for smallest eigenvalue
// tuned by ryg

const float singularEps = 2.0 * 1.192092896e-7; // float32 epsilon, *2 to have a bit of margin

// QR factorization using MGS
// store 1 / diag elements in diag of R since that's what we need
bool QR(IN(mat3,m),OUT(mat3,q),OUT(mat3,r)) {
    q[0] = normalize(m[0]);
    q[1] = normalize(m[1] - dot(m[1], q[0])*q[0]);
    q[2] = cross(q[0], q[1]);

    float d0 = dot(m[0], q[0]);
    float d1 = dot(m[1], q[1]);
    float d2 = dot(m[2], q[2]);
    float maxd = max(max(abs(d0), abs(d1)), abs(d2));
    float mind = min(min(abs(d0), abs(d1)), abs(d2));

    // Are we numerically singular? (This test is written to work
    // in the presence of NaN/Inf; using >= won't work right.)
    if (!(maxd * singularEps < mind))
        return false;
    
    r[0] = vec3(1.0 / d0, 0.0, 0.0);
    r[1] = vec3(dot(m[1],q[0]), 1.0 / d1, 0.0);
    r[2] = vec3(dot(m[2],q[0]), dot(m[2],q[1]), 1.0 / d2);
    return true;
}

// matrix a must be upper triangular
// with main diagonal storing reciprocal of actual vals
vec3 solve_Ux_b(IN(mat3,a), IN(vec3,b)) {
    float x2 = b[2] * a[2][2];
    float x1 = (b[1] - a[2][1]*x2) * a[1][1];
    float x0 = (b[0] - a[1][0]*x1 - a[2][0]*x2) * a[0][0];
    return vec3(x0,x1,x2);
}    

// rayleigh quotient iteration from Q R matrices
void rayleigh_quot(IN(mat3,a), INOUT(float,mu), INOUT(vec3, x)) {
    mat3 q, r;
    vec3 y = x;
    for (int i = 0; i < 5; ++i) {
        x = y / length(y);
        if (!QR(a - mat3(mu), q, r))
            break;
        y = solve_Ux_b(r, x * q);
        mu = mu + 1.0 / dot(y,x);
    }
}

// inverse iter to find EV closest to mu
void inverse_iter(IN(mat3,a), INOUT(float,mu), INOUT(vec3, x)) {
    mat3 q, r;

    // If a - mat3(mu) is singular, we already have an eigenvector!
    if (!QR(a - mat3(mu), q, r))
        return;

    // If you know eigenvalues aren't too large/small, can skip
    // normalize here. (It's only there to present over-/underflow.)
    // Normalizing once at the end (before calc of mu) works fine.
    for (int i = 0; i < 4; ++i)
        x = normalize(solve_Ux_b(r, x * q));

    mu = dot(x, a*x);
}

vec3 orthogonal(vec3 v)
{
    return abs(v.x) > abs(v.z) ? vec3(-v.y, v.x, 0.0)
                               : vec3(0.0, -v.z, v.y);
}


mat3 qef_solve(IN(mat3,ATA), OUT(vec3,sigma)) {
#if INVERSE_ITER_EIGEN    
    ATA[1][0] = ATA[0][1];
    ATA[2][0] = ATA[0][2];
    ATA[2][1] = ATA[1][2];
    
    vec3 e0 = vec3(1.0);    
    float mu = 0.0; 
    // so the problem with rayleigh is that it really likes to latch on to
    // the eigenvalue with largest absolute value.
    // better to use normal inverse iteration if we want the EV closest to 0!
    //rayleigh_quot(a, mu, x);
 
    // once to get close to smallest EV, second pass to polish
    inverse_iter(ATA, mu, e0);
    inverse_iter(ATA, mu, e0);

    mat3 iATA = inverse(ATA);
    vec3 e1 = vec3(1.0);
    float mu2 = 0.0;
    inverse_iter(iATA, mu2, e1);
    inverse_iter(iATA, mu2, e1);
    

    //vec3 e1 = orthogonal(e0);
    vec3 e2 = cross(e0,e1);
    sigma = vec3(1.0,1.0,max(0.01,sqrt(mu)*0.5));
    return mat3(e2,e1,e0);
#else // SVD
    mat3 V = mat3(1.0);
    
    svd_solve_sym(ATA, sigma, V);
    V = transp(V);
    
#if SORT_EIGENVALUES    
    if (sigma[0] < sigma[1]) {
        swap(sigma[0],sigma[1]);
        swap_vec3(V[0],V[1]);
    }
    if (sigma[0] < sigma[2]) {
        swap(sigma[0],sigma[2]);
        swap_vec3(V[0],V[2]);
    }
    if (sigma[1] < sigma[2]) {
        swap(sigma[1],sigma[2]);
        swap_vec3(V[1],V[2]);
    }
#endif    
    sigma = vec3(sqrt(sigma[0]),sqrt(sigma[1]),sqrt(sigma[2]))*0.5;
    
    return V;
#endif
}

// uncomment for a cross section view
//#define CROSS_SECTION

//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 10.0*mouseX;
	camPos = vec3(4.5*sin(an),2.0,4.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}


//------------------------------------------------------------------------
// Background 
//
// The background color. In this case it's just a black color.
//------------------------------------------------------------------------
vec3 doBackground( void )
{
    return vec3( 0.0, 0.0, 0.0);
}

vec3 min3(vec3 a, vec3 b) {
    return (a.x <= b.x)?a:b;
}

vec3 max3(vec3 a, vec3 b) {
    return (a.x > b.x)?a:b;
}

void rotate_xy(inout float x, inout float y, in float a) {
    float c = cos(a);
    float s = sin(a);
    float u = x; float v = y;
    x = c * u - s * v;
    y = s * u + c * v;
}

// Fractional Brownian Motion code by IQ.

float noise( float x, float y )
{
	return sin(1.5*x)*sin(1.5*y);
}

const mat2 m = mat2( 0.80,  0.60, -0.60,  0.80 );
float fbm4( float x, float y )
{
    vec2 p = vec2( x, y );
    float f = 0.0;
    f += 0.5000*noise( p.x, p.y ); p = m*p*2.02;
    f += 0.2500*noise( p.x, p.y ); p = m*p*2.03;
    f += 0.1250*noise( p.x, p.y ); p = m*p*2.01;
    f += 0.0625*noise( p.x, p.y );
    return f/0.9375;
}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

vec3 hsv2rgb(vec3 c) {
    vec3 rgb = hue2rgb(c.x);
    return c.z * mix(vec3(1.0), rgb, c.y);
}


//------------------------------------------------------------------------
// Modelling 
//
// Defines the shapes (a sphere in this case) through a distance field
//------------------------------------------------------------------------

#define POINT_PT_R 0.05
#define AXIS_PT_R 0.01
#define CENTER_PT_R 0.15

vec3 points[POINT_COUNT];
vec3 center;
mat3 orientation;
vec3 sigma;

void update_points() {
	mat3 ATA = mat3(0.0);
	vec4 pointaccum = vec4(0.0);
    
    float t = iTime*0.05;
    for (int i = 0; i < POINT_COUNT; ++i) {
        vec3 f = float(i) * vec3(1.0,3.0,5.0);
        points[i] = vec3(fbm4(f.y+t,f.z+t),fbm4(f.x+t,f.z+t),fbm4(f.x+t,f.y+t))*3.0;
#if SHAPE_CLOUD        
        points[i].x *= 0.21;
        float d = points[i].z + points[i].y;        
        points[i].z = mix(points[i].z, d, 0.9);
        points[i].y = mix(points[i].y, d, 0.5);
#endif
        pointaccum += vec4(points[i],1.0);
    }
    
    center = pointaccum.xyz / pointaccum.w;    

    for (int i = 0; i < POINT_COUNT; ++i) {
	    qef_add(points[i], center, ATA);
    }
    
    orientation = qef_solve(ATA, sigma);
}

float sphere(vec3 p, float r) {
    return length(p) - r;
}

vec3 doModel2( vec3 p ) {
    vec3 s = vec3(sphere(p - points[0], POINT_PT_R),0.9,1.0);
    for (int i = 1; i < POINT_COUNT; ++i) {
        s = min3(s, vec3(sphere(p - points[i], POINT_PT_R),0.9,1.0));
    }
    
    s = min3(s, vec3(sdCapsule(p, center, center + orientation[0]*sigma.x, AXIS_PT_R),0.0,1.0));
    s = min3(s, vec3(sdCapsule(p, center, center + orientation[1]*sigma.y, AXIS_PT_R),0.33,1.0));
    s = min3(s, vec3(sdCapsule(p, center, center + orientation[2]*sigma.z, AXIS_PT_R),0.66,1.0));
    
    s = min3(s, vec3(udRoundBox((p - center) * orientation, vec3(sigma.x,sigma.y,0.005), 0.0),0.0,0.0));
    
  	return s;
}

float doModel( vec3 p ) {
    return doModel2(p).x;
}
    
//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------
vec3 doMaterial( in vec3 pos, in vec3 nor )
{
    vec3 m = doModel2(pos);
    
    return hsv2rgb(vec3(m.yz,0.5))*0.5;
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
float calcSoftshadow( in vec3 ro, in vec3 rd );

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec3 mal )
{
    vec3 lin = vec3(0.0);

    // key light
    //-----------------------------
    vec3  lig = normalize(vec3(1.0,0.7,0.9));
    float dif = max(dot(nor,lig),0.0);
    float sha = 0.0; if( dif>0.01 ) sha=calcSoftshadow( pos+0.01*nor, lig );
    lin += dif*vec3(4.00,4.00,4.00)*sha;

    // ambient light
    //-----------------------------
    lin += vec3(0.50,0.50,0.50);

    
    // surface-light interacion
    //-----------------------------
    vec3 col = mal*lin;

    
    // fog    
    //-----------------------------
	col *= exp(-0.01*dis*dis);

    return col;
}

float calcIntersection( in vec3 ro, in vec3 rd )
{
	const float maxd = 20.0;           // max trace distance
	const float precis = 0.001;        // precission of the intersection
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<90; i++ )          // max number of raymarching iterations is 90
    {
        if( h<precis||t>maxd ) break;
	    h = doModel( ro+rd*t );
        t += h;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 calcNormal( in vec3 pos )
{
    const float eps = 0.002;             // precision of the normal computation

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*doModel( pos + v1*eps ) + 
					  v2*doModel( pos + v2*eps ) + 
					  v3*doModel( pos + v3*eps ) + 
					  v4*doModel( pos + v4*eps ) );
}

float calcSoftshadow( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.0005;                 // selfintersection avoidance distance
	float h = 1.0;
    for( int i=0; i<40; i++ )         // 40 is the max numnber of raymarching steps
    {
        h = doModel(ro + rd*t);
        res = min( res, 64.0*h/t );   // 64 is the hardness of the shadows
		t += clamp( h, 0.02, 2.0 );   // limit the max and min stepping distances
    }
    return clamp(res,0.0,1.0);
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;

    update_points();

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iTime, m.x );

    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
	// create view ray
	vec3 rd = normalize( camMat * vec3(p.xy,2.0) ); // 2.0 is the lens length

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	vec3 col = doBackground();

	// raymarch
    float t = calcIntersection( ro, rd );
    if( t>-0.5 )
    {
        // geometry
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);

        // materials
        vec3 mal = doMaterial( pos, nor );

        col = doLighting( pos, nor, rd, t, mal );
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.4545) );
	   
    fragColor = vec4( col, 1.0 );
}

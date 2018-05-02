// MdtBD8
// This enables/disables the pretty but
// expensive background wall

//#define FUN_WALL

// These delays can be used to switch to
// to fullscreen before accumulation begins
#ifdef FUN_WALL
#define DELAY 10
#else
#define DELAY 30
#endif

const vec3 box_size = vec3(3.0,1.0,3.0);
const vec4 spherePos = vec4( 0.0,-0.4,1.8, 0.4);
const vec3 sphereCol = vec3( 1.0, 0.4, 0.6 );
const float wiggle = 1.0;
const float tau = 6.28318;

float hash1( uint n ) 
{
    // integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
    n = n * (n * n * 15731U + 789221U) + 1376312589U;
    return float( n & uvec3(0x7fffffffU))/float(0x7fffffff);
}

#define MOD3 vec3(.1031,.11369,.13787)
float hash31(vec3 p3)
{
	p3  = fract(p3 * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return -1.0 + 2.0 * fract((p3.x + p3.y) * p3.z);
}

#ifdef FUN_WALL
vec3 hash33(vec3 p3)
{
	p3 = fract(p3 * MOD3);
    p3 += dot(p3, p3.yxz+19.19);
    return -1.0 + 2.0 * 
        fract(vec3((p3.x + p3.y)*p3.z, 
                   (p3.x+p3.z)*p3.y, 
                   (p3.y+p3.z)*p3.x));
}

float simplex_noise(vec3 p)
{
    const float K1 = 0.333333333;
    const float K2 = 0.166666667;
    
    vec3 i = floor(p + (p.x + p.y + p.z) * K1);
    vec3 d0 = p - (i - (i.x + i.y + i.z) * K2);
    
    // thx nikita: https://www.shadertoy.com/view/XsX3zB
    vec3 e = step(vec3(0.0), d0 - d0.yzx);
	vec3 i1 = e * (1.0 - e.zxy);
	vec3 i2 = 1.0 - e.zxy * (1.0 - e);
    
    vec3 d1 = d0 - (i1 - 1.0 * K2);
    vec3 d2 = d0 - (i2 - 2.0 * K2);
    vec3 d3 = d0 - (1.0 - 3.0 * K2);
    
    vec4 h = max(0.6 - vec4(dot(d0, d0), dot(d1, d1), 
                            dot(d2, d2), dot(d3, d3)), 0.0);
    vec4 n = h * h * h * h * vec4(dot(d0, hash33(i)), 
                                  dot(d1, hash33(i + i1)), 
                                  dot(d2, hash33(i + i2)), 
                                  dot(d3, hash33(i + 1.0)));
    
    return dot(vec4(31.316), n);
}

float noise_sum_abs(vec3 p)
{
    float f = 0.0;
    p = p * 3.0;
    f += 1.0000 * abs(simplex_noise(p)); p = 2.0 * p;
    f += 0.5000 * abs(simplex_noise(p)); p = 2.0 * p;
	f += 0.2500 * abs(simplex_noise(p)); p = 2.0 * p;
	f += 0.1250 * abs(simplex_noise(p)); p = 2.0 * p;
	f += 0.0625 * abs(simplex_noise(p)); p = 2.0 * p;
    
    return f;
}

float noise_sum_abs_sin(vec3 p)
{
    float f = noise_sum_abs(p);
    f = sin(f * 2.5 + p.x * 5.0 - 1.5);
    
    return f ;
}
#endif

float hash71( vec3 p, vec3 dir, int t) {
    float a = hash1( uint(t) );
 	float b = hash31(p);
    float c = hash31(dir);
    return hash31(vec3(a,b,c));
}

// from https://math.stackexchange.com/questions/44689/how-to-find-a-random-axis-or-unit-vector-in-3d
vec3 randomDir( vec3 p, vec3 dir, int t) {
    float a = hash1( uint(t) );
 	float b = hash31(p);
    float c = hash31(dir);
    float theta = tau*hash31(vec3(a,b,c));
    float z = 2.0*hash31( 
        vec3( c+1.0, 2.0*a+3.5, b*1.56+9.0 ) ) - 1.0;
    float m = sqrt(1.0-z*z);
   	return vec3( m*sin(theta), m*cos(theta), z );
}



float sdBox( vec3 p, vec3 b )
{
#ifdef FUN_WALL
  if (p.z>1.45 && abs(p.x) < 2.7){
	p.z += 
        0.25*(smoothstep(2.7, 1.5, abs(p.x)))
        *noise_sum_abs_sin(0.3*p);
  }
#endif
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) 
    + length(max(d,0.0));
}

float sdPlane( vec3 p, vec4 n )
{
  // n must be normalized
  return dot(p,n.xyz) + n.w;
}

float sdSphereReg( vec3 p, float s )
{
  return length(p)-s;
}

float sdSphere( vec3 p, float s )
{
  p.x *= 0.3;
  return length(p+vec3(0.0,0.2*sin(15.0*p.x),0.0))-s;
}

float map( vec3 p) {
    float d = 1000000.0;
    d = min( d, sdSphere(p-spherePos.xyz, spherePos.w));
    d = min( d, -sdBox( p, box_size ) );
    return d;
}

vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*0.0005;
    return normalize( e.xyy*map( pos + e.xyy ) + 
					  e.yyx*map( pos + e.yyx ) + 
					  e.yxy*map( pos + e.yxy ) + 
					  e.xxx*map( pos + e.xxx ) );
}

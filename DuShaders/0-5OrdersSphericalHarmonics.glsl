// Created by inigo quilez - iq/2013
// Added the 4th order of SH - ruofei/2017
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Five bands of Spherical Harmonics functions (or atomic orbitals if you want).
// For reference and fun.



// antialias level (try 1, 2, 3, ...)
#define AA 1
// change TIME to 0 to stop rotating
#define TIME iTime

//#define SHOW_SPHERES

//---------------------------------------------------------------------------------

// Constants, see here: http://en.wikipedia.org/wiki/Table_of_spherical_harmonics
#define k01 0.28209479177387814 // Math.sqrt(  1/Math.PI)/2
#define k02 0.4886025119029199  // Math.sqrt(  3/Math.PI)/2
#define k03 1.0925484305920792  // Math.sqrt( 15/Math.PI)/2
#define k04 0.31539156525252005 // Math.sqrt(  5/Math.PI)/4
#define k05 0.5462742152960396  // Math.sqrt( 15/Math.PI)/4
#define k06 0.5900435899266435  // Math.sqrt( 70/Math.PI)/8
#define k07 2.890611442640554   // Math.sqrt(105/Math.PI)/2
#define k08 0.4570457994644658  // Math.sqrt( 42/Math.PI)/8
#define k09 0.3731763325901154  // Math.sqrt(  7/Math.PI)/4
#define k10 1.445305721320277   // Math.sqrt(105/Math.PI)/4

#define k11 2.5033429417967046  // Math.sqrt(  35/Math.PI) * 3 / 4
#define k12 1.7701307697799304  // Math.sqrt(35/2/Math.PI) * 3 / 4
#define k13 0.9461746957575601  // Math.sqrt(   5/Math.PI) * 3 / 4
#define k14 0.6690465435572892  // Math.sqrt( 5/2/Math.PI) * 3 / 4
#define k15 0.10578554691520431 // Math.sqrt(   1/Math.PI) * 3 / 16
#define k16 0.47308734787878004 // Math.sqrt(   5/Math.PI) * 3 / 8
#define k17 0.6258357354491761  // Math.sqrt(  35/Math.PI) * 3 / 16

#define k18 2.5033429417967046  // Math.sqrt(  35/Math.PI) * 3 / 4
#define k19 1.7701307697799304  // Math.sqrt(35/2/Math.PI) * 3 / 4
#define k20 0.9461746957575601  // Math.sqrt(   5/Math.PI) * 3 / 4
#define k21 0.6690465435572892  // Math.sqrt( 5/2/Math.PI) * 3 / 4
#define k22 0.10578554691520431 // Math.sqrt(   1/Math.PI) * 3 / 16
#define k23 0.47308734787878004 // Math.sqrt(   5/Math.PI) * 3 / 8
#define k24 0.6258357354491761  // Math.sqrt(  35/Math.PI) * 3 / 16

// Y_l_m(s), where l is the band and m the range in [-l..l] 
float SH( in int l, in int m, in vec3 s ) 
{ 
	vec3 n = s.zxy;
	
    //----------------------------------------------------------
    if( l==0 )          return  k01;
    //----------------------------------------------------------
	if( l==1 && m==-1 ) return -k02*n.y;
    if( l==1 && m== 0 ) return  k02*n.z;
    if( l==1 && m== 1 ) return -k02*n.x;
    //----------------------------------------------------------
	if( l==2 && m==-2 ) return  k03*n.x*n.y;
    if( l==2 && m==-1 ) return -k03*n.y*n.z;
    if( l==2 && m== 0 ) return  k04*(3.0*n.z*n.z-1.0);
    if( l==2 && m== 1 ) return -k03*n.x*n.z;
    if( l==2 && m== 2 ) return  k05*(n.x*n.x-n.y*n.y);
    //----------------------------------------------------------
    if( l==3 && m==-3 ) return -k06*n.y*(3.0*n.x*n.x-n.y*n.y);
    if( l==3 && m==-2 ) return  k07*n.z*n.y*n.x;
    if( l==3 && m==-1 ) return -k08*n.y*(5.0*n.z*n.z-1.0);
    if( l==3 && m== 0 ) return  k09*n.z*(5.0*n.z*n.z-3.0);
    if( l==3 && m== 1 ) return -k08*n.x*(5.0*n.z*n.z-1.0);
    if( l==3 && m== 2 ) return  k10*n.z*(n.x*n.x-n.y*n.y);
    if( l==3 && m== 3 ) return -k06*n.x*(n.x*n.x-3.0*n.y*n.y);
    //----------------------------------------------------------

	return 0.0;
}

// unrolled version of the above
float SH_0_0( in vec3 s ) { vec3 n = s.zxy; return  k01; }

float SH_1_0( in vec3 s ) { vec3 n = s.zxy; return -k02*n.y; }
float SH_1_1( in vec3 s ) { vec3 n = s.zxy; return  k02*n.z; }
float SH_1_2( in vec3 s ) { vec3 n = s.zxy; return -k02*n.x; }

float SH_2_0( in vec3 s ) { vec3 n = s.zxy; return  k03*n.x*n.y; }
float SH_2_1( in vec3 s ) { vec3 n = s.zxy; return -k03*n.y*n.z; }
float SH_2_2( in vec3 s ) { vec3 n = s.zxy; return  k04*(3.0*n.z*n.z-1.0); }
float SH_2_3( in vec3 s ) { vec3 n = s.zxy; return -k03*n.x*n.z; }
float SH_2_4( in vec3 s ) { vec3 n = s.zxy; return  k05*(n.x*n.x-n.y*n.y); }

float SH_3_0( in vec3 s ) { vec3 n = s.zxy; return -k06*n.y*(3.0*n.x*n.x-n.y*n.y);   }
float SH_3_1( in vec3 s ) { vec3 n = s.zxy; return  k07*n.z*n.y*n.x;                 }
float SH_3_2( in vec3 s ) { vec3 n = s.zxy; return -k08*n.y*(5.0*n.z*n.z-1.0);       }
float SH_3_3( in vec3 s ) { vec3 n = s.zxy; return  k09*n.z*(5.0*n.z*n.z-3.0);       }
float SH_3_4( in vec3 s ) { vec3 n = s.zxy; return -k08*n.x*(5.0*n.z*n.z-1.0);       }
float SH_3_5( in vec3 s ) { vec3 n = s.zxy; return  k10*n.z*(n.x*n.x-n.y*n.y);       }
float SH_3_6( in vec3 s ) { vec3 n = s.zxy; return -k06*n.x*(n.x*n.x-3.0*n.y*n.y);   }

float SH_4_0( in vec3 s ) { vec3 n = s.zxy; return  k11 * (n.x*n.y * (n.x*n.x - n.y*n.y));              }
float SH_4_1( in vec3 s ) { vec3 n = s.zxy; return -k12 * (3.0*n.x*n.x - n.y*n.y) * n.y * n.z;          }
float SH_4_2( in vec3 s ) { vec3 n = s.zxy; return  k13 * (n.x*n.y * (7.0*n.z*n.z-dot(n,n)) );          }
float SH_4_3( in vec3 s ) { vec3 n = s.zxy; return -k14 * (n.z*n.y * (7.0*n.z*n.z-3.0*dot(n,n)) );      } 
float SH_4_4( in vec3 s ) { vec3 n = s.zxy;  
        float z2 = n.z*n.z, r2 = dot(n, n); return  k15 * (35.0 * z2*z2 - 30.0 * z2*r2 + 3.0 * r2*r2);  }
float SH_4_5( in vec3 s ) { vec3 n = s.zxy; return -k14 * (n.z*n.x * (7.0*n.z*n.z-3.0*dot(n,n)) );      } 
float SH_4_6( in vec3 s ) { vec3 n = s.zxy; return  k16 * ( (n.x*n.x-n.y*n.y)*(7.0*n.z*n.z-dot(n,n)) ); }
float SH_4_7( in vec3 s ) { vec3 n = s.zxy; return -k12 * n.x*n.z*(n.x*n.x-3.0*n.y*n.y);                }
float SH_4_8( in vec3 s ) { vec3 n = s.zxy;  
          float x2 = n.x*n.x, y2 = n.y*n.y; return  k17 * (x2 * (x2-3.0*y2) - y2*(3.0*x2 - y2));        }
 
vec3 map( in vec3 p )
{
    vec3 p00 = p - vec3( 0.00, 3.0, 0.0);
	vec3 p01 = p - vec3(-1.25, 2.0, 0.0);
	vec3 p02 = p - vec3( 0.00, 2.0, 0.0);
	vec3 p03 = p - vec3( 1.25, 2.0, 0.0);
	vec3 p04 = p - vec3(-2.50, 0.5, 0.0);
	vec3 p05 = p - vec3(-1.25, 0.5, 0.0);
	vec3 p06 = p - vec3( 0.00, 0.5, 0.0);
	vec3 p07 = p - vec3( 1.25, 0.5, 0.0);
	vec3 p08 = p - vec3( 2.50, 0.5, 0.0);
	vec3 p09 = p - vec3(-3.75,-1.0, 0.0);
	vec3 p10 = p - vec3(-2.50,-1.0, 0.0);
	vec3 p11 = p - vec3(-1.25,-1.0, 0.0);
	vec3 p12 = p - vec3( 0.00,-1.0, 0.0);
	vec3 p13 = p - vec3( 1.25,-1.0, 0.0);
	vec3 p14 = p - vec3( 2.50,-1.0, 0.0);
	vec3 p15 = p - vec3( 3.75,-1.0, 0.0);
	
    vec3 p16 = p - vec3(-5.00,-2.7, 0.0);
    vec3 p17 = p - vec3(-3.75,-2.7, 0.0);
    vec3 p18 = p - vec3(-2.50,-2.7, 0.0);
    vec3 p19 = p - vec3(-1.25,-2.7, 0.0);
    vec3 p20 = p - vec3( 0.00,-2.7, 0.0);
    vec3 p21 = p - vec3( 1.25,-2.7, 0.0);
    vec3 p22 = p - vec3( 2.50,-2.7, 0.0);
    vec3 p23 = p - vec3( 3.75,-2.7, 0.0);
    vec3 p24 = p - vec3( 5.00,-2.7, 0.0);
	
	float r, d; vec3 n, s, res;
	
    #ifdef SHOW_SPHERES
	#define SHAPE (vec3(d-0.35, -1.0+2.0*clamp(0.5 + 16.0*r,0.0,1.0),d))
	#else
	#define SHAPE (vec3(d-abs(r), sign(r),d))
	#endif
	d=length(p00); n=p00/d; r = SH_0_0( n ); s = SHAPE; res = s;
	d=length(p01); n=p01/d; r = SH_1_0( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p02); n=p02/d; r = SH_1_1( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p03); n=p03/d; r = SH_1_2( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p04); n=p04/d; r = SH_2_0( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p05); n=p05/d; r = SH_2_1( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p06); n=p06/d; r = SH_2_2( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p07); n=p07/d; r = SH_2_3( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p08); n=p08/d; r = SH_2_4( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p09); n=p09/d; r = SH_3_0( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p10); n=p10/d; r = SH_3_1( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p11); n=p11/d; r = SH_3_2( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p12); n=p12/d; r = SH_3_3( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p13); n=p13/d; r = SH_3_4( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p14); n=p14/d; r = SH_3_5( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p15); n=p15/d; r = SH_3_6( n ); s = SHAPE; if( s.x<res.x ) res=s;
    
	d=length(p16); n=p16/d; r = SH_4_0( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p17); n=p17/d; r = SH_4_1( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p18); n=p18/d; r = SH_4_2( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p19); n=p19/d; r = SH_4_3( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p20); n=p20/d; r = SH_4_4( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p21); n=p21/d; r = SH_4_5( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p22); n=p22/d; r = SH_4_6( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p23); n=p23/d; r = SH_4_7( n ); s = SHAPE; if( s.x<res.x ) res=s;
	d=length(p24); n=p24/d; r = SH_4_8( n ); s = SHAPE; if( s.x<res.x ) res=s;
	
	return vec3( res.x, 0.5+0.5*res.y, res.z );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
	vec3 res = vec3(1e10,-1.0, 1.0);

	float maxd = 20.0;
    float h = 1.0;
    float t = 0.0;
    vec2  m = vec2(-1.0);
    for( int i=0; i<200; i++ )
    {
        if( h<0.001||t>maxd ) break;
	    vec3 res = map( ro+rd*t );
        h = res.x;
		m = res.yz;
        t += h*0.3;
    }
	if( t<maxd && t<res.x ) res=vec3(t,m);
	

	return res;
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.001,0.0,0.0);

	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 tot = vec3(0.0);
    
    for( int m=0; m<AA; m++ )
    for( int n=0; n<AA; n++ )
    {        
        vec2 p = (-iResolution.xy + 2.0*(fragCoord.xy+vec2(float(m),float(n))/float(AA))) / iResolution.y;

        // camera
        float an = 0.314*TIME - 10.0*iMouse.x/iResolution.x;
        float dist = 8.0;
        vec3  ro = vec3(dist*sin(an),0.0,dist*cos(an));
        vec3  ta = vec3(0.0,0.0,0.0);

        // camera matrix
        vec3 ww = normalize( ta - ro );
        vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
        vec3 vv = normalize( cross(uu,ww));
        // create view ray
        vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

        // background 
        vec3 col = vec3(0.5) * clamp(1.0-length(p)*0.5, 0.0, 1.0);

        // raymarch
        vec3 tmat = intersect(ro,rd);
        if( tmat.y>-0.5 )
        {
            // geometry
            vec3 pos = ro + tmat.x*rd;
            vec3 nor = calcNormal(pos);
            vec3 ref = reflect( rd, nor );

            // material		
            vec3 mate = 0.5*mix( vec3(1.0,0.2,0.15), vec3(0.15,0.7,1.0), tmat.y );

            float occ = clamp( 2.0*tmat.z, 0.0, 1.0 );
            float sss = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 1.0 );

            // lights
            vec3 lin  = 2.5*occ*vec3(1.0,1.00,1.00)*(0.6+0.4*nor.y);
                 lin += 1.0*sss*vec3(1.0,0.95,0.70)*occ;		

            // surface-light interacion
            col = mate.xyz * lin;
        }

        // gamma
        col = pow( clamp(col,0.0,1.0), vec3(0.4545) );
        tot += col;
    }
    tot /= float(AA*AA);
    fragColor = vec4( tot, 1.0 );
}

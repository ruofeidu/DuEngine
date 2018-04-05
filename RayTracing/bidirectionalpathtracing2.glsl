// 
// Bidirectional path tracer 2. Created by Reinder Nijhoff 2014
// @reindernijhoff
//
// https://www.shadertoy.com/view/4lfGWr
//

#define eps 0.00001
#define LIGHTPATHLENGTH 2
#define EYEPATHLENGTH 3
#define SAMPLES 8

#define SHOWSPLITLINE
#define FULLBOX

#define DOF
#define ANIMATENOISE
#define MOTIONBLUR

#define MOTIONBLURFPS 12.

#define LIGHTCOLOR vec3(16.86, 10.76, 8.2)*200.
#define WHITECOLOR vec3(.7295, .7355, .729)*0.7
#define GREENCOLOR vec3(.117, .4125, .115)*0.7
#define REDCOLOR vec3(.611, .0555, .062)*0.7

float hash1(inout float seed) {
    return fract(sin(seed += 0.1)*43758.5453123);
}

vec2 hash2(inout float seed) {
    return fract(sin(vec2(seed+=0.1,seed+=0.1))*vec2(43758.5453123,22578.1459123));
}

vec3 hash3(inout float seed) {
    return fract(sin(vec3(seed+=0.1,seed+=0.1,seed+=0.1))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

//-----------------------------------------------------
// Intersection functions (by iq)
//-----------------------------------------------------

vec3 nSphere( in vec3 pos, in vec4 sph ) {
    return (pos-sph.xyz)/sph.w;
}

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph ) {
    vec3 oc = ro - sph.xyz;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sph.w * sph.w;
    float h = b * b - c;
    if (h < 0.0) return -1.0;

	float s = sqrt(h);
	float t1 = -b - s;
	float t2 = -b + s;
	
	return t1 < 0.0 ? t2 : t1;
}

vec3 nPlane( in vec3 ro, in vec4 obj ) {
    return obj.xyz;
}

float iPlane( in vec3 ro, in vec3 rd, in vec4 pla ) {
    return (-pla.w - dot(pla.xyz,ro)) / dot( pla.xyz, rd );
}

//-----------------------------------------------------
// scene
//-----------------------------------------------------

vec3 cosWeightedRandomHemisphereDirection( const vec3 n, inout float seed ) {
  	vec2 r = hash2(seed);
    
	vec3  uu = normalize( cross( n, vec3(0.0,1.0,1.0) ) );
	vec3  vv = cross( uu, n );
	
	float ra = sqrt(r.y);
	float rx = ra*cos(6.2831*r.x); 
	float ry = ra*sin(6.2831*r.x);
	float rz = sqrt( 1.0-r.y );
	vec3  rr = vec3( rx*uu + ry*vv + rz*n );
    
    return normalize( rr );
}

vec3 randomSphereDirection( inout float seed) {
    vec2 r = hash2(seed)*6.2831;
	vec3 dr=vec3(sin(r.x)*vec2(sin(r.y),cos(r.y)),cos(r.x));
	return dr;
}

vec3 randomHemisphereDirection( const vec3 n, inout float seed ) {
	vec3 dr = randomSphereDirection(seed);
	return dot(dr,n) * dr;
}

//-----------------------------------------------------
// light
//-----------------------------------------------------

const vec4 lightSphere = vec4( 3.0,7.5,2.5, .5 );
vec4 movingSphere;

void initMovingSphere( float time ) {
	movingSphere = vec4( 1.+abs(1.0*sin(time*1.3)), 1.+abs(2.0*sin(time)), 7.-abs(6.*cos(time*0.4)), 1.0);
}

vec3 sampleLight( const in vec3 ro, inout float seed ) {
    vec3 n = randomSphereDirection(seed) * lightSphere.w;
    return lightSphere.xyz + n;
}

//-----------------------------------------------------
// scene
//-----------------------------------------------------

vec2 intersect( in vec3 ro, in vec3 rd, inout vec3 normal ) {
	vec2 res = vec2( 1e20, -1.0 );
    float t;
	
	t = iPlane( ro, rd, vec4( 0.0, 1.0, 0.0,0.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = vec3( 0., 1., 0.); }
	t = iPlane( ro, rd, vec4( 0.0, 0.0,-1.0,8.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = vec3( 0., 0.,-1.); }
    t = iPlane( ro, rd, vec4( 1.0, 0.0, 0.0,0.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 2. ); normal = vec3( 1., 0., 0.); }
#ifdef FULLBOX
    t = iPlane( ro, rd, vec4( 0.0,-1.0, 0.0,5.49) ); if( t>eps && t<res.x && ro.z+rd.z*t < 5.5 ) { res = vec2( t, 1. ); normal = vec3( 0.,-1., 0.); }
    t = iPlane( ro, rd, vec4(-1.0, 0.0, 0.0,5.59) ); if( t>eps && t<res.x ) { res = vec2( t, 3. ); normal = vec3(-1., 0., 0.); }
#endif

	t = iSphere( ro, rd, movingSphere             ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = nSphere( ro+t*rd, movingSphere ); }
    t = iSphere( ro, rd, vec4( 4.0,1.0, 4.0, 1.0) ); if( t>eps && t<res.x ) { res = vec2( t, 5. ); normal = nSphere( ro+t*rd, vec4( 4.0,1.0, 4.0,1.0) ); }
    t = iSphere( ro, rd, lightSphere ); if( t>eps && t<res.x ) { res = vec2( t, 0.0 );  normal = nSphere( ro+t*rd, lightSphere ); }
					  
    return res;					  
}

bool intersectShadow( in vec3 ro, in vec3 rd, in float dist ) {
    float t;
	
	t = iSphere( ro, rd, movingSphere            );  if( t>eps && t<dist ) { return true; }
    t = iSphere( ro, rd, vec4( 4.0,1.0, 4.0,1.0) );  if( t>eps && t<dist ) { return true; }
#ifdef FULLBOX    
    t = iPlane( ro, rd, vec4( 0.0,-1.0, 0.0,5.49) ); if( t>eps && t<dist && ro.z+rd.z*t < 5.5 ) { return true; }
#endif
    return false; // optimisation: other planes don't cast shadows in this scene
}

//-----------------------------------------------------
// materials
//-----------------------------------------------------

vec3 matColor( const in float mat ) {
	vec3 nor = vec3(0., 0.95, 0.);
	
	if( mat<3.5 ) nor = REDCOLOR;
    if( mat<2.5 ) nor = GREENCOLOR;
	if( mat<1.5 ) nor = WHITECOLOR;
	if( mat<0.5 ) nor = LIGHTCOLOR;
					  
    return nor;					  
}

bool matIsSpecular( const in float mat ) {
    return mat > 4.5;
}

bool matIsLight( const in float mat ) {
    return mat < 0.5;
}

//-----------------------------------------------------
// brdf
//-----------------------------------------------------

vec3 getBRDFRay( in vec3 n, const in vec3 rd, const in float m, inout bool specularBounce, inout float seed ) {
    specularBounce = false;
    
    vec3 r = cosWeightedRandomHemisphereDirection( n, seed );
    if(  !matIsSpecular( m ) ) {
        return r;
    } else {
        specularBounce = true;
        
        float n1, n2, ndotr = dot(rd,n);
        
        if( ndotr > 0. ) {
            n1 = 1./1.5; n2 = 1.;
            n = -n;
        } else {
            n2 = 1./1.5; n1 = 1.;
        }
                
        float r0 = (n1-n2)/(n1+n2); r0 *= r0;
		float fresnel = r0 + (1.-r0) * pow(1.0-abs(ndotr),5.);
        
        vec3 ref;
        
        if( hash1(seed) < fresnel || m > 6.5 ) {
            ref = reflect( rd, n );
        } else {
            ref = refract( rd, n, n2/n1 );
        }
        
        return ref; // normalize( ref + 0.1 * r );
	}
}

//-----------------------------------------------------
// lightpath
//-----------------------------------------------------

struct LightPathNode {
    vec3 color;
    vec3 position;
    vec3 normal;
};

LightPathNode lpNodes[LIGHTPATHLENGTH];

void constructLightPath( inout float seed ) {
    vec3 ro = randomSphereDirection( seed );
    vec3 rd = cosWeightedRandomHemisphereDirection( ro, seed );
    ro = lightSphere.xyz - ro*lightSphere.w;
    vec3 color = LIGHTCOLOR;
 
    for( int i=0; i<LIGHTPATHLENGTH; ++i ) {
        lpNodes[i].position = lpNodes[i].color = lpNodes[i].normal = vec3(0.);
    }
    
    bool specularBounce;
    float w = 0.;
    
    for( int i=0; i<LIGHTPATHLENGTH; i++ ) {
		vec3 normal;
        vec2 res = intersect( ro, rd, normal );
        
        if( res.y > 0.5 && dot( rd, normal ) < 0. ) {
            ro = ro + rd*res.x;            
            color *= matColor( res.y );
            
            lpNodes[i].position = ro;
            if( !matIsSpecular( res.y ) ) lpNodes[i].color = color;// * clamp( dot( normal, -rd ), 0., 1.);
            lpNodes[i].normal = normal;
            
            rd = getBRDFRay( normal, rd, res.y, specularBounce, seed );
        } else break;
    }
}

//-----------------------------------------------------
// eyepath
//-----------------------------------------------------

float getWeightForPath( int e, int l ) {
    return float(e + l + 2);
}

vec3 traceEyePath( in vec3 ro, in vec3 rd, const in bool bidirectTrace, inout float seed ) {
    vec3 tcol = vec3(0.);
    vec3 fcol  = vec3(1.);
    
    bool specularBounce = true; 
	int jdiff = 0;
    
    for( int j=0; j<EYEPATHLENGTH; ++j ) {
        vec3 normal;
        
        vec2 res = intersect( ro, rd, normal );
        if( res.y < -0.5 ) {
            return tcol;
        }
        
        if( matIsLight( res.y ) ) {
            if( bidirectTrace ) {
            	if( specularBounce ) tcol += fcol*LIGHTCOLOR;
            } else {
               tcol += fcol*LIGHTCOLOR;
            }
            return tcol; // the light has no diffuse component, therefore we can return col
        }
        
        ro = ro + res.x * rd;   
        vec3 rdi = rd;
        rd = getBRDFRay( normal, rd, res.y, specularBounce, seed );
        
        fcol *= matColor( res.y );
                
        if( bidirectTrace  ) {
		    vec3 ld = sampleLight( ro, seed ) - ro;       
            
            // path of (j+1) eyepath-nodes, and 1 lightpath-node ( = direct light sampling )
            vec3 nld = normalize(ld);
            if( !specularBounce &&  !intersectShadow( ro, nld, length(ld)) ) {
                float cos_a_max = sqrt(1. - clamp(lightSphere.w * lightSphere.w / dot(lightSphere.xyz-ro, lightSphere.xyz-ro), 0., 1.));
                float weight = 2. * (1. - cos_a_max);

                tcol += (fcol * LIGHTCOLOR) * (weight * clamp(dot( nld, normal ), 0., 1.))
                    / getWeightForPath(jdiff,-1);
            }

            
            if( !matIsSpecular( res.y ) ) {
                for( int i=0; i<LIGHTPATHLENGTH; ++i ) {
                    // path of (j+1) eyepath-nodes, and i+2 lightpath-nodes.
                    vec3 lp = lpNodes[i].position - ro;
                    vec3 lpn = normalize( lp );
                    vec3 lc = lpNodes[i].color;

                    if( !intersectShadow(ro, lpn, length(lp)) ) {
                        // weight for going from (j+1)th eyepath-node to (i+2)th lightpath-node
                        
                        // IS THIS CORRECT ???
                        
                        float weight = 
                                 clamp( dot( lpn, normal ), 0.0, 1.) 
                               * clamp( dot( -lpn, lpNodes[i].normal ), 0., 1.)
                               * clamp(1. / dot(lp, lp), 0., 1.)
                            ;

                        tcol += lc * fcol * weight / getWeightForPath(jdiff,i);
                    }
                }
            }
        }
        
        if( !specularBounce) jdiff++; else jdiff = 0;
    }  
    
    return tcol;
}

//-----------------------------------------------------
// main
//-----------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 q = fragCoord.xy / iResolution.xy;
    
	float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2. + iResolution.x*cos(iTime*.5) : iMouse.x;
    bool bidirectTrace = fragCoord.x < splitCoord;
    
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------

    vec2 p = -1.0 + 2.0 * (fragCoord.xy) / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;

#ifdef ANIMATENOISE
    float seed = p.x + p.y * 3.43121412313 + fract(1.12345314312*iTime);
#else
    float seed = p.x + p.y * 3.43121412313;
#endif
    
    vec3 ro = vec3(2.78, 2.73, -8.00);
    vec3 ta = vec3(2.78, 2.73,  0.00);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));

    //-----------------------------------------------------
    // render
    //-----------------------------------------------------

    vec3 col = vec3(0.0);
    vec3 tot = vec3(0.0);
    vec3 uvw = vec3(0.0);
    
    for( int a=0; a<SAMPLES; a++ ) {

        vec2 rpof = 4.*(hash2(seed)-vec2(0.5)) / iResolution.xy;
	    vec3 rd = normalize( (p.x+rpof.x)*uu + (p.y+rpof.y)*vv + 3.0*ww );
        
#ifdef DOF
	    vec3 fp = ro + rd * 12.0;
   		vec3 rof = ro + (uu*(hash1(seed)-0.5) + vv*(hash1(seed)-0.5))*0.125;
    	rd = normalize( fp - rof );
#else
        vec3 rof = ro;
#endif        
        
#ifdef MOTIONBLUR
        initMovingSphere( iTime + hash1(seed) / MOTIONBLURFPS );
#else
        initMovingSphere( iTime );        
#endif
        
        if( bidirectTrace ) {
            constructLightPath( seed );
        }
        
        col = traceEyePath( rof, rd, bidirectTrace, seed );

        tot += col;
        
        seed = mod( seed*1.1234567893490423, 13. );
    }
    
    tot /= float(SAMPLES);
    
#ifdef SHOWSPLITLINE
	if (abs(fragCoord.x - splitCoord) < 1.0) {
		tot.x = 1.0;
	}
#endif
    
	tot = pow( clamp(tot,0.0,1.0), vec3(0.45) );

    fragColor = vec4( tot, 1.0 );
}
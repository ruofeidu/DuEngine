// https://www.shadertoy.com/view/4tByz3
// Created by inigo quilez - iq/2017
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

#define MAT_MUSH_HEAD 1.0
#define MAT_MUSH_NECK 2.0
#define MAT_LADY_BODY 3.0
#define MAT_LADY_HEAD 4.0
#define MAT_LADY_LEGS 5.0
#define MAT_GRASS     6.0
#define MAT_GROUND    7.0
#define MAT_MOSS      8.0
#define MAT_CITA      9.0

vec2 hash2( vec2 p ) { p=vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))); return fract(sin(p)*18.5453); }
vec3 hash3( float n ) { return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(338.5453123,278.1459123,191.1234)); }


float sdEllipsoid( in vec3 pos, in vec3 cen, in vec3 rad )
{
    vec3 p = pos - cen;
    float d = length(p/rad) - 1.0;   
    return d * min(min(rad.x,rad.y),rad.z);
}
    
vec2 sdLine( in vec3 pos, in vec3 a, in vec3 b )
{
    vec3 pa = pos - a;
    vec3 ba = b - a;
   
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    
    return vec2( length(pa-h*ba), h );
}

vec2 sdLineOri( in vec3 p, in vec3 b )
{
    float h = clamp( dot(p,b)/dot(b,b), 0.0, 1.0 );
    
    return vec2( length(p-h*b), h );
}

float smin( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

float smax( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( a, b, h ) + k*h*(1.0-h);
}

vec3 smax( vec3 a, vec3 b, float k )
{
	vec3 h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( a, b, h ) + k*h*(1.0-h);
}

float length2(in vec2 p ) { return dot(p,p); }
float length2(in vec3 p ) { return dot(p,p); }

vec3 rotateY( in vec3 p, float t )
{
    float co = cos(t);
    float si = sin(t);
    p.xz = mat2(co,-si,si,co)*p.xz;
    return p;
}

vec3 rotateX( in vec3 p, float t )
{
    float co = cos(t);
    float si = sin(t);
    p.yz = mat2(co,-si,si,co)*p.yz;
    return p;
}
vec3 rotateZ( in vec3 p, float t )
{
    float co = cos(t);
    float si = sin(t);
    p.xy = mat2(co,-si,si,co)*p.xy;
    return p;
}


//==================================================

vec3 mapLadyBug( vec3 p, float curmin )
{
    
    float db = length(p-vec3(0.0,-0.35,0.05))-1.3;
    if( db>curmin ) return vec3(10000.0,0.0,0.0);
    
    float dBody = sdEllipsoid( p, vec3(0.0), vec3(0.8, 0.75, 1.0) );
    dBody = smax( dBody, -sdEllipsoid( p, vec3(0.0,-0.1,0.0), vec3(0.75, 0.7, 0.95) ), 0.05 );
    dBody = smax( dBody, -sdEllipsoid( p, vec3(0.0,0.0,0.8), vec3(0.35, 0.35, 0.5) ), 0.05 );
  	dBody = smax( dBody, sdEllipsoid( p, vec3(0.0,1.7,-0.1), vec3(2.0, 2.0, 2.0) ), 0.05 );
  	dBody = smax( dBody, -abs(p.x)+0.005, 0.02 + 0.1*clamp(p.z*p.z*p.z*p.z,0.0,1.0) );

    vec3 res = vec3( dBody, MAT_LADY_BODY, 0.0 );

    // --------
    vec3 hc = vec3(0.0,0.1,0.8);
    vec3 ph = rotateX(p-hc,0.5);
    float dHead = sdEllipsoid( ph, vec3(0.0,0.0,0.0), vec3(0.35, 0.25, 0.3) );
    dHead = smax( dHead, -sdEllipsoid( ph, vec3(0.0,-0.95,0.0), vec3(1.0) ), 0.03 );
    dHead = min( dHead, sdEllipsoid( ph, vec3(0.0,0.1,0.3), vec3(0.15,0.08,0.15) ) );

    if( dHead < res.x ) res = vec3( dHead, MAT_LADY_HEAD, 0.0 );
    
    res.x += 0.0007*sin(150.0*p.x)*sin(150.0*p.z)*sin(150.0*p.y); // iqiq

    // -------------
    
    vec3 k1 = vec3(0.42,-0.05,0.92);
    vec3 k2 = vec3(0.49,-0.2,1.05);
    float dLegs = 10.0;

    float sx = sign(p.x);
    p.x = abs(p.x);
    for( int k=0; k<3; k++ )
    {   
        vec3 q = p;
        q.y -= min(sx,0.0)*0.1;
        if( k==0) q += vec3( 0.0,0.11,0.0);
        if( k==1) q += vec3(-0.3,0.1,0.2);
        if( k==2) q += vec3(-0.3,0.1,0.6);
        
        vec2 se = sdLine( q, vec3(0.3,0.1,0.8), k1 );
        se.x -= 0.015 + 0.15*se.y*se.y*(1.0-se.y);
        dLegs = min(dLegs,se.x);

        se = sdLine( q, k1, k2 );
        se.x -= 0.01 + 0.01*se.y;
        dLegs = min(dLegs,se.x);

        se = sdLine( q, k2, k2 + vec3(0.1,0.0,0.1) );
        se.x -= 0.02 - 0.01*se.y;
        dLegs = min(dLegs,se.x);
    }
    
    if( dLegs<res.x ) res = vec3(dLegs,MAT_LADY_LEGS, 0.0);


    return res;
}


vec3 worldToMushrom( in vec3 pos )
{
    vec3 qos = pos;
    qos.xy = (mat2(60,11,-11,60)/61.0) * qos.xy;
    qos.y += 0.03*sin(3.0*qos.z - 2.0*sin(3.0*qos.x));
    qos.y -= 0.4;
    return qos;
}

vec3 mapMushroom( in vec3 pos, in vec3 cur )
{
    vec3 res = cur;

    vec3 qos = worldToMushrom(pos);
    float db = length(qos-vec3(0.0,1.2,0.0)) - 1.3;
    if( db<cur.x )
    {

        {

            float d1 = sdEllipsoid( qos, vec3(0.0, 1.4,0.0), vec3(0.8,1.0,0.8) );

            d1 -= 0.025*textureLod( iChannel1, 0.05*qos.xz, 0.0 ).x - 0.02;

            float d2 = sdEllipsoid( qos, vec3(0.0, 0.5,0.0), vec3(1.3,1.2,1.3) );
            float d = smax( d1, -d2, 0.1 );
            d *= 0.8;
            if( d<res.x )
            {
                res = vec3( d, MAT_MUSH_HEAD, 0.0 );
            }
        }


        {
            pos.x += 0.3*sin(pos.y) - 0.65;
            float pa = sin( 20.0*atan(pos.z,pos.x) );
            vec2 se = sdLine( pos, vec3(0.0,2.0,0.0), vec3(0.0,0.0,0.0) );

            float tt = 0.25 - 0.1*4.0*se.y*(1.0-se.y);

            float d3 = se.x - tt;

            d3 = smin( d3, sdEllipsoid( pos, vec3(0.0, 1.7 - 2.0*length2(pos.xz),0.0), vec3(0.3,0.05,0.3) ), 0.05);
            d3 += 0.003*pa;
            d3 *= 0.7;
            
            if( d3<res.x )
                res = vec3( d3, MAT_MUSH_NECK, 0.0 );
        }
    
    }
    return res;
}



vec3 mapGrass( in vec3 pos, float h, in vec3 cur )
{
    vec3 res = cur;
    
    float db = pos.y-2.6;
    
    if( db<cur.x && pos.z>-1.65 )
    {
        const float gf = 4.0;

        vec3 qos = pos * gf;

        vec2 n = floor( qos.xz );
        vec2 f = fract( qos.xz );
        for( int j=-2; j<=2; j++ )
        for( int i=-2; i<=2; i++ )
        {
            vec2  g = vec2( float(i), float(j) );

            vec2 ra2 = hash2( n + g + vec2(31.0,57.0) );

            if( ra2.x<0.73 ) continue;

            vec2  o = hash2( n + g );
            vec2  r = g - f + o;
            vec2 ra = hash2( n + g + vec2(11.0,37.0) );

            float gh = 2.0*(0.3+0.7*ra.x);

            float rosy = qos.y - h*gf;

            r.xy = reflect( r.xy, normalize(-1.0+2.0*ra) );
            r.x -= 0.03*rosy*rosy;

            r.x *= 4.0;

            float mo = 0.1*sin( 2.0*iTime + 20.0*ra.y )*(0.2+0.8*ra.x);
            vec2 se = sdLineOri( vec3(r.x,rosy,r.y), vec3(4.0 + mo,gh*gf,mo) );

            float gr = 0.3*sqrt(1.0-0.99*se.y);
            float d = se.x - gr;
            d /= 4.0;

            d /= gf;
            if( d<res.x )
            {
                res.x = d;
                res.y = MAT_GRASS;
                res.z = r.y;
            }
        }
    }
    
    return res;
}


vec3 mapCrapInTheAir( in vec3 pos, in vec3 cur)
{
    vec3 res = cur;
    
    ivec2 id = ivec2(floor((pos.xz+2.0)/4.0));
    pos.xz = mod(pos.xz+2.0,4.0)-2.0;
    float dm = 1e10;
    for( int i=0; i<4; i++ )
    {
        vec3 o = vec3(0.0,3.2,0.0);
        o += vec3(1.7,1.50,1.7)*(-1.0 + 2.0*hash3(float(i)));
        o += vec3(0.3,0.15,0.3)*sin(0.3*iTime + vec3(float(i+id.y),float(i+3+id.x),float(i*2+1+2*id.x)));
        float d = length2(pos - o);
        dm = min(d,dm);
    }
    dm = sqrt(dm)-0.02;
    
    if( dm<res.x )
        res = vec3( dm,MAT_CITA,0);
    
    return res;
}

vec3 mapMoss( in vec3 pos, float h, vec3 cur)
{
    vec3 res = cur;

    float db = pos.y-2.2;
    if( db<res.x )
    {
    const float gf = 2.0;
    
    vec3 qos = pos * gf;
    vec2 n = floor( qos.xz );
    vec2 f = fract( qos.xz );

    for( int k=0; k<2; k++ )
    {
        for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            vec2  g = vec2( float(i), float(j) );
            vec2  o = hash2( n + g + vec2(float(k),float(k*5)));
            vec2  r = g - f + o;

            vec2 ra  = hash2( n + g + vec2(11.0, 37.0) + float(2*k) );
            vec2 ra2 = hash2( n + g + vec2(41.0,137.0) + float(3*k) );

            float mh = 0.5 + 1.0*ra2.y;
            vec3 ros = qos - vec3(0.0,h*gf,0.0);

            vec3 rr = vec3(r.x,ros.y,r.y);

            rr.xz = reflect( rr.xz, normalize(-1.0+2.0*ra) );

            rr.xz += 0.5*(-1.0+2.0*ra2);
            vec2 se  = sdLineOri( rr, vec3(0.0,gf*mh,0.0) );
            float sey = se.y;
            float d = se.x - 0.05*(2.0-smoothstep(0.0,0.1,abs(se.y-0.9)));

            vec3 pp = vec3(rr.x,mod(rr.y+0.2*0.0,0.4)-0.2*0.0,rr.z);

            float an = mod( 21.0*floor( (rr.y+0.2*0.0)/0.4 ), 1.57 );
            float cc = cos(an);
            float ss = sin(an);
            pp.xz = mat2(cc,ss,-ss,cc)*pp.xz;

            pp.xz = abs(pp.xz);
            vec3 ppp = (pp.z>pp.x) ? pp.zyx : pp; 
            vec2 se2 = sdLineOri( ppp, vec3( 0.4,0.3,0.0) );
            vec2 se3 = sdLineOri( pp,  vec3( 0.2,0.3,0.2) ); if( se3.x<se2.x ) se2 = se3;
            float d2 = se2.x - (0.02 + 0.03*se2.y);

            d2 = max( d2, (rr.y-0.83*gf*mh) );
            d = smin( d, d2, 0.05 );

            d /= gf;
            d *= 0.9;
            if( d<res.x )
            {
                res.x = d;
                res.y = MAT_MOSS;
                res.z = clamp(length(rr.xz)*4.0+rr.y*0.2,0.0,1.0);
                float e = clamp((pos.y - h)/1.0,0.0,1.0);
                res.z *= 0.02 + 0.98*e*e;
                
                if( ra.y>0.85 && abs(se.y-0.95)<0.1 ) res.z = -res.z;
            }
        }
    }

    }
    
    return res;
}


vec3 worldToLadyBug( in vec3 p )
{
    p = 4.0*(p - vec3(-0.0,3.2-0.6,-0.57));
    p = rotateY( rotateZ( rotateX( p, -0.92 ), 0.49), 3.5 );
    p.y += 0.2;
    return p;
}


const vec3 mushroomPos1 = vec3( 0.0,0.1,0.0);
const vec3 mushroomPos2 = vec3(-3.0,0.0,3.0);

float terrain( in vec2 pos )
{
    return 0.3 - 0.3*sin(pos.x*0.5 - sin(pos.y*0.5));
}

vec3 mapShadow( in vec3 pos )
{
    float h = terrain( pos.xz );
    float d = pos.y - h;
    vec3 res = vec3( d, MAT_GROUND, 0.0 );
    
    res = mapGrass(pos,h,res);
    res = mapMoss(pos,h,res);

    vec3 m1 =  pos - mushroomPos1;
    vec3 m2 = (pos - mushroomPos2).zyx;
    if( length2(m2.xz) < length2(m1.xz) ) m1 = m2;
	res = mapMushroom(m1, res);


    vec3 q = worldToLadyBug(pos);
    vec3 d3 = mapLadyBug(q, res.x*4.0); d3.x/=4.0;
    if( d3.x<res.x ) res = d3;

    return res;
}


vec3 map( in vec3 pos )
{
    vec3 res = mapShadow(pos);
        
    res = mapCrapInTheAir(pos, res);

    return res;
}


vec3 calcNormal( in vec3 pos )
{
    vec2 e = vec2(0.002,0.0); 
    
    return normalize( vec3( map(pos+e.xyy).x - map(pos-e.xyy).x,
                            map(pos+e.yxy).x - map(pos-e.yxy).x,
                            map(pos+e.yyx).x - map(pos-e.yyx).x ) );
}
    
float calcShadow( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.01;
    for( int i=0; i<100; i++ )
    {
        vec3 pos = ro + rd*t;
        float h = mapShadow( pos ).x;
        res = min( res, 16.0*max(h,0.0)/t );
        if( h<0.0001 || pos.y>3.0 ) break;
        
        t += clamp(h,0.01,0.2);
    }
    
    return clamp(res,0.0,1.0);
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
    const float tmax = 12.0;
    
	vec3 res = vec3(1.0,-1.0, 0.0);

    for( int i=0; i<256; i++ )
    {
        vec3 h = map( ro + rd*res.x );
        if( h.x<(0.00015*res.x) || res.x>tmax )
            break;
        res.x += h.x;
        res.y = h.y;
        res.z = h.z;
    }
    
    if( res.x>=tmax ) res.y = -1.0;
    
    return res;
}

void materials( in float matID, in float matID2, in vec3 pos, in vec3 nor,
                out vec3 matColor, out float matRough,
                out vec3 matNor, out float matOcc, out float matSSS, out float matRefOcc, out vec3 matGamma )
{
    matNor = nor;
    matOcc = 1.0;
    matSSS = 0.0;
    matRough = 1.0;
    matRefOcc = 1.0;
    matGamma = vec3(1.0);
    
    if( matID<MAT_MUSH_HEAD+0.5 )
    {
        vec3 m1 =  pos - mushroomPos1;
    	vec3 m2 = (pos - mushroomPos2).zyx;
    	if( length2(m2.xz) < length2(m1.xz) ) m1 = m2;

        vec3 qos = worldToMushrom( m1 );

        matColor = vec3(0.26,0.21,0.15);
        matColor -= 0.2*smoothstep(0.4,0.9,texture( iChannel1, 0.8*qos.xz ).x);
        matColor = mix( vec3(0.35,0.35,0.35 ), matColor, smoothstep(1.5,2.4,qos.y) );
        matColor = mix( vec3(0.05,0.02,0.01 ), matColor, smoothstep(1.5,1.65,qos.y) );
        matColor -= 0.2*texture( iChannel1, 0.1*qos.xz ).zyx;
        matColor *= 0.4*0.45;
        matColor = max( matColor, 0.0 );
        
        matColor += matColor*vec3(0.3,0.6,0.0)*(1.0-smoothstep( 0.8, 1.4, length(m1-vec3(0.5,1.1,-0.3)) ));
        
        matRough = 0.6;
        matSSS = 1.0;
        matOcc = smoothstep( 0.4,1.5,length(worldToLadyBug( pos ).xz) );
        matRefOcc = matOcc;
        matGamma = vec3(0.75,0.87,1.0);
    }
    else if( matID<MAT_MUSH_NECK+0.5 )
    {
        vec2 uv = vec2( pos.y*0.5, atan(pos.x,pos.z)*(3.0/3.14159) );

        matColor = vec3(0.42,0.35,0.15);
        
        float pa = smoothstep(0.3,0.8,pos.y);

        matColor -= pa*0.2*texture( iChannel1, 0.5*uv ).xxx;
        matColor = max(vec3(0.0),matColor);
        
        matColor *= 0.22;
        matColor = clamp( matColor, 0.0, 1.0 );
        
        matRough = 0.7;
        matSSS = 1.0;
        
        matOcc = clamp( (pos.y-0.5)/1.3,0.0,1.0);
        matOcc = matOcc*matOcc;
        matOcc *= clamp( 1.0-(pos.y-1.2)/1.2,0.0,1.0);
        matOcc = matOcc*0.5 + 0.5*matOcc*matOcc;
        matRefOcc = matOcc;
        matGamma = vec3(0.75,0.95,1.0);

    }
    else if( matID<MAT_LADY_BODY+.5 )
    {
        vec3 qos = worldToLadyBug( pos );
            
        // red
        matColor = vec3(0.16,0.008,0.0);

        float f = texture( iChannel1, 0.1*qos.xz ).x;
        matColor = mix( matColor, vec3(0.15,0.07,0.0), f*f );
        
        qos.x = abs(qos.x);
        vec2 uv = vec2( atan(qos.x,qos.y), 1.57*qos.z )*0.1;

        // white
        float p = length( (qos.xz-vec2(0.0,0.9))*vec2(0.5,1.0));
        matColor = mix( matColor, vec3(1.0,0.8,0.6)*0.6, 1.0-smoothstep(0.09,0.14,p) );

        // black
        p = cos(uv.x*40.0)*cos(uv.y*40.0+1.57);
        matColor *= 1.0-smoothstep( 0.35, 0.45, p );
        
        
        f = texture( iChannel1, qos.xz*vec2(0.8,0.1) ).x;
        matColor *= 1.0 - 0.5*f;
        f = texture( iChannel1, 4.0*qos.xz ).x;
        matColor *= 1.0 - 0.99*f*f;
        
        
        matColor *= 1.3;
        matRough = 0.15;
        matOcc = 0.6 + 0.4*smoothstep( 0.0,0.3,qos.y );
        matRefOcc = 0.2 + 0.8*smoothstep( 0.0,0.35,qos.y );
    }
    else if( matID<MAT_LADY_HEAD+.5 )
    {
        vec3 qos = worldToLadyBug( pos );

        matColor = vec3(0.001);

        qos.z += -0.22;
        qos.y += -0.7;
        float p = cos(12.0*qos.z)*cos(5.0*qos.y);
        p += .1*cos(48.0*qos.z)*cos(20.0*qos.y);
        matColor = mix( matColor, vec3(1.0,0.9,0.8)*0.8, smoothstep(0.8,1.0,p) );
        matRough = 0.2;
        matRefOcc = matOcc;
    }
    else if( matID<MAT_LADY_LEGS+.5 )
    {
        matColor = vec3(0.0,0.0,0.0);
        matRough = 0.8;
        matRefOcc = matOcc;
    }
    else if( matID<MAT_GRASS+0.5 )
    {
    	matColor = vec3(0.1,0.15,0.03);
        
        float h = terrain( pos.xz );
        float e = clamp(pos.y-h,0.0,1.0);
        matOcc = 0.01 + 0.99*e*e;
        
        matColor *= 1.0 - 0.3*cos(matID2*23.0);
        matColor += 0.04*sin(matID2*41.0);
        
        matSSS = 0.2;
        matColor *= 0.75;
        matRough = 0.5;
        matOcc *= 0.1+0.9*smoothstep( 0.0, 2.0, length(pos.xz-mushroomPos1.xz-vec2(0.3,0.3)) );
        //matOcc *= 0.1+0.9*smoothstep( 0.0, 2.0, length(pos.xz-mushroomPos2.xz-vec2(0.0,0.0)) );
        matRefOcc = matOcc;
        matGamma = vec3(0.9,0.9,1.0);
    }
    else if( matID<MAT_GROUND+0.5 )
    {
        matColor = vec3(0.2,0.2,0.0);
        matRough = 1.0;
        matOcc = 0.02;
        matRefOcc = matOcc;
    }
    else if( matID<MAT_MOSS+0.5 )
    {
        matColor = vec3(0.18,0.15,0.02);
        
        
        if( matID2<0.0 ) matColor = vec3(0.1,0.05,0.005);
        
        
        float f = texture( iChannel1, pos.xy*8.0 ).x;
        matColor *= 0.55 + f;
            
        matOcc = abs(matID2);
        matOcc *= 0.2+0.8*smoothstep( 0.0, 1.5, length(pos.xz-mushroomPos1.xz-vec2(0.3,0.3)) );
        matOcc *= 0.2+0.8*smoothstep( 0.0, 1.5, length(pos.xz-mushroomPos2.xz-vec2(0.0,0.0)) );
        matRough = 0.25;
        matSSS = 0.5;
        matRefOcc = matOcc;
        matGamma = vec3(0.7,0.7,1.0);
        
        if( matID2<0.0 ) { matGamma = vec3(0.7,0.9,1.0); matRough = 0.75;}
    }
    else //if( matID<MAT_CITA+0.5 )
    {
        matColor = vec3(1.0);
        matSSS = 1.0;
        matRough = 1.0;
        matGamma = vec3(0.5);
    }
}


vec3 lighting( in float dis, in vec3 rd, in vec3 pos, in vec3 nor,
               in float occ,
               in vec3 matColor, in float matRough, in float matSSS, in float matRefOcc,
               in vec3 matGamma )
{
    vec3 col = vec3(0.0);

    float fre = clamp( 1.0+dot(nor,rd), 0.0, 1.0 );
    
    float sfre = 0.04 + 0.96*pow( fre, 5.0 );
    
    float pn = exp2( 10.0*(1.0-matRough) );
    

    // sun light
    {
        vec3 sunColor = vec3(7.0,4.0,3.0)*1.4;
        vec3 sun = normalize(vec3(-0.8,0.35,-0.3));
        float dif = clamp( dot(sun,nor), 0.0, 1.0 );
        float sha = 0.0; if( dif>0.0 ) sha = calcShadow( pos, sun );
        vec3 hal = normalize( sun - rd );
        float spe = pow( clamp(dot(hal,nor), 0.0, 1.0 ), pn );
        col += matColor * sunColor * dif * vec3(sha,0.5*sha*(1.0+sha),sha*sha);
        col += (1.0-matRough)*sunColor * spe * pn * dif * sha * sfre / 4.0;
    }

    // sky light
    {
        vec3 skyColor = vec3(0.3,0.4,0.7)*1.0;
        float dif = 0.5 + 0.5*nor.y;
        col += matColor * skyColor * dif * occ;
        col += skyColor * (1.0-matRough) * smoothstep( 0.0,0.2,reflect(rd,nor).y ) * sfre * 2.5 * matRefOcc;
    }

    // bounce light
    {
        vec3 bouColor = vec3(0.2,0.4,0.0)*1.2;
        float dif = clamp(0.5 - 0.5*nor.y,0.0,1.0);
        col += matColor * bouColor * dif * occ;
    }

    col += fre*matColor*occ*matSSS;
    col = pow( max(col,0.0), matGamma );

    return col;
}

vec3 background(in vec3 d)
{
    // cheap cubemap
    vec3 n = abs(d);
    vec2 uv = (n.x>n.y && n.x>n.z) ? d.yz/d.x: 
              (n.y>n.x && n.y>n.z) ? d.zx/d.y:
                                     d.xy/d.z;
    
    return vec3(0.02,0.01,0.00) + vec3(2.5)*pow(texture( iChannel1, 0.1*uv, 1.0 ).yxz,vec3(2.6,4.0,4.2));
}

mat3 calcCamera( in vec3 ro, in vec3 ta )
{
    vec3 w = normalize( ro-ta );
    vec3 u = normalize( cross( vec3(0.0,1.0,0.0), w ) );
    vec3 v = normalize( cross( w, u ) );
    
    return mat3( u, v, w );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy+2.0*fragCoord) / iResolution.y;
    
    // camera
    vec3 ro = vec3(0.0,2.7,-3.0);
    vec3 ta = vec3(0.0,1.9,0.0);
    ro.x += 0.3*sin(0.03*iTime);    
    mat3 camRot = calcCamera( ro, ta );
    
    // ray
    vec3 rd = normalize( camRot * vec3(p,-2.0) );
    
    // background
    vec3 col = background(rd);
 
    // scene
    vec3 tm = intersect(ro,rd);
    float t = tm.x;
    float matID = tm.y;
    if( matID>0.5 )
    {
        vec3 pos = ro + t*rd;
    	vec3 nor = calcNormal( pos ); 
        
        vec3 matNormal, matColor, matGamma;
        float matRough, matOcc, matSSS, matRefOcc;
        
        materials( matID, tm.z, pos, nor, matColor, matRough, matNormal, matOcc, matSSS, matRefOcc, matGamma );
        col = lighting( t, rd, pos, matNormal, matOcc, matColor, matRough, matSSS, matRefOcc, matGamma );
    }
    else
    {
        t = 30.0;
    }
    
	fragColor = vec4( col, t*dot(rd,normalize(ta-ro)) );
}
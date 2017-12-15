// https://www.shadertoy.com/view/4sS3zG
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//#define HIGH_QUALITY_NOISE
	
float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);
	f = f*f*(3.0-2.0*f);
#ifdef HIGH_QUALITY_NOISE	
	float a = textureLod( iChannel0, (p+vec2(0.5,0.5))/256.0, 0.0 ).x;
	float b = textureLod( iChannel0, (p+vec2(1.5,0.5))/256.0, 0.0 ).x;
	float c = textureLod( iChannel0, (p+vec2(0.5,1.5))/256.0, 0.0 ).x;
	float d = textureLod( iChannel0, (p+vec2(1.5,1.5))/256.0, 0.0 ).x;
	return -1.0 + 2.0*mix( mix(a,b,f.x), mix(c,d,f.x), f.y );
#else
	return -1.0 + 2.0*textureLod( iChannel0, (p+f+0.5)/256.0, 0.0 ).x;
#endif	
}

vec2 sd2Segment( vec3 a, vec3 b, vec3 p )
{
	vec3  pa = p - a;
	vec3  ba = b - a;
	float t = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	vec3  v = pa - ba*t;
	return vec2( dot(v,v), t );
}

float udBox(vec3 p, vec3 b)
{
    return length(max(abs(p)-b, 0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
    return length(max(abs(p)-b,0.0))-r;
}

float smin( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( b, a, h ) - k*h*(1.0-h);
}

//-----------------------------------------------------------------------------------

#define NUMI 11
#define NUMF 11.0

vec3 fishPos;
float fishTime;
float isJump;
float isJump2;

vec2 anima( float ih, float t )
{
    float an1 = 0.9*(0.5+0.2*ih)*cos(5.0*ih - 3.0*t + 6.2831/4.0);
    float an2 = 1.0*cos(3.5*ih - 1.0*t + 6.2831/4.0);
    float an = mix( an1, an2, isJump );
    float ro = 0.4*cos(4.0*ih - 1.0*t)*(1.0-0.5*isJump);
	return vec2( an, ro );
}

vec3 anima2( void )
{
    vec3 a1 = vec3(0.0,        sin(3.0*fishTime+6.2831/4.0),0.0);
    vec3 a2 = vec3(0.0,1.5+2.5*cos(1.0*fishTime),0.0);
	vec3 a = mix( a1, a2, isJump );
	a.y *= 0.5;
	a.x += 0.1*sin(0.1 - 1.0*fishTime)*(1.0-isJump);
    return a;
}

vec2 sdDolphinCheap( vec3 p )
{
    vec2 res = vec2( 1000.0, 0.0 );

	p -= fishPos;
		
	vec3 a = anima2();
	
	float or = 0.0;
	float th = 0.0;
	float hm = 0.0;

	vec3 mp = a;
	for( int i=0; i<NUMI; i++ )
	{	
		float ih = float(i)/NUMF;
		vec2 anim = anima( ih, fishTime );
		
		float ll = 0.48; if( i==0 ) ll=0.655;
		vec3 b = a + ll*normalize(vec3(sin(anim.y), sin(anim.x), cos(anim.x)));
		
		vec2 dis = sd2Segment( a, b, p );

		if( dis.x<res.x ) {res=vec2(dis.x,ih+dis.y/NUMF); mp=a+(b-a)*dis.y; }
		
		a = b;
	}
	float h = res.y;
	float ra = 0.04 + h*(1.0-h)*(1.0-h)*2.7;

	res.x = 0.75 * (distance(p,mp) - ra);

	return res;
}

vec3 ccd, ccp;
	
vec2 sdDolphin( vec3 p )
{
    vec2 res = vec2( 1000.0, 0.0 );

	p -= fishPos;

	vec3 a = anima2();
	
	float or = 0.0;
	float th = 0.0;
	float hm = 0.0;

	vec3 p1 = a; vec3 d1=vec3(0.0);
	vec3 p2 = a; vec3 d2=vec3(0.0);
	vec3 p3 = a; vec3 d3=vec3(0.0);
	vec3 mp = a;
	for( int i=0; i<NUMI; i++ )
	{	
		float ih = float(i)/NUMF;
		vec2 anim = anima( ih, fishTime );
		float ll = 0.48; if( i==0 ) ll=0.655;
		vec3 b = a + ll*normalize(vec3(sin(anim.y), sin(anim.x), cos(anim.x)));
		
		vec2 dis = sd2Segment( a, b, p );

		if( dis.x<res.x ) {res=vec2(dis.x,ih+dis.y/NUMF); mp=a+(b-a)*dis.y; ccd = b-a;}
		
		if( i==3 ) { p1=a; d1 = b-a; }
		if( i==4 ) { p3=a; d3 = b-a; }
		if( i==(NUMI-1) ) { p2=b; d2 = b-a; }

		a = b;
	}
	ccp = mp;
	
	float h = res.y;
	float ra = 0.05 + h*(1.0-h)*(1.0-h)*2.7;
	ra += 7.0*max(0.0,h-0.04)*exp(-30.0*max(0.0,h-0.04)) * smoothstep(-0.1, 0.1, p.y-mp.y);
	ra -= 0.03*(smoothstep(0.0, 0.1, abs(p.y-mp.y)))*(1.0-smoothstep(0.0,0.1,h));
	ra += 0.05*clamp(1.0-3.0*h,0.0,1.0);
    ra += 0.035*(1.0-smoothstep( 0.0, 0.025, abs(h-0.1) ))* (1.0-smoothstep(0.0, 0.1, abs(p.y-mp.y)));
	
	// body
	res.x = 0.75 * (distance(p,mp) - ra);
	//res.x = 0.75 * (res.x*3.0 - ra);

    // fin	
	d3 = normalize(d3);
	float k = sqrt(1.0 - d3.y*d3.y);
	mat3 ms = mat3(  d3.z/k, -d3.x*d3.y/k, d3.x,
				        0.0,            k, d3.y,
				    -d3.x/k, -d3.y*d3.z/k, d3.z );
	vec3 ps = p - p3;
	ps = ms*ps;
	ps.z -= 0.1;
    float d5 = length(ps.yz) - 0.9;
	d5 = max( d5, -(length(ps.yz-vec2(0.6,0.0)) - 0.35) );
	d5 = max( d5, udRoundBox( ps+vec3(0.0,-0.5,0.5), vec3(0.0,0.5,0.5), 0.02 ) );
	res.x = smin( res.x, d5, 0.1 );

	
#if 1
    // fin	
	d1 = normalize(d1);
	k = sqrt(1.0 - d1.y*d1.y);
	ms = mat3(  d1.z/k, -d1.x*d1.y/k, d1.x,
				   0.0,            k, d1.y,
               -d1.x/k, -d1.y*d1.z/k, d1.z );
	ps = p - p1;
	ps = ms*ps;
	ps.x = abs(ps.x);
	float l = ps.x;
	l=clamp( (l-0.4)/0.5, 0.0, 1.0 );
	l=4.0*l*(1.0-l);
	l *= 1.0-clamp(5.0*abs(ps.z+0.2),0.0,1.0);
	ps.xyz += vec3(-0.2,0.36,-0.2);
    d5 = length(ps.xz) - 0.8;
	d5 = max( d5, -(length(ps.xz-vec2(0.2,0.4)) - 0.8) );
	d5 = max( d5, udRoundBox( ps+vec3(0.0,0.0,0.0), vec3(1.0,0.0,1.0), 0.015+0.05*l ) );
	res.x = smin( res.x, d5, 0.12 );
#endif
	
    // tail	
	d2 = normalize(d2);
	mat2 mf = mat2( d2.z, d2.y, -d2.y, d2.z );
	vec3 pf = p - p2 - d2*0.25;
	pf.yz = mf*pf.yz;
    float d4 = length(pf.xz) - 0.6;
	d4 = max( d4, -(length(pf.xz-vec2(0.0,0.8)) - 0.9) );
	d4 = max( d4, udRoundBox( pf, vec3(1.0,0.005,1.0), 0.005 ) );
	res.x = smin( res.x, d4, 0.1 );
	
	
	return res;
}

const mat2 m2 = mat2( 0.80, -0.60, 0.60, 0.80 );

vec3 sdWater( vec3 p )
{
	vec2 q = 0.16*p.xz;
    q.y *= 0.75;

	float f = 0.0;
    f += 0.50000*abs(noise( q )); q = m2*q*2.02; q -= 0.1*iTime;
    f += 0.25000*abs(noise( q )); q = m2*q*2.03; q += 0.2*iTime;
    f += 0.12500*abs(noise( q )); q = m2*q*2.01; q -= 0.4*iTime;
    f += 0.06250*abs(noise( q )); q = m2*q*2.02; q += 1.0*iTime;
    f += 0.03125*abs(noise( q ));
	
	float sss = abs(sdDolphinCheap(p).x);
	float spla = exp(-4.0*sss);
	spla += 0.5*exp(-14.0*sss);
	spla *= mix(1.0,texture( iChannel0, 0.2*p.xz ).x,spla*spla);
	spla *= -0.85;
	spla *= isJump;
	spla *= mix( 1.0, smoothstep(0.0,0.5,p.z-fishPos.z-1.5), isJump2 );

	return vec3( p.y-1.5+1.2*f + 0.1 + spla, f, sss );
}

float sdWaterCheap( vec3 p )
{
	vec2 q = 0.16*p.xz;
    q.y *= 0.75;

	float f = 0.0;
    f += 0.50000*abs(noise( q )); q = m2*q*2.02; q -= 0.1*iTime;
    f += 0.25000*abs(noise( q )); q = m2*q*2.03; q += 0.2*iTime;
    f += 0.12500*abs(noise( q )); q = m2*q*2.01; q -= 0.4*iTime;
    f += 0.06250*abs(noise( q )); q = m2*q*2.02; q += 1.0*iTime;
    f += 0.03125*abs(noise( q ));
	return f;
}

vec2 intersectDolphin( in vec3 ro, in vec3 rd )
{
	const float maxd = 10.0;
	const float precis = 0.001;
    float h = precis*3.0;
    float t = 0.0;
	float l = 0.0;
    for( int i=0; i<50; i++ )
    {
        //if( h>precis && t<maxd )
		if( h<precis || t>maxd ) break;
		{
        t += h;
	    vec2 res = sdDolphin( ro+rd*t );
        h = res.x;
		l = res.y;
		}
    }

    if( t>maxd ) t=-1.0;
    return vec2( t, l);
}

vec3 intersectWater( vec3 ro, in vec3 rd )
{
	const float precis = 0.001;
    float h = precis*3.0;
	float l = 0.0;
	float s = 0.0;

	float t = (2.5-ro.y)/rd.y; 
	if( t<0.0 ) return vec3(-1.0);

	for( int i=0; i<12; i++ )
    {
		if( h<precis ) break;
		{
        t += h;
	    vec3 res = sdWater( ro+rd*t );
        h = res.x;
		l = res.y;
		s = res.z;
		}
    }

    return vec3( t, l, s );
}


vec3 calcNormalFish( in vec3 pos )
{
    const vec3 eps = vec3(0.08,0.0,0.0);
	float v = sdDolphin(pos).x;
	return normalize( vec3(
           sdDolphin(pos+eps.xyy).x - v,
           sdDolphin(pos+eps.yxy).x - v,
           sdDolphin(pos+eps.yyx).x - v ) );
}

vec3 calcNormalWater( in vec3 pos )
{
    const vec3 eps = vec3(0.025,0.0,0.0);
    float v = sdWater(pos).x;	
	return normalize( vec3( sdWater(pos+eps.xyy).x - v,
                            eps.x,
                            sdWater(pos+eps.yyx).x - v ) );
}

float softshadow( in vec3 ro, in vec3 rd, float mint, float k )
{
    float res = 1.0;
    float t = mint;
	float h = 1.0;
    for( int i=0; i<25; i++ )
    {
        h = sdDolphinCheap(ro + rd*t).x;
        res = min( res, k*h/t );
		t += clamp( h, 0.05, 0.5 );
		if( h<0.0001 ) break;
    }
    return clamp(res,0.0,1.0);
}

//vec3 lig = normalize(vec3(0.9,0.15,0.5));
const vec3 lig = vec3(0.86,0.15,0.48);

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, float glossy, float glossy2, float shadows, in vec3 col, float occ )
{
	vec3 ref = reflect(rd,nor);
	
    // lighting
    float sky = clamp(nor.y,0.0,1.0);
	float bou = clamp(-nor.y,0.0,1.0);
    float dif = max(dot(nor,lig),0.0);
    float bac = max(0.3 + 0.7*dot(nor,-vec3(lig.x,0.0,lig.z)),0.0);
    float sha = 1.0-shadows; if( (shadows*dif)>0.001 ) sha=softshadow( pos+0.01*nor, lig, 0.0005, 32.0 );
    float fre = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 5.0 );
    float spe = max( 0.0, pow( clamp( dot(lig,ref), 0.0, 1.0), 0.01+glossy ) ) * glossy;
    float sss = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 3.0 );
		
    // lights
    vec3 brdf = vec3(0.0);
	brdf += 8.0*dif*vec3(1.80,1.35,0.90)*vec3(sha,sha*0.5+0.5*sha*sha,sha*sha);
    brdf += 1.0*sky*vec3(0.20,0.40,0.55)*occ;
    brdf += 1.0*bac*vec3(0.40,0.60,0.70)*occ;
    brdf += 1.0*bou*vec3(0.10,0.20,0.25);
    brdf += 1.0*sss*vec3(0.40,0.40,0.40)*(0.3+0.7*dif*sha)*glossy*occ;
    brdf += 0.5*spe*vec3(1.3,1.0,0.8)*sha*(0.3+0.7*fre)*occ*glossy;
    brdf += glossy*0.3*vec3(0.8,0.9,1.0)*occ*smoothstep( 0.0, 0.2, ref.y )*(0.5+0.5*smoothstep( 0.0, 1.0, ref.y ));//*smoothstep(-0.1,0.0,dif);
	
    col = col*brdf;

    col += (0.5 + 1.5*fre)*occ*glossy2*glossy2*10.0*vec3(1.0,0.9,0.8)*smoothstep( 0.0, 0.2, ref.y )*(0.5+0.5*smoothstep( 0.0, 1.0, ref.y ));//*smoothstep(-0.1,0.0,dif);
    col += 0.25*glossy*pow(spe/(0.01+glossy),8.0)*vec3(1.3,1.0,0.8)*sha*(0.3+0.7*fre)*occ;
	
	return col;
}

vec3 normalMap( in vec2 pos )
{
	pos *= 6.0;
	pos.y *= 0.375;
	
	float v = texture( iChannel2, 0.015*pos ).x;
	vec3 nor = vec3( texture( iChannel2, 0.015*pos+vec2(1.0/1024.0,0.0)).x - v,
	                 1.0/16.0,
	                 texture( iChannel2, 0.015*pos+vec2(0.0,1.0/1024.0)).x - v );
	nor.xz *= -1.0;
	return normalize( nor );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;


    //-----------------------------------------------------
    // animate
    //-----------------------------------------------------
	
	fishTime = 0.6 + 2.0*iTime - 20.0;
	
	fishPos = vec3( 0.0, 0.0-0.2, -1.1*fishTime );
	
	isJump  = 0.5 + 0.5*cos(     -0.4+0.5*fishTime);
	isJump2 = 0.5 + 0.5*cos( 0.6+0.5*fishTime);
	float isJump3 = 0.5 + 0.5*cos(-1.4+0.5*fishTime);

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------

	float an = 1.2 + 0.1*iTime - 12.0*(m.x-0.5);

	vec3 ta = vec3(fishPos.x,0.8,fishPos.z) - vec3(0.0,0.0,-2.0);
	vec3 ro = ta + vec3(4.0*sin(an),3.1,4.0*cos(an));

    // shake
	ro += 0.05*sin(4.0*iTime*vec3(1.1,1.2,1.3)+vec3(3.0,0.0,1.0) );
	ta += 0.05*sin(4.0*iTime*vec3(1.7,1.5,1.6)+vec3(1.0,2.0,1.0) );

    // camera matrix
    vec3 ww = normalize( ta - ro );
    //vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
	vec3 uu = normalize( vec3(-ww.z,0.0,ww.x) );
    vec3 vv = normalize( cross(uu,ww));
	
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww*(1.0+0.7*smoothstep(-0.4,0.4,sin(0.34*iTime))) );

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	float t = 1000.0;
	
	vec3 col = vec3(0.0);
	vec3 bgcol = vec3(0.6,0.7,0.8) - .2*clamp(rd.y,0.0,1.0);

    // quick step till y=3 bounding plane
	float pt = (3.0-ro.y)/rd.y;
	if( rd.y<0.0 && pt>0.0 ) ro=ro+rd*pt;

	// raymarch
    vec2 tmat1 = intersectDolphin(ro,rd);
	vec3 posy = vec3(-100000.0);
    if( tmat1.x>0.0 )
    {
		vec2 tmat = tmat1;
		t = tmat.x;
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormalFish(pos);
		vec3 ref = reflect( rd, nor );
		vec3 fpos = pos - fishPos;

		vec3 auu = normalize( vec3(-ccd.z,0.0,ccd.x) );
		vec3 avv = normalize( cross(ccd,auu) );
		vec3 ppp = vec3( dot(fpos-ccp,auu),  dot(fpos-ccp,avv),  tmat.y );
		vec2 uv = vec2( 1.0*atan(ppp.x,ppp.y)/3.1416, 4.0*ppp.z );

		vec3 bnor = -1.0+2.0*texture(iChannel0,uv).xyz;
        nor += 0.01*bnor;

		vec3 te = texture( iChannel2, uv ).xyz;
		vec4 mate;
		mate.w = 17.0;
        mate.xyz = mix( vec3(0.3,0.35,0.4), vec3(0.8,0.85,0.9)*0.9, 0.8*smoothstep(-0.05,0.05,ppp.y) );;

        mate.xyz *= 1.0 + 0.3*te;
		mate.xyz *= smoothstep( 0.0, 0.06, distance(vec3(abs(ppp.x),ppp.yz)*vec3(1.0,1.0,4.0),vec3(0.35,0.0,0.4)) );
		mate.xyz *= 1.0 - 0.75*(1.0-smoothstep( 0.0, 0.02, abs(ppp.y) ))*(1.0-smoothstep( 0.07, 0.11, tmat.y ));
		
		mate.xyz *= 0.1*0.23;
		
        mate.w *= (0.7+0.3*te.x)*smoothstep( 0.0, 0.01, pos.y-sdWaterCheap( pos ) );
			
        // surface-light interacion
        col = doLighting( pos, nor, rd, mate.w, 0.0, 0.0, mate.xyz, 1.0 );
	
		posy = pos;
	}

	
    vec3 tmat2 = intersectWater(ro,rd);
	vec3 col2 = vec3(0.0);
	if( tmat2.x>0.0 && (tmat1.x<0.0 || tmat2.x<tmat1.x) )
	{
		vec3 tmat = tmat2;

        t = tmat.x;

        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormalWater(pos);
		vec3 ref = reflect( rd, nor );

        vec4 mate = vec4(0.4,0.4,0.4,0.0);

		vec3 bnor = normalMap(pos.xz);
        nor = normalize( nor + 0.2*bnor );

        float fre = pow( clamp(1.0 + dot( rd, nor ),0.0,1.0), 2.0 );

		mate.xyz = 0.3*mix( vec3(0.0,0.03,0.07), 0.1*vec3(0.0,0.3,0.4), fre );
		mate.w = fre;	

        float foam = 1.0-smoothstep( 0.1, 0.65, tmat.y );
        foam *= smoothstep( 0.0, 0.3, abs(nor.x) );
		
        foam *= clamp(1.0-texture( iChannel2, vec2(1.0,0.75)*0.45*pos.xz ).x*2.0,0.0,1.0);
        mate = mix( mate, vec4(0.7,0.7,0.7,0.0), 0.2*foam );

		float al = clamp( 0.5 + 0.2*(pos.y - posy.y), 0.0, 1.0 );
		
		//foam = exp( -3.0*abs(sdFishCheap(pos).x) );
		foam = exp( -3.0*abs(tmat.z) );
		
		foam *= texture( iChannel3, pos.zx ).x;
		foam = clamp( foam*3.0, 0.0, 1.0 );
		foam *= isJump;
		foam *= mix( 1.0, smoothstep(0.0,0.5,pos.z-fishPos.z-1.5), isJump2 );
		mate.xyz = mix( mate.xyz, vec3(0.9,0.95,1.0)*0.3, foam*foam );
		col = mix( col, vec3(0.9,0.95,1.0)*1.2, foam );
		al *= 1.0-foam;

		float occ = clamp(3.5*sdDolphinCheap(pos+vec3(0.0,0.4,0.0)).x * sdDolphinCheap(pos+vec3(0.0,1.0,0.0)).x,0.0,1.0);
        occ = mix(1.0,occ,isJump);
        occ = 0.35 + 0.65*occ;
		mate.xyz *= occ;
        col *= occ;

		mate.xyz = doLighting( pos, nor, rd, mate.w*10.0, mate.w*0.5, 1.0, mate.xyz, occ );
		
        // caustics
        float cc  = 0.65*texture( iChannel0, 2.5*0.02*posy.xz + 0.007*iTime*vec2( 1.0, 0.0) ).x;
        cc += 0.35*texture( iChannel0, 1.8*0.04*posy.xz + 0.011*iTime*vec2( 0.0, 1.0) ).x;
        cc = 0.6*(1.0-smoothstep( 0.0, 0.05, abs(cc-0.5))) + 
	         0.4*(1.0-smoothstep( 0.0, 0.20, abs(cc-0.5)));
        col *= 1.0 + 0.8*cc;
		
		col = mix( col, mate.xyz, al );
	}
		
	
	float sun = pow( max(0.0,dot( lig, rd )),8.0 );
	col += vec3(0.8,0.5,0.1)*sun*0.3;

    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );

    // color
	col = col*vec3(0.9,0.85,0.8) + 0.4*col*col*(3.0-2.0*col);
		
    // vigneting	
	col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 );

    // fade	
	col *= smoothstep( 0.0, 1.0, iTime );
	
	fragColor = vec4( col, 1.0 );
}

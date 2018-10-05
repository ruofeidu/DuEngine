//Hatching by nmz (twitter: @stormoid)

/*
	nimitz here, I'll post what I feel to be "less interesting"
	shaders	on this account from now on.

	Showing here procedural hatching using a combination
	of triplanar and cube projection

	The "shadows" you see are only done using a denser hatching param.

	Also featuring simple sepia tone conversion.
*/

#define ITR 80
#define FAR 15.
#define time iTime

mat2 mm2(in float a){float c = cos(a), s = sin(a);return mat2(c,-s,s,c);}

float torus(in vec3 p, in vec2 t){
  return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}

float map(vec3 p)
{
    float d = torus(p,vec2(.9,0.33));
    d = min(d, -length(p)+5.);   
    return d;
}

float march(in vec3 ro, in vec3 rd)
{
	float precis = 0.001;
    float h=precis*2.;
    float d = 0.;
    for( int i=0; i<ITR; i++ )
    {
        if( abs(h)<precis || d>FAR ) break;
        d += h;
	    float res = map(ro+rd*d);
        h = res;
    }
	return d;
}

float noise( in vec2 x ){return texture(iChannel0, x*.01).x;}
float texh(in vec2 p, in float str)
{
    p*= .7;
    float rz= 1.;
    for (int i=0;i<10;i++)
    {
        float g = texture(iChannel0,vec2(0.025,.5)*p).x;
        g = smoothstep(0.-str*0.1,2.3-str*0.1,g);
        rz = min(1.-g,rz);
        p.xy = p.yx;
        p += .07;
        p *= 1.2;
        if (float(i) > str)break;
    }
    return rz*1.05;
}

vec3 cubeproj(in vec3 p, in float str)
{
    vec3 x = vec3(texh(p.zy/p.x,str));
    vec3 y = vec3(texh(p.xz/p.y,str));
    vec3 z = vec3(texh(p.xy/p.z,str));
    
    p = abs(p);
    if (p.x > p.y && p.x > p.z) return x;
    else if (p.y > p.x && p.y > p.z) return y;
    else return z;
}

float texcube(in vec3 p, in vec3 n, in float str)
{
	float x = texh(p.yz,str);
	float y = texh(p.zx,str);
	float z = texh(p.xy,str);
    n *= n;
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}

vec3 normal(in vec3 p, in vec3 rd)
{  
    vec2 e = vec2(-1., 1.)*0.005;
	vec3 n = (e.yxx*map(p + e.yxx) + e.xxy*map(p + e.xxy) + e.xyx*map(p + e.xyx) + e.yyy*map(p + e.yyy) );
	n -= max(.0, dot (n, rd))*rd;
    return normalize(n);
}

float shadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<21; i++ )
    {
		float h = map( ro + rd*t );
        res = min( res, 6.0*h/t );
        t += clamp( h, 0.03, 0.2 );
        if( abs(h)<0.005 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}

vec3 sepia(in vec3 col)
{
    return vec3(dot(col, vec3(0.393,0.769,0.189)),
                dot(col, vec3(0.349,0.686,0.168)),
                dot(col, vec3(0.272,0.534,0.131)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = q-0.5;
	p.x*=iResolution.x/iResolution.y;
	vec2 mo = iMouse.xy / iResolution.xy-.5;
	mo.x *= iResolution.x/iResolution.y;
    
    vec3 ro = vec3(0,2.+sin(time*0.5)-.7,0.);
    ro.x += sin(time*.5)*4.;
    ro.z += cos(time*.5)*4.;
    
    vec3 tgt = vec3(0,0,.5+sin(time));
    vec3 eye = normalize( tgt - ro);
    vec3 rgt = normalize(cross( vec3(0.0,1.0,0.0), eye ));
    vec3 up = normalize(cross(eye,rgt));
    vec3 rd = normalize( p.x*rgt + p.y*up + 1.5*eye );

	float rz = march(ro,rd);
	
    vec3 col = vec3(0.);
    vec3 ligt = vec3(1,2,3);
    
    if ( rz < FAR )
    {
        vec3 pos = ro+rz*rd;
        vec3 nor= normal(pos,rd);
        float nl  = max(dot(nor,normalize(ligt)),0.);
        float sh = shadow(pos,normalize(ligt-pos),0.1,distance(pos,ligt));
        nl *= sh*0.8+0.2;
        nl = 1.0-nl;
        nl = clamp(nl,0.,1.);
        const float st = 10.;
        vec3 col1 = vec3(texcube(pos,nor,nl*st));
        vec3 col2 = cubeproj(pos,nl*st);
        col = mix(col1,col2, .5);
    }
    
    if (distance(ro,ligt) < rz)
    {
		float lball = pow(max(dot(normalize(rd), normalize(ligt-ro)),0.), 4000.0);
    	col += lball*vec3(1)*2.;
    }
    
    col = sepia(col);
	col *= pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.12 )*0.5+0.5; //form iq
	fragColor = vec4( col, 1.0 );
}
// https://www.shadertoy.com/view/4d2cWd 
// Splitting DNA by Martijn Steinrucken aka BigWings - 2017
// countfrolic@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// Its still a little slow. I tried a bunch of things to optimize:
// Using raytracing, instead of marching:  works, is significantly faster but I couldn't get rid of artifacts. 
// Using bounding volumes: makes it a little bit faster, though not nearly as much as I had hoped.
// Only calculating the color once in the end: should save a ton of mix-es, not noticably faster
// Skipping to the next strand when marching away from current one: works, makes it a little faster
// Mirroring the backbone: doesn't have any noticable effect
//
// Took me a loong time to figure out the atomic structure of the bases, its not easy to figure 
// out from 2d pictures, I might very well have made a mistake.
//
// Use the mouse to look around a little bit.
//
// Anyways, worked on this for too long already, gotta ship it. Hope you like!


#define INVERTMOUSE -1.

// comment out to see one basepair by itself
#define STRANDS

#define MAX_INT_STEPS 100

#define MIN_DISTANCE 0.1
#define MAX_DISTANCE 1000.
#define RAY_PRECISION .1

#define OPTIMIZED
#define USE_BOUNDING_VOLUMES
// set to -1 to see bounding spheres
#define SHOW_BOUNDING_VOLUMES 1.  

#define S(x,y,z) smoothstep(x,y,z)
#define B(x,y,z,w) S(x-z, x+z, w)*S(y+z, y-z, w)
#define sat(x) clamp(x,0.,1.)
#define SIN(x) sin(x)*.5+.5

float smth = .6;
float hr = 1.;					// radii of atoms
float nr = 2.264;
float cr = 2.674;
float or = 2.102;
float pr = 3.453;

vec3 hc = vec3(1.);				// colors of atoms
vec3 nc = vec3(.1, .1, 1.);
vec3 cc = vec3(.1);
vec3 oc = vec3(1., .1, .1);
vec3 pc = vec3(1., .75, .3);

const vec3 lf=vec3(1., 0., 0.);
const vec3 up=vec3(0., 1., 0.);
const vec3 fw=vec3(0., 0., 1.);

const float halfpi = 1.570796326794896619;
const float pi = 3.141592653589793238;
const float twopi = 6.283185307179586;


vec3 bg = vec3(.1, .5, 1.); // global background color

float L2(vec3 p) {return dot(p, p);}
float L2(vec2 p) {return dot(p, p);}

float N1( float x ) { return fract(sin(x)*5346.1764); }
float N2(float x, float y) { return N1(x + y*23414.324); }

float N3(vec3 p) {
    p  = fract( p*0.3183099+.1 );
	p *= 17.0;
    return fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}

vec3 N31(float p) {
    //  3 out, 1 in... DAVE HOSKINS
   vec3 p3 = fract(vec3(p) * vec3(.1031,.11369,.13787));
   p3 += dot(p3, p3.yzx + 19.19);
   return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}


struct ray {
    vec3 o;
    vec3 d;
};

struct camera {
    vec3 p;			// the position of the camera
    vec3 forward;	// the camera forward vector
    vec3 left;		// the camera left vector
    vec3 up;		// the camera up vector
	
    vec3 center;	// the center of the screen, in world coords
    vec3 i;			// where the current ray intersects the screen, in world coords
    ray ray;		// the current ray: from cam pos, through current uv projected on screen
    vec3 lookAt;	// the lookat point
    float zoom;		// the zoom factor
};

struct de {
    // data type used to pass the various bits of information used to shade a de object
	float d;	// distance to the object
    float m; 	// material
    vec3 col;
    
    vec3 id;
    float spread;
    // shading parameters
    vec3 pos;		// the world-space coordinate of the fragment
    vec3 nor;		// the world-space normal of the fragment
    vec3 rd;
    float fresnel;	
};
    
struct rc {
    // data type used to handle a repeated coordinate
	vec3 id;	// holds the floor'ed coordinate of each cell. Used to identify the cell.
    vec3 h;		// half of the size of the cell
    vec3 p;		// the repeated coordinate
    vec3 c;		// the center of the cell, world coordinates
};
    
rc Repeat(vec3 pos, vec3 size) {
	rc o;
    o.h = size*.5;					
    o.id = floor(pos/size);			// used to give a unique id to each cell
    o.p = mod(pos, size)-o.h;
    o.c = o.id*size+o.h;
    
    return o;
}
    
camera cam;


void CameraSetup(vec2 uv, vec3 position, vec3 lookAt, float zoom) {
	
    cam.p = position;
    cam.lookAt = lookAt;
    cam.forward = normalize(cam.lookAt-cam.p);
    cam.left = cross(up, cam.forward);
    cam.up = cross(cam.forward, cam.left);
    cam.zoom = zoom;
    
    cam.center = cam.p+cam.forward*cam.zoom;
    cam.i = cam.center+cam.left*uv.x+cam.up*uv.y;
    
    cam.ray.o = cam.p;						// ray origin = camera position
    cam.ray.d = normalize(cam.i-cam.p);	// ray direction is the vector from the cam pos through the point on the imaginary screen
}

float remap01(float a, float b, float t) { return (t-a)/(b-a); }


// DE functions from IQ
// https://www.shadertoy.com/view/Xds3zN

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

vec2 smin2( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return vec2(mix( b, a, h ) - k*h*(1.0-h), h);
}

float smax( float a, float b, float k )
{
	float h = clamp( 0.5 + 0.5*(b-a)/k, 0.0, 1.0 );
	return mix( a, b, h ) + k*h*(1.0-h);
}

float sdSphere( vec3 p, vec3 pos, float s ) { return (length(p-pos)-s)*.9; }


vec3 background(vec3 r) {
	float y = pi*0.5-acos(r.y);  		// from -1/2pi to 1/2pi		
    
    return bg*(1.+y);
}

vec4 Adenine(vec3 p, float getColor) {
   #ifdef USE_BOUNDING_VOLUMES
    float b = sdSphere(p, vec3(29.52, 6.64, 3.04), 11.019);
    
    if(b>0.)
        return vec4(bg, b+SHOW_BOUNDING_VOLUMES);
    else {
 #endif
    
    float h =  sdSphere(p, vec3(22.44, 13.63, 3.04), hr);
    h = min(h, sdSphere(p, vec3(21.93, 0.28, 3.04), hr));
    h = min(h, sdSphere(p, vec3(26.08, -1.19, 3.04), hr));
    h = min(h, sdSphere(p, vec3(39.04, 3.98, 3.04), hr));
    
    float n =  sdSphere(p, vec3(23.18, 7.49, 3.04), nr);
    n = min(n, sdSphere(p, vec3(28.39, 11.95, 3.04), nr));
    n = min(n, sdSphere(p, vec3(24.43, 0.75, 3.04), nr));
    n = min(n, sdSphere(p, vec3(32.79, 2.79, 3.04), nr));
    n = min(n, sdSphere(p, vec3(34.93, 8.83, 3.04), nr));
    
    float c =  sdSphere(p, vec3(24.50, 11.22, 3.04), cr);
    c = min(c, sdSphere(p, vec3(25.75, 4.47, 3.04), cr));
    c = min(c, sdSphere(p, vec3(29.65, 5.2, 3.04), cr));
    c = min(c, sdSphere(p, vec3(30.97, 8.93, 3.04), cr));
    c = min(c, sdSphere(p, vec3(36.06, 5.03, 3.04), cr));
    
    
        vec3 col = vec3(0.);
        float d;

        if(getColor!=0.) {
            vec2 i = smin2(h, n, smth);
            col = mix(nc, hc, i.y);        

            i = smin2(i.x, c, smth);
            col = mix(cc, col, i.y);

            d = i.x;
        } else
            d = smin(c, smin(h, n, smth), smth);

        return vec4(col, d);
    #ifdef USE_BOUNDING_VOLUMES
    }
    #endif
}

vec4 Thymine(vec3 p, float getColor) {

 #ifdef USE_BOUNDING_VOLUMES
    float b = sdSphere(p, vec3(12.96, 5.55, 3.04), 10.466);
    
    if(b>0.)
        return vec4(bg, b+SHOW_BOUNDING_VOLUMES);
    else {
 #endif
    float o =  sdSphere(p, vec3(18.171, -.019, 3.04), or);
    o = min(o, sdSphere(p, vec3(15.369, 13.419, 3.04), or));
    
    float h =  sdSphere(p, vec3(19.253, 7.218, 3.04), hr);
    h = min(h, sdSphere(p, vec3(12.54, -3.449, 4.534), hr));
    h = min(h, sdSphere(p, vec3(7.625, -1.831, 4.533), hr));
    h = min(h, sdSphere(p, vec3(10.083, -2.64, 0.052), hr));
    
    float n =  sdSphere(p, vec3(16.77, 6.7, 3.04), nr);
    n = min(n, sdSphere(p, vec3(10.251, 8.846, 3.04), nr));
    
    float c =  sdSphere(p, vec3(10.541, -1.636, 3.04), cr);
    c = min(c, sdSphere(p, vec3(11.652, 2.127, 3.04), cr));
    c = min(c, sdSphere(p, vec3(15.531, 2.936, 3.04), cr));
    c = min(c, sdSphere(p, vec3(9.012, 5.082, 3.04), cr));
    c = min(c, sdSphere(p, vec3(14.13, 9.655, 3.04), cr));
    

        vec3 col = vec3(0.);
        float d;

        if(getColor!=0.) {
            vec2 i = smin2(h, n, smth);
            col = mix(nc, hc, i.y);        

            i = smin2(i.x, c, smth);
            col = mix(cc, col, i.y);

            i = smin2(i.x, o, smth);
            col = mix(oc, col, i.y);

            d = i.x;
        } else
            d = smin(o, smin(c, smin(h, n, smth), smth), smth);

        return vec4(col, d);
    #ifdef USE_BOUNDING_VOLUMES
    }
    #endif
}




vec4 Cytosine(vec3 p, float getColor) {

 #ifdef USE_BOUNDING_VOLUMES
    float b = sdSphere(p, vec3(14.556, 5.484, 3.227), 10.060);
    if(b>0.)
        return vec4(bg, b+SHOW_BOUNDING_VOLUMES);
    else {
 #endif
        
        float c = sdSphere(p, vec3(11.689, 1.946, 3.067), cr);
        c = min(c, sdSphere(p, vec3(15.577, 2.755, 3.067), cr));
        c = min(c, sdSphere(p, vec3(14.176, 9.474, 3.067), cr));
        c = min(c, sdSphere(p, vec3(9.058, 4.9, 3.067), cr));

        float n = sdSphere(p, vec3(18.412, 0.342, 3.067), nr);
        n = min(n, sdSphere(p, vec3(16.816, 6.519, 3.067), nr));
        n = min(n, sdSphere(p, vec3(10.297, 8.665, 3.067), nr));

        float h = sdSphere(p, vec3(6.526, 3.015, 3.067), hr);
        h = min(h, sdSphere(p, vec3(10.61, -1.045, 3.067), hr));
        h = min(h, sdSphere(p, vec3(18.805, -2.297, 3.067), hr));
        h = min(h, sdSphere(p, vec3(20.95, 0.584, 3.067), hr));


        float o = sdSphere(p, vec3(15.415, 13.237, 3.067), or);

        vec3 col = vec3(1.);

        float d;
        
        if(getColor!=0.) {
            vec2 i = smin2(c, n, smth);
            col = mix(nc, cc, i.y);        

            i = smin2(i.x, h, smth);
            col = mix(hc, col, i.y);

            i = smin2(i.x, o, smth);
            col = mix(oc, col, i.y);
            
            d = i.x;
        } else
            d = smin(o, smin(h, smin(c, n, smth), smth), smth);
        
        return vec4(col, d);
    #ifdef USE_BOUNDING_VOLUMES
    }
    #endif
}

vec4 Guanine(vec3 p, float getColor) {

 #ifdef USE_BOUNDING_VOLUMES
    float b = sdSphere(p, vec3(29.389, 8.944, 3.227), 12.067);
    
    if(b>0.)
        return vec4(bg, b+SHOW_BOUNDING_VOLUMES);
    else {
 #endif
        
        float c = sdSphere(p, vec3(24.642, 11.602, 3.067), cr);
        c = min(c, sdSphere(p, vec3(31.111, 9.311, 3.067), cr));
        c = min(c, sdSphere(p, vec3(29.79, 5.576, 3.067), cr));
        c = min(c, sdSphere(p, vec3(25.893, 4.854, 3.067), cr));
        c = min(c, sdSphere(p, vec3(36.19, 5.409, 3.067), cr));

        float n = sdSphere(p, vec3(22.56, 14.31, 3.067), nr);
        n = min(n, sdSphere(p, vec3(23.32, 7.867, 3.067), nr));
        n = min(n, sdSphere(p, vec3(28.538, 12.325, 3.067), nr));
        n = min(n, sdSphere(p, vec3(32.934, 3.164, 3.067), nr));
        n = min(n, sdSphere(p, vec3(35.07, 9.209, 3.067), nr));

        float h = sdSphere(p, vec3(20.044, 14.723, 3.04), hr);
        h = min(h, sdSphere(p, vec3(22.852, 16.965, 3.04), hr));
        h = min(h, sdSphere(p, vec3(20.856, 7.404, 3.067), hr));
        h = min(h, sdSphere(p, vec3(39.187, 4.352, 3.067), hr));


        float o = sdSphere(p, vec3(24.7, 1.893, 3.067), or);

        vec3 col = vec3(1.);
        
        float d;
        
        if(getColor!=0.) {
            vec2 i = smin2(c, n, smth);
            col = mix(nc, cc, i.y);        

            i = smin2(i.x, h, smth);
            col = mix(hc, col, i.y);

            i = smin2(i.x, o, smth);
            col = mix(oc, col, i.y);
            
            d = i.x;
        } else
            d = smin(o, smin(h, smin(c, n, smth), smth), smth);
        
        return vec4(col, d);
    #ifdef USE_BOUNDING_VOLUMES
    }
    #endif
}


vec4 Backbone(vec3 p, float getColor) {

 #ifdef USE_BOUNDING_VOLUMES
    float b = sdSphere(p, vec3(0., 7.03, 0.), 10.572);   
    if(b>0.)
        return vec4(bg, b+SHOW_BOUNDING_VOLUMES);
    else {
 #endif       
        float c = sdSphere(p, vec3(1.391, 8.476, -0.708), cr);
        c = min(c, sdSphere(p, vec3(5.173, 9.661, -0.708), cr));
        c = min(c, sdSphere(p, vec3(6.342, 10.028, 3.061), cr));
        c = min(c, sdSphere(p, vec3(0.222, 8.109, 3.061), cr));
        c = min(c, sdSphere(p, vec3(0.658, 4.4, 4.8871), cr));

        float h = sdSphere(p, vec3(-5.853, 0., 2.213), hr);
        h = min(h, sdSphere(p, vec3(5.4512, 12.437, -2.216), hr));
        h = min(h, sdSphere(p, vec3(6.986, 7.541, -2.216), hr));
        h = min(h, sdSphere(p, vec3(-1.726, 10.517, 4.39), hr));
        h = min(h, sdSphere(p, vec3(3.203, 2.519, 4.691), hr));
        h = min(h, sdSphere(p, vec3(-1.619, 3.162, 3.063), hr));

        float o = sdSphere(p, vec3(-4.918, 1.599, 0.344), or);
        o = min(o, sdSphere(p, vec3(-1.471, 0.995, -5.1), or));
        o = min(o, sdSphere(p, vec3(-0.836, 6.288, -1.438), or));
        o = min(o, sdSphere(p, vec3(3.282, 9.068, 5.391), or));
        o = min(o, sdSphere(p, vec3(-6.286, 5.299, -4.775), or));
        
        float ph = sdSphere(p, vec3(-3.377, 3.544, -2.742), pr);
		
        #ifdef STRANDS
        o = min(o, sdSphere(p, vec3(-6.286, 5.299, 6.558), or));
        ph = min(ph, sdSphere(p, vec3(-3.377, 3.544, 8.592), pr)); // extra so it tiles better
        #endif
        
        vec3 col = vec3(1.);
		float d;
        
        if(getColor!=0.) {
            vec2 i = smin2(c, h, smth);
            col = mix(hc, cc, i.y);        

            i = smin2(i.x, o, smth);
            col = mix(oc, col, i.y);

            i = smin2(i.x, ph, smth);
            col = mix(pc, col, i.y);
            
            d = i.x;
        } else
            d = smin(ph, smin(o, smin(c, h, smth), smth), smth);
        
        return vec4(col, d);
  #ifdef USE_BOUNDING_VOLUMES      
    }
  #endif  
}




vec4 map( vec3 p, vec3 id, float spread, float getColor ) {
    
    p.z += 2.4;// offset so it tiles better
    vec4 col;
    
    vec3 bp = p;    
    bp.x = 22.5-bp.x;
    float side = sign(bp.x);
    bp.x = 22.5-abs(bp.x)+spread;
    bp.z = bp.z*side - min(0., side)*5.;
    vec4 b = Backbone(bp, getColor);
    
    vec4 c = vec4(1000.);
    vec4 g = vec4(1000.);
    vec3 cp = p;
    vec3 gp = p;
    
    float n = N3(id);
    
    if(n<.5) {
    	cp.xz = -cp.xz + vec2(46., 6.);
    	gp.xz = -gp.xz + vec2(46., 6.);
    }
    cp.x += spread;
    gp.x -= spread;
    
    if(mod(floor(n*4.), 2.)==0.) {
    	c = Cytosine(cp, getColor);
    	g = Guanine(gp, getColor);
    } else {    
    	g = Adenine(gp, getColor);
    	c = Thymine(cp, getColor);
    }
  
    col.a = min(b.a, min(c.a, g.a));
  
    if(getColor!=0.) {
        if(col.a==b.a)
            col.rgb = b.rgb;	
        else if(col.a==c.a)
            col.rgb = c.rgb;
        else
            col.rgb = g.rgb;
    }
    
    return col;
}


de castRay( ray r ) {
    float t = iTime*.3;
    
    de o;
    o.m = -1.0;
    vec2 cbd = vec2(MIN_DISTANCE, MAX_DISTANCE);
    vec2 bbd = cbd;
    
    vec4 col_pos;
    
    vec3 p = vec3(0.);
    
    float d = MIN_DISTANCE;
    rc q;
    vec3 center = vec3(19.12, 7.09, 3.09);
    float spread;
    
    vec3 grid = vec3(180., 180., 11.331);
    
    #ifdef STRANDS
    for( int i=0; i<MAX_INT_STEPS; i++ ) {
        p = r.o+r.d*d;
        float oz = p.z;
        
        q = Repeat(p, grid);
        float sd = length((q.c.xy-center.xy));
            
        p.z += t*200.*S(800., 100., sd);
        float n = N2(q.id.x, q.id.y);
        
        p.y += sin(n*twopi + p.z*.003+t)*50.*S(300., 500., sd);
        
        q = Repeat(p, grid);
		
       
        float z = oz*.05;
        float z2 = smax(0., abs(oz*.03)-6., 2.);
        float s = sin(z2);
        float c = cos(z2);
        
        oz *= .012;
        spread = max(0., 6.-oz*oz);
        spread *= spread;
        spread *= S(250., 1., length(q.id.xy*grid.xy+q.h.xy-r.o.xy));
            
        vec3 rC = ((2.*step(0., r.d)-1.)*q.h-q.p)/r.d;	// ray to cell boundary
        float dC = min(min(rC.x, rC.y), rC.z)+.01;		// distance to cell just past boundary
        
       
        
        float dS = MAX_DISTANCE;
        
        #ifdef OPTIMIZED
        vec2 bla = q.p.xy-center.xy;
        if(dot(bla, r.d.xy)>0. && length(bla)>50.)	// if we are stepping away from the strand and we are already far enough
        	dC = min(rC.x, rC.y)+1.;				// then we won't hit this strand anymore and we can skip to the next one
        else {
            #endif 
             q.p-=center;
        mat2 m = mat2(c, -s, s, c);
        q.p.xy *= m;
        q.p+=center;
            
        	dC = rC.z +.01;
            dS = map( q.p, q.id, spread, 0. ).a;
        #ifdef OPTIMIZED
        } 
        #endif
        
            
        if( dS<RAY_PRECISION || d>MAX_DISTANCE ) break;      
        
        d+=min(dS, dC);	// move to distance to next cell or surface, whichever is closest
    }
    
    #else
	q.id = vec3(0.);
    spread = 0.;
     for( int i=0; i<MAX_INT_STEPS; i++ ) {
        p = r.o+r.d*d;
         
        col_pos = map( p, vec3(0.), 0., 0. );
        float dS = col_pos.a;
        if( dS<RAY_PRECISION || d>MAX_DISTANCE ) break;      
       
        d+=dS;
    }
    #endif
    
    if(d<MAX_DISTANCE) { 
        o.m=1.;
        o.d = d;
        o.id = q.id;
        o.spread = spread;
        #ifdef STRANDS
        o.pos = q.p;
        #else
        o.pos = p;
        #endif
        
        o.d = d;
    }
    return o;
}

vec4 nmap( de o, vec3 offs ) {
   
    return map(o.pos+offs, o.id, o.spread, 0.);
}

de GetSurfaceProps( de o )
{
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 p = o.pos-eps.yyx;
    vec4 c = map(p, o.id, o.spread, 1.);
    o.col = c.rgb;
    
    vec3 nor = vec3(
	    nmap(o, eps.xyy).a - nmap(o, -eps.xyy).a,
	    nmap(o, eps.yxy).a - nmap(o, -eps.yxy).a,
	    nmap(o, eps.yyx).a - c.a );
	o.nor = normalize(nor);
    
    return o;
}

vec3 AtomMat(de o, vec3 rd) {
    o = GetSurfaceProps( o );
    
    vec3 R = reflect(cam.ray.d, o.nor);
    vec3 ref = background(R);
    
    float dif = dot(up, o.nor)*.5+.5;
    dif = mix(.3, 1., dif);
    
	vec3 col = o.col*dif;
    
    float t = iTime*50.+length(o.col)*10.;

    float fresnel = 1.-sat(dot(o.nor, -rd));
    fresnel = pow(fresnel, .5);
          
    
    
    #ifdef STRANDS
    float up = dot(rd, vec3(0., 1., 0.));
    col = mix(col, ref, fresnel*.5*S(.8, .0, up));
    col *= S(.9, .2, up);
    #else  
    col = mix(col, ref, fresnel*.5);
    #endif
    
    col = mix(col, bg, S(0., 1000., o.d));

    return col;
}

vec3 render( vec2 uv, ray camRay, float depth ) {
    // outputs a color
    
    bg = background(cam.ray.d);
    
    vec3 col = bg;
    de o = castRay(camRay);
   
    if(o.m>0.) {
        col = AtomMat(o, cam.ray.d);
    }
    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy);
    uv -= .5;
    uv.y *= iResolution.y/iResolution.x;
    vec2 m = iMouse.xy/iResolution.xy;
    
	float t = iTime;
    
   if(m.x==0.&&m.y==0.) m = vec2(.5, .5);
    
    
    #ifdef STRANDS
    float camDist = -4.;
    
    t = t * .2;
    
    float y = t*.5;;
    float x = t;
    vec3 camPos = vec3(-60.+sin(t)*180., -80.+sin(y)*250., 0.);
    
    m -= .5;
    vec3 pos = vec3(-(cos(x)+m.x)*3., -(cos(y)+m.y)*3., camDist);//*rotX;
    #else
    
    float turn = (.1-m.x)*twopi+t*.0;
    float s = sin(turn);
    float c = cos(turn);
    mat3 rotX = mat3(c,  0., s, 0., 1., 0., s,  0., -c);
    
    float camDist = -100.;
    vec3 camPos = vec3(19., 0., 0.);
    
    vec3 pos = vec3(0., INVERTMOUSE*camDist*cos((m.y)*pi), camDist)*rotX;
    #endif
    	
    CameraSetup(uv, camPos+pos, camPos, 1.);
    
    vec3 col = render(uv, cam.ray, 0.);
   
    fragColor = vec4(col, 1.);
}

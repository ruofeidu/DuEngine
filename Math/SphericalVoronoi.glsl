// MtBGRD
/* Spherical voronoi, by mattz. 
   License Creative Commons Attribution 3.0 (CC BY 3.0) Unported License.

   Mouse rotates (or click in bottom left for auto-rotate).

   Keys do things:

     D - toggle demo mode (nothing else does anything until you leave demo mode)

     S - toggle sphere
     W - toggle warp through tangent function
     R - toggle randomization
     P - toggle points
     G - toggle grid boundaries
     V - toggle voronoi cell boundaries
     C - toggle color scheme (random or by cube face)
     T - toggle voronoi cell texture

     N,M - change number of points 

   Much of the code below could be simplified/optimized. 

*/

/* Number of points per edge of the cube face (we will have 6*N^2 points) */
float N = 8.0;

/* Bunch o' settings */
float fade_in = 1.0;
float warp_fraction = 1.0;
float randomize_amount = 1.0;
float sphere_fraction = 1.0;
float enable_color = 1.0;
float enable_voronoi_edges = 1.0;
float enable_grid_lines = 1.0;
float enable_points = 1.0;
float color_scheme = 1.0;
float enable_texture = 0.0;

/* Bunch o' other globals. */
const float farval = 1e5;
const vec3 tgt = vec3(0);
const vec3 cpos = vec3(0,0,2.8);
const int rayiter = 60;
const float dmax = 20.0;
vec3 L = normalize(vec3(-0.7, 1.0, -1.0));
mat3 Rview;

const float dot_size = 0.02;
const float dot_step = 0.005;

/* Magic angle that equalizes projected area of squares on sphere. */
#define MAGIC_ANGLE 0.86867505 // radians

float warp_theta = MAGIC_ANGLE;
float tan_warp_theta;


/* Return a permutation matrix whose first two columns are u and v basis 
   vectors for a cube face, and whose third column indicates which axis 
   (x,y,z) is maximal. */
mat3 getPT(in vec3 p) {

    vec3 a = abs(p);
    float c = max(max(a.x, a.y), a.z);    

    vec3 s = c == a.x ? vec3(1.,0,0) : c == a.y ? vec3(0,1.,0) : vec3(0,0,1.);

    s *= sign(dot(p, s));
    vec3 q = s.yzx;
    return mat3(cross(q,s), q, s);

}

/* Warp to go cube -> sphere */
vec2 warp(vec2 x) {
    return tan(warp_theta*x)/tan_warp_theta;
}

/* Unwarp to go sphere -> cube */
vec2 unwarp(vec2 x) {
    return atan(x*tan_warp_theta)/warp_theta; 
}

/* Return squared great circle distance of two points projected onto sphere. */
float sphereDist2(vec3 a, vec3 b) {
	// Fast-ish approximation for acos(dot(normalize(a), normalize(b)))^2
    return 2.0-2.0*dot(normalize(a),normalize(b));
}


/* Just used for visualization to make sure dots are round regardless of 
   whether we are visualizing them on cube or sphere. */
float sphereOrCubeDist(vec3 a, vec3 b) {
    return mix(length(a-b), sqrt(sphereDist2(a,b)), sphere_fraction);    
}


/* Just used to visualize distance from spherical Voronoi cell edges. */
float bisectorDistance(vec3 p, vec3 a, vec3 b) {
    vec3 n1 = cross(a,b);
    vec3 n2 = normalize(cross(n1, 0.5*(normalize(a)+normalize(b))));
    return abs(dot(p, n2));             
}


/* RGB from hue. */
vec3 hue(float h) {
    vec3 c = mod(h*6.0 + vec3(2, 0, 4), 6.0);
    return h >= 1.0 ? vec3(h-1.0) : clamp(min(c, -c+4.0), 0.0, 1.0);
}


/* Get index (0-5) for axis. */
float axisToIdx(vec3 axis) {
    
    float idx = dot(abs(axis), vec3(0.0, 2.0, 4.0));
    if (dot(axis, vec3(1.0)) < 0.0) { idx += 1.0; }
    
    return idx;
    
}

/* From https://www.shadertoy.com/view/4djSRW */

#define HASHSCALE3 vec3(.1031, .1030, .0973)

vec3 hash33(vec3 p3) {
	p3 = fract(p3 * HASHSCALE3);
    p3 += dot(p3, p3.yxz+19.19);
    return fract((p3.xxy + p3.yxx)*p3.zyx);

}

bool wrapCube(in mat3 PT, 
              inout vec2 uvn,
              out mat3 PTn) {
    
    // new uv location might have gone off edge of cube face
    // ...see if it has by comparing to clamped version
    vec2 uvn_clamp = clamp(uvn, -1.0, 1.0);
    vec2 extra = abs(uvn_clamp - uvn);

    // it doesn't make sense to go over both corners so only allow
    // overflow/underflow in u or v but not both
    if (min(extra.x, extra.y) > 0.0) {
        
        return false;
        
    } else {            

        // check if we have gone off starting face
        float esum = extra.x + extra.y;

        if (esum > 0.0) {
            // need to re-establish what face we are on
            vec3 p = PT * vec3(uvn_clamp, 1.0 - esum);
            PTn = getPT(p);
            uvn = (p * PTn).xy;
        } else {
            // same as starting face
            PTn = PT;
        }

        return true;
        
    }
    
}


/* Color the sphere/cube points. */
vec3 gcolor(vec3 pos) {

    // get permutation matrix 
    mat3 PT = getPT(pos);
    
    // project to cube face
    vec3 cf = pos * PT; 
    
    // UV is in [-1, 1] range
    vec2 uv = cf.xy / cf.z; 
    
    // unwarp from sphere -> cube (approximtion of atan)
    uv = unwarp(uv);      
    
    // for viz only
    pos /= (dot(pos, PT[2]));
    
    // quantize uv of nearest cell
    vec2 uv_ctr = (floor(0.5*N*uv + 0.5) + 0.5)*2.0/N;
    
    // for drawing grid lines below
    vec2 l = abs(mod(uv + 1.0/N, 2.0/N) - 1.0/N)*0.5*N;

    // store distance, material & point for 1st, 2nd closest
    float d1 = 1e4, d2 = 1e4;
    float m1 = -1.0, m2 = -1.0;
    vec3 p1 = vec3(0), p2 = vec3(0);

    // for neighbors in 4x4 neighborhood
    for (int du=-2; du<=1; ++du) {
        for (int dv=-2; dv<=1; ++dv) {
            
            mat3 PTn;
            
            // any time you see 2.0/N it maps from [-1, 1] to [0, N]
            vec2 uvn = uv_ctr + vec2(float(du), float(dv))*2.0/N;
            
            if (wrapCube(PT, uvn, PTn)) {

                // now generate a unique id for the cell
                vec2 ssn = floor((uvn*0.5 + 0.5)*N);
                float faceid = axisToIdx(PTn[2]);
                vec3 id = vec3(ssn, faceid);
                
                // generate 3 random #'s from id
                vec3 r = hash33(id);
                
                // randomize dot position within cell
                uvn += (r.xy-0.5)*2.0*randomize_amount/N;

                // random material
                float mn = mix((faceid+0.5 + 0.5*r.z - 0.25)/6.0, r.z, color_scheme);
                
                // warp cube -> sphere
                uvn = warp(uvn);

                // can save 1 multiplication over general matrix mult.
                // because we know last coord is 1
                vec3 pn = PTn[0]*uvn.x + PTn[1]*uvn.y + PTn[2];

                // update distances if closer
                float dn = sphereDist2(pn, pos);
 
                if (dn < d1) {
                    d2 = d1; p2 = p1; m2 = m1;
                    d1 = dn; p1 = pn; m1 = mn;
                } else if (dn < d2) {
                    d2 = dn; p2 = pn; m2 = mn;
                }

            }
            
        }
            
    }

    // get distance to voronoi boundary
    float b = bisectorDistance(pos, p2, p1);
    
    // rainbow stained glass texture business
    m1 = fract(m1 + enable_texture*(0.5*sqrt(N))*(sqrt(d2)-sqrt(d1)));
    
    // cell background color
    vec3 bg = mix(hue(m1), hue(m2), 0.5*smoothstep(0.003, 0.0, b));
    
    // gray vs rgb
    vec3 c = mix(vec3(0.9), bg, enable_color);

    // grid lines
    float s = mix(0.02, 0.015, sphere_fraction);
    c = mix(c, vec3(0.7), smoothstep(2.0*s, s, min(l.x, l.y))*enable_grid_lines);

    // voronoi lines    
    c = mix(c, vec3(0.0), smoothstep(0.01, 0.00, b)*enable_voronoi_edges);

    // draw points
    c = mix(c, vec3(0.0), smoothstep(dot_step, 0.0, sphereOrCubeDist(pos, p1)-dot_size)*enable_points);

    return vec3(c);
    
    
}


/* Rotate about x-axis */
mat3 rotX(in float t) {
    float cx = cos(t), sx = sin(t);
    return mat3(1., 0, 0, 
                0, cx, sx,
                0, -sx, cx);
}


/* Rotate about y-axis */
mat3 rotY(in float t) {
    float cy = cos(t), sy = sin(t);
    return mat3(cy, 0, -sy,
                0, 1., 0,
                sy, 0, cy);

}


/* Adapted from http://iquilezles.org/www/articles/distfunctions/distfunctions.htm */
float sdCube(vec3 p, float r) {    
    vec3 d = abs(p) - r;
    return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d,0.0));    
}



/* Distance function to scene is a single cube/sphere. */
vec2 map(in vec3 pos) {	

    float d = mix(sdCube(pos,0.5773), length(pos)-1.0, sphere_fraction);    
    vec2 rval = vec2(d, 3.0);

    return rval;

}


/* IQ's normal calculation. */
vec3 calcNormal( in vec3 pos ) {
    vec3 eps = vec3( 0.001, 0.0, 0.0 );
    vec3 nor = vec3(
        map(pos+eps.xyy).x - map(pos-eps.xyy).x,
        map(pos+eps.yxy).x - map(pos-eps.yxy).x,
        map(pos+eps.yyx).x - map(pos-eps.yyx).x );
    return normalize(nor);
}


/* IQ's distance marcher. */
vec2 castRay( in vec3 ro, in vec3 rd, in float maxd ) {

    const float precis = 0.002;   
    float h=2.0*precis;

    float t = 0.0;
    float m = -1.0;

    for( int i=0; i<rayiter; i++ )
    {
        if( abs(h)<precis||t>maxd ) continue;//break;
        t += h;
        vec2 res = map( ro+rd*t );
        h = res.x;
        m = res.y;        
    }    

    if (t > maxd) {
        m = -1.0;
    }

    return vec2(t, m);

}



/* Pretty basic shading function. */
vec3 shade( in vec3 ro, in vec3 rd ){

    vec2 tm = castRay(ro, rd, dmax);        

    vec3 c;


    if (tm.y < 0.0) {

        c = vec3(1.0);

    } else {        

        vec3 pos = ro + tm.x*rd;
        vec3 n = calcNormal(pos);
        
        pos -= n * map(pos).x;

        vec3 color = gcolor(pos);

        vec3 diffamb = (0.5*clamp(dot(n,L), 0.0, 1.0)+0.5) * color;
        vec3 R = 2.0*n*dot(n,L)-L;
        float spec = 0.3*pow(clamp(-dot(R, rd), 0.0, 1.0), 20.0);
        c = diffamb + spec;

    }

    return c;

}


/* Bunch of ASCII keycodes */
const float KEY_C = 67.5/256.0;
const float KEY_D = 68.5/256.0;
const float KEY_G = 71.5/256.0;
const float KEY_M = 77.5/256.0;
const float KEY_N = 78.5/256.0;
const float KEY_R = 82.5/256.0;
const float KEY_S = 83.5/256.0;
const float KEY_T = 84.5/256.0;
const float KEY_P = 80.5/256.0;
const float KEY_W = 87.5/256.0;
const float KEY_V = 86.5/256.0;

/* Compare key state to default state. */
float keyState(float key, float default_state) {
    return abs( texture(iChannel0, vec2(key, 0.75)).x - default_state );
}


/* Adapted from https://github.com/danro/jquery-easing/blob/master/jquery.easing.js */
float easeOutBounce(float t, float d) {
    if ((t/=d) < (1./2.75)) {
        return (7.5625*t*t);
    } else if (t < (2./2.75)) {
        return (7.5625*(t-=(1.5/2.75))*t + .75);
    } else if (t < (2.5/2.75)) {
        return (7.5625*(t-=(2.25/2.75))*t + .9375);
    } else {
        return (7.5625*(t-=(2.625/2.75))*t + .984375);
    }
}


/* Easing function. */
float bounce_in(float lo, float hi, float u) {
    return u < lo ? 0.0 : u > hi ? 1.0 :  1.0 - easeOutBounce(hi-u, hi-lo);
}


/* Easing function. */
float bounce_out(float lo, float hi, float u) {
    return u < lo ? 0.0 : u > hi ? 1.0 : easeOutBounce(u-lo, hi-lo);
}


/* ...finally! */
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
    

    vec2 uv = (fragCoord.xy - .5*iResolution.xy) * 0.8 / (iResolution.y);

    vec3 rz = normalize(tgt - cpos),
        rx = normalize(cross(rz,vec3(0,1.,0))),
        ry = cross(rx,rz);

    float t;
    
    /* Do settings depending on whether demo mode. */
    if (keyState(KEY_D, 1.0) == 1.0) {

        float k = iTime;
        t = mod(k, 32.0);
        N = pow(2.0, mod(floor(k/32.0), 2.0)+3.0);

        fade_in = smoothstep(0.0, 4.0, t) * smoothstep(32.0, 30.0, t);
        enable_grid_lines = smoothstep(4.0, 6.0, t) * smoothstep(18.0, 16.0, t);
        enable_points = smoothstep(4.0, 6.0, t) * smoothstep(22.0, 20.0, t);    
        warp_fraction = bounce_out(6.0, 8.0, t);
        randomize_amount = bounce_in(8.0, 10.0, t);        
        sphere_fraction = bounce_out(12.0, 14.0, t);
        enable_color = smoothstep(16.0, 18.0, t);
        enable_voronoi_edges = smoothstep(20.0, 22.0, t);
        enable_texture = smoothstep(24.0, 26.0, t);

    } else {

        t = iTime;

        N = pow(2.0, 2.0+keyState(KEY_N, 1.0)+2.0*keyState(KEY_M, 0.0));

        enable_grid_lines = keyState(KEY_G, 0.0);
        enable_points = keyState(KEY_P, 0.0);
        warp_fraction = keyState(KEY_W, 1.0);        
        randomize_amount = keyState(KEY_R, 1.0);
        sphere_fraction = keyState(KEY_S, 1.0);
        enable_color = 1.0;
        color_scheme = keyState(KEY_C, 1.0);
        enable_voronoi_edges = keyState(KEY_V, 1.0);
        enable_texture = keyState(KEY_T, 0.0);

    }
     
    // For demonstration, warp_theta varies, but it should just be MAGIC_ANGLE for "production" code.
    warp_theta = max(warp_fraction*MAGIC_ANGLE, 0.001);
    tan_warp_theta = tan(warp_theta);

  
    /* Handle mouse motion for rotation. */
    float thetay = (t-7.0) * 0.1;
    float thetax = (t-7.0) * 0.05;        

    if (max(iMouse.x, iMouse.y) > 20.0) { 
        thetax = (iMouse.y - .5*iResolution.y) * 5.0/iResolution.y; 
        thetay = (iMouse.x - .5*iResolution.x) * -10.0/iResolution.x; 
    }

    Rview = mat3(rx,ry,rz)*rotX(thetax)*rotY(thetay);        
    L = Rview*L;

   	/* Render. */
    vec3 rd = Rview*normalize(vec3(uv, 1.)),
        ro = tgt + Rview*vec3(0,0,-length(cpos-tgt));

    fragColor.xyz = mix(vec3(1.0), shade(ro, rd), fade_in);


}

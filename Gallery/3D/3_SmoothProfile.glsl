// variant of https://shadertoy.com/view/4sKfD3
// smooth op from http://iquilezles.org/www/articles/smin/smin.htm

#define K 4.
#define exp(x) exp(min(30.,x))
#define smin(a,b) -log( exp( -K*(a) ) + exp( -K*(b) ) ) / K
#define smax(a,b) -(smin(-(a),-(b))) 

void mainImage(out vec4 O, vec2 U) {
    
    float t = iTime * 0.1, z, r, h=6.;                 // r: radius h: height/2.
    mat2  R = mat2( sin(t+vec4(0,33,11,0)) );
    vec3  q = iResolution,
          D = normalize(vec3(.3*(U+U-q.xy)/q.y, -1)),// ray direction
          p = 30./q, a;                          // marching point along ray

    O-=O;
    for ( O++; O.x > 0. && t > .01 ; O-=.015 ) {
        q = p,
        q.xz *= R, q.yz *= R,                    // rotation
        q.x = mod(q.x+3.,6.)-3.,                 // repeat in x
        z = q.z; 
        r = 1. - ( q.y > 0. ? z : sin(3.*z) ) / 15.; // radius
        q.y = abs(q.y)-5.;                       // 2 rows
        q.z = mod(q.z,3.) - 1.5,                 // vertical blocks
            
        a = abs(q), 
        t = smax(a.x,a.y) -r,             // smooth square column radius decreasing with z
        t = smax(t,a.z-1.5);                     // sblocks top
        t = max(t,abs(z) -h),                    // inter range of Z

        p += t*D;                                // step forward = dist to obj
    }
}

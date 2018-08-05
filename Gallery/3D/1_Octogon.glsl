// https://www.shadertoy.com/view/4sKfD3
void mainImage(out vec4 O, vec2 U) {
    
    float t = iTime * 0.1, r=1., h=6.;                 // r: radius h: height/2.
    mat2  R = mat2( sin(t+vec4(0,33,11,0)) );
    vec3  q = iResolution,
          D = normalize(vec3(.3*(U+U-q.xy)/q.y, -1)),// ray direction
          p = 30./q, a;                          // marching point along ray 
    O-=O;
    for ( O++; O.x > 0. && t > .01 ; O-=.015 )
        q = p,
        q.xz *= R, q.yz *= R,                    // rotation
        q.x = mod(q.x+3.,6.) -3.,                // repeat in x
        q.y = abs(q.y)-5.,                       // 2 rows
            
        a = abs(q), 
        t = max(a.x,a.y) -r,                     // square column
      //t = max(t,max(a.x+a.y,a.x-a.y)/1.41-1.), // inter rot45(square column)
        t = max(t,(a.x+a.y)/1.41 -r),            // simplifies due to abs() symmetry
        t = max(t,a.z -h),                       // inter range of Z

        p += t*D;                                // step forward = dist to obj
}

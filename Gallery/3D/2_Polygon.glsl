// 
// variant of https://shadertoy.com/view/4sKfD3 ( columns )
// and https://www.shadertoy.com/view/lsGczd    ( polygons )

void mainImage(out vec4 O, vec2 U) {
    
    float t = iTime * 0.1, i, v=0.;
    mat2  R = mat2( sin(t+vec4(0,33,11,0)) );
    vec3  q = iResolution,
          D = normalize(vec3(.3*(U+U-q.xy)/q.y, -1)),// ray direction
          p = 30./q;                             // marching point along ray 
    O-=O;
    for ( O++; O.x > 0. && t > .01 ; O-=.015 ) {
        q = p,
        q.xz *= R, q.yz *= R,                    // rotation
        i = (q.x+3.)/6.;                         // floor = column number
        q.x = mod(q.x+3.,6.)-3.,                 // repeat in x
        q.y = abs(q.y)-5.;                       // 2 rows
        
        float r = 2., h = 2.,                    // radius, height/2
              N = 3. + floor(abs(i)),            // number poly sides
              a = atan(q.x,q.y), l = length(q.xy),
              b = 3.14159/N;
        a = mod(a,2.*b)-b;
      //l *= cos(a) / cos(b),                    // 2D polygonal distance
        l *= cos(a),                             // 2D polygonal distance
        r *= cos(b),                             // r = vertices, not faces
        t = max( l-r, abs(q.z) -h );             // inter Z-range
        if (i<0.) t = max(t, -(l-r*.75));        // hole
        if (iMouse.z>0.) t = min(v=t, q.z+h);    // debug: plot SDF on a floor
        
        p += t*D;                                // step forward = dist to obj
    }
    if (v>0.) O.r = sin(6.28*2.*v);
}

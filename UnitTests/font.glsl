 // --- access to the image of ascii code c
vec4 Char(vec2 p, int C) {
    if (p.x<0.|| p.x>1. || p.y<0.|| p.y>1.) return vec4(0,0,0,1e5);
  //return texture   ( iChannel0, p/16. + fract( vec2(C, 15-C/16) / 16. ) );
  //return textureLod( iChannel0, p/16. + fract( vec2(C, 15-C/16) / 16. ) , 
  //                   log2(length(fwidth(p/16.*iResolution.xy))) );
    return textureGrad( iChannel0, p/16. + fract( vec2(C, 15-C/16) / 16. ) , 
                       dFdx(p/16.),dFdy(p/16.) );
    // possible variants: (but better separated in an upper function) 
    //     - inout pos and include pos.x -= .5 + linefeed mechanism
    //     - flag for bold and italic 
}

// --- display int4
vec4 pInt(vec2 p, float n) {
    vec4 v = vec4(0);
    if (n < 0.) 
        v += Char(p - vec2(-.5,0), 45 ),
        n = -n;

    for (float i = 3.; i>=0.; i--) 
        n /= 10.,
        v += Char(p - vec2(.5*i,0), 48+ int(fract(n)*10.) );
    return v;
}

void mainImage( out vec4 O,  vec2 U )
{
    U /= iResolution.y;
    float t = 3.*iTime;

    O = Char(U,int(t));     // try .xxxx for mask, .wwww for distance field.
 // return;                 // uncomment to just see the letter count.
    
    vec4 O2 = Char(U,int(++t));
    O = mix(O,O2,fract(t));             // linear morphing 
 // O = sqrt(mix(O*O,O2*O2,fract(t)));  // quadratic morphing
    
    
    O =  smoothstep(.5,.49,O.wwww)
       * O.yzww;                        // comment for B&W

  
  U *= 8.; O+=pInt(U,t).xxxx;           // ascii code
  U.x -=9.; 
  O += Char(U,64+13   ).x; U.x-=.5;     // text
  O += Char(U,64+15+32).x; U.x-=.5;
  O += Char(U,64+18+32).x; U.x-=.5;
  O += Char(U,64+16+32).x; U.x-=.5;
  O += Char(U,64+ 8+32).x; U.x-=.5;
  O += Char(U,64+ 9+32).x; U.x-=.5;
  O += Char(U,64+14+32).x; U.x-=.5;
  O += Char(U,64+ 7+32).x; U.x-=.5;
}
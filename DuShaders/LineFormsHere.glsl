// MsjcRd
// Created by randy read - rcread/2015
// remixed by starea/2017 @ shadertoy: https://www.shadertoy.com/view/MsjcRd
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// float char(vec2 p, int C) {
//     if (p.x < 0. || p.x > 1. || p.y < 0.|| p.y > 1.) return 0.;
//     return textureGrad(iChannel0, p/16. + fract(vec2(C, 15-C/16) / 16.), dFdx(p/16.),dFdy(p/16.) ).r;
// }

void mainImage(out vec4 f, vec2 u) {
    // vec4 fontColor = vec4(0.5); 
    // vec2 p = u.xy / iResolution.y; 
    // float fontSize = 10.0;
    // f = mix(f, fontColor, char((p * 10.0) - vec2(0., 1.), 65));
    // f = mix(f, fontColor, char((p * 10.0) - vec2(.5, 1.), 79));
    // f = mix(f, fontColor, char((p * 10.0) - vec2(1., 1.), 86));
    // f = mix(f, fontColor, char((p * 10.0) - vec2(1.5, 1.), 69));
    
    u *= 3./iResolution.y; 
    for (float i=-5.; i<=4.; i+=.09)
        f += (i*i+i+1.)/6e2/abs(i*(u.y-u.x-i)-u.x+2.) ;  
} 

// void mainImage2( out vec4 c, vec2 p ) {	
//     c -= c;
// 	for ( float i = 0.; i < 3. ; i += .1 ) 
//         p -= iResolution.y / 8., c += .4 / abs( i * p.x - p.y );
// }
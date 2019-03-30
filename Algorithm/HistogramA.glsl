// https://www.shadertoy.com/view/https://www.shadertoy.com/view/4dd3Wj
float R = 256.;  // sort array RxR

float xor(float x, float c) { 
    float y=0., s=1.;
    
    for (int i=0; i<8; i++) 
       y += s* mod ( floor(x/s)+floor(c/s), 2. ), s*=2. ; 
    
    return y;
}

float id(vec2 U) {
    return floor(U.x) + 256.*floor(U.y);
}

void mainImage( out vec4 O,  vec2 U )
{   
    if (iResolution.y < R) R /= 2.; // for icon resolution

    float t = float(iFrame);
    if (mod(t,512.)==10. ) { O = texture(iChannel1, U/R).rrrr; return; }
    if (mod(t,512.)==266.) { O = texture(iChannel2, U/R); return; }
    
    
    O =  texture(iChannel0, U/iResolution.xy);
    
    if ( max(U.x,U.y) < R )   // sort array RxR
    { 
        vec2 S = vec2(xor(U.x,mod(t*1.73+103.7,R)),                     // dual location
                      xor(U.y,mod(t*11.4+51.8 ,R)) ) +.5;
        vec4 OS = texture(iChannel0, S/iResolution.xy);               // its pixel value
    	if (sign( (length(OS)-length(O))*(id(S)-id(U))) < 0.) O = OS;   // swap if bad ordered
    }
}

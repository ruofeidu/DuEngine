// 4dGGz1
// application of https://www.shadertoy.com/view/4s3GDs

// set you module and phase in Buf A

#define SIZE (iResolution.x/2.-30.) //Size must be changed in each tab.

//Display modes.     Tuned by pressing SPACE after clicking left or right window
#define MAGNITUDE 0.
#define PHASE     1.
#define COMPONENT 2.
#define REAL      3.
#define IMAG      4.

//Scaling
#define LOG 0
#define LINEAR 1

#define MAG_SCALE LINEAR

bool keyToggle(int ascii) { return (texture(iChannel1,vec2((.5+float(ascii))/256.,0.75)).x > 0.);}

vec4 rainbow(float x)  { return .5 + .5 * cos(6.2832*(x - vec4(0,1,2,0)/3.)); }
vec4 rainbow(vec2 C)   { return rainbow(atan(C.y,C.x)/3.1416 + .5); }

vec4 paintDFT(vec2 F, float mode) {
    // F /= SIZE;
    return 
         mode == MAGNITUDE 
     #if   MAG_SCALE == LOG
                           ?  vec4(log(length(F)))
     #elif MAG_SCALE == LINEAR
                           ?  vec4(length(F))
     #endif
       : mode == PHASE     ?  rainbow(F)        
       : mode == COMPONENT ?  .5+.5*vec4(F, 0,0)
       : mode == REAL      ?  .5+.5*vec4(F.x)
       : mode == IMAG      ?  .5+.5*vec4(F.y)
       : vec4(-1); // error
}


void mainImage( out vec4 O,  vec2 uv )
{    
    vec2 R = iResolution.xy;
    
    vec2 pixel = ( uv - R/2.) / SIZE  + vec2(2,1)/2.,
         tile  = floor(pixel),
         stile = floor(mod(2.*pixel,2.));    
	     uv = fract(pixel) * SIZE / R;
    O-=O;

    vec2 DISPLAY_MODE = floor(texture(iChannel3, .5/R).zw); // persistant key flag.
    if (tile.y==-1. && abs(tile.x-.5)<1.) {   // buttons displaying current flags value
        for (float i=0.; i<5.; i++) 
            O += smoothstep(.005,.0,abs(length(uv*R/SIZE-vec2(.2+i/7.,.97))-.025));
        float v = tile.x==0. ? DISPLAY_MODE[0] : DISPLAY_MODE[1];
        O.b += smoothstep(.03,.02,length(uv*R/SIZE-vec2(.2+v/7.,.97)));
    }
    
    if (keyToggle(64+6)) // 'F' 
        O += paintDFT(texture(iChannel2, fract(uv)).xy, DISPLAY_MODE[1]); // tiled display
    else {  
        if(tile == vec2(0,0))  // Input spectrum (Left)
            O += paintDFT(texture(iChannel3, uv).xy, DISPLAY_MODE[0]);

        if(tile == vec2(1,0))  // Output DFT (Right)
            O += paintDFT(texture(iChannel2, uv).xy, DISPLAY_MODE[1]);
        }
}
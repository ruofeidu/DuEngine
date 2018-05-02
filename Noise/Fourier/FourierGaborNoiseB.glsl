// 4dGGz1
// invFourier transform 

// Horizontal + Vertical Discrete Fourier Transform of the input 
// 2 passes pipelined : in -> buf.zw -> buf.xy -> out
// ( adapted from  Flyguy's https://www.shadertoy.com/view/MscGWS# )


#define SIZE (iResolution.x/2.-30.) //Size must be changed in each tab.

//#define tex(ch,x,y) texture(ch, vec2(x,y)/iResolution.xy )
#define tex(ch,x,y)  texelFetch(ch, ivec2(x,y), 0)

vec2 cmul (vec2 a,float b) { return mat2(a,-a.y,a.x)*vec2(cos(b), sin(b)); } // complex a*exp(i.b)
#define W(uv)   mod(uv+SIZE/2.,SIZE)                    // wrap [-1/2,1/2] to [0,1]


void mainImage( out vec4 O, vec2 U )
{
    O-=O; 
    
    if(U.x > SIZE || U.y > SIZE) return;

    for(float n = 0.; n < 1000.; n++)  {
        if (n>=SIZE) break;
        float m = W(n);       // W to warp 0,0 to mid-window.
        vec2 xn = tex(iChannel0, m+.5, U.y).xy,
             yn = tex(iChannel1, U.x, m+.5).zw,
             a =  6.2831853 *  W(U-.5) * n/SIZE;
        
        O.zw += cmul(xn, a.x);
        O.xy += cmul(yn, a.y);
    }
    
    O.zw /= SIZE;
}
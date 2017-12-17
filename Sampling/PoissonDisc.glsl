// https://www.shadertoy.com/view/MslfDf
// Generate Poisson-disc distribution by simulated repulsive springs between particles.
// see spectrum (and tilable version) in https://www.shadertoy.com/view/MssfDf

#define zoom 10.

#define P(i,j)  ( floor(U/zoom)+vec2(i,j)+ texelFetch(iChannel0, ivec2(U/zoom)+ivec2(i,j), 0).xy ) 

//#define N 30
//#define P(i,j)  ( vec2(i,j) + texelFetch(iChannel0, ivec2(i,j), 0).xy )  // for 0..N loops


/**/
void mainImage( out vec4 O, vec2 U )
{   
    O -= O; 
 
    for (int j=-3; j<=3; j++)
        for (int i=-3; i<=3; i++) 
            O += smoothstep(2.,0., length( P(i,j) *zoom - U ) );
}
/**/




/**  // Voronoi version

void mainImage( out vec4 O, vec2 U )
{   
    float v, l = 1e9,_l;
    
    for (int j=-3; j<=3; j++)
        for (int i=-3; i<=3; i++) {
            v = length( P(i,j) *zoom - U );
            if (v<l) _l=l, l=v;
        }
    
    O = .1* vec4(_l-l);  
    //O = .1*vec4(l,0,_l-l,0);
}
/**/

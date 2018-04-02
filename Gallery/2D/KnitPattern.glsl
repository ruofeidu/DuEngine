// https://www.shadertoy.com/view/MsKyWD
#define D(z) ;                                  /* draw 3/4 disk */ \
    l = length( V = 1. - mod( U = -U , 2.) );                       \
    l<.88 && ( V.x<0.||V.y>0. ) && z+1. > a                         \
        ? c = ++a + sin(28.3*l) : l ;

#define mainImage(O,u)                                              \
    vec2 U = 10.*u/iResolution.y, V;                                \
    float l, c=0., a=c                          /* col, opacity  */ \
          D()                                   /* binary blend  */ \
    U.x++ D()                                                       \
    U.y++ D(V.y)                                /* Z-buffer      */ \
    U.x-- D()                                                       \
    O += ++c -a                                 /* 1.-a = centers*/
        
        

        
        
/** // 226 chars
              // draw 3/4 disk
#define D(z)                                    \
    l = length( V = mod( U = -U , 2.) -1. );    \
    l<.87 && ( V.x<0.||V.y>0.) && z+1. > a      \
        ? O += 1.+sin(28.3*l)-O, a = 1. : l

void mainImage( out vec4 O, vec2 U ) {
    U *= -10./iResolution.y; vec2 V; float l,a=0.;
    O-=O;  D();           // binary blend
    U.x++; D();
    U.y++; D(V.y);        // Z-buffer
    U.x--; D();
    O += 1.-a;
}

/**/




/** // 242 chars

#define B   1. > O.w ? O = vec4(l,l,l,1) : O                  // blend (binary)
#define D   l = 4.5* length( V = mod( U = -U , 2.) -1. );     \
            if (l<3.9 &&( V.x<0.||V.y>0.))  l= 1.+sin(6.3*l), // draw 3/4 disk

void mainImage( out vec4 O, vec2 U )
{
    U *= -10./iResolution.y; vec2 V; float l;
    O-=O;  D B;
    U.x++; D B;
    U.y++; D V.y+B;                                           // Z-buffer
    U.x--; D B;
    l++;     B;
}

/**/




/** // 272 chars

#define Z   O = ++V.y > O.w ? vec4(l,l,l,1) : O               // Z-buffer
#define B   O += (1.-O.w) *   vec4(l,l,l,1)                   // blend                           

#define D   l = 4.5* length( V = mod( U = -U , 2.) -1. );     \
            if (l<3.9 &&( V.x<0.||V.y>0.))  l= 1.+sin(6.3*l), // draw 3/4 disk

void mainImage( out vec4 O, vec2 U )
{
    U *= -10./iResolution.y; vec2 V; float l;
           D B;
    U.x++; D B;
    U.y++; D Z;
    U.x--; D B;
    l++;   B;
}

/**/




/**

// Z=0 : blend(alpha)  Z=1: Z-buffer(w)
#define B(Z,v)  Z>0 ? O = 1.+V.y>O.w ? vec4(v,v,v,1.) : O            \
                        : O += (1.-O.w) *  vec4(v,v,v,1)
                            
#define D(Z) { vec2 V = fract(U=-U)*2.-1.; float l = 4.5*length(V);  \
                  if (l<3.9 &&( V.x<0.||V.y>0.)) B(Z,1.+sin(6.3*l)); }

void mainImage( out vec4 O, vec2 U )
{
    U *= -5./iResolution.y;
               D(0);
    U.x += .5; D(0);
    U.y += .5; D(1);
    U.x -= .5; D(0);
    O += 1.-O.w;
}

/**/
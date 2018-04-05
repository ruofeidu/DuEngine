// 
// reduction by Coyote: 262
                                                 // draw segment [a,b]
#define L  *I ; o+= 3e-3 / length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1.) *v - u+a )
#define P  ; b=c= vec2(r.x,1)/(4.+r.y) L;   b=a L;   a=c L;   a=c; r= I*r.yx;

void mainImage(out vec4 o, vec2 v)
{
	vec2 I=vec2(1,-1), a,b,c=iResolution.xy, 
         u = (v+v-c)/c.y,
         r = sin(iDate.w-.8*I); r += I*r.yx  // .8-.8*I = vec2(0,1.6)
    P  o-=o        // just to initialize a
	P P P P        // 4*3 segments

}
/**/



/*// reduction by Nrx: 264
                                                 // draw segment [a,b]
#define L  *I ; o+= 3e-3 / length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1.) *v - u+a ) ;
#define P  ; b=c= vec2(r.x,1)/(4.+r.y) L   b=a L   a=c L   a=c; r= I*r.yx;

void mainImage(out vec4 o, vec2 v)
{
	vec2 I=vec2(1,-1), a,b,c=iResolution.xy, 
         u = (v+v-c)/c.y,
         r = sin(iDate.w-.8*I); r += I*r.yx  // .8-.8*I = vec2(0,1.6)
    P  o-=o        // just to initialize a
	P P P P        // 4*3 segments

}
/**/




/* // reduction by FabriceNeyret2: 270 -1 by Nrx
                                                 // draw segment [a,b]
#define L ; o+= 3e-3 / length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1.) *v - u+a ) ;
#define P   b=c= vec2(r.x,1)/(4.+r.y) L   b=a*I L   a=c*I L   a=c; r= I*r.yx;

void mainImage(out vec4 o, vec2 U)
{
	vec2 I=vec2(1,-1), a,b,c=iResolution.xy, 
         u = (U+U-c)/c.y,
         v = sin(iDate.w-.8*I), r = v + I*v.yx;  // .8-.8*I = vec2(0,1.6)
    P  o-=o       // just to initialize a
	P P P P        // 4*3 segments

}
/**/



/* // reduction by FabriceNeyret2: 285
                                                 // draw segment [a,b]
#define L ; o+= 3e-3 / length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1.) *v - u+a ) ;
#define P   b=c= vec2(l,1)/(4.+m) L   b=a*I L   a=c*I L   a=c; e=l; l=m; m=-e;

void mainImage(out vec4 o, vec2 u)
{
	vec2 v, I=vec2(1,-1), a,b,c=iResolution.xy;
	u = (u+u-c)/c.y;   
	float m=iDate.w, l=sin(m), e; m=cos(m)-l; l+=m+l;
    P  o-=o;       // just to initialize a
	P P P P        // 4*3 segments

}
/**/


/* // reduction by FabriceNeyret2: 303
                                                 // draw segment [a,b]
#define L ; o+=3e-3/length(clamp(dot(u-a,v=b-a)/dot(v,v),0.,1.)*v-u+a);
#define P(A,B) b=c=vec2(A,1)/(4.+B) L b=a*I L a=c*I L a=c;

void mainImage(out vec4 o, in vec2 u)
{
	vec2 v, I=vec2(1,-1), a,b,c;
	u = 2.*u/iResolution.y - 1.4-.4*I;   // - vec2(1.8,1)
	float m=iDate.w, l=sin(m); m=cos(m)-l; l+=m+l;
    P( l, m ) o-=o;  // just to initialize a
	P( m,-l )        // --- draw 4*3 segments
	P(-l,-m )
	P(-m, l )
	P( l, m )
}
/**/



/* // reduction by Nrx: 318
                                                 // draw segment [a,b]
#define L o+=3e-3/length(clamp(dot(u-a,v=b-a)/dot(v,v),0.,1.)*v-u+a);
#define P(A,B) b=c=vec2(A,1)/(4.+B); L b=a*I; L a=c*I; L a=c;

void mainImage(out vec4 o, in vec2 u)
{
	o-=o;
	u = 2.*u/iResolution.y - vec2(1.8,1); 
	float m=iDate.w, l=sin(m); m=cos(m)-l; l+=m+l;
	vec2 v, I=vec2(1,-1), a=vec2(l,1)/(4.+m), b,c;
	P( m,-l)   
	P(-l,-m)
	P(-m, l)
	P( l, m)
}
/**/



/* // reduction by Nrx: 347
                                                 // draw segment [a,b]
// #define L(a,b) (l=dot(w=u-a,v=b-a))>0.&&l<(m=dot(v,v))      ? o += 3e-5/(dot(w,w)-l*l/m) :o;
// #define L(a,b)  l=dot(w=u-a,v=b-a); m=l*l/dot(v,v);   l > m ? o += 3e-5/(dot(w,w)-m)     :o;
// #define L(a,b) o+=3e-5/dot(v=clamp(dot(u-a,v=b-a)/dot(v,v),0.,1.)*v-u+a,v);
   #define L(a,b)  o+=3e-3/length( clamp( dot(u-a,v=b-a)/dot(v,v), 0.,1. ) *v - u+a );

#define Z(x,y)  vec2( x,1 ) / ( 4.+y )           // perspective transform
#define P(A,B)  L(A,B)  L(A*I,B*I)  L(A,A*I)     // draw 1 top segment + 1 bottom + 1 vertical

void mainImage( out vec4 o, in vec2 u )
{
    o-=o;
    u = 2.*u/iResolution.y - vec2(1.8,1); 
    
    float m=iDate.w, l=sin(m); m=cos(m)-l; l+=m+l;
    vec2  v, I=vec2(1,-1), 
          a=Z(l,m), b=Z(m,-l), c=Z(-l,-m), d=Z(-m,l); // 4 top vertices screen coords

          P(a,b) P(b,c) P(c,d) P(d,a)                 // draw 4*3 segments
}
/**/



/*
// reduction by FabriceNeyret2 : 366
                                                 // draw segment [a,b]
#define L(a,b)  l=dot(w=u-a,v=b-a)/(m=length(v)), l>.0&&l<m ? o += 3e-5/(dot(w,w)-l*l)   :o;

#define Z(x,y)  vec2( x,1 ) / ( 4.+y )           // perspective transform
#define P(A,B)  L(A,B)  L(A*I,B*I)  L(A,A*I)     // draw 1 top segment + 1 bottom + 1 vertical

void mainImage( out vec4 o, in vec2 u )
{
    o-=o;
    u = 2.*u/iResolution.y - vec2(1.8,1); 
    
    float t=iDate.w, l,m, 
          S=-sin(t),C=cos(t),P=C+S,M=C-S;
    vec2  v,w, I=vec2(1,-1),
          a = Z(M,P), b = Z(P,-M), c = Z(-M,-P), d = Z(-P,M); // 4 top vertices screen coords

          P(a,b) P(b,c) P(c,d) P(d,a)                         // draw 4*3 segments
}
/**/



/*
// reduction by FabriceNeyret2 : 382

#define L(a,b) l=dot(w=u-a,v=b-a)/(m=length(v)), l>.0&&l<m ? o += 3e-5/(dot(w,w)-l*l) :o;
#define Z(A) vec2( (A).x,1 ) / ( 4.+(A).y )
#define P(A,B)  L(A,B)  L(A*I,B*I)  L(A,A*I)

void mainImage( out vec4 o, in vec2 u )
{
    o-=o;
    u = 2.*u/iResolution.y -vec2(1.8,1); 
    
    float t=iDate.w, S=-sin(t),C=cos(t),l,m;
    vec2 i=vec2(C,S),k=vec2(-S,C), v,w, I=vec2(1,-1),
         a =  Z(i+k), b =  Z(i-k), c = Z(-i-k), d = Z(k-i);

    P(a,b) P(b,c) P(c,d) P(d,a)
}
/**/



/*
// reduction by FabriceNeyret2 : 408

#define L(a,r,b,s) l=dot(w=u-vec2(a,r),v=vec2(b-a,s-r))/(m=length(v)), l>.0&&l<m ? o += 3e-5/(dot(w,w)-l*l) :o;

#define P(A,B) r=1./(4.+A.y);  s=1./(4.+B.y); L(A.x*r,r,B.x*s,s) L(A.x*r,-r,B.x*s,-s) L(A.x*r,r,A.x*r,-r)

void mainImage( out vec4 o, in vec2 u )
{
    o-=o;
    u = 2.*u/iResolution.y -vec2(1.8,1); 
    
    float t=iDate.w, S=-sin(t),C=cos(t),l,m,r,s;
    vec2 i=vec2(C,S),k=vec2(-S,C), v,w,
         a =  i+k, b =  i-k, c = -i-k, d = -i+k;

    P(a,b) P(b,c) P(c,d) P(d,a)
}
/**/



/*
// reduction by Nrx: 419

#define L(u,a,b) (l=dot(w=u-a,v=b-a))>0.&&l<(m=dot(v,v))?o+=3e-5/(dot(w,w)-l*l/m):o;
#define P(A,B) L(u,A.xy/(4.+A.z),B.xy/(4.+B.z));

void mainImage( out vec4 o, in vec2 u )
{
    o-=o;
    u = 2.*u/iResolution.y -vec2(1.8,1); 

	float t=iDate.w, S=sin(t), C=cos(t), l, m;
	vec2 v,w;
	vec3 i=vec3(C,0,-S),j=vec3(0,1,0),k=vec3(S,0,C),
         a=i+j+k, b=i+j-k, c=i-j-k, d=i-j+k;

    P(a,b) P(b,c) P(c,d) P(d,a)
    P(-c,-d) P(-d,-a) P(-a,-b) P(-b,-c)
    P(a,-c) P(b,-d) P(c,-a) P(d,-b)
}
/**/




/*
// original by FabriceNeyret2 449

#define L(u,a,b) l=dot(w=u-a,v=b-a)/(m=length(v)), l>.0&&l<m ? o += 3e-3/sqrt(dot(w,w)-l*l) :o;

#define P(A,B) L(u,A.xy/(4.+A.z),B.xy/(4.+B.z));

void mainImage( out vec4 o, in vec2 u )
{
    o-=o;
    u = 2.*u/iResolution.y -vec2(1.8,1); 
    
    float t=iDate.w, S=-sin(t),C=cos(t),l,m;
    vec2 v,w;
    //mat3 M = mat3(C,0,S,0,1,0,-S,0,C);
    //vec3 a = vec3( 1, 1, 1)*M, b = vec3( 1, 1, -1)*M,
    //     c = vec3( 1,-1,-1)*M, d = vec3( 1,-1,  1)*M,
    //     e = vec3(-1, 1, 1)*M, f = vec3(-1, 1, -1)*M,
    //     g = vec3(-1,-1,-1)*M, h = vec3(-1,-1,  1)*M;
    vec3 i=vec3(C,0,S),j=vec3(0,1,0),k=vec3(-S,0,C),
         a =  i+j+k, b =  i+j-k, c =  i-j-k, d =  i-j+k,
         e = -i+j+k, f = -i+j-k, g = -i-j-k, h = -i-j+k;

    P(a,b) P(b,c) P(c,d) P(d,a)
    P(e,f) P(f,g) P(g,h) P(h,e)
    P(a,e) P(b,f) P(c,g) P(d,h)
}
/**/
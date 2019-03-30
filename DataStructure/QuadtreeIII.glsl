// https://www.shadertoy.com/view/lljSDy
// By Dr. Fabrice Neyret
void mainImage( out vec4 o,  vec2 U )
{
    o -= o;
    float r=.1, t=iTime, H = iResolution.y;
    U /=  H;                              // object : disc(P,r)
    vec2 P = .5+.5*vec2(cos(t),sin(t*.7)), fU;  
    U*=.5; P*=.5;                         // unzoom for the whole domain falls within [0,1]^n
    
    o.b = .25;                            // backgroud = cold blue
    
    for (int i=0; i<7; i++) {             // to the infinity, and beyond ! :-)
        fU = min(U,1.-U); if (min(fU.x,fU.y) < 3.*r/H) { o--; break; } // cell border
    	if (length(P-.5) - r > .7) break; // cell is out of the shape

                // --- iterate to child cell
        fU = step(.5,U);                  // select child
        U = 2.*U - fU;                    // go to new local frame
        P = 2.*P - fU;  r *= 2.;
        
        o += .13;                         // getting closer, getting hotter
    }
               
	o.gb *= smoothstep(.9,1.,length(P-U)/r); // draw object
}













/* // for the record: a 282 chars version

void mainImage( out vec4 o, vec2 U )
{
    float r=.1, t=iDate.w, H = iResolution.y;
    U *=  .5/H;  
    vec2 P = .25+.25*vec2(cos(t),sin(t*.7)), f;  
     
    o -= o; o.b = .25;  
    
    for (int i=0; i<7; i++) { 
        f = min(U,1.-U); if (min(f.x,f.y) < 3.*r/H)  o--; 
    	if (length(P-.5) - r < .7)
        	f = step(.5,U), 
        	U += U - f,          
        	P += P - f,  r += r,       
        	o += .13;    
    }
               
	o.gb *= step(r,length(P-U));  
}

/**/

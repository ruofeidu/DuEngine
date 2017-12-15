// https://www.shadertoy.com/view/MdKGRw
// only line 0, pixels 0 to 33 of bufA are used
// if you need the full buffer but the .a components, you might adapt this util to use only .a 

#define FAKE_MOUSE 1 // fake mouse motion if no user input
#define Sradius .02  // influence radius for sliders
#define Bradius .04  // influence radius for buttons

#define HORIZ   1.
#define VERTIC -1.


#define UI(x) texture(iChannel0,(vec2(x,0)+.5)/R)

#define add_slider(x,y,d,l,v0) { nbS++; if (U==vec2(nbS,0.))    O = vec4(x,y,(l)*(d),v0); }
#define add_button(x,y,v0)     { nbB++; if (U==vec2(nbB+16,0.)) O = vec4(x,y,0,v0);       }


void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy;
    O = texture(iChannel0,U/R);
    U -= .5;
    
    if (iFrame==0) {
        int nbS = 0, nbB = 0;
        
        add_slider (.15,.05,HORIZ, .5,.3); // --- define your sliders here ---
        add_slider (.15,.10,HORIZ, .5,.6); // read value [0,1] in UI(i).a  , i=1..16
        add_slider (.05,.15,VERTIC,.5,.0);
        add_slider (.10,.15,VERTIC,.5,.9);
        
        add_button ( .9,.2,  1.);          // --- define your buttons here ---
        add_button ( .9,.1, -1.);          // read value {-1,1} in UI(i+16).a , i=1..16
        add_button ( 1.,.2,  1.);          
        add_button ( 1.,.1, -1.);          
        
        if (U==vec2(0,0)) O.xy = vec2(nbS, nbB);
        return;
    }
    
    if (U==vec2(33,0)) {  // previous mouse state (for BufA) our mouse state (other shaders)
        vec4 m = iMouse;
#if FAKE_MOUSE
        if (length(m.xy)<10. && m.z<=0.) { // fake mouse motion if no user input
	        float t = iTime;         // you can reset this state by putting the mouse back in the corner
	        m.xy = (.5+.4*vec2(cos(t),sin(t)))*R;
	    }   
#endif
        O = m;
        return; 
    }              
    if (U==vec2(34,0)) { O = UI(33); return; } // previous mouse state (for other shaders)
    
    if (iMouse.z>0. && U.y==0.) {          // --- let mouse trigers the right slider or button
       	vec2 M = iMouse.xy/iResolution.y;
        if (U.x <= UI(0).x) {
	        vec4 S = UI(U.x);
    	    float l = abs(S.z);
        	vec2 m = iMouse.xy/iResolution.y;
	        if (S.z>0. && abs(M.y-S.y)<Sradius && abs(M.x-S.x-l/2.)<l/2. ) O.a = (M.x-S.x)/l;
    	    if (S.z<0. && abs(M.x-S.x)<Sradius && abs(M.y-S.y-l/2.)<l/2. ) O.a = (M.y-S.y)/l;
    	}
        else if (UI(33).z<0. &&  U.x>16. && U.x<=16.+UI(0).y ) {
	        vec4 S = UI(U.x);
            if (length(M-S.xy)<Bradius) O.a *= -1.;
        }
    }
        
}
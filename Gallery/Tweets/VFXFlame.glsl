// 4djfDR
/*[SH17A]VFX Flame,by 834144373
   Licence: https://creativecommons.org/licenses/by-nc-sa/3.0/
	https://www.shadertoy.com/view/4djfDR
*/

//this trick inspir from theGiallo's Tiniest Shadertoy Trick www.shadertoy.com/view/Xd2BWh  
#define mainImage(C,U) C.xy=U/iResolution.xy*8.-4.,C=pow(vec4(1.9,1.4,1,1)*smoothstep(1.,0.,.3+length(C.y+1.+vec2(0,pow(abs(C.x),2.4)*1e2+.1*sin(iTime*3e4)))*.23),vec4(1,1.1,.8,1))

/*
void mainImage( out vec4 C, vec2 U )
{
   	U = U/iResolution.xy*8.-4.;
	
    //U.x = smoothstep(1.,0.,.3+length(U.y+1.+vec2(0.,pow(abs(U.x),2.4)*1e2+.1*sin(iTime*3e4)))*.23);
    C = pow(
        //Shane's method with the similar color effect
        vec4(1.9, 1.4, 1, 1)*smoothstep(1.,0.,.3+length(U.y+1.+vec2(0.,pow(abs(U.x),2.4)*1e2+.1*sin(iTime*3e4)))*.23),
            vec4(1, 1.1, .8, 1)
    );
    
	//--C = U.xxxx;
    //--C.g /= 2.4;
    //--C += pow(U.x,1.1);
    //--C.b = pow(U.x,.8);
	//Non-Visual Effects for -4 chars
    //C.b = U.x*1.1;
	
}
*/

//------------189 chars Now!!! :-b
/*
void mainImage( out vec4 C, vec2 U )
{
    U = U/iResolution.xy*8.-4.;
    U.x = smoothstep(
        1.,
        0.,
        .3+length(U.y+1.+vec2(0.,U.x*U.x*5e1+.1*sin(iTime*3e6)))*.23
    );
    
    //Shane's method with the same color effect :-😁
    C = pow(vec4(1.9, 1.4, 1, 1)*U.x, vec4(1, 1.1, .8, 1));
    /*
    C = U.xxxx;
    C.g /= 2.4;
    C += pow(U.x,1.1);
    C.b = pow(U.x,.8);
	//Non-Visual Effects for -4 chars
    //C.b = U.x*1.1;
	/**/
//}


/* History version 206 chars

void mainImage( out vec4 C, vec2 U )
{
    C -= C;
    U = U/iResolution.xy*8.-4.;
    U.y += 1.;
	C.rg += smoothstep(
        1.,
        0.,
        .3+length(U.y+vec2(0.,U.x*U.x*5e1+.2*fract(sin(iTime*3e6))))*.23
    );
	C.g /=2.4;

    C += pow(C.rrrr,vec4(1.1,1.1,.8,.0));
    //Describe
    //--C.rg += pow(a,1.1);
	//for VFX
    //--C.b += pow(a,0.8);
	//Non-Visual Effects
    //	C.b += a*1.1;
}
*/

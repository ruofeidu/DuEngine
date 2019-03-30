// https://www.shadertoy.com/view/https://www.shadertoy.com/view/XsjyDW
void mainImage(out vec4 Out,in vec2 In){ 
    
    Out=vec4(0);vec4 t=vec4(0);
    t=texture(iChannel1,In/iResolution.xy, -100.0);//bufB=3d
    Out.xyzw+=1.*t;
    
    t=texture(iChannel2,In/iResolution.xy, -100.0);//bufC=text
    Out.xyz+=1.*t.w*t.xyz*t.xyz;
    
    //Out+= .2*texture(iChannel3,In/iResolution.xy, -100.0);//bufD=2d
        
////post processing:
    Out*=Out;//f(Out)=Out*Out; simple way to increase contrast.
}

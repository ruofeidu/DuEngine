// ldG3Ww
float random()
{
	return fract(sin(dot(gl_FragCoord.xy, vec2(12.9898,78.233))) * 43758.5453);  
}
float randomTime()
{
	return fract(sin(dot(gl_FragCoord.xy*iTime, vec2(12.9898,78.233))) * 43758.5453);  
}

vec4 get_pixel(float x_offset, float y_offset)
{
	return texture(iChannel0, (gl_FragCoord.xy / iResolution.xy) + (vec2(x_offset, y_offset) / iResolution.xy));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // r and g for xvelocity and yvelocity
    float xvel = get_pixel(0.0, 0.0).r;
    float yvel = get_pixel(0.0, 0.0).g;
    // b for pressure
    float press = 0.0;
    // a for vorticity (spin) +=clockwise -=counterclockwise
    float spin = 0.0;
    
    //// advection:
    press += get_pixel(-xvel,-yvel).b;
    spin += get_pixel(-xvel,-yvel).a;
    //\\ end advection
    
    ////// vorticity:
    float vortAmount = 0.04;
    //vortAmount = 0.008*(6.5-press);
    xvel += (get_pixel(0.0,-1.0).a)*vortAmount;
    xvel -= (get_pixel(0.0,1.0).a)*vortAmount;
    yvel += (get_pixel(-1.0,0.0).a)*vortAmount;
    yvel -= (get_pixel(1.0,0.0).a)*vortAmount;
    
    
    float spinAmount = 1.6;
    spin += get_pixel(0.0,-1.0).r*spinAmount;
    spin -= get_pixel(0.0,1.0).r*spinAmount;
	spin += get_pixel(-1.0,0.0).g*spinAmount;
    spin -= get_pixel(1.0,0.0).g*spinAmount;
    
    
    //\\\\ end vorticity
    
	
    
    //// pressure:
    float pressureAmount = -0.06+0.004*press;
    xvel -= (get_pixel(-1.5,0.0).b-press)*pressureAmount;
    xvel += (get_pixel(1.5,0.0).b-press)*pressureAmount;
    yvel -= (get_pixel(0.0,-1.5).b-press)*pressureAmount;
    yvel += (get_pixel(0.0,1.5).b-press)*pressureAmount;
    //\\ end pressure
    
    //// random:
    
    if(iTime<0.01){
        xvel += 0.3*(randomTime());
        yvel += 0.3*(randomTime());
    }
    press *= 0.98+(0.01*random())*clamp(press,0.0,3.0);
    //\\ end random
    
    if (iMouse.z > 0.0){
        press += 0.3*smoothstep(1.0,0.0,length(fragCoord.xy-iMouse.xy)*0.016);
    } else {
    	press += 0.3*smoothstep(1.0,0.0,length(fragCoord.xy-(iResolution.xy*0.5+150.0*vec2(sin(iTime),cos(iTime))))*0.016);
    	press += 0.3*smoothstep(1.0,0.0,length(fragCoord.xy-(iResolution.xy*0.5+150.0*vec2(sin(iTime+3.141),cos(iTime+3.141))))*0.016);
    }
        
    fragColor.r = xvel*0.97;
    fragColor.g = yvel*0.97;
    fragColor.b = press*0.983;
    fragColor.a = spin*0.906;
}
float density=.9;
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 o=vec2(1.)/500.;
    fragCoord/=iResolution.xy;

    // Load the fluid buffer states. There are two, stored in R and G. Only R is changed per pass,
    // and the two channels are swapped using a swizzle mask.
    fragColor.rg=texture(iChannel0,fragCoord).gr;

    fragColor.r = (texture(iChannel0,fragCoord+o*vec2( 0.,+1.)).r+
        		texture(iChannel0,fragCoord+o*vec2( 0,-1)).r+
                texture(iChannel0,fragCoord+o*vec2(-1, 0)).r+
                texture(iChannel0,fragCoord+o*vec2(+1, 0)).r+
                texture(iChannel0,fragCoord+o*vec2(-1,-1)).r+
                texture(iChannel0,fragCoord+o*vec2(+1,-1)).r+
                texture(iChannel0,fragCoord+o*vec2(-1,+1)).r+
                texture(iChannel0,fragCoord+o*vec2(+1,+1)).r+
                texture(iChannel0,fragCoord+o*vec2( 0, 0)).r)*2./9.-
        		texture(iChannel0,fragCoord+o*vec2( 0, 0)).g;
            
   
    // Add the interaction with the inner box.
    float ba=iTime;
    mat3 boxxfrm=mat3(cos(ba),sin(ba),0,-sin(ba),cos(ba),0,0,0,1)*
        		mat3(cos(ba),0,sin(ba),-sin(ba),0,cos(ba),0,1,0)*4.;
    vec3 bp=vec3(fragCoord.x*2.-1.,.1,fragCoord.y*2.-1.);
    vec3 bp2=boxxfrm*bp;
    float bd=length(max(vec3(0.),abs(bp2)-vec3(1.)));
    
    if(bd<1e-3)
   		fragColor.r+=.03;

    // Add some random drips.
    float p=.01;
    float c=floor(mod(iTime,64.)/p);
    fragColor.r += (1.-smoothstep(0.,.01,distance(fragCoord,1.5*vec2(cos(c*11.),sin(c*7.1)))))*.8;    
    
    fragColor.r *= density;
}
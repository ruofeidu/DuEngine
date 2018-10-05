// https://www.shadertoy.com/view/XtVcWc
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float tx = texture(iChannel0, fragCoord.xy/iResolution.xy).x;
    float rz = max(iMouse.z, tx);
    
    if (iFrame < 20)
        rz = 0.;
    fragColor = vec4(rz,0.0,1.0,1.0);
}

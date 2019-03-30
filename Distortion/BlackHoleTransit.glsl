// 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord.xy/iResolution.xy;
    
    uv *= 4.;
    uv.x *= iResolution.x/iResolution.y;
    
    vec2 bh = vec2(-3.+mod(iTime,12.),2.);
    float distToHole = distance(uv,bh);
    vec2 awayVec = normalize(uv - bh);
    
    uv -= awayVec/distToHole*.6;
    vec3 space = texture(iChannel0,uv*.2).rgb*clamp(0.,1.,pow(3.*distToHole,2.)/8.);
    uv -= 1.;
    
    space = space*space*space;
    vec3 col = space * 2.;
    
    // Output to screen
    fragColor = vec4(col,1.0);
}

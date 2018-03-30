// https://www.shadertoy.com/view/4sVyzR
bool space() {
    return texture(iChannel3, vec2(32.5/256.0, 0.5) ).x > 0.5;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    vec4 init = texture(iChannel2,uv);
    vec3 result;
    if(init == vec4(0.0)|| space()){
        result = fastSurfaceBlur(iChannel0,iChannel1,fragCoord/iResolution.xy,vec2(1.0/iResolution.x,0.0)).rgb;
    }
    else{
        result = fastSurfaceBlur(iChannel2,iChannel1,fragCoord/iResolution.xy,vec2(1.0/iResolution.x,0.0)).rgb;
    } 
    fragColor = vec4(result.rgb,1.0);
}

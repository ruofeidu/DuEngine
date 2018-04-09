// 
void mainImage( out vec4 o, in vec2 fc ) {
    vec2 uv = fc/iResolution.xy;
   
    float a = texture(iChannel0, vec2(0.5, iTime * 0.001)).r;
    // 2D rotation of "a" radians
    float nx = uv.x * cos(a) - uv.y * sin(a);
    float ny = uv.x * sin(a) + uv.y * cos(a);

    vec3 col = texture(iChannel0, vec2(nx, iTime * 0.01 + ny * 0.01)).rgb;

    o = vec4(col.bgr,1.0);
}
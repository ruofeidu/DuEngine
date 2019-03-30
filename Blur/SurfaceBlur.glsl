// https://www.shadertoy.com/view/4sVyzR
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
    fragColor = texture(iChannel0,uv);
}

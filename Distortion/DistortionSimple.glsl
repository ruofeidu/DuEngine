#define DISTORTION_AMOUNT 0.01

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    float X = uv.x * 6. + iTime;
    float Y = uv.y * 6. + iTime;
    uv.x += cos(X + Y) * DISTORTION_AMOUNT * cos(Y);
    uv.y += sin(X + Y) * DISTORTION_AMOUNT * sin(Y);
    fragColor = texture(iChannel0,uv);
}
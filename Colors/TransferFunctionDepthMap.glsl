// llVBDD
float grayScale(in vec3 col)
{
    return dot(col, vec3(0.2126, 0.7152, 0.0722));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    float x = grayScale(texture(iChannel0, uv).rgb);
    float xr = x >= 0.5 ? max(5.0 / 255.0, 2.0 - 2.0 * x) : 1.0;
    float xg = (x < 0.5) ? (0.5 - x) * 2.0 : 0.0;
    fragColor = vec4(xr, xg, 0.0, 1.0);

}

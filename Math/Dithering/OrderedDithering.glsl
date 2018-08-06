// https://www.shadertoy.com/view/Xl3yRl
mat4x4 M = mat4x4(
    0., 8., 2., 10.,
    12., 4., 14., 6.,
    3., 11., 1., 9.,
    15., 7., 13., 5.
    );
float R = 0.25;

float PixelSize = 2.;

void ditheting(inout float v, vec2 coords)
{
    v += R * (M[int(coords.x) % 4][int(coords.y) % 4] / 16.0 - .5);
    v = (step(.25, v) + step(.5, v) + step(.75, v)) / 3.;
    //v = step(.5, v);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	fragCoord -= mod(fragCoord, PixelSize) - vec2(PixelSize, PixelSize) * .5;
    vec2 uv = fragCoord/iResolution.xy;
    
    vec3 col = texture(iChannel0, uv).rgb;
    col *= 1.;
    
    float v = col.r * .299 + col.g * .587 + col.b * .114;
	
    
    ditheting(v, fragCoord);
    ditheting(col.r, fragCoord);
    ditheting(col.g, fragCoord);
    ditheting(col.b, fragCoord);
    
    fragColor = vec4(col, 1.0);
}
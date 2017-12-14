// https://www.shadertoy.com/view/XdKGDW
void mainImage(out vec4 fragColor,in vec2 fragCoord)
{
  fragColor = texture(iChannel0,fragCoord.xy/iResolution.xy);
}

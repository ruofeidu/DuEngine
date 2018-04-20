// https://www.shadertoy.com/view/MsXcWr
const float BLUR = 0.008;
const vec3  GAMMA = vec3(1./2.2);

vec4 gamma(in vec4 i) { return vec4(pow(i.xyz, GAMMA), i.w); }
vec4 img(vec2 d) { return textureLod(iChannel0, d/iResolution.xy, 0.); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec4 col = img(fragCoord);
  vec3 b = vec3(1,-1,0) * col.w * BLUR * iResolution.x;
  fragColor = gamma((col + img(fragCoord+b.xx) 
                         + img(fragCoord+b.xy)
                         + img(fragCoord+b.yx)
                         + img(fragCoord+b.yy))/5.);
}

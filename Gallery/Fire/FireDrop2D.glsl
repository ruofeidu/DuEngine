// https://www.shadertoy.com/view/tdGXWm
// V-Drop - Del 19/11/2019 - this is more the effect I wanted.
#define PI 3.14159
#define TAU 6.28318

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = (fragCoord.xy - 0.5 * iResolution.xy) / iResolution.y;

  if (iMouse.z > 0.5)
    uv.y = 1.0 - uv.y; // V-flip

  vec3 col = vec3(1.55, 0.65, .225); // Drop Colour
  uv.x = uv.x * 64.0;                // H-Count
  float dx = fract(uv.x);
  uv.x = floor(uv.x);
  float t = iTime * 0.4;
  uv.y *= 0.15;                         // stretch
  float o = sin(uv.x * 215.4);          // offset
  float s = cos(uv.x * 33.1) * .3 + .7; // speed
  float trail = mix(95.0, 35.0, s);     // trail length
  float yv = fract(uv.y + t * s + o) * trail;
  yv = 1.0 / yv;
  yv = smoothstep(0.0, 1.0, yv * yv);
  yv = sin(yv * PI) * (s * 5.0);
  float d2 = sin(dx * PI);
  yv *= d2 * d2;
  col = col * yv;
  fragColor = vec4(col, 1.0);
}

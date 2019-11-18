// The MIT License
// Copyright © 2017 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions: The above copyright
// notice and this permission notice shall be included in all copies or
// substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS",
// WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
// TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
// FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR
// THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Computes the analytic derivatives of a 2D Gradient Noise

// Value    Noise 2D, Derivatives: https://www.shadertoy.com/view/4dXBRH
// Gradient Noise 2D, Derivatives: https://www.shadertoy.com/view/XdXBRH
// Value    Noise 3D, Derivatives: https://www.shadertoy.com/view/XsXfRH
// Gradient Noise 3D, Derivatives: https://www.shadertoy.com/view/4dffRH
// Value    Noise 2D             : https://www.shadertoy.com/view/lsf3WH
// Value    Noise 3D             : https://www.shadertoy.com/view/4sfGzS
// Gradient Noise 2D             : https://www.shadertoy.com/view/XdXGW8
// Gradient Noise 3D             : https://www.shadertoy.com/view/Xsl3Dl
// Simplex  Noise 2D             : https://www.shadertoy.com/view/Msf3WH

vec2 hash(in vec2 x) // replace this by something better
{
  const vec2 k = vec2(0.3183099, 0.3678794);
  x = x * k + k.yx;
  return -1.0 + 2.0 * fract(16.0 * k * fract(x.x * x.y * (x.x + x.y)));
}

// return gradient noise (in x) and its derivatives (in yz)
vec3 noised(in vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);

#if 1
  // quintic interpolation
  vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
  vec2 du = 30.0 * f * f * (f * (f - 2.0) + 1.0);
#else
  // cubic interpolation
  vec2 u = f * f * (3.0 - 2.0 * f);
  vec2 du = 6.0 * f * (1.0 - f);
#endif

  vec2 ga = hash(i + vec2(0.0, 0.0));
  vec2 gb = hash(i + vec2(1.0, 0.0));
  vec2 gc = hash(i + vec2(0.0, 1.0));
  vec2 gd = hash(i + vec2(1.0, 1.0));

  float va = dot(ga, f - vec2(0.0, 0.0));
  float vb = dot(gb, f - vec2(1.0, 0.0));
  float vc = dot(gc, f - vec2(0.0, 1.0));
  float vd = dot(gd, f - vec2(1.0, 1.0));

  return vec3(va + u.x * (vb - va) + u.y * (vc - va) +
                  u.x * u.y * (va - vb - vc + vd), // value
              ga + u.x * (gb - ga) + u.y * (gc - ga) +
                  u.x * u.y * (ga - gb - gc + gd) + // derivatives
                  du * (u.yx * (va - vb - vc + vd) + vec2(vb, vc) - va));
}

// -----------------------------------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 p = (-iResolution.xy + 2.0 * fragCoord) / iResolution.y;

  vec3 n = noised(8.0 * p);

  vec3 col = 0.5 + 0.5 * ((p.x > 0.0) ? n.yzx : n.xxx);

  fragColor = vec4(col, 1.0);
}

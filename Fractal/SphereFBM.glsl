// https://www.shadertoy.com/view/Ws3XWl
// The MIT License
// Copyright © 2019 Inigo Quilez
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

// Offseting an SDF with FBM produces beautiful results, but breaks
// the metric of the field, resulting often in having to slow down
// the marcher by decresing the step size.
//
// Instead of using noise as basis for the FBM, this shader operates
// by using a smooth but random distance fields as basis for the FBM.
// The field is computer in each cell by placing a sphere of random
// size in each corner and computing the smooth minimum.
//
// The FBM combines multiple copies of this random field with incresing
// frequencies and decreasing size as usual. Since the smooth field is
// a distance bound and the FBM combines the fields with a bounded blend
// operation, the resulting FBM is a bound SDF too, and doesn't need the
// reduction in step size during marching. It also plays nicely with
// shadows and occlusion techniques that are based on distances.

// 0 = lattice
// 1 = simplex
#define NOISE 0

float hash(vec3 p) // replace this by something better
{
  p = 17.0 * fract(p * 0.3183099 + vec3(.11, .17, .13));
  return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return min(max(d.x, max(d.y, d.z)), 0.0) + length(max(d, 0.0));
}

// http://iquilezles.org/www/articles/smin/smin.htm
float smin(float a, float b, float k) {
  float h = max(k - abs(a - b), 0.0);
  return min(a, b) - h * h * 0.25 / k;
}

// http://iquilezles.org/www/articles/smin/smin.htm
float smax(float a, float b, float k) {
  float h = max(k - abs(a - b), 0.0);
  return max(a, b) + h * h * 0.25 / k;
}

// http://iquilezles.org/www/articles/boxfunctions/boxfunctions.htm
vec2 iBox(in vec3 ro, in vec3 rd, in vec3 rad) {
  vec3 m = 1.0 / rd;
  vec3 n = m * ro;
  vec3 k = abs(m) * rad;
  vec3 t1 = -n - k;
  vec3 t2 = -n + k;
  float tN = max(max(t1.x, t1.y), t1.z);
  float tF = min(min(t2.x, t2.y), t2.z);
  if (tN > tF || tF < 0.0)
    return vec2(-1.0);
  return vec2(tN, tF);
}

//---------------------------------------------------------------
//
// A smooth but random SDF. For each cell, it places a sphere of
// random size in each corner and computer the smooth minimum.
//
//---------------------------------------------------------------

float noiseSDF(in vec3 p) {
#if NOISE == 0
  vec3 i = floor(p);
  vec3 f = fract(p);

  const float G1 = 0.30;
  const float G2 = 0.75;

#define RAD(r) ((r) * (r)*G2)
#define SPH(i, f, c) length(f - c) - RAD(hash(i + c))

  return smin(
      smin(smin(SPH(i, f, vec3(0, 0, 0)), SPH(i, f, vec3(0, 0, 1)), G1),
           smin(SPH(i, f, vec3(0, 1, 0)), SPH(i, f, vec3(0, 1, 1)), G1), G1),
      smin(smin(SPH(i, f, vec3(1, 0, 0)), SPH(i, f, vec3(1, 0, 1)), G1),
           smin(SPH(i, f, vec3(1, 1, 0)), SPH(i, f, vec3(1, 1, 1)), G1), G1),
      G1);
#else
  const float K1 = 0.333333333;
  const float K2 = 0.166666667;

  vec3 i = floor(p + (p.x + p.y + p.z) * K1);
  vec3 d0 = p - (i - (i.x + i.y + i.z) * K2);

  vec3 e = step(d0.yzx, d0);
  vec3 i1 = e * (1.0 - e.zxy);
  vec3 i2 = 1.0 - e.zxy * (1.0 - e);

  vec3 d1 = d0 - (i1 - 1.0 * K2);
  vec3 d2 = d0 - (i2 - 2.0 * K2);
  vec3 d3 = d0 - (1.0 - 3.0 * K2);

  float r0 = hash(i + 0.0);
  float r1 = hash(i + i1);
  float r2 = hash(i + i2);
  float r3 = hash(i + 1.0);

  const float G1 = 0.20;
  const float G2 = 0.50;

#define SPH(d, r) length(d) - r *r *G2

  return smin(smin(SPH(d0, r0), SPH(d1, r1), G1),
              smin(SPH(d2, r2), SPH(d3, r3), G1), G1);
#endif
}

// rotation matrix
const mat3 m = mat3(0.00, 0.80, 0.60, -0.80, 0.36, -0.48, -0.60, -0.48, 0.64);

vec2 map(in vec3 p) {
  // box
  float d = sdBox(p, vec3(1.0));

  p += 0.5;

  // fbm
  float t = 0.0;
  float s = 1.0;
  for (int i = 0; i < 6; i++) {
    d = smax(d, -noiseSDF(p) * s, 0.2 * s);
    t += d;
    p = 2.01 * m * p; // next octave
    s = 0.50 * s;
  }
  t = 1.0 + t * 2.0;
  t = t * t;

  return vec2(d, t);
}

const float precis = 0.0005;

vec2 interesect(in vec3 ro, in vec3 rd) {
  vec2 res = vec2(-1.0);

  // bounding volume
  vec2 dis = iBox(ro, rd, vec3(1.0));
  if (dis.y < 0.0)
    return res;

  // raymarch
  float tmax = dis.y;
  float t = dis.x;
  for (int i = 0; i < 256; i++) {
    vec3 pos = ro + t * rd;
    vec2 h = map(pos);
    res.x = t;
    res.y = h.y;

    if (h.x < precis || t > tmax)
      break;
    t += h.x;
  }

  if (t > tmax)
    res = vec2(-1.0);
  return res;
}

// http://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 calcNormal(in vec3 pos) {
  vec2 e = vec2(1.0, -1.0) * 0.5773 * precis;
  return normalize(e.xyy * map(pos + e.xyy).x + e.yyx * map(pos + e.yyx).x +
                   e.yxy * map(pos + e.yxy).x + e.xxx * map(pos + e.xxx).x);
}

// http://iquilezles.org/www/articles/rmshadows/rmshadows.htm
float calcSoftShadow(vec3 ro, vec3 rd, float tmin, float tmax, float w) {

  // bounding volume
  vec2 dis = iBox(ro, rd, vec3(1.0));
  if (dis.y < 0.0)
    return 1.0;

  tmin = max(tmin, dis.x);
  tmax = min(tmax, dis.y);

  float t = tmin;
  float res = 1.0;
  for (int i = 0; i < 256; i++) {
    float h = map(ro + t * rd).x;
    res = min(res, h / (w * t));
    t += clamp(h, 0.005, 0.50);
    if (res < -1.0 || t > tmax)
      break;
  }
  res = max(res, -1.0); // clamp to [-1,1]

  return 0.25 * (1.0 + res) * (1.0 + res) * (2.0 - res); // smoothstep
}

// fibonazzi points in s aphsre:
// http://lgdv.cs.fau.de/uploads/publications/spherical_fibonacci_mapping_opt.pdf
vec3 forwardSF(float i, float n) {
  const float PI = 3.141592653589793238;
  const float PHI = 1.618033988749894848;
  float phi = 2.0 * PI * fract(i / PHI);
  float zi = 1.0 - (2.0 * i + 1.0) / n;
  float sinTheta = sqrt(1.0 - zi * zi);
  return vec3(cos(phi) * sinTheta, sin(phi) * sinTheta, zi);
}

#if HW_PERFORMANCE == 0
#define AA 1
#else
#define AA 2 // make this 2 or 3 for antialiasing
#endif

#define ZERO min(iFrame, 0)

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 tot = vec3(0.0);

#if AA > 1
  for (int m = ZERO; m < AA; m++)
    for (int n = ZERO; n < AA; n++) {
      // pixel coordinates
      vec2 o = vec2(float(m), float(n)) / float(AA) - 0.5;
      vec2 p = (2.0 * (fragCoord + o) - iResolution.xy) / iResolution.y;
      float d = 0.5 * sin(fragCoord.x * 147.0) * sin(fragCoord.y * 131.0);
#else
  vec2 p = (2.0 * fragCoord - iResolution.xy) / iResolution.y;
#endif

      // camera anim
      float an = -0.1 * iTime;
      vec3 ro = 4.0 * vec3(cos(an), 0.4, sin(an));
      vec3 ta = vec3(0.0, -0.35, 0.0);

      // camera matrix
      vec3 cw = normalize(ta - ro);
      vec3 cu = normalize(cross(cw, vec3(0.0, 1.0, 0.0)));
      vec3 cv = normalize(cross(cu, cw));
      vec3 rd = normalize(p.x * cu + p.y * cv + 2.7 * cw);

      // render
      vec3 col = vec3(0.01);
      vec2 tm = interesect(ro, rd);
      float t = tm.x;
      if (t > 0.0) {
        vec3 pos = ro + t * rd;
        vec3 nor = calcNormal(pos);
        float occ = tm.y * tm.y;

        // material
        vec3 mate = mix(vec3(0.6, 0.3, 0.1), vec3(1), tm.y) * 0.7;

        // lighting
        vec3 lig = normalize(vec3(1.0, 0.5, 0.6));
        float dif = clamp(dot(lig, nor), 0.0, 1.0);
        dif *= calcSoftShadow(pos + nor * 0.001, lig, 0.001, 10.0, 0.003);

        vec3 hal = normalize(lig - rd);
        float spe = clamp(dot(hal, nor), 0.0, 1.0);
        spe = pow(spe, 4.0) * dif *
              (0.04 + 0.96 * pow(max(1.0 - dot(hal, lig), 0.0), 5.0));

        col = vec3(0.0);
        col += mate * 1.5 * vec3(1.30, 0.85, 0.75) * dif;
        col += 9.0 * spe;
        col += mate * 0.3 * vec3(0.40, 0.45, 0.60) * occ * (0.6 + 0.4 * nor.y);
      }

      // gamma
      tot += pow(col, vec3(0.4545));
#if AA > 1
    }
  tot /= float(AA * AA);
#endif

  // vignetting
  vec2 q = fragCoord / iResolution.xy;
  tot *= 0.7 + 0.3 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.2);

  // cheap dithering
  tot += sin(fragCoord.x * 114.0) * sin(fragCoord.y * 211.1) / 512.0;

  fragColor = vec4(tot, 1.0);
}

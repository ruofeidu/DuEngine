// cheap Poisson-disc approximation ( almost-loopless ! )
// Better than jittered-grid (as used in Voronoi shaders)

// Variant of basic https://shadertoy.com/view/Xl3czS
// allowing higher density without grid artifacts, or larger shapes.

#define blend                                                                  \
  0 // Correct blend on collisions. Costlier; usefull only for white noise

#define hue(v)                                                                 \
  (.6 +                                                                        \
   .6 * cos(6.28 * v +                                                         \
            vec4(0, 23, 21, 0))) // https://www.shadertoy.com/view/ll2cDc

const float
    g = 8., // grid size. Trick: defines cell = trigger seed, shape = nxn cells
    r = 24.,
    k = r / g,          // shape size, in pixel & grid units.
    d = 45. / 255. / k; // shape density / k
const int n = int(k);   // n x n: neighborhood covered by shape

void mainImage(out vec4 O, vec2 U) {
  vec2 R = iResolution.xy, P, _P, V;
  O -= O;
  // O.b += mod(floor(U.x/g)+floor(U.y/g),2.);                // grid (debug)
  if (U.x - .5 == R.x / 2.)
    O.r++; // separator

  float t = 1e9, v, _t;
  if (U.x < R.x / 2.)
    for (int i = 0; i < n * n; i++) { // search neighborhood covered by shape
      V = U / g + vec2(i % n, i / n);
      v = texelFetch(iChannel0, ivec2(V), 0).x; // left: blue noise
      // if (v<t)  t=v, P=V;
      if (v < t)
        _t = t, t = v, _P = P, P = V;
      else if (v < _t)
        _t = v, _P = V; // for collisions
    }
  else
    for (int i = 0; i < n * n; i++) {
      V = U / g + vec2(i % n, i / n);
      v = texelFetch(iChannel1, ivec2(V), 0).x; // right: white noise
      // if (v<t)  t=v, P=V;
      if (v < t)
        _t = t, t = v, _P = P, P = V;
      else if (v < _t)
        _t = v, _P = V; // for collisions
    }

#define dist length(2. * fract((ceil(P) - U / g) / k) - 1.)
#define shape(v) smoothstep(1., 1. - 4. / r, v) // disc shape

  if (t < d) {
    v = dist;
#if !blend
    if (v > 1. && _t < d) // manage collisions
      t = _t, P = _P, v = dist;
#endif
    v = shape(v);
    O += v * hue(t / d);

#if blend // correct blend on collisions. Costlier; usefull only for white noise
    if (_t < d) // note that we only manage simple collisions.
      t = _t, P = _P, O += (1. - v) * shape(dist) * hue(t / d);
#endif
  }
}

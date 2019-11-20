// https://www.shadertoy.com/view/WsGSzD
float hash1(int n) {
  // integer hash copied from Hugo Elias
  n = (n << 13) ^ n;
  n = n * (n * n * 15731 + 789221) + 1376312589;
  return float(n & ivec3(0x7fffffff)) / float(0x7fffffff);
}

// cross
float tile1(vec2 uv) {
  float d = min(abs(uv.x), abs(uv.y));
  return d;
}

// two circles
float tile2(vec2 uv) {
  if (uv.y < -uv.x)
    uv.xy = -uv.xy;
  float d = abs(distance(uv, vec2(1, 1)) - 1.);
  return d;
}

// rotation of tile2
float tile3(vec2 uv) { return tile2(vec2(-uv.x, uv.y)); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  float zoom = cos(iTime * .5) * 5. + 6.;
  vec2 uv = (fragCoord * 2. - iResolution.xy) / iResolution.y * zoom;

  float e = zoom * 2. / min(iResolution.x, iResolution.y);

  vec2 tile = floor(uv);
  float id = tile.x * 10000. + tile.y;
  uv = (uv - floor(uv) - .5) * 2.;

  vec3 col = vec3(0);

  float t = hash1(int(id));
  float d = 1e20;
  if (t < 0.33) {
    d = tile1(uv);
  } else if (t < 0.67) {
    d = tile2(uv);
  } else {
    d = tile3(uv);
  }

  col = vec3(smoothstep(e * 5., e, d));

  fragColor = vec4(col, 1.0);
}

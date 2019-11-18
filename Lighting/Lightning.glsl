// https://www.shadertoy.com/view/WsGSWD
// Set this to 1 to disable the rapid flickering.
//
// Useful while working on this to avoid seizing if you
// increase the frequency or stare at it for too long.
#define ANTI_SEIZURE 0

// https://stackoverflow.com/a/4275343/1697183
float rand(vec2 co) {
  return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

// based on sdLine
float sdUnevenCapsule(in vec2 p, in vec2 a, in vec2 b, in float r1,
                      in float r2) {
  vec2 pa = p - a, ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h) - mix(r1, r2, h);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = 2.2 * (fragCoord - .5 * iResolution.xy) / iResolution.y;

  // use this  to debug in slow motion :^)
  float my_iTime = 1. * iTime;

  // how many times does it strike, on average, per second?
  float freq = .4;

  // how fast does it hit the ground?
  float speed = 8.;

  float t_base = floor(freq * my_iTime);

  // random offset within time period
  float t_off = 1. * rand(vec2(t_base, 134.)) / freq;
  my_iTime += t_off;
  t_base += t_off;

  vec2 pos = vec2(1. * (2. * rand(vec2(t_base, 995.)) - 1.),
                  1. + .2 * (2. * rand(vec2(t_base, 46.)) - 1.));
  float r = .03;
  float a = radians(270.) + radians(45.) * (2. * rand(vec2(t_base, 13.)) - 1.);

  float d = 1e10;

  float sum_len = 0.;

#if ANTI_SEIZURE
  float t = 1.;
#else
  float t = speed * (freq * my_iTime - t_base) / freq;
  if ((t > 1. && t < 1.6) || t > 2.5)
    t = 0.;
#endif

  float len_max = 8. * t;

  // Branches
  vec2 branch_1_pos;
  float branch_1_len = 0.;
  float branch_1_r = 0.;
  float branch_1_a;

  vec2 branch_2_pos;
  float branch_2_len = 0.;
  float branch_2_r = 0.;
  float branch_2_a;

  for (int i = 0; i < 12; ++i) {
    if (sum_len >= len_max)
      break;

    if (i == 3) {
      branch_1_pos = pos;
      branch_1_len = sum_len;
      branch_1_r = .5 * r;
      branch_1_a =
          radians(270.) + radians(90.) * (2. * rand(vec2(t_base, 13.)) - 1.);
    }

    if (i == 6) {
      branch_2_pos = pos;
      branch_2_len = sum_len;
      branch_2_r = .5 * r;
      branch_2_a =
          radians(270.) - radians(90.) * (2. * rand(vec2(t_base, 17.)) - 1.);
    }

    float len = .12 + .18 * rand(vec2(300. + float(i) + t_base, 1337.));
    float a_next =
        mix(a, radians(270.) +
                   radians(40.) *
                       (2. * rand(vec2(float(300 * i) + t_base, 1337.)) - 1.),
            .9);

    vec2 next = pos + len * vec2(cos(a), sin(a));
    float r_next = .9 * r;

    d = min(d, sdUnevenCapsule(uv, pos, next, r, r_next));
    pos = next;
    r = r_next;
    a = a_next;

    sum_len = sum_len + len;
  }

  for (int i = 0; i < 10; ++i) {
    if (branch_1_len >= len_max)
      break;

    float len = .07 + .07 * rand(vec2(300. + float(i) + t_base, 1337.));
    float a_next =
        mix(radians(270.),
            branch_1_a +
                radians(40.) *
                    (2. * rand(vec2(float(300 * i) + t_base, 1337.)) - 1.),
            .5);

    vec2 next = branch_1_pos + len * vec2(cos(branch_1_a), sin(branch_1_a));
    float r_next = .9 * branch_1_r;

    d = min(d, sdUnevenCapsule(uv, branch_1_pos, next, branch_1_r, r_next));

    branch_1_pos = next;
    branch_1_r = r_next;
    branch_1_a = a_next;

    branch_1_len += len;
  }

  for (int i = 0; i < 10; ++i) {
    if (branch_2_len >= len_max)
      break;

    float len = .07 + .07 * rand(vec2(300. + float(i) + t_base, 1337.));
    float a_next =
        mix(radians(270.),
            branch_2_a +
                radians(40.) *
                    (2. * rand(vec2(float(300 * i) + t_base, 1337.)) - 1.),
            .5);

    vec2 next = branch_2_pos + len * vec2(cos(branch_2_a), sin(branch_2_a));
    float r_next = .9 * branch_2_r;

    d = min(d, sdUnevenCapsule(uv, branch_2_pos, next, branch_2_r, r_next));

    branch_2_pos = next;
    branch_2_r = r_next;
    branch_2_a = a_next;

    branch_2_len += len;
  }

  vec3 sky =
      // blue
      .2 * vec3(0, 0, 1) * clamp(sum_len, 0., 1.)
      // white
      + .1 * vec3(1, 1, 1) * clamp(sum_len - .8, 0., 1.);

  fragColor = vec4(
      sky + clamp(.9 - sqrt(d + .01), 0., 1.) * sky * max(.9 * uv.y + 2., 0.) +
          vec3(smoothstep(.0, -.01, d)),
      1.);
}

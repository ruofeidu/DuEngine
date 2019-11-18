// variant of https://www.shadertoy.com/view/lttcD7

void mainImage(out vec4 O, vec2 U) {
  vec3 R = iResolution / 2.;
  vec2 S = sign(U - .5 - R.xy);
  if (S.x * S.y == 0.) {
    O = vec4(1, 0, 0, 0);
    return;
  } // separation

  if (S.y > 0.)
    U = U - R.zy; // top = blue noise
  if (S.x > 0.)
    U = (U - R.xz) / 3., R.x /= 3.; // right = zoom
  O = S.y > 0.
          ? texelFetch(iChannel0, ivec2(U) % 1024, 0) // top = blue noise
          : texelFetch(iChannel1, ivec2(U) % 256, 0); // bottom = white noise

  O = iMouse.z <= 0. ? vec4(U.x / R.x < O.x) // B & W gradient thresholding
                     : step(U.x / R.x, O);   // colored variant

  // O = vec4( length(step( U.x/R.x, O )) /2.);     // luminance
}

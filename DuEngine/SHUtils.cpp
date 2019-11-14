// DuEngine: Real-time Rendering Engine and Shader Testbed
// Ruofei Du | http://www.duruofei.com
//
// Creative Commons Attribution-ShareAlike 3.0 License with 996 ICU clause:
//
// The above license is only granted to entities that act in concordance with
// local labor laws. In addition, the following requirements must be observed:
// The licensee must not, explicitly or implicitly, request or schedule their
// employees to work more than 45 hours in any single week. The licensee must
// not, explicitly or implicitly, request or schedule their employees to be at
// work consecutively for 10 hours. For more information about this protest, see
// http://996.icu

#include "stdafx.h"
#include "SHUtils.h"
// int factorial(int x, int result = 1) {
//	if (x == 1) return result; else return factorial(x - 1, x * result);
//}

double sinc(double x) { return (abs(x) < 1.0e-4) ? 1.0 : (sin(x) / x); }

// evaluate an Associated Legendre Polynomial P(l,m,x) at x
double P(int l, int m, double x) {
  double pmm = 1.0;
  if (m > 0) {
    double somx2 = sqrt((1.0 - x) * (1.0 + x));
    double fact = 1.0;
    for (int i = 1; i <= m; i++) {
      pmm *= (-fact) * somx2;
      fact += 2.0;
    }
  }
  if (l == m) return pmm;
  double pmmp1 = x * (2.0 * m + 1.0) * pmm;
  if (l == m + 1) return pmmp1;
  double pll = 0.0;
  for (int ll = m + 2; ll <= l; ++ll) {
    pll = ((2.0 * ll - 1.0) * x * pmmp1 - (ll + m - 1.0) * pmm) / (ll - m);
    pmm = pmmp1;
    pmmp1 = pll;
  }
  return pll;
}

double K(int l, int m) {
  // renormalisation constant for SH function
  double temp =
      ((2.0 * l + 1.0) * factorial[l - m]) / (4.0 * PI * factorial[l + m]);
  return sqrt(temp);
}

// Returns a point sample of a Spherical Harmonic basis function.
// l is the band, range [0..N]
// m in the range [-l..l]
// theta in the range [0..Pi]
// phi in the range [0..2*Pi]
double SH(int l, int m, double theta, double phi) {
  const double sqrt2 = sqrt(2.0);
  if (m == 0)
    return K(l, 0) * P(l, m, cos(theta));
  else if (m > 0)
    return sqrt2 * K(l, m) * cos(m * phi) * P(l, m, cos(theta));
  else
    return sqrt2 * K(l, -m) * sin(-m * phi) * P(l, -m, cos(theta));
}

// test function
float test_function(float phi, float theta) {
  using namespace std;
  return 1.0f;
  // return max(0.0, 5.0 * cos(theta) - 4.0) + max(0.0, -4.0 * sin(theta - PI) *
  // cos(phi - 2.5) - 3.0);
}

template <class T>
T clamp(T x, T a, T b) {
  if (x < a) return a;
  if (x > b) return b;
  return x;
}

template <class T>
T smoothstep(T edge0, T edge1, T x) {
  // Scale, and clamp x to 0..1 range
  x = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
  // Evaluate polynomial
  return x * x * x * (x * (x * 6 - 15) + 10);
}

Vec3d heatMap(double greyValue) {
  Vec3d heat;
  heat[2] = smoothstep(0.5, 0.8, greyValue);
  if (greyValue >= 0.90) {
    heat[2] *= (1.1 - greyValue) * 5.0;
  }
  if (greyValue > 0.7) {
    heat[1] = smoothstep(1.0, 0.7, greyValue);
  } else {
    heat[1] = smoothstep(0.0, 0.7, greyValue);
  }
  heat[0] = smoothstep(1.0, 0.0, greyValue);
  if (greyValue <= 0.3) {
    heat[0] *= greyValue / 0.3;
  }
  return heat;
}

Vec3b mix(Vec3d a, Vec3d b, double alpha) {
  double gamma = 2.2;
  double x =
      pow(pow(a[0] * alpha, gamma) + pow(b[0] * (1 - alpha), 2.2), 1.0 / gamma);
  double y =
      pow(pow(a[1] * alpha, gamma) + pow(b[1] * (1 - alpha), 2.2), 1.0 / gamma);
  double z =
      pow(pow(a[2] * alpha, gamma) + pow(b[2] * (1 - alpha), 2.2), 1.0 / gamma);
  return Vec3b((uchar)(x * 255), (uchar)(y * 255), (uchar)(z * 255));
}

Vec3b mix(Vec3b a, Vec3b b, double alpha) {
  double gamma = 2.2;
  const double oneOver255 = 1.0 / 255.0;
  double x = pow(pow(oneOver255 * alpha * a[0], gamma) +
                     pow(oneOver255 * b[0] * (1 - alpha), 2.2),
                 1.0 / gamma);
  double y = pow(pow(oneOver255 * alpha * a[1], gamma) +
                     pow(oneOver255 * b[1] * (1 - alpha), 2.2),
                 1.0 / gamma);
  double z = pow(pow(oneOver255 * alpha * a[2], gamma) +
                     pow(oneOver255 * b[2] * (1 - alpha), 2.2),
                 1.0 / gamma);
  return Vec3b(uchar(x * 255), uchar(y * 255), uchar(z * 255));
}

double sqr(double x) { return x * x; }

void outputResult(vector<Vec3d> &res) {
  printf("========\n");
  for (int k = 0; k < 1; ++k) {
    for (int l = 0, idx = 0; l < NUM_BANDS; ++l) {
      for (int m = -l; m <= l; ++m) {
        printf("%.4f\t", res[idx++][k]);
        // printf("%.5f, ", res[idx++][k]);
      }
      printf("\n");
    }
  }
  printf("========\n");
}

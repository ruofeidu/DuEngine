// 
#define DEBUG 0

const float PI = 3.14159265358979323846;
const float PI2 = PI * 2.0;
const float PI_2 = PI * 0.5;

float sinc(float x) {
    return (abs(x) < 1e-4) ? 1.0 : (sin(x)/x);
}

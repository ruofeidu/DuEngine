// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// More info: http://www.iquilezles.org/www/articles/genetic/genetic.htm

float brushb( in vec2 p, in vec3 c )
{
    return exp( -(100.0*c.z)*(100.0*c.z)*dot(p-c.xy,p-c.xy) );
}

const vec2 a = vec2( 0.556640625, 0.0 );
const vec2 ba = vec2( -0.08203125, 1.0 );
const float k = 0.9933157;
float brusha( in vec2 p, in vec3 c )
{
    vec2 pa = c.xy - a;
    vec2 q = a + ba*dot(pa,ba)*k;///dot(ba,ba);
    vec2 c2 = 2.0*q - c.xy;
    return mix( brushb( p, c ), 1.0, brushb(p,vec3(c2,c.z)) );
}

vec3 getCol( in float x )
{
    return 0.5 + 0.5*sin( x + vec3(1.0,1.5,2.0) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.y;
    uv.x -=  0.5*(iResolution.x / iResolution.y - 1.0);

    vec3 col = vec3(0.0);

    col = mix( col, getCol(1.05), brusha(uv,vec3(0.62,0.83,0.98)) );
    col = mix( col, getCol(0.16), brusha(uv,vec3(0.98,0.56,0.11)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.08,0.93,0.35)) );
    col = mix( col, getCol(1.99), brusha(uv,vec3(0.75,0.85,0.53)) );
    col = mix( col, getCol(0.22), brusha(uv,vec3(0.99,0.69,0.09)) );
    col = mix( col, getCol(0.05), brusha(uv,vec3(0.90,0.45,0.27)) );
    col = mix( col, getCol(1.42), brusha(uv,vec3(0.52,0.09,0.35)) );
    col = mix( col, getCol(0.07), brusha(uv,vec3(0.07,0.33,0.47)) );
    col = mix( col, getCol(0.19), brusha(uv,vec3(0.01,0.71,0.10)) );
    col = mix( col, getCol(2.74), brusha(uv,vec3(0.62,0.24,0.11)) );
    col = mix( col, getCol(1.69), brusha(uv,vec3(0.27,0.82,0.36)) );
    col = mix( col, getCol(0.02), brusha(uv,vec3(0.18,0.37,0.45)) );
    col = mix( col, getCol(0.07), brusha(uv,vec3(0.97,0.97,0.13)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.02,0.76,0.11)) );
    col = mix( col, getCol(2.82), brusha(uv,vec3(0.16,0.70,0.17)) );
    col = mix( col, getCol(1.99), brusha(uv,vec3(0.71,0.77,0.62)) );
    col = mix( col, getCol(2.64), brusha(uv,vec3(0.45,0.67,0.08)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.87,0.45,0.39)) );
    col = mix( col, getCol(1.51), brusha(uv,vec3(0.48,0.10,0.32)) );
    col = mix( col, getCol(1.54), brusha(uv,vec3(0.68,0.17,0.47)) );
    col = mix( col, getCol(0.11), brusha(uv,vec3(0.88,0.48,0.39)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.08,0.82,0.23)) );
    col = mix( col, getCol(0.02), brusha(uv,vec3(0.06,0.42,0.15)) );
    col = mix( col, getCol(0.08), brusha(uv,vec3(0.92,0.87,0.17)) );
    col = mix( col, getCol(1.34), brusha(uv,vec3(0.38,0.80,0.82)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.90,0.96,0.25)) );
    col = mix( col, getCol(2.35), brusha(uv,vec3(0.80,0.87,0.27)) );
    col = mix( col, getCol(0.19), brusha(uv,vec3(0.50,0.44,0.45)) );
    col = mix( col, getCol(0.09), brusha(uv,vec3(0.91,0.53,0.23)) );
    col = mix( col, getCol(0.11), brusha(uv,vec3(1.00,0.54,0.12)) );
    col = mix( col, getCol(1.42), brusha(uv,vec3(0.44,0.12,0.38)) );
    col = mix( col, getCol(2.19), brusha(uv,vec3(0.66,0.99,0.12)) );
    col = mix( col, getCol(1.86), brusha(uv,vec3(0.38,0.54,0.19)) );
    col = mix( col, getCol(1.22), brusha(uv,vec3(0.57,0.92,0.28)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.98,0.62,0.11)) );
    col = mix( col, getCol(1.69), brusha(uv,vec3(0.25,0.82,0.37)) );
    col = mix( col, getCol(1.34), brusha(uv,vec3(0.32,0.89,0.59)) );
    col = mix( col, getCol(0.09), brusha(uv,vec3(0.03,0.91,0.19)) );
    col = mix( col, getCol(1.27), brusha(uv,vec3(0.67,0.36,0.49)) );
    col = mix( col, getCol(2.47), brusha(uv,vec3(0.09,0.69,0.31)) );
    col = mix( col, getCol(2.88), brusha(uv,vec3(0.60,0.17,0.30)) );
    col = mix( col, getCol(1.02), brusha(uv,vec3(0.55,0.26,0.24)) );
    col = mix( col, getCol(1.40), brusha(uv,vec3(0.34,0.81,0.54)) );
    col = mix( col, getCol(1.15), brusha(uv,vec3(0.69,0.86,0.35)) );
    col = mix( col, getCol(2.92), brusha(uv,vec3(0.17,0.52,0.31)) );
    col = mix( col, getCol(1.71), brusha(uv,vec3(0.33,0.65,0.18)) );
    col = mix( col, getCol(1.54), brusha(uv,vec3(0.46,0.51,0.30)) );
    col = mix( col, getCol(1.92), brusha(uv,vec3(0.49,0.70,0.11)) );
    col = mix( col, getCol(2.89), brusha(uv,vec3(0.17,0.59,0.19)) );
    col = mix( col, getCol(0.02), brusha(uv,vec3(0.12,0.40,0.21)) );
    col = mix( col, getCol(1.15), brusha(uv,vec3(0.44,0.66,0.17)) );
    col = mix( col, getCol(1.00), brusha(uv,vec3(0.31,0.74,0.76)) );
    col = mix( col, getCol(2.39), brusha(uv,vec3(0.78,0.66,0.14)) );
    col = mix( col, getCol(3.00), brusha(uv,vec3(0.14,0.84,0.43)) );
    col = mix( col, getCol(2.19), brusha(uv,vec3(0.12,0.53,0.54)) );
    col = mix( col, getCol(0.06), brusha(uv,vec3(0.10,0.40,0.19)) );
    col = mix( col, getCol(2.89), brusha(uv,vec3(0.14,0.66,0.18)) );
    col = mix( col, getCol(3.00), brusha(uv,vec3(0.84,0.53,0.44)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.13,0.35,0.45)) );
    col = mix( col, getCol(2.96), brusha(uv,vec3(0.54,0.57,0.26)) );
    col = mix( col, getCol(0.39), brusha(uv,vec3(0.46,0.44,0.55)) );
    col = mix( col, getCol(2.59), brusha(uv,vec3(0.75,0.46,0.19)) );
    col = mix( col, getCol(2.74), brusha(uv,vec3(0.23,0.46,0.26)) );
    col = mix( col, getCol(2.55), brusha(uv,vec3(0.68,0.75,0.50)) );
    col = mix( col, getCol(0.94), brusha(uv,vec3(0.56,0.22,0.48)) );
    col = mix( col, getCol(3.00), brusha(uv,vec3(0.44,0.58,0.29)) );
    col = mix( col, getCol(1.94), brusha(uv,vec3(0.72,0.95,0.22)) );
    col = mix( col, getCol(0.94), brusha(uv,vec3(0.29,0.67,0.42)) );
    col = mix( col, getCol(1.34), brusha(uv,vec3(0.25,0.68,0.40)) );
    col = mix( col, getCol(2.04), brusha(uv,vec3(0.10,0.57,0.41)) );
    col = mix( col, getCol(0.07), brusha(uv,vec3(0.96,0.92,0.16)) );
    col = mix( col, getCol(1.62), brusha(uv,vec3(0.60,0.99,0.17)) );
    col = mix( col, getCol(1.22), brusha(uv,vec3(0.61,0.75,0.39)) );
    col = mix( col, getCol(0.06), brusha(uv,vec3(0.85,0.41,0.60)) );
    col = mix( col, getCol(1.99), brusha(uv,vec3(0.69,0.22,0.43)) );
    col = mix( col, getCol(1.28), brusha(uv,vec3(0.36,0.70,0.32)) );
    col = mix( col, getCol(2.64), brusha(uv,vec3(0.90,0.80,0.46)) );
    col = mix( col, getCol(2.29), brusha(uv,vec3(0.77,0.85,0.47)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.88,0.94,0.37)) );
    col = mix( col, getCol(0.11), brusha(uv,vec3(0.11,0.34,0.47)) );
    col = mix( col, getCol(1.49), brusha(uv,vec3(0.67,0.93,0.34)) );
    col = mix( col, getCol(2.09), brusha(uv,vec3(0.30,0.58,0.15)) );
    col = mix( col, getCol(1.34), brusha(uv,vec3(0.59,0.24,0.37)) );
    col = mix( col, getCol(1.05), brusha(uv,vec3(0.53,0.72,0.22)) );
    col = mix( col, getCol(0.11), brusha(uv,vec3(0.15,0.46,0.50)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.87,0.85,0.43)) );
    col = mix( col, getCol(1.15), brusha(uv,vec3(0.60,0.94,0.29)) );
    col = mix( col, getCol(1.02), brusha(uv,vec3(0.60,0.29,0.27)) );
    col = mix( col, getCol(1.34), brusha(uv,vec3(0.27,0.64,0.19)) );
    col = mix( col, getCol(1.82), brusha(uv,vec3(0.78,0.74,0.40)) );
    col = mix( col, getCol(0.91), brusha(uv,vec3(0.49,0.95,0.14)) );
    col = mix( col, getCol(1.28), brusha(uv,vec3(0.42,0.29,0.24)) );
    col = mix( col, getCol(0.06), brusha(uv,vec3(0.97,0.42,0.32)) );
    col = mix( col, getCol(0.13), brusha(uv,vec3(0.16,0.36,0.39)) );
    col = mix( col, getCol(2.39), brusha(uv,vec3(0.43,0.84,0.18)) );
    col = mix( col, getCol(3.00), brusha(uv,vec3(0.61,0.60,0.39)) );
    col = mix( col, getCol(1.22), brusha(uv,vec3(0.68,0.71,0.30)) );
    col = mix( col, getCol(2.39), brusha(uv,vec3(0.92,0.71,0.35)) );
    col = mix( col, getCol(1.76), brusha(uv,vec3(0.91,0.67,0.35)) );
    col = mix( col, getCol(1.78), brusha(uv,vec3(0.59,0.73,0.21)) );
    col = mix( col, getCol(3.00), brusha(uv,vec3(0.66,0.88,0.49)) );
    col = mix( col, getCol(0.09), brusha(uv,vec3(0.05,0.37,0.21)) );
    col = mix( col, getCol(1.34), brusha(uv,vec3(0.34,0.75,0.79)) );
    col = mix( col, getCol(0.11), brusha(uv,vec3(0.04,0.71,0.45)) );
    col = mix( col, getCol(1.15), brusha(uv,vec3(0.67,0.85,0.53)) );
    col = mix( col, getCol(3.00), brushb(uv,vec3(0.81,0.86,0.30)) );
    col = mix( col, getCol(0.80), brushb(uv,vec3(0.31,0.75,1.37)) );
    col = mix( col, getCol(2.55), brushb(uv,vec3(0.63,0.65,0.47)) );
    col = mix( col, getCol(0.05), brushb(uv,vec3(0.10,0.91,0.39)) );
    col = mix( col, getCol(1.42), brushb(uv,vec3(0.62,0.83,0.60)) );
    col = mix( col, getCol(2.11), brushb(uv,vec3(0.68,0.29,0.31)) );
    col = mix( col, getCol(2.49), brushb(uv,vec3(0.70,0.38,0.23)) );
    col = mix( col, getCol(0.94), brushb(uv,vec3(0.31,0.67,0.20)) );
    col = mix( col, getCol(0.05), brushb(uv,vec3(0.99,0.92,0.14)) );
    col = mix( col, getCol(1.22), brushb(uv,vec3(0.40,1.02,0.09)) );
    col = mix( col, getCol(0.13), brushb(uv,vec3(0.02,0.98,0.15)) );
    col = mix( col, getCol(0.20), brushb(uv,vec3(0.35,0.77,1.08)) );
    col = mix( col, getCol(3.00), brushb(uv,vec3(0.41,0.34,0.54)) );
    col = mix( col, getCol(2.07), brushb(uv,vec3(0.71,0.49,0.47)) );
    col = mix( col, getCol(2.85), brushb(uv,vec3(0.71,0.88,0.53)) );
    col = mix( col, getCol(3.00), brushb(uv,vec3(0.68,0.88,0.62)) );
    col = mix( col, getCol(1.29), brushb(uv,vec3(0.39,0.73,0.32)) );
    col = mix( col, getCol(1.07), brushb(uv,vec3(0.45,0.95,0.14)) );
    col = mix( col, getCol(0.05), brushb(uv,vec3(0.01,0.31,0.39)) );
    col = mix( col, getCol(0.02), brushb(uv,vec3(0.10,0.84,0.32)) );
    col = mix( col, getCol(1.87), brushb(uv,vec3(0.35,0.76,2.28)) );
    col = mix( col, getCol(0.19), brushb(uv,vec3(0.48,0.44,0.55)) );
    col = mix( col, getCol(1.80), brushb(uv,vec3(0.20,0.72,0.37)) );
    col = mix( col, getCol(1.15), brushb(uv,vec3(0.26,0.69,0.26)) );
    col = mix( col, getCol(1.40), brushb(uv,vec3(0.49,0.84,0.33)) );
    col = mix( col, getCol(3.00), brushb(uv,vec3(0.28,0.86,0.73)) );
    col = mix( col, getCol(1.22), brushb(uv,vec3(0.54,0.96,0.18)) );
    col = mix( col, getCol(0.82), brushb(uv,vec3(0.50,0.65,0.32)) );
    col = mix( col, getCol(0.11), brushb(uv,vec3(0.04,0.32,0.39)) );
    col = mix( col, getCol(1.81), brushb(uv,vec3(0.21,0.65,0.32)) );
    col = mix( col, getCol(0.19), brushb(uv,vec3(0.00,0.63,0.12)) );
    col = mix( col, getCol(2.22), brushb(uv,vec3(0.30,0.49,0.14)) );
    col = mix( col, getCol(0.02), brushb(uv,vec3(0.06,0.98,0.20)) );
    col = mix( col, getCol(0.82), brushb(uv,vec3(0.44,0.27,0.24)) );
    col = mix( col, getCol(0.09), brushb(uv,vec3(0.09,0.97,0.34)) );
    col = mix( col, getCol(0.08), brushb(uv,vec3(0.09,0.48,0.23)) );
    col = mix( col, getCol(1.31), brushb(uv,vec3(0.68,0.82,1.14)) );
    col = mix( col, getCol(0.13), brushb(uv,vec3(0.01,0.37,0.18)) );
    col = mix( col, getCol(2.96), brushb(uv,vec3(0.84,0.62,0.19)) );
    col = mix( col, getCol(2.21), brushb(uv,vec3(0.67,0.94,0.35)) );
    col = mix( col, getCol(1.22), brushb(uv,vec3(0.49,0.77,0.30)) );
    col = mix( col, getCol(2.44), brushb(uv,vec3(0.32,0.35,0.21)) );
    col = mix( col, getCol(1.80), brushb(uv,vec3(0.40,0.26,0.20)) );
    col = mix( col, getCol(1.09), brushb(uv,vec3(0.51,0.51,0.46)) );
    col = mix( col, getCol(2.55), brushb(uv,vec3(0.69,0.55,0.16)) );

    fragColor = vec4(col,1.0);
}

// lslBzS
// http://www.iquilezles.org/www/articles/functions/functions.htm
// Reimplemented by starea @ shadertoy using Flyguy's Implicit Plotter https://www.shadertoy.com/view/4tB3WV
#define PI 3.14159265359

//Implicit / f(x) plotter thing.

//XY range of the display.
#define DISP_SCALE 2.0 

//Line thickness (in pixels).
#define LINE_SIZE 2.0

//Grid line & axis thickness (in pixels).
#define GRID_LINE_SIZE 1.0
#define GRID_AXIS_SIZE 2.0

//Number of grid lines per unit.
#define GRID_LINES 1.0

//Clip areas outside DISP_SCALE
//#define CLIP_EDGES

const vec2 GRAD_OFFS = vec2(0.001, 0);

#define GRAD(f, p) (vec2(f(p) - f(p + GRAD_OFFS.xy), f(p) - f(p + GRAD_OFFS.yx)) / GRAD_OFFS.xx)

//PLOT(Function, Color, Destination, Screen Position)
#define PLOT(f, c, d, p) d = mix(c, d, smoothstep(0.0, (LINE_SIZE / iResolution.y * DISP_SCALE), abs(f(p) / length(GRAD(f,p)))))


//>>>>>>>>>>>>>>>>> iq's little functions starts >>>>>>>>>>>>>>>>>>>>

float almostIdentity( float x, float m, float n )
{
    if( x>m ) return x;

    float a = 2.0f*n - m;
    float b = 2.0f*m - 3.0f*n;
    float t = x/m;

    return (a*t + b)*t*t + n;
}

float impulse( float k, float x )
{
    float h = k*x;
    return h*exp(1.0f-h);
}

float cubicPulse( float c, float w, float x )
{
    x = abs(x - c);
    if( x>w ) return 0.0f;
    x /= w;
    return 1.0f - x*x*(3.0f-2.0f*x);
}

float pcurve( float x, float a, float b )
{
    float k = pow(a+b,a+b) / (pow(a,a)*pow(b,b));
    return k * pow( x, a ) * pow( 1.0-x, b );
}

float expStep( float x, float k, float n )
{
    return exp( -k*pow(x,n) );
}


float parabola( float x, float k )
{
    return pow( 4.0f*x*(1.0f-x), k );
}

//>>>>>>>>>>>>>>>>> iq's little functions ends >>>>>>>>>>>>>>>>>>>>
// starea's Print-friendly Color Palette: https://www.shadertoy.com/view/4ltSWN
vec3 RGBLabel(int i) {
	if (i == 0) return vec3(1.000, 1.000, 0.701);  else
	if (i == 1) return vec3(0.988, 0.834, 0.898);  else
	if (i == 2) return vec3(0.992, 0.805, 0.384); else
	if (i == 3) return vec3(0.775, 0.779, 0.875); else
	if (i == 4) return vec3(0.701, 0.871, 0.312); else
	if (i == 5) return vec3(0.553, 0.827, 0.780); else
	if (i == 6) return vec3(0.502, 0.694, 0.827); else
	if (i == 7) return vec3(0.984, 0.502, 0.347);
	return vec3(0.0);
}

// 0.
// When you don't want to change a value unless it's too small.
// Rather than doing a sharp conditional branch, you can blend your value with a threshold smoothly with a cubic polynomial. 
// m: f(x) = x, x > m
// n: f(0) = n
float AlmostIdentity(vec2 p) {
	float y = almostIdentity(p.x, 0.5, 0.1);
	return p.y - y;
}

// 1.
// Great for triggering behaviours or making envelopes for music or animation, 
// and for anything that grows fast and then slowly decays. 
float Impulse(vec2 p)
{	
	return p.y - impulse(p.x, 5.0);
}

// 2.
// Of course you found yourself doing smoothstep(c-w,c,x)-smoothstep(c,c+w,x) very often, probably cause you were trying to isolate some features.
// Then this cubicPulse() is your friend. Also, why not, you can use it as a cheap replacement for a gaussian.
float CubicPulse(vec2 p)
{
	return p.y - cubicPulse(0.5, 0.2, p.x);
}

// 3.
// A natural attenuation is an exponential of a linearly decaying quantity
float ExpStep(vec2 p)
{
	return p.y - expStep(0.00005, 0.005, -p.x);
}

	
float gain(float x, float k) 
{
    float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), k);
    return (x<0.5)?a:1.0-a;
}

float Gain(vec2 p) {
    return p.y - gain(p.x, 3.0);
}

float Parabola(vec2 p)
{
	return p.y - parabola(p.x, 5.0);
}

// A nice choice to remap the 0..1 interval into 0..1, such that the corners are remapped to 0. 
// Very useful to skew the shape one side or the other in order to make leaves, eyes, and many other interesting shapes
float PowerCurve(vec2 p)
{
	return p.y - pcurve(p.x, 1.0, 2.0);
}

float grid(vec2 p);

float grid(vec2 p)
{
	vec2 uv = mod(p,1.0 / GRID_LINES);
	
	float halfScale = 1.0 / GRID_LINES / 2.0;
	
	float gridRad = (GRID_LINE_SIZE / iResolution.y) * DISP_SCALE;
	float grid = halfScale - max(abs(uv.x - halfScale), abs(uv.y - halfScale));
	grid = smoothstep(0.0, gridRad, grid);
	
	float axisRad = (GRID_AXIS_SIZE / iResolution.y) * DISP_SCALE;
	float axis = min(abs(p.x), abs(p.y));
	axis = smoothstep(axisRad-0.05, axisRad, axis);
	
	return min(grid, axis);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 aspect = iResolution.xy / iResolution.y;
	vec2 uv = ( fragCoord.xy / iResolution.y ) - aspect / 2.0;
	uv *= DISP_SCALE;
	
	vec3 col = vec3(grid(uv) * 0.25);
    
    PLOT(AlmostIdentity, RGBLabel(0), col, uv);
    
    PLOT(Impulse, RGBLabel(1), col, uv);
    
    PLOT(CubicPulse, RGBLabel(2), col, uv);
    
    PLOT(Gain, RGBLabel(6), col, uv);
    
    PLOT(ExpStep, RGBLabel(3), col, uv);
    
    PLOT(Parabola, RGBLabel(4), col, uv);
    
    PLOT(PowerCurve, RGBLabel(5), col, uv);
    
	#ifdef CLIP_EDGES 
		col *= 1.0 - step(DISP_SCALE / 2.0, abs(uv.x));    
	#endif
	
	fragColor = vec4( vec3(col), 1.0 );
}
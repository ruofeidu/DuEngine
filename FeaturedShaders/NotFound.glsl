// https://www.shadertoy.com/view/MtVyDm
/*
* License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
* Created by bal-khan
*/

vec2	march(vec3 pos, vec3 dir);
vec3	camera(vec2 uv);
void	rotate(inout vec2 v, float angle);

float 	t;			// time
vec3	ret_col;	// torus color
vec3	h; 			// light amount

#define I_MAX		20.
#define E			0.00001
#define FAR			100.
#define PI 			3.14159
#define TAU 		PI*2.

//#define MOUSE_ROT
//#define ALIASING

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    t  = iTime*.125;
    vec3	col = vec3(0., 0., 0.);
    #ifdef ALIASING
	if (mod(float(fragCoord.x), 2.) <= 1. || mod(float(fragCoord.y), 2.) <= 1.)
    	discard;
    #endif
	vec2 R = iResolution.xy,
          uv  = vec2(fragCoord.xy-R/2.) / min(R.x, R.y);
  	float aspect = max(R.x/R.y, R.y/R.x);
	uv *= aspect;
	vec3	dir = camera(uv);
	vec3	pos = vec3(.0, .0, 44.5);

    h*=0.;
    vec2	inter = (march(pos, dir));
    col += h * 1.;
    fragColor =  vec4(col,1.0);
}

float mylength(vec3 p) {return max(abs(p.x), max(abs(p.y), abs(p.z)));}
float mylength(vec2 p) {return max(abs(p.x), abs(p.y));}

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p-a, ba = b-a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
}

float four_df(vec3 p, vec3 off)
{
    p -= off;
    vec3 pp = p;
    
    pp.x -= 1.;
    float ret = sdCapsule(pp, vec3(.0, 10.*1.5, .0), vec3(.0, -10.*1.5, .0), .25 );

    pp = p;
    rotate(pp.xy, 1.57);
    pp.z = abs(pp.z)-clamp(exp(-pp.y+0.), .0, 1.);
    pp = pp-vec3(min(exp(-pp.y+5.), 1.)*2.1*sin(pp.y*.5+iTime), .0, .0);
    ret = min(ret,
                sdCapsule(pp, vec3(.0, 10.*1.5, .0), vec3(.0, -7.*1.5, 0.0), .25)
                );
    pp = p;
    rotate(pp.xy, 1.57*1.5);
    pp.x -= 6.5*1.5+1.;
    ret = min(ret,
                sdCapsule(pp, vec3(.0, 7.*1.5, .0), vec3(.0, -6.*1.5, 0.0), .25)
                );
  return ret;
}
      
float	scene(vec3 p)
{  
    float	var;
    float	mind = 1e5;
    #ifdef MOUSE_ROT
    rotate(p.xz, TAU*(iMouse.x-.05*iResolution.x)/iResolution.x);
    rotate(p.yz, TAU*(iMouse.y-.05*iResolution.y)/iResolution.y);
    #endif
    var = atan(p.x,p.y);
    vec2 q = vec2( ( length(p.xy) )-10.,p.z);
    rotate(q, -var*2.+iTime*.50);
    q = abs(q)-2.;
    rotate(q, var*4.+iTime*1.);
    q.y = abs(q.y)-.8;
    rotate(q, var*3.+iTime*1.);
    q.x = abs(q.x)-.8;
    mind = mylength(q)+.5+1.05*(length(fract(q*.18205*(3.+3.*sin(var*2. - iTime*.250)) )-.5)-1.215);
  
    float the_4 = four_df(vec3((abs(p.x))*(p.x<0.0 ? -1. : 1.)+(p.x<0.0 ? 1. : -1.)*35.,p.yz), vec3(.0, .0, .0));

    h += vec3(.525+.20*(1.+sin(var*1. - iTime*.25)), .4, .25)*.0125/max(.0001, .125021+.0051*mind*mind);
    
    mind = min(mind, the_4);
  
    h += -vec3(.5, .4, .5)*.0025/max(.0001,.021+mind*mind);

    h += vec3(.31, .21, .25)*.00125/max(.0001, .005+.000151*the_4*the_4);
    
    return (mind);
}

vec2	march(vec3 pos, vec3 dir)
{
    vec2	dist = vec2(0.0, 0.0);
    vec3	p = vec3(0.0, 0.0, 0.0);
    vec2	s = vec2(0.0, 0.0);
	    for (float i = -1.; i < I_MAX; ++i)
	    {
	    	p = pos + dir * dist.y;
	        dist.x = scene(p)*.7;
	        dist.y += dist.x;
            // log trick by aiekick
	        if (log(dist.y*dist.y/dist.x/1e5) > .0 || dist.x < E || dist.y > FAR)
            {
                break;
            }
	        s.x++;
    }
    s.y = dist.y;
    return (s);
}

// Utilities

void rotate(inout vec2 v, float angle)
{
	v = vec2(cos(angle)*v.x+sin(angle)*v.y,-sin(angle)*v.x+cos(angle)*v.y);
}

vec3	camera(vec2 uv)
{
    float		fov = .75;
	vec3		forw  = vec3(0.0, 0.0, -1.0);
	vec3    	right = vec3(1.0, 0.0, 0.0);
	vec3    	up    = vec3(0.0, 1.0, 0.0);

    return (normalize((uv.x) * right + (uv.y) * up + fov * forw));
}

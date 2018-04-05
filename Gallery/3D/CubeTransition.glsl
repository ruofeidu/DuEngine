//  transition of cube
float persp = .7;
float unzoom = .3;
float reflection = .4;
float floating = 3.;

vec2 project (vec2 p) 
{
	return p * vec2(1, -1.2) + vec2(0, -floating/100.);
}

bool inBounds (vec2 p) 
{
      return all(lessThan(vec2(0), p)) && all(lessThan(p, vec2(1)));
}

vec4 bgColor (vec2 p, vec2 pfr, vec2 pto) 
{
  	vec4 c = vec4(0, 0, 0, 1);
  	pfr = project(pfr);
  	if (inBounds(pfr)) 
    {
    	c += mix(vec4(0), texture(iChannel0, pfr), reflection * mix(1., 0., pfr.y));
  	}
  	pto = project(pto);
  	if (inBounds(pto)) 
    {
    	c += mix(vec4(0), texture(iChannel1, pto), reflection * mix(1., 0., pto.y));
  	}
  	return c;
}

// p : the position
// persp : the perspective in [ 0, 1 ]
// center : the xcenter in [0, 1] \ 0.5 excluded
vec2 xskew (vec2 p, float persp, float center) 
{
  	float x = mix(p.x, 1.-p.x, center);
  	return (
    	(
      		vec2( x, (p.y - .5*(1.-persp) * x) / (1.+(persp-1.)*x) )
      		- vec2(.5-distance(center, .5), 0)
    	)
    	* vec2(.5 / distance(center, .5) * (center<0.5 ? 1. : -1.), 1.)
    	+ vec2(center<0.5 ? 0. : 1., .0)
  	);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    float progress = sin(iTime*0.6+10.)*.5+.5;
	if (iMouse.z>0.) progress = iMouse.x/iResolution.x; 
        
  	vec2 op = fragCoord.xy / iResolution.xy;
  	float uz = unzoom * 2.0*(0.5-distance(0.5, progress));
  	vec2 p = -uz*0.5+(1.0+uz) * op;
  	vec2 fromP = xskew(
    	(p - vec2(progress, 0.0)) / vec2(1.0-progress, 1.0),
    	1.0-mix(progress, 0.0, persp),
    	0.0
  	);
  	vec2 toP = xskew(
    	p / vec2(progress, 1.0),
    	mix(pow(progress, 2.0), 1.0, persp),
    	1.0
  	);
  	if (inBounds(fromP)) 
    {
    	fragColor = texture(iChannel0, fromP);
  	}
  	else if (inBounds(toP)) 
    {
    	fragColor = texture(iChannel1, toP);
  	}
  	else 
    {
    	fragColor = bgColor(op, fromP, toP);
  	}
}
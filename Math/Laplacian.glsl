// https://www.shadertoy.com/view/4djyzK
// The MIT License
// Copyright © 2017 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

// Computes the laplacian of a distance field.

// The Laplacian measures average rate of change at a given location (while gradient measures
// the direction of maximum change). If compareted agains a threshold, you can use is as an
// edge detector. You can also use it to detect linear sections of the distanec field, where
// the Laplace is zero, or alternativelly, measure how curved the isolines are (where the
// laplacian is higher the bigger the curvature).



float sdBox( vec2 p, vec2 b )
{
  vec2 d = abs(p) - b;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdTriangle( in vec2 p0, in vec2 p1, in vec2 p2, in vec2 p )
{
	vec2 e0 = p1 - p0;
	vec2 e1 = p2 - p1;
	vec2 e2 = p0 - p2;
	vec2 v0 = p - p0;
	vec2 v1 = p - p1;
	vec2 v2 = p - p2;
	vec2 pq0 = v0 - e0*clamp( dot(v0,e0)/dot(e0,e0), 0.0, 1.0 );
	vec2 pq1 = v1 - e1*clamp( dot(v1,e1)/dot(e1,e1), 0.0, 1.0 );
	vec2 pq2 = v2 - e2*clamp( dot(v2,e2)/dot(e2,e2), 0.0, 1.0 );
    float s = sign( e0.x*e2.y - e0.y*e2.x );
    vec2 d = min( min( vec2( dot( pq0, pq0 ), s*(v0.x*e0.y-v0.y*e0.x) ),
                       vec2( dot( pq1, pq1 ), s*(v1.x*e1.y-v1.y*e1.x) )),
                       vec2( dot( pq2, pq2 ), s*(v2.x*e2.y-v2.y*e2.x) ));
	return -sqrt(d.x)*sign(d.y);
}

vec2 v1, v2, v3;

float map( in vec2 p )
{
    float d1 = length(p-vec2(-0.6,-0.3))-0.4;
    float d2 = sdTriangle( v1, v2, v3, p );
    float d3 = sdBox( p-vec2(1.0,0.5), vec2(0.6,0.2) );
    return min( d1, min(d2,d3) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;

    v1 = 0.7*cos( iTime*0.55 + vec2(0.0,1.5) + 0.0 );
	v2 = 0.5*cos( iTime*0.50 + vec2(0.0,1.7) + 3.0 );
	v3 = 0.8*cos( iTime*0.60 + vec2(0.0,1.6) + 4.0 );

    vec2 e = vec2(2.0/iResolution.y,0.0);
	float dis = map( p );
    vec2  gra = vec2(map(p+e.xy)-map(p-e.xy), map(p+e.yx)-map(p-e.yx))/(2.0*e.x);
    float lap = (map(p+e.xy) + map(p-e.xy) + map(p+e.yx) + map(p-e.yx) - 4.0*map(p))/(e.x*e.x);
    
    
    //vec3 col = vec3(0.9+0.1*gra,0.0);
	vec3 col = vec3(1.0,0.7,0.3);
    if( dis<0.0 ) col = col.zxy;
    col *= 1.0 - 0.7*exp(-1.5*abs(dis));
    col *= 0.96 + 0.04*cos(200.0*dis);
	col = mix( col, vec3(0.0,0.0,0.0), 1.0-smoothstep(0.0,0.01,abs(dis)) );
    
  
    // laplacian display
    float anim = fract( iTime/8.0 );
         if( lap<-10.0 ) { if( anim>0.25 ) col  = vec3(1.0,1.0,1.0); }
    else if( lap> 10.0 ) { if( anim>0.50 ) col  = vec3(1.0,0.8,0.1); }
    else                 { if( anim>0.75 ) col += vec3(1.0,1.0,1.0)*abs(lap)*0.1; }
    
	fragColor = vec4(col,1.0);
}

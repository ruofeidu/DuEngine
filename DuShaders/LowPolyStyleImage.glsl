// Delaunay Triangulation effect on top of Video
// by Tom'2016
// Modified by @starea to fix the boundaries

// PolyCube version with interaction:
//  http://polycu.be/edit/?h=d0YR9J

// It has some artifacts. I'm not sure if possible to remove them all,
// as even JFA for base Voronoi is not 100% accurate. Surprisingly,
// most of the time it kind of works ;)

// Extends my previous Voronoi filter attempt:
//  https://www.shadertoy.com/view/4sy3W3

// Uses jump-flood-fill concept (JFA), originally stated in this paper:
//  http://www.comp.nus.edu.sg/~tants/jfa/i3d06.pdf

#define GAMMA_CORRECTION 1

//============================================================
vec2 GetCoord( float offset )
{
    float y = floor(offset / iResolution.x);
    return vec2( offset - y * iResolution.x, y ) + .5;
}

//============================================================
// Signed distance to a 2D triangle by iq
//   https://www.shadertoy.com/view/XsXSz4
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
    
    // Correction for flipped triangle, we don't need it if consistent order is kept
    //float s = -sign(e0.x*e1.y - e0.y*e1.x); e0 *= s; e1 *= s; e2 *= s;
    
    vec2 d = min( min( vec2( dot( pq0, pq0 ), v0.x*e0.y-v0.y*e0.x ),
                       vec2( dot( pq1, pq1 ), v1.x*e1.y-v1.y*e1.x )),
                       vec2( dot( pq2, pq2 ), v2.x*e2.y-v2.y*e2.x ));

	return -sqrt(d.x)*sign(d.y);
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
#if 0 // debug feature extraction
    
    fragColor = texture(iChannel1, uv).wwww;
    
#else
    
	vec4 tri = texture(iChannel0, uv);
    
    if (tri.x == 0.) {
        fragColor = vec4(0);
        return;
    }
            
    vec2 p0 = GetCoord(tri.x);
    vec2 p1 = GetCoord(tri.y);
    vec2 p2 = GetCoord(tri.z);
    vec2 p3 = (p0 + p1 + p2) * (1.0/3.0);
    
    float dist = sdTriangle(p0, p1, p2, fragCoord);
    if (tri.w != 0.) {
        p3 = GetCoord(tri.w);
        dist = min(dist, sdTriangle(p0, p2, p3, fragCoord));
    }
    
#if 0 // test triangles
    dist = smoothstep(1.,-1.0,dist);
    fragColor = vec4(vec3(dist), 1.);
#else
    dist = smoothstep(1.,0.5,dist);
    vec3 c0 = texture(iChannel1, p0 / iChannelResolution[1].xy ).xyz;
    vec3 c1 = texture(iChannel1, p1 / iChannelResolution[1].xy ).xyz;
    vec3 c2 = texture(iChannel1, p2 / iChannelResolution[1].xy ).xyz;
    vec3 c3 =texture(iChannel1, p3 / iChannelResolution[1].xy ).xyz;
#if GAMMA_CORRECTION
    vec3 video = pow( (pow(c0, vec3(2.2)) + pow(c1, vec3(2.2)) + pow(c2, vec3(2.2)) + pow(c3, vec3(2.2))) / 4.0, 
                     vec3(1.0 / 2.2));
#else
    vec3 video = (c0 + c1 + c2 + c3) / 4.0;
#endif //GAMMA_CORRECTION
    
    vec3 color = video.xyz * dist;
    fragColor = vec4(color, 1.);
#endif
    
#endif
    if (iMouse.w > 0.0) {
    	fragColor = vec4(texture(iChannel3, uv).xyz, 1.0);    
    }
	vec2 q = fragCoord.xy / iResolution.xy;
    fragColor.rgb *= 0.1 + 0.25 + 0.75 * pow( 16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.15 );
    
}

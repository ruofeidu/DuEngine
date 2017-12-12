// Triangulation JFA by Tom@2016

// this must be in sync with Voronoi JFA algorithm constant
const float c_maxSteps = 8.0;

//============================================================
vec4 FindTriangles (in vec2 fragCoord )
{
    vec2 baseCoord = fragCoord / iChannelResolution[1].xy;
    vec3 one = vec3( vec2(1,1) / iChannelResolution[1].xy, 0 );
    float offset0 = texture( iChannel1, baseCoord ).x;
    float offset1 = texture( iChannel1, baseCoord + one.zy ).x;
    float offset2 = texture( iChannel1, baseCoord + one.xy ).x;
    float offset3 = texture( iChannel1, baseCoord + one.xz ).x;
    // Keep CW order
    // 1 2
    // 0 3
    float count = float(offset0 != offset1);
    count += float(offset0 != offset2);
    count += float(offset0 != offset3);
    count += float(offset1 != offset2);
    count += float(offset1 != offset3);
    count += float(offset2 != offset3);
    // if 3 are different => only one comparison will be false, thus count = 5
    // if 4 are different => count = 6
    
    if (count == 6.)
    {
        return vec4(offset0,offset1,offset2,offset3);
    }
    
    if (count == 5.)
    {
        if (offset0 == offset1) return vec4(offset0,offset2,offset3,0.0);
        if (offset1 == offset2) return vec4(offset0,offset1,offset3,0.0);
        if (offset2 == offset0) return vec4(offset1,offset2,offset3,0.0);
        return vec4(offset0,offset1,offset2,0.0);
    }
    
    return vec4(0);
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
vec2 GetCoord( float offset )
{
    float y = floor(offset / iResolution.x);
    return vec2( offset - y * iResolution.x, y ) + .5;
}

//============================================================
vec4 StepTriJFA (in vec2 fragCoord, in float level)
{
    float stepwidth = floor(exp2(c_maxSteps - 1. - level)+0.5);
    
    float bestDistance = 9999.0;
    vec4 bestTri = vec4(0);
    
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            vec2 sampleCoord = fragCoord + vec2(x,y) * stepwidth;
            
            vec4 tri = texture( iChannel0, sampleCoord / iChannelResolution[0].xy);
            if (tri.x == 0.) continue;
            
            vec2 p0 = GetCoord(tri.x);
            vec2 p1 = GetCoord(tri.y);
            vec2 p2 = GetCoord(tri.z);
            
            float dist = sdTriangle(p0, p1, p2, fragCoord);
            if (tri.w != 0.) {
                vec2 p3 = GetCoord(tri.w);
                dist = min(dist, sdTriangle(p0, p2, p3, fragCoord));
            }
            if (dist < bestDistance)
            {
                bestDistance = dist;
                bestTri = tri;
            }
        }
    }
    
    return bestTri;
}

//============================================================
float TriangleArea( in vec2 p0, in vec2 p1, in vec2 p2 )
{
    vec2 e0 = p1 - p0;
	vec2 e1 = p2 - p1;
    return e0.x*e1.y - e0.y*e1.x;
}

//============================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float level = mod(float(iFrame+1),c_maxSteps);
   	if (level < .5) {
        vec4 tri = FindTriangles( fragCoord );
		#if 1
        	// Skip flipped triangles:
            if ( tri.x == 0. )
            {
                fragColor = tri;
                return;
            }
            vec2 p0 = GetCoord(tri.x);
            vec2 p1 = GetCoord(tri.y);
            vec2 p2 = GetCoord(tri.z);
            float area = TriangleArea( p0, p1, p2 );
            if ( tri.w != 0. ) // quad
            {
                if ( area >= 0. )
                {
                    if ( TriangleArea( p0, p2, GetCoord(tri.w) ) >= 0. )
                        tri = vec4(0); // skip both triangles
                    else
                        tri = vec4(tri.xzw, 0); // second triangle is still valid
                }
            }
            else if ( area >= 0. )
            {
                tri = vec4(0); // skip
            }
		#endif
        fragColor = tri;
        return;
    }
    fragColor = StepTriJFA(fragCoord, level);
}

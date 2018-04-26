// ltG3Rt
vec3 Barycentric(in vec3 v0, in vec3 v1, in vec3 v2, in vec3 p, in vec3 normal) {
	float area = dot(cross(v1 - v0, v2 - v0), normal);
	if (abs(area) < 0.0001) return vec3(0.0, 0.0, 0.0);
	
	vec3 pv0 = v0 - p;
	vec3 pv1 = v1 - p;
	vec3 pv2 = v2 - p;
	
	vec3 asub = vec3(dot(cross(pv1, pv2), normal),
					 dot(cross(pv2, pv0), normal),
					 dot(cross(pv0, pv1), normal));
	return abs(asub) / vec3(abs(area)).xxx;
}

vec3 OtherInterpolation(in vec3 v0, in vec3 v1, in vec3 v2, in vec3 p) {
    return vec3(1.0/length(v0-p), 1.0/length(v1-p), 1.0/length(v2-p))/sqrt(4.0); 
}

void drawGrid(vec2 coord, inout vec3 col) {
    const vec3 COLOR_AXES = vec3(0.698, 0.8745, 0.541);
    const vec3 COLOR_GRID = vec3(1.0, 1.0, 0.702);
    const float tickWidth = 0.1;
    
    for (float i = -2.0; i < 2.0; i += tickWidth) {
		if (abs(coord.x - i) < 0.004) col = COLOR_GRID;
		if (abs(coord.y - i) < 0.004) col = COLOR_GRID;
	}
	if( abs(coord.x) < 0.006 ) col = COLOR_AXES;
	if( abs(coord.y) < 0.007 ) col = COLOR_AXES;	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
	vec2 uv = (2.0 * fragCoord.xy / iResolution.xy - 1.0) * aspect;
    
	vec3 v0 = vec3(0.0, 1.0, 0.0) * aspect.xyy;
	vec3 v1 = vec3(1.0, -1.0, 0.0) * aspect.xyy;
	vec3 v2 = vec3(-1.0, -1.0, 0.0) * aspect.xyy;

	const vec3 normal = vec3(0.0, 0.0, 1.0);
	vec3 color = Barycentric(v0, v1, v2, vec3(uv, 0.0), normal);

    
	if (color.x + color.y + color.z > 1.00001) 
    {
		color = vec3(0.0, 0.0, 0.0);
    } else if (iMouse.w > 0.0)
    {
        color = OtherInterpolation(v0, v1, v2, vec3(uv, 0.0));
    }
    
    vec3 grids = vec3(0.0);
    drawGrid(uv, grids);
    color = color + grids * 0.2; 

	fragColor = vec4(color, 1.0);
}
// 
// ray computation vars
const float PI = 3.14159265359;
const float fov = 50.0;

// epsilon-type values
const float S = 0.01;
const float EPSILON = 0.01;

// const delta vectors for normal calculation
const vec3 deltax = vec3(S ,0, 0);
const vec3 deltay = vec3(0 ,S, 0);
const vec3 deltaz = vec3(0 ,0, S);

float distanceToNearestSurface(vec3 p){
	float s = 1.0;
    vec3 d = abs(p) - vec3(s);
    return min(max(d.x, max(d.y,d.z)), 0.0)
        + length(max(d,0.0));
}


// better normal implementation with half the sample points
// used in the blog post method
vec3 computeSurfaceNormal(vec3 p){
    float d = distanceToNearestSurface(p);
    return normalize(vec3(
        distanceToNearestSurface(p+deltax)-d,
        distanceToNearestSurface(p+deltay)-d,
        distanceToNearestSurface(p+deltaz)-d
    ));
}


vec3 computeLambert(vec3 p, vec3 n, vec3 l){
    return vec3(dot(normalize(l-p), n));
}

vec3 intersectWithWorld(vec3 p, vec3 dir){
    float dist = 0.0;
    float nearest = 0.0;
    vec3 result = vec3(0.0);
    for(int i = 0; i < 20; i++){
        nearest = distanceToNearestSurface(p + dir*dist);
        if(nearest < EPSILON){
            vec3 hit = p+dir*dist;
            vec3 light = vec3(100.0*sin(iTime), 30.0*cos(iTime), 50.0*cos(iTime));
            result = computeLambert(hit, computeSurfaceNormal(hit), light);
            break;
        }
        dist += nearest;
    }
    return result;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy;
    
    float cameraDistance = 10.0;
    vec3 cameraPosition = vec3(10.0*sin(iTime), 0.0, 10.0*cos(iTime));
	vec3 cameraDirection = vec3(-1.0*sin(iTime), 0.0, -1.0*cos(iTime));
	vec3 cameraUp = vec3(0.0, 1.0, 0.0);
  
    // generate the ray for this pixel
    const float fovx = PI * fov / 360.0;
    float fovy = fovx * iResolution.y/iResolution.x;
    float ulen = tan(fovx);
    float vlen = tan(fovy);
    
    vec2 camUV = uv*2.0 - vec2(1.0, 1.0);
    vec3 nright = normalize(cross(cameraUp, cameraDirection));
    vec3 pixel = cameraPosition + cameraDirection + nright*camUV.x*ulen + cameraUp*camUV.y*vlen;
    vec3 rayDirection = normalize(pixel - cameraPosition);
    
    vec3 pixelColour = intersectWithWorld(cameraPosition, rayDirection);
    fragColor = vec4(pixelColour, 1.0);
}
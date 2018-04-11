// https://www.shadertoy.com/view/lsyyW
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// My second ray tracer following Peter Shirley's "Raytracing : the next week.
// Still didn't get it on volumetric's though.
// Also hard to implement class-based objects like boxes.
// We can of course hardcode them like Cornell Box i've done here
// But thats really a struggle.

// Made better emissive materials.
// Got more idea on diel and metal ones.

// Set it bigger to less noise and accurate render.
#define MAX_WEIGHT 150.0

#define MAX_DISTANCE 25.0

#define SAMPLES 10
#define MAX_BOUNCES 5
#define NUM_SPHERES 11

#define PI  3.14159265359
#define PI2 6.28318530717

// Materials
#define LAMB 0
#define METAL 1
#define DIEL 2
#define EMISSIVE 3
#define ISOTROPIC 4
#define CHECKER 5
#define PERLIN 6

const float GAMMA = 2.2;

///-- Scene Objects -------------------------------------------------------

struct Material
{
	int type;
    vec3 albedo;
    
    // value corresponds to a material. 
    //
    // Roughness for metal.
    // Refract index for dielectrics.
    // Color multiplier for current fake emission mat.
    float v; 
};
    
struct Sphere
{
	vec3 c;
    float r;
    Material mat;
};

// XY-aligned rect on z distance.
struct xyRect
{
    float x0;
    float x1; 
    float y0;
    float y1;
    float z;
    Material mat;
};
    
// XZ-aligned rect on z distance.
struct xzRect
{
    float x0;
    float x1; 
    float z0;
    float z1;
    float y;
    Material mat;
};
    
// YZ-aligned rect on z distance.
struct yzRect
{
    float y0;
    float y1; 
    float z0;
    float z1;
    float x;
    Material mat;
};

// Just for the sake of simplicity.
struct Ray 
{
    vec3 origin;
    vec3 direction;
};
    
struct bBox3
{
    vec3 pMin;
    vec3 pMax;
};
    
// Spheres on scene declaration.
Sphere scene[NUM_SPHERES];


///-- Helper Functions -----------------------------------------------------
    
float seed = 0.0;
vec2 UV = vec2(0.0);

float random() 
{
	return fract(sin(dot(UV, vec2(12.9898, 78.233)) + seed++) * 43758.5453);
}

// We use it for ray scattering.
vec3 randomUnitVector() 
{
	float theta = random() * PI2;
    float z = random() * 2.0 - 1.0;
    float a = sqrt(1.0 - z * z);
    vec3 vector = vec3(a * cos(theta), a * sin(theta), z);
    return vector * sqrt(random());
}

// Shlick's formula for transparent materials like glass.
float schlick(float cosine, float IOR) 
{
 	float r0 = (1.0 - IOR) / (1.0 + IOR);
    r0 *= r0;
    return r0 + (1.0 - r0) * pow(1.0 - cosine, 5.0);
}

vec2 hash( vec2 x )  
{
    const vec2 k = vec2( 0.318653, 0.3673123 );
    x = x * k + k.yx;
    return -1.0 + 2.0 * fract( 16.0 * k * fract( x.x * x.y * (x.x + x.y)));
}

// Simple 2D gradient noise taken from you know where: https://www.shadertoy.com/view/XdXGW8
// Thx IQ :)
float noise2D( in vec2 p )
{
    vec2 i = floor( p );
    vec2 f = fract( p );
	
	vec2 u = f * f * (3.0 - 2.0 * f);

    return mix( mix( dot( hash( i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ), 
                     dot( hash( i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( hash( i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ), 
                     dot( hash( i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

#define NUM_OCTAVES 2

float fbm ( in vec2 _st) 
{
    float v = 0.5;
    float a = 0.5;
    
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.25), sin(0.25),
                    -sin(0.25), cos(0.25));
    
    for (int i = 0; i < NUM_OCTAVES; ++i) 
    {
        v += a * noise2D(_st);
        _st = rot * _st * 2.0;
        
        // Need to clamp, or it is very soft when camera is away and very sharp when near.
        a *= 0.5;
    }
    
    if(v <= 0.5)
    {
        return 0.1;
    }
    
    else if(v >= 0.5)
    {
        return 1.;
    }
}

// I guess i've seen a correct formula for sphere cheker pattern.
// This one gives artifacts.
vec3 CheckerTex(vec3 p)
{
    float sines = sin(p.x * 10.) * sin(p.y * 10.) * sin(p.z * 10.);
    if(sines < 0.) return vec3(0.1);
    else return vec3(1.0);
}

// Function uses 3d coordinate to covert them to polar.
// Usefull to map 2d textures on a sphere.
vec2 GetSphereUV(vec3 p)
{
    float phi = atan(p.z, p.x);
    float theta = asin(p.y);
    float u = 1. - (phi + PI) / PI2;
    float v = (theta + PI / 2.) / PI;
    
    return vec2(u, v);
}

///-- INTERSECT FUNCTIONS -----------------------------------------------------


// The point where we intersected something.
vec3 getHitPoint(Ray ray, float t) 
{
 	return ray.origin + t * ray.direction;   
}

// XY plane intersection.
bool xyIntersect(Ray ray, xyRect rect, float tMin, float tMax, out float t)
{
    t = (rect.z - ray.origin.z) / ray.direction.z;
    
    // Checking for min max clamp.
    if(t < tMin || t > tMax) return false;
    
    float x = ray.origin.x + t * ray.direction.x;
    float y = ray.origin.y + t * ray.direction.y;
    
    // Checking if we are inside rect 2d bounds.
    if(x < rect.x0 || x > rect.x1 || y < rect.y0 || y > rect.y1) return false;
    
    return true;
}

// XZ plane intersection.
bool xzIntersect(Ray ray, xzRect rect, float tMin, float tMax, out float t)
{
    t = (rect.y - ray.origin.y) / ray.direction.y;
    
    // Checking for min max clamp.
    if(t < tMin || t > tMax) return false;
    
    float x = ray.origin.x + t * ray.direction.x;
    float z = ray.origin.z + t * ray.direction.z;
    
    // Checking if we are inside rect 2d bounds.
    if(x < rect.x0 || x > rect.x1 || z < rect.z0 || z > rect.z1) return false;
    
    return true;
}

// YZ plane intersection.
bool yzIntersect(Ray ray, yzRect rect, float tMin, float tMax, out float t)
{
    t = (rect.x - ray.origin.x) / ray.direction.x;
    
    // Checking for min max clamp.
    if(t < tMin || t > tMax) return false;
    
    float y = ray.origin.y + t * ray.direction.y;
    float z = ray.origin.z + t * ray.direction.z;
    
    // Checking if we are inside rect 2d bounds.
    if(y < rect.y0 || y > rect.y1 || z < rect.z0 || z > rect.z1) return false;
    
    return true;
}

///-- MAIN FUNCTIONS --------------------------------------------------------

// Ray tracing function.
bool hitScene(Ray ray, float tMin, float tMax,
              out vec3 position, out vec3 normal, out Material material, out Sphere sphere)
{
    // By default we assume that we are at max distance
    // and didn't hit anything.
    float closestSoFar = tMax;
    bool isHit = false;
    float t;
    
    // Green wall.
    xyRect xyrect = xyRect(-3., 3., -0.2, 4., 4., Material(LAMB, vec3(0.12, 0.45, 0.15), 0.0));
    if(xyIntersect(ray, xyrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
            isHit = true;
            vec3 p = getHitPoint(ray, t);
            position = p;
            normal = vec3(0, 0, -1);
            material = xyrect.mat;
        }
    }
    
    // Red wall.
    xyrect = xyRect(-3., 3., -0.2, 4., -4., Material(LAMB, vec3(0.65, 0.05, 0.05), 0.0));
    if(xyIntersect(ray, xyrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
            isHit = true;
            vec3 p = getHitPoint(ray, t);
            position = p;
            normal = vec3(0, 0, 1);
            material = xyrect.mat;
    	}
    }
    
    // Back wall.
    yzRect yzrect = yzRect(-0.2, 4.0, -4., 4., -3.0, Material(LAMB, vec3(0.73), 0.0));
    if(yzIntersect(ray, yzrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
            isHit = true;
            vec3 p = getHitPoint(ray, t);
            position = p;
            normal = vec3(1, 0, 0);
            material = yzrect.mat;
    	}
    }
    
    // Bottom wall.
    xzRect xzrect = xzRect(-3., 3., -4., 4., -0.2, Material(LAMB, vec3(0.73), 0.0));
    if(xzIntersect(ray, xzrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
            isHit = true;
            vec3 p = getHitPoint(ray, t);
            position = p;
            normal = vec3(0, 1, 0);
            material = xzrect.mat;
    	}
    }
    
    // Upper wall.
    xzrect = xzRect(-3., 3., -4., 4., 4.0, Material(LAMB, vec3(0.73), 0.0));
    if(xzIntersect(ray, xzrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
            isHit = true;
            vec3 p = getHitPoint(ray, t);
            position = p;
            normal = vec3(0, -1, 0);
            material = xzrect.mat;
        }
    }
    
    // Bottom metal panel.
    xzrect = xzRect(1.5, 2.5, 2.25, 3.25, -0.19, Material(METAL, vec3(0.83), 0.1));
    if(xzIntersect(ray, xzrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
        	isHit = true;
        	vec3 p = getHitPoint(ray, t);
            position = p;
        	normal = vec3(0, 1, 0);
        	material = xzrect.mat;
        }
    }
    
    // Right metal panel.
    xyrect = xyRect(1.0, 2.5, 0.5, 2.5, -3.99, Material(METAL, vec3(0.9), 0.0));
    if(xyIntersect(ray, xyrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
            isHit = true;
            vec3 p = getHitPoint(ray, t);
            position = p;
            normal = vec3(0, 0, 1);
            material = xyrect.mat;
    	}
    }
    
    // Upper light panel.
    xzrect = xzRect(-1.5, 1.5, -1.5, 1.5, 3.99, Material(EMISSIVE, vec3(1.0), 1.35));
    if(xzIntersect(ray, xzrect, tMin, tMax, t))
    {
        if (t > tMin && t < closestSoFar)
        {
            closestSoFar = t;
        	isHit = true;
        	vec3 p = getHitPoint(ray, t);
            position = p;
        	normal = vec3(0, -1, 0) + randomUnitVector();
        	material = xzrect.mat;
        }
    }
    
    // Intersection with spheres.
    // Looping through all, caching the closest 't' point.
    // which is a distance from ray origin and later used to get hit point.
    for (int i = 0; i < NUM_SPHERES; i++) 
    {
        Sphere sphere = scene[i];
        
        // Sphere intersection formula.
        vec3 oc = ray.origin - sphere.c;
        float a = dot(ray.direction, ray.direction);
        float b = dot(oc, ray.direction);
        float c = dot(oc, oc) - sphere.r * sphere.r;
        float discriminant = b * b - a * c;
        
        if (discriminant > 0.0001) 
        {
            // We only need the closer side of a sphere.
			float t = (-b - sqrt(discriminant)) / a;
            
            if (t < tMin) 
            {
                t = (-b + sqrt(discriminant)) / a;
            }
            
            // If we hit sphere, which is closest so far,
            // we set it to closest, and re-set output
            // materials and other stuff.
            if (t > tMin && t < closestSoFar) 
            {
                closestSoFar = t;
                isHit = true;
                
                vec3 p = getHitPoint(ray, t);
                position = p;
                normal = (p - sphere.c) / sphere.r;
                material = sphere.mat;
            }
        }
    }
        
    return isHit;
}

// Main tracing function.
vec3 trace(Ray ray) 
{
    vec3 normal, position;
    Material material;
    Sphere sphere;
    
    vec3 color = vec3(1.0);
    vec3 attenuation = vec3(1.0);
         
    // So for each bounce, we try to hit anything
    // on the scene (spheres only yet), and then we 
    // apply the material of that object to properly
    // color it. After all (when the bounce hit nothing)
    // we multiply the rest of attenuation by "sky" color.
    for (int b = 0; b < MAX_BOUNCES; b++) 
    {       
        if (hitScene(ray, 0.001, MAX_DISTANCE, position, normal, material, sphere)) 
        {
            // Lambertian material.
            if (material.type == LAMB) 
            {
                vec3 direction = normal + randomUnitVector();
                ray = Ray(position, direction);
                color *= material.albedo * attenuation;
                attenuation *= material.albedo;
            }
            
            // Metallic material.
            else if (material.type == METAL)
            {
                vec3 reflected = reflect(ray.direction, normal);
                vec3 direction = randomUnitVector() * material.v + reflected;
                
                if (dot(direction, normal) > 0.0) 
                {
               		ray = Ray(position, direction);
                	color *= material.albedo * attenuation;
               	 	attenuation *= material.albedo;
                }
            }
            
            // Dielectric material.
            else if (material.type == DIEL)
            {
                 vec3 outward_normal;
                 vec3 reflected = reflect(ray.direction, normal);
                 float ni_over_nt;

                 vec3 refracted;
                 
                 attenuation = vec3(1.0, 1.0, 1.0); 
                
                 float reflect_prob;
                 float cosine;

                 if (dot(ray.direction, normal) > 0.) 
                 {
                      outward_normal = -normal;
                      ni_over_nt = material.v;
                      cosine = dot(ray.direction, normal) / length(ray.direction);
                      cosine = sqrt(1. - material.v * material.v * (1. - cosine * cosine));
                 }
                
                 else 
                 {
                      outward_normal = normal;
                      ni_over_nt = 1.0 / material.v;
                      cosine = -dot(ray.direction, normal) / length(ray.direction);
                 }

                 refracted = refract(normalize(ray.direction), normalize(outward_normal), ni_over_nt);
                 if (length(refracted) > 0.0) 
                 {
                     reflect_prob = schlick(cosine, material.v);
                 }


                 else reflect_prob = 1.0;

                 if (random() < reflect_prob)
                    ray = Ray(position, reflected);

                 else ray = Ray(position, refracted);

                 color *= material.albedo * attenuation;
                 attenuation *= color;
            }
            
            // Emissive material. (WIP)
            // First version here: https://www.shadertoy.com/view/4sVcDh
            // This one is not fully correct, too.
            // But at least it works better for this scene.
            // While resetting ray to its origin, we don't
            // mix other colors onto emissive object surface.
            // But that doesn't seem to work in an open scene (link above)
            // without the walls, becuse we end up hitting nothing and go black.
            else if (material.type == EMISSIVE )
            {
                vec3 direction = normal + randomUnitVector();
                ray = Ray(ray.origin, ray.direction);
                color *= material.albedo * material.v;
               	attenuation *= color;
            }
            
            // We apply a simple checker pattern to a material.
            else if (material.type == CHECKER)
            {
               vec3 direction = normal + randomUnitVector();
               ray = Ray(position, direction);
               color *= CheckerTex(normal * material.v) * material.albedo;
               attenuation *= color; 
            }
            
            // We add a perlin noise texure to a material.
            else if (material.type == PERLIN)
            {
               vec3 direction = normal + randomUnitVector();
               ray = Ray(position, direction);
               color *= fbm(GetSphereUV(normal) * 25.) * material.v * material.albedo;
               attenuation *= color; 
            }
        }
        
        // At the end we mix with "sky" color which is an iChannel1.
        else 
        {
            vec3 skyColor = texture(iChannel1, -ray.direction).rgb;
            skyColor = pow(skyColor, vec3(GAMMA));
            color = attenuation * skyColor;
        }
    }
    
    return color;
}

///-------------------------------------------------------------------------

// Putting it all somewhere on the scene.
void SceneFill() 
{
    // Spheres.
    scene[0] = Sphere(vec3(-1.0, 1.0, 0.0), 1.0, Material(METAL, vec3(0.75, 0.75, 0.75), 0.05));
    scene[1] = Sphere(vec3(-0.75, 1.0, 3.0), 0.75, Material(EMISSIVE, vec3(0.0, 0.5, 1.4), 1.0));
    
    scene[2] = Sphere(vec3(-0.75, 1.0, -3.0), 0.75, Material(DIEL, vec3(0.9, 0.9, 0.3), 1.517));
    // Negative radius hack sphere inside main (DIEL) one for correct reflection.
    scene[3] = Sphere(vec3(-0.75, 1.0, -3.0), -0.74, Material(DIEL, vec3(0.9, 0.9, 0.3), 1.517));
    
    scene[4] = Sphere(vec3(0.35, 0.6, -1.8), 0.6, Material(CHECKER, vec3(1.8, 0.9, 0.0), 1.));
    scene[5] = Sphere(vec3(0.35, 0.6, 1.8), 0.6, Material(PERLIN, vec3(1.0, 0.0, 0.8), 1.)); 
    scene[6] = Sphere(vec3(2.0, 0.4, 2.75), 0.4, Material(CHECKER, vec3(0.0, 2.9, 1.3), 1.5));
    
    // Nice combo of Lambert + diel surface gives enamel fill.
    scene[7] = Sphere(vec3(2.0, 0.4, -2.75), 0.4, Material(LAMB, vec3(0.2, 0.0, 0.8), 0.15));
    scene[8] = Sphere(vec3(2.0, 0.4, -2.75), 0.401, Material(DIEL, vec3(1.0), 1.517));
    
    scene[9] = Sphere(vec3(2.0, 0.4, -0.916), 0.4, Material(LAMB, vec3(0.13, 0.9, 0.1), 0.));
    scene[10] = Sphere(vec3(2.0, 0.4, 0.916), 0.4, Material(METAL, vec3(0.83), 0.345)); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Initialization and seed.
    SceneFill();
    seed = iTime;

    // Basic normalization.
    UV = fragCoord / iResolution.xy;
    vec2 pixelSize = vec2(1.0) / iResolution.xy;
    
    float aspect = iResolution.x / iResolution.y;
    
    // Camera stuff taken from https://www.shadertoy.com/view/ldtSR2.
    const float fov = 80.0;
    float halfWidth = tan(radians(fov) * 0.5);
    float halfHeight = halfWidth / aspect;
    
    const float dist = 7.5;
    vec2 mousePos = iMouse.xy / iResolution.xy;  
    
    if (all(equal(mousePos, vec2(0.0)))) 
    {
        mousePos = vec2(0.63, 0.27); // Default position.
    }
    
    float x = cos(mousePos.x * 10.0) * dist;
    float z = sin(mousePos.x * 10.0) * dist;
    float y = mousePos.y * 10.0;
        
    vec3 origin = vec3(x, y, z);
    vec3 lookAt = vec3(0.0, 1.4, 0.0);
    vec3 upVector = vec3(0.0, 1.0, 0.0);
    
    vec3 w = normalize(origin - lookAt);
    vec3 u = cross(upVector, w);
    vec3 v = cross(w, u);
    
    vec3 lowerLeft = origin - halfWidth * u - halfHeight * v - w;
    vec3 horizontal = u * halfWidth * 2.0;
    vec3 vertical = v * halfHeight * 2.0;
    
    vec3 color = vec3(0.0);
    
    // We add random amount for a better AA. More samples - smoother.
    for (int s = 0; s < SAMPLES; s++) 
    {        
     	vec3 direction = lowerLeft - origin;
        direction += horizontal * (pixelSize.x * random() + UV.x);
        direction += vertical * (pixelSize.y * random() + UV.y);
        color += trace(Ray(origin, direction));
    }
    
    color /= float(SAMPLES);
       
    vec3 previousColor = texture(iChannel0, UV).rgb;
    
    float weight = min(float(iFrame + 1), float(MAX_WEIGHT));
    
    // Resetting weight on mouse change.
    if (!all(lessThanEqual(iMouse.zw, vec2(0.0)))) 
    {
        weight = 1.0;
    }
    
    vec3 newColor = mix(previousColor, color, 1.0 / weight);
    
    fragColor = vec4(newColor, 1.0);
}
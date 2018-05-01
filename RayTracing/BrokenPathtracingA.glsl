// XstBzM
// By Roman Smirnov
// License Creative Commons Attribution 4.0 International

#define RAND_PERIOD_SCALE 78.233
#define RAND_SEED_SCALE 3758.5453

#define PI 3.14159265359
#define PI_2 2.0 * PI
#define INV_PI 1.0 / PI
#define MAX_RAY_DISTANCE 999.9
#define EPSILON 0.00001

#define EDGE_SIZE 0.0025
#define BOUNCES 8
#define NO_SPEC_ORDER 3
#define ITERATIONS 6

#define CHECKER_FADE 0.5
#define DIELECTRIC_SPEC vec3(0.04,0.04,0.04)
#define MIN_ROUGHNESS 0.001

struct Ray
{
	vec3 pos;
	vec3 dir;
    int order;
    vec3 medium;
	float ior;
};

struct Camera
{
	vec3 pos;
	vec3 dir;
	
    vec3 orbitPoint;
    float orbitDist;
    
	float focusDist;
	float fstop;
	float focalLength;
	float sensorSize;
	
	float aspect;
};

#define MAT_COMMON 0
#define MAT_EMISSIVE 1
#define MAT_REFRACT 2
#define MAT_CHECKER 3
struct Material
{
	vec3 albedo;
	float roughness;
	vec3 specular;
	float ior;
	
	int type;
};

struct HitInfo
{
	float t;
	vec3 pos;
	vec3 normal;
	Material mat;
};

struct Sphere
{
	vec3 pos;
	float radius;
	
	Material mat;
};

struct Box
{
	vec3 pos;
	vec3 ext;
	
	Material mat;
};

#define SCENE_SPHERE_COUNT 12
Sphere sceneSpheres[SCENE_SPHERE_COUNT];
#define SCENE_BOX_COUNT 14
Box sceneBoxes[SCENE_BOX_COUNT];

Camera CreateScene()
{    
    Camera cam;
	cam.sensorSize = 0.024;
	cam.focalLength = 0.035;
	cam.fstop = 3.5;
	cam.focusDist = 7.0;
    
    cam.orbitPoint = vec3(0.0, 2.0, 0.0);
    cam.orbitDist = 4.3;
    
	sceneSpheres[0] = Sphere(vec3(0,0,0), 15.0, Material(vec3(10.0,13.0,16.0), 1.0, DIELECTRIC_SPEC, 1.0, MAT_EMISSIVE));
	sceneSpheres[1] = Sphere(vec3(3.0,0.8,-3.0), 0.8, Material(vec3(0.0,0.0,0.0), 0.3, vec3(1.0,0.7655,0.336), 1.0, MAT_COMMON));
	sceneSpheres[2] = Sphere(vec3(4,1.0,-4), 1.0, Material(vec3(0.99,0.01,0.01), 0.5, DIELECTRIC_SPEC, 1.0, MAT_COMMON));    
    sceneSpheres[3] = Sphere(vec3(1.5,1.0,1.0), 1.0, Material(vec3(0.8,0.99,0.95), 0.2, DIELECTRIC_SPEC, 1.33, MAT_REFRACT));    
	sceneSpheres[4] = Sphere(vec3(-4,0.5,1), 0.5, Material(vec3(70,15,6), 1.0, DIELECTRIC_SPEC, 1.0, MAT_EMISSIVE));	
    sceneSpheres[5] = Sphere(vec3(4,0.8,-2), 0.8, Material(vec3(0.9,0.3,0.7), 0.9, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
	sceneSpheres[6] = Sphere(vec3(4,0.7,0), 0.7, Material(vec3(0.99,0.1,0.01), 0.4, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
	sceneSpheres[7] = Sphere(vec3(-4,0.8,-1.4), 0.8, Material(vec3(0.1,0.99,0.01), 0.8, DIELECTRIC_SPEC, 1.0, MAT_COMMON));    
    sceneSpheres[8] = Sphere(vec3(-3.5,1,-3), 1.0, Material(vec3(0.1,0.1,1.0), 0.3, DIELECTRIC_SPEC, 1.2, MAT_REFRACT));	
    sceneSpheres[9] = Sphere(vec3(2.5,0.6,-4.2), 0.6, Material(vec3(0.0,0.0,0.0), 0.4, vec3(0.6724,0.6373,0.5855), 1.0, MAT_COMMON));
    sceneSpheres[10] = Sphere(vec3(-3.5,1,3), 1.0, Material(vec3(1.0,0.1,0.5), 0.5, DIELECTRIC_SPEC, 1.2, MAT_REFRACT));
    sceneSpheres[11] = Sphere(vec3(-1,0.7,-0.7), 0.7, Material(vec3(0,0,0), 0.5, vec3(1.0,0.7655,0.336), 1.0, MAT_COMMON));
	
	sceneBoxes[0] = Box(vec3(5.49,2.5,0), vec3(0.5,2.5,5), Material(vec3(0.8,0.9,0.1), 0.9, DIELECTRIC_SPEC, 1.0, MAT_CHECKER));
    sceneBoxes[1] = Box(vec3(-5.49,2.5,0), vec3(0.5,2.5,5), Material(vec3(0.9,0.1,0.4), 0.9, DIELECTRIC_SPEC, 1.0, MAT_CHECKER));
    sceneBoxes[2] = Box(vec3(0,2.5,5.5), vec3(5,2.5,0.5), Material(vec3(0.1,0.9,0.4), 0.4, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
    sceneBoxes[3] = Box(vec3(0,2.5,-5.5), vec3(5,2.5,0.5), Material(vec3(0.1,0.4,0.9), 0.4, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
    sceneBoxes[4] = Box(vec3(0,-0.49,0), vec3(5,0.5,5), Material(vec3(0.7,0.7,0.7), 0.3, DIELECTRIC_SPEC, 1.0, MAT_CHECKER));
    sceneBoxes[5] = Box(vec3(2.5,5.5,0), vec3(4.0,0.5,5), Material(vec3(0.8,0.8,0.8), 0.9, DIELECTRIC_SPEC, 1.0, MAT_COMMON));    
    sceneBoxes[6] = Box(vec3(4.5,2.5,0), vec3(0.2,0.2,2.2), Material(vec3(100,50,35), 1.0, DIELECTRIC_SPEC, 1.0, MAT_EMISSIVE));
    sceneBoxes[7] = Box(vec3(4.0,1.0,1.5), vec3(0.5,1.0,0.5), Material(vec3(1.0,0.2,0.01), 0.35, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
    sceneBoxes[8] = Box(vec3(3.0,2.0,3.5), vec3(0.5,2.0,0.5), Material(vec3(0.2,0.02,1.0), 0.6, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
    sceneBoxes[9] = Box(vec3(-4,2.0,4.8), vec3(0.2,1.0,0.2), Material(vec3(10,10,50), 1.0, DIELECTRIC_SPEC, 1.0, MAT_EMISSIVE));
    sceneBoxes[10] = Box(vec3(-3,2.0,-4.5), vec3(0.8,2.0,0.3), Material(vec3(0,0,0), 0.35, vec3(0.913, 0.921, 0.925), 1.0, MAT_COMMON));
	sceneBoxes[11] = Box(vec3(0,0.7,-4), vec3(0.8,0.7,0.5), Material(vec3(0,0,0), 0.5, vec3(0.955, 0.637, 0.538), 1.0, MAT_COMMON));	
    sceneBoxes[12] = Box(vec3(-1.3,2.5,-1.5), vec3(0.1,2.5,0.1), Material(vec3(0.5,1.0,0.2), 0.7, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
    sceneBoxes[13] = Box(vec3(-1.3,2.5,1.5), vec3(0.1,2.5,0.1), Material(vec3(1.0,0.6,0.2), 0.7, DIELECTRIC_SPEC, 1.0, MAT_COMMON));
    
    return cam;
}

float seed = 0.0;

vec2 fragUV = vec2(0.0);
vec2 pixelSize = vec2(0.0);

float Rand() 
{
	float r = fract(sin(seed) * RAND_SEED_SCALE);
	seed += 43758.5453;
    return r;    
}

// wrong, fixed version in: https://www.shadertoy.com/view/4scfz4 
vec3 RandDirectionSize(vec3 normal, float size) 
{
	float theta = Rand() * PI_2;
    float cosT = Rand() * 2.0 - 1.0;
    float sinT = sqrt(1.0 - cosT * cosT);
    vec3 randomUnitVector = vec3(sinT * cos(theta), sinT * sin(theta), cosT) * sqrt(Rand());
    return normalize(normal + randomUnitVector * size);
}

vec3 RandDirection(vec3 normal) 
{
    return RandDirectionSize(normal, 1.0 - EPSILON);
}
    
vec3 PointFromRay(Ray r, float t)
{
	return r.pos + t * r.dir;
}

vec3 GetSensorPoint(Camera cam, vec2 uv)
{        
	vec2 wh = vec2(cam.sensorSize * cam.aspect, cam.sensorSize);
	float z = 1.0 / ((1.0 / cam.focalLength) - (1.0 / cam.focusDist));
	vec2 xy = (uv - vec2(0.5, 0.5)) * wh;
        
	return vec3(-xy.x, xy.y, z);	
}

vec3 GetAperturePoint(Camera cam)
{
	float d = cam.focalLength / cam.fstop;
	float theta = 2.0 * PI * Rand();
	float r = sqrt(Rand()) * d * 0.5;
	return vec3(r * cos(theta), r * sin(theta), 0.0);
}

Ray GetRayFromCamera(Camera cam)
{
    const vec3 up = vec3(0,1,0);
    
    vec3 dirF = normalize(cam.dir);
    vec3 dirT = -normalize(cross(dirF, up));
    vec3 dirU = normalize(cross(dirF, dirT));
	
	vec2 jitteredUV = fragUV.xy + vec2(EDGE_SIZE, cam.aspect * EDGE_SIZE) * 2.0 * vec2(Rand() - 0.5, Rand() - 0.5);
	
	vec3 sensor = GetSensorPoint(cam, jitteredUV);	
	vec3 focalPoint = normalize(sensor) * cam.focusDist;
	
	vec3 lensPoint = GetAperturePoint(cam);
	vec3 refractLocalRay = normalize(focalPoint - lensPoint);
	
	vec3 rayPos = cam.pos + (dirT * lensPoint.x + dirU * lensPoint.y + dirF * lensPoint.z);
	vec3 rayDir = normalize(dirT * refractLocalRay.x + dirU * refractLocalRay.y + dirF * refractLocalRay.z);
	
    return Ray(rayPos, rayDir, 0, vec3(1,1,1), 1.0);
}

bool RayBoxIntersection(Ray r, Box b, out HitInfo hitInfo)
{
	vec3 invdir = 1.0 / (r.dir * MAX_RAY_DISTANCE);
    vec3 minC = b.pos - b.ext;
    vec3 maxC = b.pos + b.ext;
	
	vec3 p0Int = (minC - r.pos) * invdir;
	vec3 p1Int = (maxC - r.pos) * invdir;
	
	vec3 closest = min(p0Int, p1Int);
	vec3 furthest = max(p0Int, p1Int);

	float minT = max(closest.x, max(closest.y, closest.z));
	float maxT = min(furthest.x, min(furthest.y, furthest.z));
		
    if (maxT < 0.0 || minT > maxT)
    {
        return false;
    }
    
	hitInfo.t = minT * MAX_RAY_DISTANCE;
	hitInfo.pos = PointFromRay(r, hitInfo.t);
	hitInfo.mat = b.mat;
    
    if(minT == p0Int.x)
        hitInfo.normal = vec3(-1,0,0);     
    else if(minT == p1Int.x)
        hitInfo.normal = vec3(1,0,0);
    else if(minT == p0Int.y)
        hitInfo.normal = vec3(0,-1,0);
    else if(minT == p1Int.y)
        hitInfo.normal = vec3(0,1,0);
    else if(minT == p0Int.z)
        hitInfo.normal = vec3(0,0,-1);
    else// if(minT == p1Int.z)
        hitInfo.normal = vec3(0,0,1);        
        
	return true;
}

bool RaySphereIntersection(Ray r, Sphere s, out HitInfo hitInfo)
{
	vec3 k = r.pos - s.pos;
    float b = dot(k, r.dir);
	float c = dot(k, k) - s.radius * s.radius;
	float d = b * b - c;
	 
	if(d < 0.0)
	{
		return false;
	}
		
	float sqrtfd = sqrt(d);

	float t1 = -b + sqrtfd;
	float t2 = -b - sqrtfd;

	float minT = min(t1,t2);
	float maxT = max(t1,t2);

	float t = (minT >= 0.0) ? minT : maxT;

	hitInfo.t = t;
	hitInfo.pos = PointFromRay(r, t);
	hitInfo.normal = (c < 0.0 ? -1.0 : 1.0) * normalize(hitInfo.pos - s.pos);
	hitInfo.mat = s.mat;
	
	return (t > 0.0);
}

bool RayTraceScene(Ray ray, out HitInfo hitInfo)
{
    hitInfo.t = MAX_RAY_DISTANCE;
	
	bool isHit = false;
	for (int i = 0; i < SCENE_SPHERE_COUNT; i++) 
    {
		HitInfo tempInfo;
		if(RaySphereIntersection(ray, sceneSpheres[i], tempInfo))
		{
			if(hitInfo.t > tempInfo.t)
			{
				isHit = true;
				hitInfo = tempInfo;
			}
		}
	}
	
	for (int i = 0; i < SCENE_BOX_COUNT; i++) 
    {
		HitInfo tempInfo;
		if(RayBoxIntersection(ray, sceneBoxes[i], tempInfo))
		{
			if(hitInfo.t > tempInfo.t)
			{
				isHit = true;
				hitInfo = tempInfo;
			}
		}
	}
	
	return isHit;
}

float FSchlickDiffuse(float F90, float NoX )
{ 
	return 1.0 + ( F90 - 1.0 ) * pow(1.0 - NoX, 5.0);
}

vec3 DiffuseBurley( vec3 albedo, float roughness, float NoV, float NoL, float VoH )
{
	float energyBias = mix(0.0, 0.5, roughness );
	float energyFactor = mix(1.0, 1.0 / 1.51, roughness );
	float FD90 = energyBias + 2.0 * VoH * VoH * roughness;
	float FdV = FSchlickDiffuse(FD90, NoV);
	float FdL = FSchlickDiffuse(FD90, NoL);
	return albedo * FdV * FdL * energyFactor * INV_PI;
}

vec3 FSchlick(vec3 specular, float VoH)
{ 
	return specular + ( vec3(1,1,1) - specular ) * pow(1.0 - VoH, 5.0);
}

float D_GGX( float roughness, float NoH )
{
	float a = roughness * roughness;
    float denomn = ( NoH * a * a - NoH ) * NoH + 1.0;
    if(denomn < EPSILON)
    {
        return 1.0;
    }
	float d = a / denomn;
	return INV_PI * d * d;		
}

float G_GGX(float roughness, float NoX)
{
	float a = roughness * roughness;
	float NoXsqr = NoX * NoX;
	float G = 2.0 / (1.0 + sqrt(1.0 + a * a * (1.0 - NoXsqr) / NoXsqr));
	return G;
}
float GG_GGX(float NoL, float NoV, float roughness)
{
	return G_GGX(roughness, NoV) * G_GGX(roughness, NoL);
}

float IORtoR0( float IOR )
{
	float R0 = (IOR - 1.0) / (IOR + 1.0);
	R0 *= R0;
	return R0;
}

vec3 BRDF(Material mat, vec3 normal, vec3 view, vec3 lightDir)
{
	vec3 H = normalize(view + lightDir);
	float NoV = clamp(dot(normal, view), EPSILON, 1.0);
	float NoL = clamp(dot(normal, lightDir), EPSILON, 1.0);
	float VoH = clamp(dot(view, H), EPSILON, 1.0);
	float NoH = clamp(dot(normal, H), EPSILON, 1.0);
	
    float clampedRoughness = max(mat.roughness, MIN_ROUGHNESS);
    vec3 specular = mat.specular;
    if(mat.type == MAT_REFRACT)
    {
        specular = vec3(IORtoR0(mat.ior));
    }
    
	return D_GGX(clampedRoughness, NoH) * GG_GGX(NoL, NoV, clampedRoughness) * FSchlick(specular, VoH);
}

vec3 Diffuse(Material mat, vec3 normal, vec3 view, vec3 lightDir, vec3 wpos)
{
	vec3 H = normalize(view + lightDir);
	float NoV = clamp(dot(normal, view), EPSILON, 1.0);
	float NoL = clamp(dot(normal, lightDir), EPSILON, 1.0);
	float VoH = clamp(dot(view, H), EPSILON, 1.0);
	
    vec3 albedo = mat.albedo;
    if(mat.type == MAT_CHECKER)
    {
        vec3 sq = floor(wpos.xyz) * 0.5;
        if(fract(sq.x + sq.y + sq.z) < 0.1)
        {
        	albedo *= CHECKER_FADE; 
        }
    }
    
	return DiffuseBurley(albedo, max(mat.roughness, MIN_ROUGHNESS), NoV, NoL, VoH);
}

bool IsPureSpec(Material mat)
{
	return (mat.albedo.x + mat.albedo.y + mat.albedo.z == 0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    seed = sin(iTime * RAND_PERIOD_SCALE);
    
    fragUV = fragCoord / iResolution.xy;
	pixelSize = vec2(1.0, 1.0) / iResolution.xy;
	
    Camera cam = CreateScene();	
	cam.aspect = float(iResolution.x) / float(iResolution.y);
    
   	// input                
    if(iMouse.x != 0.0 || iMouse.y != 0.0)
    {
		float xIn = 2.0 * PI * (iMouse.x / iResolution.x);
     	float yIn = -PI * (iMouse.y / iResolution.y - 0.5);
        xIn *= 2.0;
        
        vec3 tempDir = vec3(sin(xIn), sin(yIn), cos(xIn));
        cam.pos = tempDir * cam.orbitDist + cam.orbitPoint;
        cam.dir = -tempDir;
    }
    else
    {
		cam.pos = cam.orbitPoint - vec3(cam.orbitDist, 0, 0);
		cam.dir = vec3(1, 0, 0);
    }
    
	vec3 currentFrame = vec3(0,0,0);
    for(int k = 0; k < ITERATIONS; k++)
	{
		vec3 colorAcc = vec3(0,0,0);
		vec3 falloffAcc = vec3(1,1,1);
        
		Ray currentRay = GetRayFromCamera(cam);
        
        for(int i = 0; i < BOUNCES; i++)
        {		
            HitInfo hitInfo;
            bool isHit = RayTraceScene(currentRay, hitInfo);
			if(!isHit)
			{
				break;
			}
			
			// Beer-Lambert law
			falloffAcc *= exp(-hitInfo.t * (vec3(1,1,1) - currentRay.medium));
			
            if(hitInfo.mat.type == MAT_EMISSIVE)
            {
                colorAcc = hitInfo.mat.albedo * falloffAcc;
                break;
            }
            else
            {
                vec3 view = -currentRay.dir;

                vec3 randDir;
                if( IsPureSpec(hitInfo.mat) || (Rand() < 0.5 && currentRay.order < NO_SPEC_ORDER) )
                {
                    vec3 reflected = reflect(currentRay.dir, hitInfo.normal);
					
					// Hack for mirror surfaces
                    if(hitInfo.mat.roughness == 0.0) 
					{
                    	randDir = reflected;
					}
                    else
					{
                    	randDir = RandDirection(reflected);
					}

                    if(dot(randDir, hitInfo.normal) < 0.0)
                    {
                        continue;
                    }

                    currentRay = Ray(hitInfo.pos + randDir * EPSILON, randDir, currentRay.order + 1, currentRay.medium, currentRay.ior);
                    falloffAcc *= BRDF(hitInfo.mat, hitInfo.normal, view, currentRay.dir);
                }
                else
                {
					if(hitInfo.mat.type == MAT_REFRACT)
					{										
						float NoV = dot(hitInfo.normal, view);
						vec3 nextMedium = hitInfo.mat.albedo;						
						float nextIor = hitInfo.mat.ior;					
						float iorRatio = 1.0 / hitInfo.mat.ior;
						if(currentRay.ior != 1.0)
						{
							if(currentRay.ior == iorRatio)
							{
								iorRatio = 1.0 / currentRay.ior;
								nextMedium = vec3(1,1,1);
								nextIor = 1.0;
							}
							else
							{
								iorRatio = hitInfo.mat.ior / currentRay.ior;
							}							
						}
										
						float refractCos = 1.0 - iorRatio * iorRatio * ( 1.0 - NoV * NoV );
						
						if(refractCos < 0.0)
						{
							// Total internal reflection
							vec3 refractDir = reflect(currentRay.dir, hitInfo.normal);
							vec3 randRefractDir = RandDirection(refractDir);
							
							if(dot(randRefractDir, hitInfo.normal) < 0.0)
							{
								continue;
							}
                            
							currentRay = Ray(hitInfo.pos + randRefractDir * EPSILON, randRefractDir, currentRay.order + 1, currentRay.medium, currentRay.ior);
						}
						else
						{
                            refractCos = sqrt(refractCos);
                            
							vec3 refractDir = iorRatio * (-view) + ( iorRatio * NoV - refractCos ) * hitInfo.normal;
							vec3 randRefractDir = RandDirectionSize(refractDir, hitInfo.mat.roughness * hitInfo.mat.roughness);
							
							if(dot(randRefractDir, hitInfo.normal) >= 0.0)
							{
								continue;
							}
							
							currentRay = Ray(hitInfo.pos + randRefractDir * EPSILON, randRefractDir, currentRay.order + 1, nextMedium, nextIor);
						}
					}
					else
					{
						randDir = RandDirection(hitInfo.normal);

						currentRay = Ray(hitInfo.pos + randDir * EPSILON, randDir, currentRay.order + 1, currentRay.medium, currentRay.ior);
						falloffAcc *= Diffuse(hitInfo.mat, hitInfo.normal, view, currentRay.dir, hitInfo.pos);
					}					
                }			
            }		
        }
        
        currentFrame += colorAcc;
    }
    currentFrame = currentFrame / vec3(ITERATIONS, ITERATIONS, ITERATIONS);
		
    vec3 prevFrame = texture(iChannel0, fragUV).rgb;        
    int lastFrame = int(texture(iChannel1, fragUV).r);
    
    float blendFactor = 1.0 / float(iFrame - lastFrame + 1);
    if(iMouse.z > 0.0) 
    {        
        blendFactor = 1.0;
    }
    
    currentFrame = mix(prevFrame, currentFrame, blendFactor);
    
    fragColor = vec4(currentFrame, 1);
}
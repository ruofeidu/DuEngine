
const float infinity = 10000.0f;
const vec3 backgroundColor = vec3(0, 0, 0.1);

const float camNearPlane = 0.2f;
const float camScreenDimension = 0.1f;
const float camDist = 10.0f;
const float camMaxHeight = 7.0f;
const float camMinHeight = 0.0f;
const float camHeightSpeed = 1.5f;
const float camSpeed = 1.0f;

const float specularAngle = 0.5f; // Smaller is bigger specular
const float specularExp = 10.0f;

const float ambientLight = 0.2f;

// OBJ to raytrace
#define SPHERE_COUNT 		6
#define PLANE_COUNT 		3
#define TOTAL_OBJ_COUNT 	SPHERE_COUNT + PLANE_COUNT

// Lights
#define LIGHT_COUNT 		3

struct 	SCamera
{
    vec3 	m_Position;
    vec3 	m_Side;
    vec3 	m_Forward;
    vec3 	m_Up;
};
    
struct 	SSphere
{
    vec3 	m_Position;
    float 	m_Radius;
    float 	m_UvScale;
    float 	m_Reflection;
    int 	m_TextureId;
};

struct SPlane
{
    vec3 	m_Position;
    vec3 	m_Normal;
    vec3 	m_Tangent;
    float 	m_UvScale;
    float 	m_Reflection;
    int 	m_TextureId;
};
    
struct 	SLight
{
    vec3 	m_Position;
    vec3 	m_Color;
	float 	m_Intensity;
	float 	m_Range;
};

struct 	SRayHit
{
    float 	m_Distance;
	vec3 	m_Position;
    vec3 	m_Normal;
    vec2 	m_Uv;
    int 	m_TextureId;
    float 	m_Reflection;
};
    
struct 	SScene
{
    SCamera 	m_Camera;
    SSphere	 	m_Spheres[SPHERE_COUNT];
    SPlane 		m_Planes[PLANE_COUNT];
    
    SLight 		m_Lights[LIGHT_COUNT];
    
    SRayHit		m_Hits[TOTAL_OBJ_COUNT];
};
    
SCamera	buildLookAt(vec3 position, vec3 toLookAt, vec3 up)
{
    SCamera	cam;
        
    cam.m_Position = position;
    cam.m_Forward = normalize(toLookAt - position);
    cam.m_Side = normalize(cross(up, cam.m_Forward));
    cam.m_Up = cross(cam.m_Forward, cam.m_Side);
    return cam;
}

SScene 	createScene()
{
    SScene 	scene;
    
	float camHeight = (cos(iTime * camHeightSpeed) * 0.5 + 0.5) * (camMaxHeight - camMinHeight) + camMinHeight;
    vec3 camPos = vec3(cos(iTime * camSpeed) * camDist, camHeight, sin(iTime * camSpeed) * camDist);

    scene.m_Camera = buildLookAt(camPos, vec3(0, 0, 0), vec3(0, 1, 0));
    for (int i = 0; i < SPHERE_COUNT; ++i)
    {            
        scene.m_Spheres[i].m_Position = vec3((i -SPHERE_COUNT / 2) * 2, cos(iTime * 2.0f + float(i)) * 2.0f + 2.0f, 0);
        scene.m_Spheres[i].m_Radius = 0.8f;
        scene.m_Spheres[i].m_UvScale = 1.0f;
        scene.m_Spheres[i].m_TextureId = 1;
        scene.m_Spheres[i].m_Reflection = float(i) / float(SPHERE_COUNT - 1);
    }

    for (int i = 0; i < PLANE_COUNT; ++i)
    {
        if (i == 0)
        {
			scene.m_Planes[i].m_Position = vec3(0, -1, 0);
        	scene.m_Planes[i].m_Normal = vec3(0, 1, 0);
        	scene.m_Planes[i].m_Tangent = vec3(0, 0, 1);
	        scene.m_Planes[i].m_TextureId = 0;
    	    scene.m_Planes[i].m_Reflection = 0.0f;
        }
        else if (i == 1)
        {
			scene.m_Planes[i].m_Position = vec3(0, 0, -10);
        	scene.m_Planes[i].m_Normal = vec3(0, 0, 1);
        	scene.m_Planes[i].m_Tangent = vec3(0, 1, 0);
	        scene.m_Planes[i].m_TextureId = 2;
    	    scene.m_Planes[i].m_Reflection = 0.3f;
        }
        else if (i == 2)
        {
			scene.m_Planes[i].m_Position = vec3(15, 0, 0);
        	scene.m_Planes[i].m_Normal = vec3(-1, 0, 0);
        	scene.m_Planes[i].m_Tangent = vec3(0, 1, 0);
	        scene.m_Planes[i].m_TextureId = 2;
    	    scene.m_Planes[i].m_Reflection = 0.3f;
        }
        scene.m_Planes[i].m_UvScale = 0.2f;
    }

    for (int i = 0; i < LIGHT_COUNT; ++i)
    {
        scene.m_Lights[i].m_Position = vec3((i - LIGHT_COUNT / 2) * 5, 7.0f, 0);
        scene.m_Lights[i].m_Color = vec3(1, 1, 1);
        scene.m_Lights[i].m_Intensity = 0.8f;
        scene.m_Lights[i].m_Range = 50.0f;
    }
    return scene;
}

float 	remap(float value, float curMin, float curMax, float newMin, float newMax)
{
	return newMin + (value - curMin) * (newMax - newMin) / (curMax - curMin);
}

vec3 	uvToWorldSpace(SCamera cam, vec2 uv, float nearDist, float aspectRatio, float verticalOpening)
{
    // Now we convert this in world space
    vec3 nearPlaneCenter = cam.m_Position + (cam.m_Forward * nearDist);
	vec3 worldSpaceUv = nearPlaneCenter +
        				(uv.x * cam.m_Side * aspectRatio * verticalOpening) +
        				(uv.y * cam.m_Up * verticalOpening);
	return worldSpaceUv;
}

SRayHit 	hitPlane(SPlane plane, vec3 rayOrigin, vec3 rayDirection)
{
    SRayHit 	hit;
    
    float denom = dot(plane.m_Normal, rayDirection);
    float solution = dot(plane.m_Position - rayOrigin, plane.m_Normal) / denom;
    vec3 planeBiTan = cross(plane.m_Normal, plane.m_Tangent);
    
	hit.m_Distance = solution < 0.0f ? infinity : solution;
    
    if (hit.m_Distance != infinity)
    {
   	 	hit.m_Position = rayOrigin + solution * rayDirection;
   	 	hit.m_Normal = plane.m_Normal;

    	vec3 originToIntersect = hit.m_Position - plane.m_Position;

    	hit.m_Uv = vec2(dot(plane.m_Tangent, originToIntersect), dot(planeBiTan, originToIntersect));
    	hit.m_Uv *= plane.m_UvScale;
    	hit.m_Uv.x = abs(hit.m_Uv.x) > 1.0f ? fract(hit.m_Uv.x) : hit.m_Uv.x;
    	hit.m_Uv.y = abs(hit.m_Uv.y) > 1.0f ? fract(hit.m_Uv.y) : hit.m_Uv.y;
    	hit.m_TextureId = plane.m_TextureId;
		hit.m_Reflection = plane.m_Reflection;
    }        
    return hit;
}

SRayHit 	hitSphere(SSphere sphere, vec3 rayOrigin, vec3 rayDirection)
{
    SRayHit 	hit;

    // To sphere space ray origin
    rayOrigin -= sphere.m_Position;

    vec3 	squareDir = rayDirection * rayDirection;
	vec3 	squareOri = rayOrigin * rayOrigin;
	float 	squareRadius = sphere.m_Radius * sphere.m_Radius;
    
    float 	a = dot(rayDirection, rayDirection);
    float 	b = 2.0f * rayOrigin.x * rayDirection.x + 
      	  		2.0f * rayOrigin.y * rayDirection.y + 
       			2.0f * rayOrigin.z * rayDirection.z;
    float 	c = dot(rayOrigin, rayOrigin) - squareRadius;
        
    float delta = b * b - 4.0f * a * c;

    // To World space ray origin
	rayOrigin += sphere.m_Position;
    
    if (delta >= 0.0f)
    {
        float deltaSqrt = delta == 0.0f ? 0.0f : sqrt(delta);
        
	    float solution1 = (-b + deltaSqrt) / (2.0f * a);
    	float solution2 = (-b - deltaSqrt) / (2.0f * a);
        
        float closest = min(solution1, solution2);
        
        hit.m_Distance = closest < 0.0f ? infinity : closest;

        if (hit.m_Distance != infinity)
    	{
        	hit.m_Position = rayOrigin + rayDirection * closest;
        	hit.m_Normal = normalize(hit.m_Position - sphere.m_Position);

        	float dotNormX = (dot(hit.m_Normal, vec3(1, 0, 0))) * 0.5 + 0.5f; // between 0 and 0.5
        	float dotNormY = (dot(hit.m_Normal, vec3(0, 1, 0))) * 0.5f + 0.5f; // between 0 and 0.5
        	float dotNormZ = dot(hit.m_Normal, vec3(0, 0, 1));
        
        	hit.m_Uv.x = dotNormX;
        	hit.m_Uv.y = dotNormY;
			hit.m_TextureId = sphere.m_TextureId;
			hit.m_Reflection = sphere.m_Reflection;
        }
        return hit;
    }
    hit.m_Distance = infinity;
    return hit;
}

void computePointLight(SLight light, vec3 surfPos, vec3 surfNormal,
                        vec3 camPos, vec3 rayDirection, out vec3 diffuse, out float spec)
{
    vec3 surfToLight = light.m_Position - surfPos;
    float squareDist = dot(surfToLight, surfToLight) / light.m_Range + 1.0f;

    float diffuseIntensity = max(0.0f, dot(normalize(surfToLight), surfNormal));
    diffuseIntensity = diffuseIntensity * light.m_Intensity / squareDist;

    diffuse += light.m_Color * diffuseIntensity;
    
    vec3 reflectedRay = reflect(rayDirection, surfNormal);
    float collinearity = dot(normalize(surfToLight), normalize(reflectedRay));

    float 	specIntensity = remap(max(specularAngle, collinearity), specularAngle, 1.0f, 0.0f, 1.0f);
    specIntensity = pow(specIntensity, specularExp);
    specIntensity = specIntensity * light.m_Intensity / squareDist;

    spec += specIntensity;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    SScene scene = createScene();
    
    float  aspectRatio = iResolution.x / iResolution.y;
    
    // Normalized pixel coordinates (from -1 to 1)
    vec2 screenUv = (fragCoord / iResolution.xy) * 2.0f - 1.0f;
    
	vec3 worldSpaceUv = uvToWorldSpace(scene.m_Camera, screenUv, camNearPlane, aspectRatio, camScreenDimension);

    vec3 rayOrigin = worldSpaceUv;
    vec3 rayDirection = worldSpaceUv - scene.m_Camera.m_Position;

	SRayHit closestHit;

    // We start with a distance != infinity
    closestHit.m_Distance = 0.0f;

    float	colorToCreate = 1.0f; // At the begining we need to create 100% of the color
    vec3 	accumColor = vec3(0.0f);
    

    for (int rayi = 0; rayi < 4 && closestHit.m_Distance != infinity && colorToCreate > 0.0f; ++rayi)
    {
        // First we intersect all the scene objects
        int obji = 0;
        
        for (int spherei = 0; spherei < SPHERE_COUNT; ++spherei)
        {    
    		scene.m_Hits[obji] = hitSphere(scene.m_Spheres[spherei], rayOrigin, rayDirection);
            ++obji;
        }
        for (int planei = 0; planei < PLANE_COUNT; ++planei)
        {    
    		scene.m_Hits[obji] = hitPlane(scene.m_Planes[planei], rayOrigin, rayDirection);
            ++obji;
        }

        // Then we gather the "best" result (closest object we hit)
        closestHit.m_Distance = infinity;
        
        for (int hiti = 0; hiti < TOTAL_OBJ_COUNT; ++hiti)
        {    
            if (scene.m_Hits[hiti].m_Distance < closestHit.m_Distance)
            {
                closestHit = scene.m_Hits[hiti];
            }
        }
        
        // If we find that there was a hit, then we compute the color for this fragment
		if (closestHit.m_Distance != infinity)
        {
            vec3 	objectColor;
            
            // First we sample the diffuse texture for this obj
            if (closestHit.m_TextureId == 0)
            {
        		objectColor = texture(iChannel0, closestHit.m_Uv).rgb;
            }
            else if (closestHit.m_TextureId == 1)
            {
        		objectColor = texture(iChannel1, closestHit.m_Uv).rgb;
            }
            else
            {
        		objectColor = texture(iChannel2, closestHit.m_Uv).rgb;
            }
            
            // Then we compute the light influence on this object
			vec3 	diffuse = vec3(0.0f);
            float 	spec = 0.0f;

            for (int lighti = 0; lighti < LIGHT_COUNT; ++lighti)
            {
				computePointLight(scene.m_Lights[lighti],
 								closestHit.m_Position, closestHit.m_Normal,
            	            	rayOrigin, rayDirection,
                	      		diffuse, spec);
            }

            // We compute what is left of the color to compute
            float 	nextColorToCreate = colorToCreate * closestHit.m_Reflection;

            // We then compute how much the current surface absorbs
			float 	colorContrib = colorToCreate - nextColorToCreate; 
            
            colorToCreate = nextColorToCreate;
            
            // Then we compute the final color and accumulate it
		    accumColor += colorContrib * ((diffuse + ambientLight) * objectColor + spec);

            rayOrigin = closestHit.m_Position + closestHit.m_Normal * 0.001f;;
    	    rayDirection = reflect(rayDirection, closestHit.m_Normal);
        }
        else
        {
            vec3 	envColor = texture(iChannel3, normalize(rayDirection)).rgb;
            
	        accumColor += colorToCreate * envColor;
            colorToCreate = 0.0f;
        }
    }

    // Output to screen
	fragColor = vec4(accumColor, 1);
}
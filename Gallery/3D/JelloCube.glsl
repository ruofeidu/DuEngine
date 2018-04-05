// 
#define FLT_MAX 3.402823466e+38

const vec3 c_absorb = vec3(0.3,1.8,1.8);
const float c_refraction = 0.99;
const vec3 c_reflect = vec3(0.0);

vec3 c_lightDirection = normalize(vec3(1.0,-2.0,-1.0));
const vec3 c_lightColorDiffuse = vec3(0.3);
const vec3 c_lightColorSpecular = vec3(0.3);

//=======================================================================================
vec3 NormalAtPos (vec3 pos)
{
    vec3 normal = pos - vec3(0.5);
    vec3 absNormal = abs(normal);
    if (absNormal.x > absNormal.y)
    {
        if (absNormal.x > absNormal.z)
        {
            normal.x = sign(normal.x);
            normal.y = 0.0;
            normal.z = 0.0;
        }
        else
        {
            normal.x = 0.0;
            normal.y = 0.0;
            normal.z = sign(normal.z);            
        }
    }
    else
    {
        if (absNormal.y > absNormal.z)
        {
            normal.x = 0.0;
            normal.y = sign(normal.y);
            normal.z = 0.0;
        }
        else
        {
            normal.x = 0.0;
            normal.y = 0.0;
            normal.z = sign(normal.z);            
        }
    }
    return normal;
}

//=======================================================================================
bool RayIntersectAABox (vec3 boxMin, vec3 boxMax, in vec3 rayPos, in vec3 rayDir, out vec2 time)
{
	vec3 roo = rayPos - (boxMin+boxMax)*0.5;
    vec3 rad = (boxMax - boxMin)*0.5;

    vec3 m = 1.0/rayDir;
    vec3 n = m*roo;
    vec3 k = abs(m)*rad;
	
    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

    time = vec2( max( max( t1.x, t1.y ), t1.z ),
                 min( min( t2.x, t2.y ), t2.z ) );
	
    return time.y>time.x && time.y>0.0;
}

//=======================================================================================
vec3 HandleRay (in vec3 rayPos, in vec3 rayDir, in vec3 pixelColor, out float hitTime)
{
	float time = 0.0;
	float lastHeight = 0.0;
	float lastY = 0.0;
	float height;
	bool hitFound = false;
    hitTime = FLT_MAX;
    bool fromUnderneath = false;
    
    vec2 timeMinMax = vec2(0.0);
    if (!RayIntersectAABox(vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0), rayPos, rayDir, timeMinMax))
        return pixelColor;
    
    // calculate surface normal
    vec3 frontCollisionPos = rayPos + rayDir * timeMinMax.x;
    vec3 frontNormal = NormalAtPos(frontCollisionPos);
    vec3 frontRefractedRayDir = refract(rayDir, frontNormal, c_refraction / 1.0);
    
    // shouldn't ever miss!!
    vec2 refractTimeMinMax = vec2(0.0);
    if (!RayIntersectAABox(vec3(0.0,0.0,0.0), vec3(1.0,1.0,1.0), frontCollisionPos, frontRefractedRayDir, refractTimeMinMax))
        return vec3(0.0,1.0,0.0);
    
    vec3 backCollisionPos = frontCollisionPos + frontRefractedRayDir * refractTimeMinMax.y;
    vec3 backNormal = -NormalAtPos(backCollisionPos);
    
    // refraction
    vec3 refractRayDir = refract(frontRefractedRayDir, backNormal, 1.0 / c_refraction);
    pixelColor = texture(iChannel0, refractRayDir).rgb;
    
    // reflection
    vec3 reflectColor = texture(iChannel0, reflect(rayDir, frontNormal)).rgb * c_reflect;
    
    // calculate and apply absorption
    vec3 absorb = exp(-c_absorb * (refractTimeMinMax.y - refractTimeMinMax.x));    
    pixelColor *= absorb;
    
    // diffuse
    float diffuseColorDP = clamp(dot(-c_lightDirection, frontNormal), 0.0, 1.0);
    vec3 diffuseColor = c_lightColorDiffuse * diffuseColorDP;
    
    // specular
    vec3 specularColorDir = reflect(-c_lightDirection, frontNormal);
    float specularColorDP = clamp(dot(specularColorDir, rayDir), 0.0, 1.0);
    vec3 specularColor = c_lightColorSpecular * specularColorDP;
    
    
    // return the color we calculated
	return pixelColor + diffuseColor + specularColor + reflectColor;
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{       
    //----- camera
    vec2 mouse = iMouse.xy / iResolution.xy;

    vec3 cameraAt 	= vec3(0.5,0.5,0.5);

    float angleX = iMouse.z > 0.0 ? 6.28 * mouse.x : 3.14 + iTime * 0.25;
    float angleY = iMouse.z > 0.0 ? (mouse.y * 6.28) - 0.4 : 0.5;
    vec3 cameraPos	= (vec3(sin(angleX)*cos(angleY), sin(angleY), cos(angleX)*cos(angleY))) * (2.0 + 2.0 * (sin(iTime)*0.5+0.5));
    cameraPos += vec3(0.5,0.5,0.5);

    vec3 cameraFwd  = normalize(cameraAt - cameraPos);
    vec3 cameraLeft  = normalize(cross(normalize(cameraAt - cameraPos), vec3(0.0,sign(cos(angleY)),0.0)));
    vec3 cameraUp   = normalize(cross(cameraLeft, cameraFwd));

    float cameraViewWidth	= 6.0;
    float cameraViewHeight	= cameraViewWidth * iResolution.y / iResolution.x;
    float cameraDistance	= 6.0;  // intuitively backwards!
	
		
	// Objects
	vec2 rawPercent = (fragCoord.xy / iResolution.xy);
	vec2 percent = rawPercent - vec2(0.5,0.5);
	
	vec3 rayTarget = (cameraFwd * vec3(cameraDistance,cameraDistance,cameraDistance))
				   - (cameraLeft * percent.x * cameraViewWidth)
		           + (cameraUp * percent.y * cameraViewHeight);
	vec3 rayDir = normalize(rayTarget);
	
	
    float hitTime = FLT_MAX;
	vec3 pixelColor = texture(iChannel0, rayDir).rgb;
    pixelColor = HandleRay(cameraPos, rayDir, pixelColor, hitTime);
    
    fragColor = vec4(clamp(pixelColor,0.0,1.0), 1.0);
}
/*
TODO:
* modify rays to make it look wiggly?
* have a define for sphere instead of cube?
* try adding bump mapping?
? Where does the black in the refraction come from?
*/
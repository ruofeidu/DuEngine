// MlBSDm
// @starea, Ruofei Du.

const float kPI = 3.141592654;

struct C_Ray {
    vec3 vOrigin;
    vec3 vDir;
};

void GetCameraRay( const in vec3 vPos, const in vec3 vForwards, const in vec3 vWorldUp, const in vec2 fragCoord, out C_Ray ray)
{
    vec2 vUV = ( fragCoord.xy / iResolution.xy );
    vec2 vViewCoord = vUV * 2.0 - 1.0;	

    ray.vOrigin = vPos;

    vec3 vRight = normalize(cross(vWorldUp, vForwards));
    vec3 vUp = cross(vRight, vForwards);
        
    ray.vDir = normalize( vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards);    
}

void GetCameraRayLookat( const in vec3 vPos, const in vec3 vInterest, const in vec2 fragCoord, out C_Ray ray)
{
	vec3 vForwards = normalize(vInterest - vPos);
	vec3 vUp = vec3(0.0, 1.0, 0.0);

	GetCameraRay(vPos, vForwards, vUp, fragCoord, ray);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    C_Ray ray;
    // adjust this for distance and edge distrotion.
    
	float zPosition = 3.0; 
    vec3 vCameraPos = vec3(0.0, 0.0, zPosition);
	vCameraPos.x += sin(iTime * 5.0) * 0.5;
	
	vec3 vCameraIntrest = vec3(0.0, 0.0, 20.0);
	GetCameraRayLookat( vCameraPos, vCameraIntrest, fragCoord, ray);

    float fHitDist = 100.0; // Raymarch(ray);
	vec3 vHitPos = ray.vOrigin + ray.vDir * fHitDist;
	vec3 vProjPos = vHitPos;
		
	float fProjectionDist = 0.5;
	vec2 vUV = vec2(((vProjPos.xy) * fProjectionDist) / vProjPos.z);
	
	vec2 vProjectionOffset = vec2(0.5, 0.5);
	vUV += vProjectionOffset;
		
    // flip the texture coordinates
	vUV.y = 1.0 - vUV.y;
    //float scale = 0.9; 
    //vUV = (((vUV * 2.0) - 1.0) * scale + scale) * 0.5; 
    
	vec3 vResult = texture(iChannel0, vUV).rgb;
	
	fragColor = vec4(vResult, 1.0);
}

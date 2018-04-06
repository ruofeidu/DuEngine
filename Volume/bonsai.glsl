// 
#define FLT_MAX 3.402823466e+38
const float PI = 3.1415926535897932;
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

// The maximum distance through our rendering volume is sqrt(3).
// The maximum number of steps we take to travel a distance of 1 is 512.
// ceil( sqrt(3) * 512 ) = 887
// This prevents the back of the image from getting cut off when steps=512 & viewing diagonally.
const int MAX_STEPS = 887;

//Acts like a texture3D using Z slices and trilinear filtering.
vec4 sampleAs3DTexture( vec3 texCoord )
{
	vec4 colorSlice1, colorSlice2;
	vec2 texCoordSlice1, texCoordSlice2;

	//The z coordinate determines which Z slice we have to look for.
	//Z slice number goes from 0 to 255.
	float zSliceNumber1 = floor(texCoord.z  * 255.0);

	//As we use trilinear we go the next Z slice.
	float zSliceNumber2 = min( zSliceNumber1 + 1.0, 255.0); //Clamp to 255

	//The Z slices are stored in a matrix of 16x16 of Z slices.
	//The original UV coordinates have to be rescaled by the tile numbers in each row and column.
	texCoord.xy /= 16.0;

	texCoordSlice1 = texCoordSlice2 = texCoord.xy;

	//Add an offset to the original UV coordinates depending on the row and column number.
	texCoordSlice1.x += (mod(zSliceNumber1, 16.0 ) / 16.0);
	texCoordSlice1.y += floor((255.0 - zSliceNumber1) / 16.0) / 16.0;

	texCoordSlice2.x += (mod(zSliceNumber2, 16.0 ) / 16.0);
	texCoordSlice2.y += floor((255.0 - zSliceNumber2) / 16.0) / 16.0;

	//Get the opacity value from the 2D texture.
	//Bilinear filtering is done at each texture2D by default.
	colorSlice1 = texture2D( iChannel1, texCoordSlice1 );
	colorSlice2 = texture2D( iChannel1, texCoordSlice2 );

	//Based on the opacity obtained earlier, get the RGB color in the transfer function texture.
	colorSlice1.rgb = texture2D( iChannel2, vec2( colorSlice1.a, 1.0) ).rgb;
	colorSlice2.rgb = texture2D( iChannel2, vec2( colorSlice2.a, 1.0) ).rgb;

	//How distant is zSlice1 to ZSlice2. Used to interpolate between one Z slice and the other.
	float zDifference = mod(texCoord.z * 255.0, 1.0);

	//Finally interpolate between the two intermediate colors of each Z slice.
	return mix(colorSlice1, colorSlice2, zDifference) ;
}

//=======================================================================================
vec3 HandleRay (in vec3 rayPos, in vec3 rayDir, in vec3 pixelColor, out float hitTime, out vec3 frontPos, out vec3 backPos)
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
    
	frontPos = frontCollisionPos;
	backPos = backCollisionPos;
	return frontCollisionPos;
	
    // // refraction
    // vec3 refractRayDir = refract(frontRefractedRayDir, backNormal, 1.0 / c_refraction);
    // pixelColor = texture(iChannel0, refractRayDir).rgb;
    // 
    // // reflection
    // vec3 reflectColor = texture(iChannel0, reflect(rayDir, frontNormal)).rgb * c_reflect;
    // 
    // // calculate and apply absorption
    // vec3 absorb = exp(-c_absorb * (refractTimeMinMax.y - refractTimeMinMax.x));    
    // pixelColor *= absorb;
    // 
    // // diffuse
    // float diffuseColorDP = clamp(dot(-c_lightDirection, frontNormal), 0.0, 1.0);
    // vec3 diffuseColor = c_lightColorDiffuse * diffuseColorDP;
    // 
    // // specular
    // vec3 specularColorDir = reflect(-c_lightDirection, frontNormal);
    // float specularColorDP = clamp(dot(specularColorDir, rayDir), 0.0, 1.0);
    // vec3 specularColor = c_lightColorSpecular * specularColorDP;
    // 
    // 
	// pixelColor = vec3(rayPos);
	// return pixelColor; 
    // // return the color we calculated
	// return pixelColor + diffuseColor + specularColor + reflectColor;
}

//=======================================================================================
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{       
    //----- camera
    vec2 mouse = iMouse.xy / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy;

	mouse.y -= 0.5;
    vec3 cameraAt 	= vec3(0.5,0.5,0.5);

    float angleX = PI * 2.0 * mouse.x;
    float angleY = PI * 2.0 * mouse.y;
    vec3 cameraPos	= (vec3(sin(angleX)*cos(angleY), sin(angleY), cos(angleX)*cos(angleY))) * (2.0 + 2.0 * (0.0+0.5));
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
	vec3 frontPos = vec3(0.0); 
	vec3 backPos = vec3(0.0); 
	
    pixelColor = HandleRay(cameraPos, rayDir, pixelColor, hitTime, frontPos, backPos);
    
	
	//The direction from the front position to back position.
	vec3 dir = backPos - frontPos;
	float rayLength = length(dir);
	float steps = 256.0; 
	//Calculate how long to increment in each step.
	float delta = 1.0 / steps;
	
	//The increment in each direction for each step.
	vec3 deltaDirection = normalize(dir) * delta;
	float deltaDirectionLength = length(deltaDirection);

	//Start the ray casting from the front position.
	vec3 currentPosition = frontPos;

	//The color accumulator.
	vec4 accumulatedColor = vec4(0.0);

	//The alpha value accumulated so far.
	float accumulatedAlpha = 0.0;

	//How long has the ray travelled so far.
	float accumulatedLength = 0.0;

	//If we have twice as many samples, we only need ~1/2 the alpha per sample.
	//Scaling by 256/10 just happens to give a good value for the alphaCorrection slider.
	float alphaScaleFactor = 25.6 * delta;

	vec4 colorSample;
	float alphaSample;
	float alphaCorrection = 1.5;
	//Perform the ray marching iterations
	for (int i = 0; i < MAX_STEPS; i++)
	{
		//Get the voxel intensity value from the 3D texture.
		colorSample = sampleAs3DTexture( currentPosition );

		//Allow the alpha correction customization.
		alphaSample = colorSample.a * alphaCorrection;

		//Applying this effect to both the color and alpha accumulation results in more realistic transparency.
		alphaSample *= (1.0 - accumulatedAlpha);

		//Scaling alpha by the number of steps makes the final color invariant to the step size.
		alphaSample *= alphaScaleFactor;

		//Perform the composition.
		accumulatedColor += colorSample * alphaSample;

		//Store the alpha accumulated so far.
		accumulatedAlpha += alphaSample;

		//Advance the ray.
		currentPosition += deltaDirection;
		accumulatedLength += deltaDirectionLength;

		//If the length traversed is more than the ray length, or if the alpha accumulated reaches 1.0 then exit.
		if(accumulatedLength >= rayLength || accumulatedAlpha >= 1.0 )
			break;
	}
	
	fragColor = accumulatedColor;
	
    // fragColor = vec4(clamp(pixelColor,0.0,1.0), 1.0);
    // fragColor = texture(iChannel1, uv);
}

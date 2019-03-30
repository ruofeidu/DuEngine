float scale = 0.5;
const float PI = 3.14159265359;

// https://en.wikipedia.org/wiki/Stereographic_projection
vec3 stereographicPlaneToSphere(vec2 planePos) {
    float x = planePos.x;
    float y = planePos.y;
    float x2 = x*x;
    float y2 = y*y;
    return vec3(
        2.*x / (1. + x2 + y2),
        2.*y / (1. + x2 + y2),
        (-1. + x2 + y2) / (1. + x2 + y2)
    );
}
vec2 stereographicSphereToPlane(vec3 spherePos) {
    return vec2(
        spherePos.x / (1. - spherePos.z),
        spherePos.y / (1. - spherePos.z)
    );
}

vec3 rotateAngleAxis(vec3 v, float angle, vec3 axis) {
    axis = normalize(axis);
    return (
        v * cos(angle) +
        cross(axis, v) * sin(angle) +
        axis * (dot(axis, v) * (1.-cos(angle)))
    );
}



void mainImage_( out vec4 fragColor, in vec2 fragCoord )
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/iResolution.xy;
	vec2 pos = uv;
    
    pos -= 0.5;  // translate 0,0 in center
    pos /= scale;

    vec3 spherePos = stereographicPlaneToSphere(pos);
    spherePos = rotateAngleAxis(spherePos, PI, vec3(0,1,0));
    
    pos = stereographicSphereToPlane(spherePos);
    pos.x -= iTime;
    pos = fract(pos);

    // Output to screen
    fragColor = texture(iChannel0, pos);
}
    



/// antialiasing code below





// aspect ratio correction
#define resolution (vec2 (iResolution.x / 2.0, iResolution.x))
#define g_arcorrection (resolution.x / resolution.y)


vec3 GetPixelColor(vec2 pos)
{
	vec4 o;
    mainImage_(o, pos);
    return o.xyz;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	   
    vec3 pixelColor;

    bool xOdd = (floor(mod(fragCoord.x,2.0)) == 1.0);
    bool yOdd = (floor(mod(fragCoord.y,2.0)) == 1.0);

    vec2 a = vec2(xOdd ? 0.25 : -0.25, yOdd ? -0.5  :  0.5 );
    vec2 b = vec2(xOdd ? 0.5  : -0.5 , yOdd ?  0.25 : -0.25 );
    vec2 c = a * vec2(-1);
    vec2 d = b * vec2(-1);

    pixelColor  = GetPixelColor((fragCoord.xy + a)) / 4.0;
    pixelColor += GetPixelColor((fragCoord.xy + b)) / 4.0;
    pixelColor += GetPixelColor((fragCoord.xy + c)) / 4.0;
    pixelColor += GetPixelColor((fragCoord.xy + d)) / 4.0;

    // write pixel
	fragColor = vec4(pixelColor, 1.0);
}
